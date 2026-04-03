variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "flow_log_retention_days" { type = number }
variable "common_tags" { type = map(string) }

