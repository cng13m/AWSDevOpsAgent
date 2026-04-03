# AWS Web App Platform

Terraform scaffold for a production-ready baseline AWS environment to host a containerized web app with:

- `ECS Fargate` behind an `Application Load Balancer`
- `RDS PostgreSQL`
- `ECR` image registry
- `CloudWatch` logs, dashboards, and alarms
- `SNS` email alerting
- `CloudTrail`, `AWS Config`, and `VPC Flow Logs`
- GitHub Actions CI/CD with GitHub OIDC roles instead of long-lived AWS keys
- A separate Terraform bootstrap stack for remote state

## Repo Layout

```text
.github/workflows/         GitHub Actions for infra and app delivery
app/                       Minimal sample web app container
docs/                      Runbooks and operator notes
terraform/bootstrap/       One-time state backend bootstrap
terraform/devops-agent/    Separate AWS DevOps Agent onboarding stack
terraform/envs/dev/        Dev environment root stack
terraform/modules/         Reusable Terraform modules
```

## Quick Start

1. Bootstrap Terraform state:
   - `cd terraform/bootstrap/state-backend`
   - `terraform init`
   - `terraform apply -var-file=terraform.tfvars`
2. Copy the generated bucket and table names into the backend config you use locally or in GitHub Actions.
3. Review and update:
   - `terraform/envs/dev/terraform.tfvars`
4. Deploy an environment:
   - `terraform -chdir=terraform/envs/dev init -backend-config="bucket=..." -backend-config="dynamodb_table=..." -backend-config="region=..." -backend-config="key=dev/terraform.tfstate"`
   - `terraform -chdir=terraform/envs/dev apply`
5. Configure GitHub repository variables and secrets described in [docs/runbook.md](docs/runbook.md).
6. Optionally deploy AWS DevOps Agent onboarding using [docs/devops-agent.md](docs/devops-agent.md).

## Notes

- The sample app under `app/` is intentionally minimal so CI/CD has a working container target.
- `terraform/envs/*/terraform.tfvars` contain placeholders and should be updated before first apply.
- The bootstrap stack uses local state initially because it creates the remote backend used by the other stacks.
