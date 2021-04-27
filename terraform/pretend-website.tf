resource "aws_s3_bucket" "pretend_website" {
  bucket        = var.fastly_domain_name
  acl           = "public-read"
  force_destroy = "true"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

data "aws_iam_policy_document" "public_bucket_policy" {
  statement {
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    # condition {
    #   test     = "IpAddress"
    #   variable = "aws:SourceIp"
    #   values   = var.ip_whitelist
    # }
    resources = ["${aws_s3_bucket.pretend_website.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.pretend_website.id
  policy = data.aws_iam_policy_document.public_bucket_policy.json
}

resource "aws_s3_bucket_object" "pretend_website_entrypoint" {
  bucket       = aws_s3_bucket.pretend_website.bucket
  key          = "index.html"
  source       = "${path.module}/pretend-website-index.html"
  etag         = filemd5("${path.module}/pretend-website-index.html")
  content_type = "text/html"
}