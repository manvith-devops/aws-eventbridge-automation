# Reports topic – receives EC2 start/stop reports and snapshot cleanup summaries
resource "aws_sns_topic" "manvith_reports" {
  name = "manvith-assignment14-reports"
  tags = local.common_tags
}

# Security alerts topic – receives hourly security group alerts
resource "aws_sns_topic" "manvith_security_alerts" {
  name = "manvith-assignment14-security-alerts"
  tags = local.common_tags
}

# Email subscription for reports (confirm via email after apply)
resource "aws_sns_topic_subscription" "manvith_reports_email" {
  topic_arn = aws_sns_topic.manvith_reports.arn
  protocol  = "email"
  endpoint  = local.email
}

# Email subscription for security alerts
resource "aws_sns_topic_subscription" "manvith_security_email" {
  topic_arn = aws_sns_topic.manvith_security_alerts.arn
  protocol  = "email"
  endpoint  = local.email
}