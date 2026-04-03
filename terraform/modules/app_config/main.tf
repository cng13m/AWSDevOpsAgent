resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name  = "/app/${var.project_name}/${var.environment}/${each.key}"
  type  = "String"
  value = each.value

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${replace(each.key, "/", "-")}"
  })
}
