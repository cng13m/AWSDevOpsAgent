variable "aws_region" {
  description = "AWS region for the remote state backend."
  type        = string
}

variable "project_name" {
  description = "Project name used in backend resource names."
  type        = string
}

variable "owner" {
  description = "Owner tag."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
}

