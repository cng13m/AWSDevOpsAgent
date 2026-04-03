output "state_bucket_name" {
  description = "Terraform remote state bucket."
  value       = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  description = "Terraform state lock table."
  value       = aws_dynamodb_table.locks.name
}

