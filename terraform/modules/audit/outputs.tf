output "alb_logs_bucket_name" { value = aws_s3_bucket.alb_logs.bucket }
output "flow_logs_log_group_name" { value = aws_cloudwatch_log_group.flow_logs.name }
output "trail_bucket_name" { value = aws_s3_bucket.trail.bucket }

