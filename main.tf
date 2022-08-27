terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}
# Data Sources used in the module
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      "*"
    ]
  }
  statement {
    sid = "Allow Logs to use the key"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.region.amazonaws.com"]
    }
    resources = [
      "*"
    ]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }
}
resource "aws_kms_key" "cloudwatch" {
  description = "cloudwatch log group key for ${data.aws_region.current.name}"
  policy      = data.aws_iam_policy_document.cloudwatch.json

  tags = merge(
    var.tags,
    {
      Region      = data.aws_region.current.name
      Description = "kms cmk for cloudwatch log groups"
    }
  )
}
