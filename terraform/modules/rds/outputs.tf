output "endpoint" { value = aws_db_instance.this.address }
output "port" { value = aws_db_instance.this.port }
output "db_identifier" { value = aws_db_instance.this.identifier }
output "secret_arn" { value = aws_secretsmanager_secret.db.arn }

