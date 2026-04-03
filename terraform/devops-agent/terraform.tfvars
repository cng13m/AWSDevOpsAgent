aws_region              = "us-east-1"
project_name            = "aws-web-platform"
environment             = "dev"
agent_space_name        = "aws-web-platform-dev-space"
agent_space_description = "AWS DevOps Agent for the dev web app environment"
enable_operator_app     = true

resource_tags_for_topology = {
  app = "aws-web-platform"
  env = "dev"
}

