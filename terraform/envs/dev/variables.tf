variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "owner" { type = string }
variable "cost_center" { type = string }
variable "github_org" { type = string }
variable "github_repo" { type = string }
variable "github_default_branch" { type = string }
variable "image_tag" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_data_subnet_cidrs" { type = list(string) }
variable "app_service" {
  type = object({
    container_port = number
    cpu            = number
    memory         = number
    desired_count  = number
    min_capacity   = number
    max_capacity   = number
    health_check = object({
      path                = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      interval            = number
      matcher             = string
      grace_period        = number
    })
    autoscaling_targets = object({
      cpu    = number
      memory = number
    })
  })
}
variable "database" {
  type = object({
    name                         = string
    username                     = string
    instance_class               = string
    allocated_storage            = number
    max_allocated_storage        = number
    backup_retention_days        = number
    deletion_protection          = bool
    multi_az                     = bool
    performance_insights_enabled = bool
    monitoring_interval          = number
    engine_version               = string
    backup_window                = string
    maintenance_window           = string
    cloudwatch_logs_exports      = list(string)
    apply_immediately            = bool
  })
}
variable "observability" {
  type = object({
    alarm_email             = string
    log_retention_days      = number
    flow_log_retention_days = number
    alarm_thresholds = object({
      alb_target_5xx_count   = number
      ecs_cpu_high           = number
      ecs_memory_high        = number
      ecs_running_task_count = number
      rds_cpu_high           = number
      rds_connections_high   = number
      rds_free_storage_bytes = number
    })
  })
}
variable "app_config" { type = map(string) }
