resource "aws_cloudwatch_event_rule" "manvith_ec2_scheduler_rule" {
  name                = "manvith-ec2-scheduler-rule"
  description         = "Runs EC2 scheduler every 5 minutes - Moath Malkawi"
  schedule_expression = "rate(5 minutes)"
  state               = "ENABLED"
  tags                = local.common_tags
}

resource "aws_cloudwatch_event_target" "manvith_ec2_scheduler_target" {
  rule      = aws_cloudwatch_event_rule.manvith_ec2_scheduler_rule.name
  target_id = "manvith-ec2-scheduler-lambda"
  arn       = aws_lambda_function.manvith_ec2_scheduler.arn
}

resource "aws_lambda_permission" "manvith_ec2_scheduler_allow" {
  statement_id  = "AllowEventBridgeEC2Scheduler"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manvith_ec2_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.manvith_ec2_scheduler_rule.arn
}

# ── Rule 2: Snapshot Cleanup – every Sunday at 2:00am UTC ────────────────────

resource "aws_cloudwatch_event_rule" "manvith_snapshot_cleanup_rule" {
  name                = "manvith-snapshot-cleanup-rule"
  description         = "Runs weekly snapshot cleanup every Sunday at 2am UTC - Moath Malkawi"
  schedule_expression = "cron(0 2 ? * SUN *)"
  state               = "ENABLED"
  tags                = local.common_tags
}

resource "aws_cloudwatch_event_target" "manvith_snapshot_cleanup_target" {
  rule      = aws_cloudwatch_event_rule.manvith_snapshot_cleanup_rule.name
  target_id = "manvith-snapshot-cleanup-lambda"
  arn       = aws_lambda_function.manvith_snapshot_cleanup.arn
}

resource "aws_lambda_permission" "manvith_snapshot_cleanup_allow" {
  statement_id  = "AllowEventBridgeSnapshotCleanup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manvith_snapshot_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.manvith_snapshot_cleanup_rule.arn
}

# ── Rule 3: Security Checker – every hour ────────────────────────────────────

resource "aws_cloudwatch_event_rule" "manvith_security_checker_rule" {
  name                = "manvith-security-checker-rule"
  description         = "Runs security group check every hour - Moath Malkawi"
  schedule_expression = "rate(1 hour)"
  state               = "ENABLED"
  tags                = local.common_tags
}

resource "aws_cloudwatch_event_target" "manvith_security_checker_target" {
  rule      = aws_cloudwatch_event_rule.manvith_security_checker_rule.name
  target_id = "manvith-security-checker-lambda"
  arn       = aws_lambda_function.manvith_security_checker.arn
}

resource "aws_lambda_permission" "manvith_security_checker_allow" {
  statement_id  = "AllowEventBridgeSecurityChecker"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manvith_security_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.manvith_security_checker_rule.arn
}