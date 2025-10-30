terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.60" }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1) Primary symmetric key with automatic yearly rotation
resource "aws_kms_key" "day7" {
  description             = "Day7 data key (auto-rotation enabled)"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid: "EnableRoot",
      Effect: "Allow",
      Principal: { AWS: "arn:aws:iam::${data.aws_caller_identity.me.account_id}:root" },
      Action: "kms:*",
      Resource: "*"
    }]
  })
}

data "aws_caller_identity" "me" {}

# 2) Stable alias apps use (manual rotation = just point alias to new key)
resource "aws_kms_alias" "day7_alias" {
  name          = "alias/mc-day7-data"
  target_key_id = aws_kms_key.day7.key_id
}

output "aws_key_arn"   { value = aws_kms_key.day7.arn }
output "aws_alias"     { value = aws_kms_alias.day7_alias.name }
