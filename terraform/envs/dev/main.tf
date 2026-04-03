data "aws_region" "current" {}

locals {
  common_tags = {
    app         = var.project_name
    env         = var.environment
    owner       = var.owner
    cost-center = var.cost_center
    managed-by  = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  project_name              = var.project_name
  environment               = var.environment
  azs                       = var.azs
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
  common_tags               = local.common_tags
}

module "audit" {
  source = "../../modules/audit"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.network.vpc_id
  flow_log_retention_days = var.observability.flow_log_retention_days
  common_tags             = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

module "app_config" {
  source = "../../modules/app_config"

  project_name = var.project_name
  environment  = var.environment
  parameters   = var.app_config
  common_tags  = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name                    = var.project_name
  environment                     = var.environment
  private_subnet_ids              = module.network.private_data_subnet_ids
  db_security_group_id            = module.network.db_security_group_id
  db_name                         = var.database.name
  db_username                     = var.database.username
  instance_class                  = var.database.instance_class
  allocated_storage               = var.database.allocated_storage
  max_allocated_storage           = var.database.max_allocated_storage
  backup_retention_period         = var.database.backup_retention_days
  deletion_protection             = var.database.deletion_protection
  multi_az                        = var.database.multi_az
  performance_insights_enabled    = var.database.performance_insights_enabled
  monitoring_interval             = var.database.monitoring_interval
  engine_version                  = var.database.engine_version
  backup_window                   = var.database.backup_window
  maintenance_window              = var.database.maintenance_window
  enabled_cloudwatch_logs_exports = var.database.cloudwatch_logs_exports
  apply_immediately               = var.database.apply_immediately
  common_tags                     = local.common_tags
}

module "ecs_service" {
  source = "../../modules/ecs_service"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_app_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  ecs_security_group_id = module.network.ecs_security_group_id
  ecr_repository_url    = module.ecr.repository_url
  image_tag             = var.image_tag
  container_port        = var.app_service.container_port
  cpu                   = var.app_service.cpu
  memory                = var.app_service.memory
  desired_count         = var.app_service.desired_count
  min_capacity          = var.app_service.min_capacity
  max_capacity          = var.app_service.max_capacity
  health_check          = var.app_service.health_check
  autoscaling_targets   = var.app_service.autoscaling_targets
  log_retention_days    = var.observability.log_retention_days
  alb_logs_bucket_name  = module.audit.alb_logs_bucket_name
  environment_variables = {
    APP_ENV    = var.environment
    AWS_REGION = data.aws_region.current.name
    DB_HOST    = module.rds.endpoint
    DB_PORT    = tostring(module.rds.port)
  }
  secret_arns        = { DATABASE_SECRET = module.rds.secret_arn }
  ssm_parameter_arns = module.app_config.parameter_arns
  common_tags        = local.common_tags
}

module "observability" {
  source = "../../modules/observability"

  project_name            = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  alarm_email             = var.observability.alarm_email
  alb_arn_suffix          = module.ecs_service.alb_arn_suffix
  target_group_arn_suffix = module.ecs_service.target_group_arn_suffix
  cluster_name            = module.ecs_service.cluster_name
  service_name            = module.ecs_service.service_name
  db_identifier           = module.rds.db_identifier
  alarm_thresholds        = var.observability.alarm_thresholds
  common_tags             = local.common_tags
}

module "github_oidc" {
  source = "../../modules/github_oidc"

  project_name            = var.project_name
  environment             = var.environment
  github_org              = var.github_org
  github_repo             = var.github_repo
  github_default_branch   = var.github_default_branch
  task_execution_role_arn = module.ecs_service.task_execution_role_arn
  task_role_arn           = module.ecs_service.task_role_arn
  common_tags             = local.common_tags
}
