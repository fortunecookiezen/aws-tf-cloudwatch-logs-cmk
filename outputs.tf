output "key_arn" {
  description = "arn of the kms cmk"
  value       = aws_kms_key.cloudwatch.arn
}