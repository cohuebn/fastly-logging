output "namespace" {
  description = "The namespace to associate with all resources"
  value       = var.namespace
}

output "fastly_logging_stream_arn" {
  description = "The ARN of the Fastly logging Kinesis stream"
  value       = aws_kinesis_stream.fastly_logs.arn
}

output "cloud_formation_stack_name" {
  description = "The name of the Cloud Formation stack bootstrapped for SAM deploy"
  value       = aws_cloudformation_stack.log_streaming.name
}

output "artifacts_bucket" {
  description = "The name of the bucket to store code artifacts in"
  value       = aws_s3_bucket.artifacts.bucket
}