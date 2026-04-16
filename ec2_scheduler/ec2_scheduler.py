import boto3
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    ec2 = boto3.client("ec2")
    sns = boto3.client("sns")

    current_hour = datetime.now(timezone.utc).hour
    now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    # Find all Dev-tagged instances (running or stopped)
    response = ec2.describe_instances(
        Filters=[
            {"Name": "tag:Environment", "Values": ["Dev"]},
            {"Name": "instance-state-name", "Values": ["running", "stopped"]},
        ]
    )

    running_ids = []
    stopped_ids = []

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            iid = instance["InstanceId"]
            state = instance["State"]["Name"]
            if state == "running":
                running_ids.append(iid)
            elif state == "stopped":
                stopped_ids.append(iid)

    action_taken = "No action (outside scheduled window)"
    instances_stopped = 0
    instances_started = 0

    # Stop after 6pm UTC (hour >= 18)
    if current_hour >= 18:
        if running_ids:
            ec2.stop_instances(InstanceIds=running_ids)
            instances_stopped = len(running_ids)
            action_taken = f"STOPPED {instances_stopped} instance(s)"

    # Start at 9am UTC (hour == 9)
    elif current_hour == 9:
        if stopped_ids:
            ec2.start_instances(InstanceIds=stopped_ids)
            instances_started = len(stopped_ids)
            action_taken = f"STARTED {instances_started} instance(s)"

    report = (
        f"EC2 Scheduler Report - Manvith Katkuri\n"
        f"{'=' * 50}\n"
        f"Timestamp     : {now_str}\n"
        f"Current Hour  : {current_hour}:00 UTC\n"
        f"Action Taken  : {action_taken}\n"
        f"Dev Instances : {len(running_ids) + len(stopped_ids)} total "
        f"({len(running_ids)} running, {len(stopped_ids)} stopped)\n"
        f"Stopped Now   : {instances_stopped}\n"
        f"Started Now   : {instances_started}\n"
        f"Running IDs   : {', '.join(running_ids) if running_ids else 'None'}\n"
        f"Stopped IDs   : {', '.join(stopped_ids) if stopped_ids else 'None'}\n"
    )

    sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject="EC2 Scheduler Report - Manvith Katkuri",
        Message=report,
    )

    print(report)
    return {
        "statusCode": 200,
        "body": report,
        "instances_stopped": instances_stopped,
        "instances_started": instances_started,
    }