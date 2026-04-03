data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  stack_name = "${var.project_name}-${var.environment}-devops-agent"
  common_tags = {
    app        = var.project_name
    env        = var.environment
    managed-by = "terraform"
  }
  topology_tags = [
    for key, value in var.resource_tags_for_topology : {
      Key   = key
      Value = value
    }
  ]
  operator_resources = var.enable_operator_app ? {
    DevOpsAgentRoleWebappAdmin = {
      Type = "AWS::IAM::Role"
      Properties = {
        RoleName = "${var.project_name}-${var.environment}-devops-agent-webapp"
        AssumeRolePolicyDocument = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "aidevops.amazonaws.com"
              }
              Action = "sts:AssumeRole"
              Condition = {
                StringEquals = {
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
              }
            }
          ]
        }
        Policies = [
          {
            PolicyName = "DevOpsAgentOperatorAccess"
            PolicyDocument = {
              Version = "2012-10-17"
              Statement = [
                {
                  Effect = "Allow"
                  Action = [
                    "aidevops:*"
                  ]
                  Resource = "*"
                },
                {
                  Effect = "Allow"
                  Action = [
                    "support:AddAttachmentsToSet",
                    "support:AddCommunicationToCase",
                    "support:CreateCase",
                    "support:DescribeAttachment",
                    "support:DescribeCases",
                    "support:DescribeCommunications",
                    "support:DescribeServices",
                    "support:DescribeSeverityLevels"
                  ]
                  Resource = "*"
                }
              ]
            }
          }
        ]
        Tags = [
          for key, value in local.common_tags : {
            Key   = key
            Value = value
          }
        ]
      }
    }
  } : {}
  operator_app = var.enable_operator_app ? {
    Iam = {
      OperatorAppRoleArn = {
        "Fn::GetAtt" = ["DevOpsAgentRoleWebappAdmin", "Arn"]
      }
    }
  } : null
  template_resources = merge(
    {
      DevOpsAgentRoleAgentSpace = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = "${var.project_name}-${var.environment}-devops-agent-space"
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Effect = "Allow"
                Principal = {
                  Service = "aidevops.amazonaws.com"
                }
                Action = "sts:AssumeRole"
                Condition = {
                  StringEquals = {
                    "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                  }
                }
              }
            ]
          }
          ManagedPolicyArns = [
            "arn:${data.aws_partition.current.partition}:iam::aws:policy/AIOpsAssistantPolicy"
          ]
          Tags = [
            for key, value in local.common_tags : {
              Key   = key
              Value = value
            }
          ]
        }
      }
      AgentSpace = {
        Type = "AWS::DevOpsAgent::AgentSpace"
        Properties = merge(
          {
            Name        = var.agent_space_name
            Description = var.agent_space_description
          },
          var.enable_operator_app ? { OperatorApp = local.operator_app } : {}
        )
      }
      MonitorAssociation = {
        Type = "AWS::DevOpsAgent::Association"
        Properties = {
          AgentSpaceId = {
            Ref = "AgentSpace"
          }
          ServiceId = "aws"
          Configuration = {
            Aws = {
              AccountId        = data.aws_caller_identity.current.account_id
              AccountType      = "monitor"
              AssumableRoleArn = { "Fn::GetAtt" = ["DevOpsAgentRoleAgentSpace", "Arn"] }
              Tags             = local.topology_tags
            }
          }
        }
      }
    },
    local.operator_resources
  )
  template_outputs = merge(
    {
      AgentSpaceId = {
        Value = {
          Ref = "AgentSpace"
        }
      }
      AgentSpaceArn = {
        Value = {
          "Fn::GetAtt" = ["AgentSpace", "Arn"]
        }
      }
      AgentSpaceRoleArn = {
        Value = {
          "Fn::GetAtt" = ["DevOpsAgentRoleAgentSpace", "Arn"]
        }
      }
      MonitorAssociationId = {
        Value = {
          Ref = "MonitorAssociation"
        }
      }
    },
    var.enable_operator_app ? {
      OperatorAppRoleArn = {
        Value = {
          "Fn::GetAtt" = ["DevOpsAgentRoleWebappAdmin", "Arn"]
        }
      }
    } : {}
  )
}

resource "aws_cloudformation_stack" "devops_agent" {
  name         = local.stack_name
  capabilities = ["CAPABILITY_NAMED_IAM"]
  on_failure   = "ROLLBACK"
  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "AWS DevOps Agent onboarding for the ${var.project_name} ${var.environment} environment."
    Resources                = local.template_resources
    Outputs                  = local.template_outputs
  })

  tags = local.common_tags
}
