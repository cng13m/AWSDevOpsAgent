variable "aws_region" {
  description = "AWS region for AWS DevOps Agent. This service currently requires us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in stack naming."
  type        = string
  default     = "aws-web-platform"
}

variable "environment" {
  description = "Environment label associated with the agent space."
  type        = string
  default     = "dev"
}

variable "agent_space_name" {
  description = "Friendly name for the AWS DevOps Agent Space."
  type        = string
  default     = "aws-web-platform-dev-space"
}

variable "agent_space_description" {
  description = "Description for the AWS DevOps Agent Space."
  type        = string
  default     = "AWS DevOps Agent for the dev web app environment"
}

variable "enable_operator_app" {
  description = "Whether to enable the AWS DevOps Agent web app using IAM auth."
  type        = bool
  default     = true
}

variable "resource_tags_for_topology" {
  description = "Tags used by AWS DevOps Agent to scope topology crawl for this environment."
  type        = map(string)
  default = {
    app = "aws-web-platform"
    env = "dev"
  }
}
