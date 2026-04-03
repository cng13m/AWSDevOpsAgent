resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.environment}-db-subnets" })
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}/${var.environment}/database/master"

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.environment}-db-secret" })
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "postgres"
    dbname   = var.db_name
  })
}

resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "this" {
  identifier                      = "${var.project_name}-${var.environment}"
  engine                          = "postgres"
  engine_version                  = "16.3"
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  db_name                         = replace(var.db_name, "-", "_")
  username                        = var.db_username
  password                        = random_password.db.result
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [var.db_security_group_id]
  skip_final_snapshot             = !var.deletion_protection
  deletion_protection             = var.deletion_protection
  backup_retention_period         = var.backup_retention_period
  multi_az                        = var.multi_az
  performance_insights_enabled    = var.performance_insights_enabled
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
  storage_encrypted               = true
  publicly_accessible             = false
  auto_minor_version_upgrade      = true
  backup_window                   = "03:00-04:00"
  maintenance_window              = "sun:04:00-sun:05:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  apply_immediately               = false

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.environment}-postgres" })

  depends_on = [aws_secretsmanager_secret_version.db]
}

