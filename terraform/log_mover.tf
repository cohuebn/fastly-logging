data "aws_iam_policy_document" "function_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "log_mover" {
  assume_role_policy    = data.aws_iam_policy_document.function_assume_role_policy.json
  force_detach_policies = true
  name                  = "${var.namespace}-log-mover"
  tags                  = merge(local.tags, { Name = "${var.namespace}-log-mover" })
}

data "aws_iam_policy_document" "log_mover_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "log_mover_cloudwatch" {
  name   = "${aws_iam_role.log_mover.name}-cloudwatch"
  role   = aws_iam_role.log_mover.id
  policy = data.aws_iam_policy_document.log_mover_cloudwatch.json
}

data "aws_iam_policy_document" "log_mover_read_s3_logs" {
  statement {
    effect = "Allow"
    actions = [
      "s3:List*", "s3:Get*"
    ]
    resources = [aws_s3_bucket.fastly_logs.arn, "${aws_s3_bucket.fastly_logs.arn}/*"]
  }
}

resource "aws_iam_role_policy" "log_mover_s3" {
  name   = "${aws_iam_role.log_mover.name}-s3"
  role   = aws_iam_role.log_mover.id
  policy = data.aws_iam_policy_document.log_mover_read_s3_logs.json
}

resource "aws_cloudformation_stack" "log_streaming" {
  name               = var.namespace
  on_failure         = "DELETE"
  tags               = merge(local.tags, { Name = var.namespace })
  template_body      = file("${path.module}/cloud_formation_stub.yml")
  capabilities       = ["CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
  timeout_in_minutes = var.sam_timeout_in_minutes
  lifecycle {
    # Ignore template_body changes as this stack will be updated externally
    # by SAM deployments
    ignore_changes = [tags, template_body, capabilities]
  }

  parameters = {
    Namespace          = var.namespace
    CloudWatchLogGroup = aws_cloudwatch_log_group.fastly_logs.name
    CloudWatchLogGroup = aws_cloudwatch_log_group.fastly_logs.name
    FunctionRoleArn    = aws_iam_role.log_mover.arn
  }
}
