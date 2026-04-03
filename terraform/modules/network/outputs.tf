output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = values(aws_subnet.public)[*].id }
output "private_app_subnet_ids" { value = values(aws_subnet.private_app)[*].id }
output "private_data_subnet_ids" { value = values(aws_subnet.private_data)[*].id }
output "alb_security_group_id" { value = aws_security_group.alb.id }
output "ecs_security_group_id" { value = aws_security_group.ecs.id }
output "db_security_group_id" { value = aws_security_group.db.id }

