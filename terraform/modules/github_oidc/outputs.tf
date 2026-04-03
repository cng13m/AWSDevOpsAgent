output "provider_arn" { value = aws_iam_openid_connect_provider.github.arn }
output "terraform_role_arn" { value = aws_iam_role.terraform.arn }
output "deploy_role_arn" { value = aws_iam_role.deploy.arn }
output "readonly_role_arn" { value = aws_iam_role.readonly.arn }
