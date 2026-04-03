variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "alarm_email" { type = string }
variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "cluster_name" { type = string }
variable "service_name" { type = string }
variable "db_identifier" { type = string }
variable "common_tags" { type = map(string) }

