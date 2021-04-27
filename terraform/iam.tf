data "aws_iam_policy_document" "fastly_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [local.fastly_aws_account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.fastly_customer_account_id]
    }
  }
}

resource "aws_iam_role" "fastly" {
  assume_role_policy    = data.aws_iam_policy_document.fastly_assume_role.json
  force_detach_policies = true
  name                  = "${var.namespace}-fastly"
  tags                  = merge(local.tags, { Name = "${var.namespace}-fastly" })
}

data "aws_iam_policy_document" "fastly" {
  statement {
    actions   = ["kinesis:PutRecords", "kinesis:ListShards"]
    resources = [aws_kinesis_stream.fastly_logs.arn]
  }

  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.fastly_logs.arn}/*"]
  }
}

resource "aws_iam_role_policy" "fastly" {
  name   = aws_iam_role.fastly.name
  policy = data.aws_iam_policy_document.fastly.json
  role   = aws_iam_role.fastly.id
}
