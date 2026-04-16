import boto3
import os
from datetime import datetime, timezone, timedelta


def lambda_handler(event, context):
    ec2 = boto3.client("ec2")
    sns = boto3.client("sns")

    now = datetime.now(timezone.utc)
    cutoff_date = now - timedelta(days=30)
    now_str = now.strftime("%Y-%m-%d %H:%M UTC")

    # Fetch all snapshots owned by this account
    response = ec2.describe_snapshots(OwnerIds=["self"])
    all_snapshots = response["Snapshots"]

    total_found = len(all_snapshots)
    deleted_ids = []
    skipped_tagged = []
    skipped_recent = []
    errors = []

    for snapshot in all_snapshots:
        snap_id = snapshot["SnapshotId"]
        start_time = snapshot["StartTime"]
        tags = snapshot.get("Tags", [])

        if start_time >= cutoff_date:
            skipped_recent.append(snap_id)
            continue

        # Older than 30 days — delete only if untagged
        if not tags:
            try:
                ec2.delete_snapshot(SnapshotId=snap_id)
                deleted_ids.append(snap_id)
            except Exception as e:
                errors.append(f"{snap_id}: {str(e)}")
        else:
            skipped_tagged.append(snap_id)

    report = (
        f"Weekly Snapshot Cleanup Report - Manvith Katkuri\n"
        f"{'=' * 50}\n"
        f"Timestamp              : {now_str}\n"
        f"Total snapshots found  : {total_found}\n"
        f"Older than 30 days     : {len(deleted_ids) + len(skipped_tagged)}\n"
        f"Deleted (untagged)     : {len(deleted_ids)}\n"
        f"Skipped (tagged)       : {len(skipped_tagged)}\n"
        f"Skipped (recent)       : {len(skipped_recent)}\n"
        f"Errors                 : {len(errors)}\n"
    )

    if deleted_ids:
        report += f"\nDeleted Snapshot IDs:\n"
        for sid in deleted_ids:
            report += f"  - {sid}\n"

    if errors:
        report += f"\nErrors encountered:\n"
        for err in errors:
            report += f"  - {err}\n"

    sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject="Weekly Snapshot Cleanup Report - Manvith Katkuri",
        Message=report,
    )

    print(report)
    return {
        "statusCode": 200,
        "body": report,
        "deleted_count": len(deleted_ids),
        "skipped_tagged": len(skipped_tagged),
        "errors": len(errors),
    }