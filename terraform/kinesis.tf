resource "aws_kinesis_stream" "fastly_logs" {
  name             = "${var.namespace}-fastly-logs"
  shard_count      = var.stream_shards
  retention_period = var.stream_retention_in_hours

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
    "IteratorAgeMilliseconds",
    "WriteProvisionedThroughputExceeded"
  ]

  tags = merge(local.tags, { Name = "${var.namespace}-fastly-logs" })
}