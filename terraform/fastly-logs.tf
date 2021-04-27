resource "aws_s3_bucket" "fastly_logs" {
  bucket        = "${var.namespace}-logs"
  force_destroy = "true"
}
