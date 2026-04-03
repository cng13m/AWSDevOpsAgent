aws_region                = "us-east-1"
project_name              = "aws-web-platform"
environment               = "dev"
owner                     = "platform-team"
cost_center               = "engineering"
github_org                = "cng13m"
github_repo               = "AWSDevOpsAgent"
github_default_branch     = "main"
image_tag                 = "latest"
vpc_cidr                  = "10.10.0.0/16"
azs                       = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs       = ["10.10.0.0/24", "10.10.1.0/24"]
private_app_subnet_cidrs  = ["10.10.10.0/24", "10.10.11.0/24"]
private_data_subnet_cidrs = ["10.10.20.0/24", "10.10.21.0/24"]
app_service = {
  container_port = 8080
  cpu            = 256
  memory         = 512
  desired_count  = 1
  min_capacity   = 1
  max_capacity   = 2
  health_check = {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
    grace_period        = 60
  }
  autoscaling_targets = {
    cpu    = 60
    memory = 70
  }
}
database = {
  name                         = "appdb"
  username                     = "appuser"
  instance_class               = "db.t4g.micro"
  allocated_storage            = 20
  max_allocated_storage        = 100
  backup_retention_days        = 1
  deletion_protection          = false
  multi_az                     = false
  performance_insights_enabled = false
  monitoring_interval          = 0
  engine_version               = "16.3"
  backup_window                = "03:00-04:00"
  maintenance_window           = "sun:04:00-sun:05:00"
  cloudwatch_logs_exports      = ["postgresql", "upgrade"]
  apply_immediately            = false
}
observability = {
  alarm_email             = "shefkiu.genc@gmail.com"
  log_retention_days      = 14
  flow_log_retention_days = 14
  alarm_thresholds = {
    alb_target_5xx_count   = 5
    ecs_cpu_high           = 80
    ecs_memory_high        = 85
    ecs_running_task_count = 1
    rds_cpu_high           = 80
    rds_connections_high   = 100
    rds_free_storage_bytes = 5368709120
  }
}
app_config = {
  "app/LOG_LEVEL"           = "info"
  "app/FEATURE_FLAG_SAMPLE" = "true"
}
