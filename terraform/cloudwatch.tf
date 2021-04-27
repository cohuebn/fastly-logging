resource "aws_cloudwatch_log_group" "fastly_logs" {
  name              = "${var.namespace}-fastly-logs"
  retention_in_days = 5
  tags              = merge(local.tags, { Name = "${var.namespace}-fastly-logs" })
}