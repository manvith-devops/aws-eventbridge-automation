data "archive_file" "ec2_scheduler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/ec2_scheduler.py"
  output_path = "${path.module}/ec2_scheduler.zip"
}

data "archive_file" "snapshot_cleanup_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/snapshot_cleanup.py"
  output_path = "${path.module}/snapshot_cleanup.zip"
}

data "archive_file" "security_checker_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/security_checker.py"
  output_path = "${path.module}/security_checker.zip"
}

# ── Lambda 1: EC2 Scheduler (every 5 minutes) ────────────────────────────────

resource "aws_lambda_function" "manvith_ec2_scheduler" {
  function_name    = "manvith-ec2-scheduler"
  description      = "Stop/start Dev EC2 instances based on time of day - Moath Malkawi"
  filename         = data.archive_file.ec2_scheduler_zip.output_path
  source_code_hash = data.archive_file.ec2_scheduler_zip.output_base64sha256
  role             = aws_iam_role.manvith_lambda_role.arn
  handler          = "ec2_scheduler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.manvith_reports.arn
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "manvith_ec2_scheduler_logs" {
  name              = "/aws/lambda/${aws_lambda_function.manvith_ec2_scheduler.function_name}"
  retention_in_days = 7
  tags              = local.common_tags
}

# ── Lambda 2: Snapshot Cleanup (every Sunday 2am) ───────────────────────────

resource "aws_lambda_function" "manvith_snapshot_cleanup" {
  function_name    = "manvith-snapshot-cleanup"
  description      = "Delete untagged EBS snapshots older than 30 days - "
  filename         = data.archive_file.snapshot_cleanup_zip.output_path
  source_code_hash = data.archive_file.snapshot_cleanup_zip.output_base64sha256
  role             = aws_iam_role.manvith_lambda_role.arn
  handler          = "snapshot_cleanup.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.manvith_reports.arn
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "manvith_snapshot_cleanup_logs" {
  name              = "/aws/lambda/${aws_lambda_function.manvith_snapshot_cleanup.function_name}"
  retention_in_days = 7
  tags              = local.common_tags
}

# ── Lambda 3: Security Checker (hourly) ─────────────────────────────────────

resource "aws_lambda_function" "manvith_security_checker" {
  function_name    = "manvith-security-checker"
  description      = "Alert on security groups with 0.0.0.0/0 on port 22 - Moath Malkawi"
  filename         = data.archive_file.security_checker_zip.output_path
  source_code_hash = data.archive_file.security_checker_zip.output_base64sha256
  role             = aws_iam_role.manvith_lambda_role.arn
  handler          = "security_checker.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.manvith_security_alerts.arn
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "manvith_security_checker_logs" {
  name              = "/aws/lambda/${aws_lambda_function.manvith_security_checker.function_name}"
  retention_in_days = 7
  tags              = local.common_tags
}