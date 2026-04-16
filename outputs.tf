output "ec2_scheduler_lambda_arn" {
  description = "ARN of the EC2 Scheduler Lambda (Manvith Katkuri)"
  value       = aws_lambda_function.manvith_ec2_scheduler.arn
}

output "snapshot_cleanup_lambda_arn" {
  description = "ARN of the Snapshot Cleanup Lambda (Manvith Katkuri)"
  value       = aws_lambda_function.manvith_snapshot_cleanup.arn
}

output "security_checker_lambda_arn" {
  description = "ARN of the Security Checker Lambda (Manvith Katkuri)"
  value       = aws_lambda_function.manvith_security_checker.arn
}

output "reports_sns_topic_arn" {
  description = "ARN of the reports SNS topic (Manvith Katkuri)"
  value       = aws_sns_topic.manvith_reports.arn
}

output "security_alerts_sns_topic_arn" {
  description = "ARN of the security alerts SNS topic (Manvith Katkuri)"
  value       = aws_sns_topic.manvith_security_alerts.arn
}

output "ec2_scheduler_eventbridge_rule" {
  description = "EventBridge rule name for EC2 scheduler (every 5 minutes)"
  value       = aws_cloudwatch_event_rule.manvith_ec2_scheduler_rule.name
}

output "snapshot_cleanup_eventbridge_rule" {
  description = "EventBridge rule name for snapshot cleanup (every Sunday 2am UTC)"
  value       = aws_cloudwatch_event_rule.manvith_snapshot_cleanup_rule.name
}

output "security_checker_eventbridge_rule" {
  description = "EventBridge rule name for security checker (hourly)"
  value       = aws_cloudwatch_event_rule.manvith_security_checker_rule.name
}

output "manual_test_commands" {
  description = "AWS CLI commands to manually trigger each Lambda for testing"
  value = {
    test_ec2_scheduler    = "aws lambda invoke --function-name manvith-ec2-scheduler --region us-east-1 /tmp/ec2_output.json && cat /tmp/ec2_output.json"
    test_snapshot_cleanup = "aws lambda invoke --function-name manvith-snapshot-cleanup --region us-east-1 /tmp/snap_output.json && cat /tmp/snap_output.json"
    test_security_checker = "aws lambda invoke --function-name manvith-security-checker --region us-east-1 /tmp/sec_output.json && cat /tmp/sec_output.json"
  }
}