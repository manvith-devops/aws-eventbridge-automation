import boto3
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    ec2 = boto3.client("ec2")
    sns = boto3.client("sns")

    now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    # Paginate through all security groups
    risky_groups = []
    paginator = ec2.get_paginator("describe_security_groups")

    for page in paginator.paginate():
        for sg in page["SecurityGroups"]:
            for rule in sg.get("IpPermissions", []):
                from_port = rule.get("FromPort")
                to_port = rule.get("ToPort")
                ip_protocol = rule.get("IpProtocol", "")

                # -1 means all traffic; also handle TCP rules covering port 22
                port_22_exposed = ip_protocol == "-1" or (
                    from_port is not None
                    and to_port is not None
                    and from_port <= 22 <= to_port
                )

                if not port_22_exposed:
                    continue

                open_cidrs = [
                    r["CidrIp"]
                    for r in rule.get("IpRanges", [])
                    if r.get("CidrIp") == "0.0.0.0/0"
                ]
                open_ipv6 = [
                    r["CidrIpv6"]
                    for r in rule.get("Ipv6Ranges", [])
                    if r.get("CidrIpv6") == "::/0"
                ]

                if open_cidrs or open_ipv6:
                    risky_groups.append(
                        {
                            "GroupId": sg["GroupId"],
                            "GroupName": sg["GroupName"],
                            "VpcId": sg.get("VpcId", "EC2-Classic"),
                            "Description": sg.get("Description", ""),
                            "OpenCidrs": open_cidrs + open_ipv6,
                        }
                    )
                    break  # No need to check further rules for this SG

    if risky_groups:
        subject = f"SECURITY ALERT: {len(risky_groups)} SG(s) with Open SSH - Manvith Katkuri"
        message = (
            f"SECURITY ALERT - Manvith Katkuri\n"
            f"{'=' * 50}\n"
            f"Timestamp        : {now_str}\n"
            f"Risky SGs Found  : {len(risky_groups)}\n\n"
            f"Security groups with 0.0.0.0/0 (or ::/0) access on port 22:\n\n"
        )
        for sg in risky_groups:
            message += (
                f"  Group ID    : {sg['GroupId']}\n"
                f"  Group Name  : {sg['GroupName']}\n"
                f"  VPC         : {sg['VpcId']}\n"
                f"  Description : {sg['Description']}\n"
                f"  Open CIDRs  : {', '.join(sg['OpenCidrs'])}\n"
                f"  {'- ' * 25}\n"
            )
        message += (
            "\nACTION REQUIRED: Review and restrict these security groups "
            "to specific IP ranges to reduce attack surface.\n"
        )
    else:
        subject = "Security Check Passed - No Open SSH - Manvith Katkuri"
        message = (
            f"Security Check Report - Manvith Katkuri\n"
            f"{'=' * 50}\n"
            f"Timestamp : {now_str}\n"
            f"Result    : PASSED - No security groups found with 0.0.0.0/0 on port 22.\n"
        )

    sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject=subject,
        Message=message,
    )

    print(message)
    return {
        "statusCode": 200,
        "body": message,
        "risky_sg_count": len(risky_groups),
        "alert_sent": len(risky_groups) > 0,
    }