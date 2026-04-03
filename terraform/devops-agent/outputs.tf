output "agent_space_id" {
  description = "ID of the AWS DevOps Agent Space."
  value       = aws_cloudformation_stack.devops_agent.outputs["AgentSpaceId"]
}

output "agent_space_arn" {
  description = "ARN of the AWS DevOps Agent Space."
  value       = aws_cloudformation_stack.devops_agent.outputs["AgentSpaceArn"]
}

output "agent_space_role_arn" {
  description = "Role ARN assumed by AWS DevOps Agent to investigate this AWS account."
  value       = aws_cloudformation_stack.devops_agent.outputs["AgentSpaceRoleArn"]
}

output "monitor_association_id" {
  description = "Association ID connecting this AWS account to the agent space."
  value       = aws_cloudformation_stack.devops_agent.outputs["MonitorAssociationId"]
}

output "operator_app_role_arn" {
  description = "IAM role ARN used for AWS DevOps Agent web app access."
  value       = lookup(aws_cloudformation_stack.devops_agent.outputs, "OperatorAppRoleArn", null)
}

output "console_url" {
  description = "AWS console entry point for AWS DevOps Agent."
  value       = "https://console.aws.amazon.com/devopsagent/home?region=${var.aws_region}"
}

