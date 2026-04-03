output "alb_dns_name" { value = module.ecs_service.alb_dns_name }
output "ecs_cluster_name" { value = module.ecs_service.cluster_name }
output "ecs_service_name" { value = module.ecs_service.service_name }
output "ecr_repository_url" { value = module.ecr.repository_url }
output "cloudwatch_dashboard_name" { value = module.observability.dashboard_name }
output "ecs_log_group_name" { value = module.ecs_service.log_group_name }
output "rds_endpoint" { value = module.rds.endpoint }
output "database_secret_arn" { value = module.rds.secret_arn }
output "alarm_topic_arn" { value = module.observability.sns_topic_arn }
output "github_actions_terraform_role_arn" { value = module.github_oidc.terraform_role_arn }
output "github_actions_deploy_role_arn" { value = module.github_oidc.deploy_role_arn }
output "github_actions_readonly_role_arn" { value = module.github_oidc.readonly_role_arn }

