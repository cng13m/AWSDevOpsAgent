variable "project_name" { type = string }
variable "environment" { type = string }
variable "azs" { type = list(string) }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_data_subnet_cidrs" { type = list(string) }
variable "common_tags" { type = map(string) }

