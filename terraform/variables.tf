variable "namespace" {
  description = "The namespace to associate with all resources"
  type        = string
  default     = "fastly-poc"
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "stream_shards" {
  description = "How many Kinesis shards should be used for streaming logs"
  type        = number
  default     = 24
}

variable "stream_retention_in_hours" {
  description = "How long should Fastly logs be stored in Kinesis"
  type        = number
  default     = 24
}

variable "fastly_customer_account_id" {
  description = "Your Fastly customer account id. This is required to allow Fastly IAM authentication into your AWS account"
  type        = string
  default     = "2l6iO2y3qmdfYDOzhmZwni"
}

variable "fastly_domain_name" {
  description = "The Fastly domain (used to create an S3 bucket with same name)"
  type        = string
  default     = "wwt-fastly-log-testing.global.ssl.fastly.net"
}

variable "sam_timeout_in_minutes" {
  type        = number
  description = "The number of minutes allowed before canceling the SAM deployment (timeout)"
  default     = 8
}

variable "ip_whitelist" {
  default = [
    "198.200.139.0/24", # STL VPN
    "23.84.136.53/32",  # huebnerc
  ]
  type = list(string)
}