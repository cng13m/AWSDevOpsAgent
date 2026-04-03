# AWS Web App Platform

Terraform-based AWS infrastructure for a `dev` web app environment, plus a separate AWS DevOps Agent stack for AWS-side investigation and operational checks.

The platform currently includes:

- `ECS Fargate` behind an `Application Load Balancer`
- `RDS PostgreSQL`
- `ECR` image registry
- `CloudWatch` logs, dashboards, and alarms
- `SNS` email alerting
- `CloudTrail`, `AWS Config`, and `VPC Flow Logs`
- GitHub Actions CI/CD using GitHub OIDC instead of long-lived AWS keys
- A separate Terraform bootstrap stack for remote state
- A separate Terraform stack for `AWS DevOps Agent`

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

## Current Architecture

- The repo is intentionally `dev`-only.
- The app infrastructure and AWS DevOps Agent are managed in separate Terraform states.
- GitHub Actions handles Terraform changes and app deployments.
- AWS DevOps Agent is connected to AWS resources separately so it can inspect the environment and, once connected in the console, understand GitHub pipeline and repo context too.

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
5. Configure GitHub repository variables, secrets, and branch workflow described in [docs/runbook.md](docs/runbook.md).
6. Optionally deploy AWS DevOps Agent onboarding using [docs/devops-agent.md](docs/devops-agent.md).

## GitHub Workflow

GitHub is configured around a branch and PR flow:

- Work on a feature branch, not directly on `main`
- Open a pull request into `main`
- PRs run Terraform `plan`
- Merges to `main` run Terraform `apply` for `dev`
- App changes under `app/` trigger the image build and ECS deployment workflow

Required repository variables:

- `AWS_REGION`
- `TF_STATE_BUCKET`
- `TF_LOCK_TABLE`

Required repository or environment secrets:

- `AWS_ROLE_TERRAFORM`
- `AWS_ROLE_DEPLOY`
- `AWS_ROLE_READONLY`

## AWS DevOps Agent

This repo includes a separate AWS DevOps Agent stack in `terraform/devops-agent`.

What it does:

- creates an Agent Space
- creates the IAM role AWS DevOps Agent uses to inspect this AWS account
- creates the operator app role
- associates the AWS account with the Agent Space

What it is used for:

- checking AWS-side infrastructure state
- investigating alarms, logs, metrics, and resource topology
- correlating AWS findings with GitHub repository and pipeline context after GitHub is connected in the AWS DevOps Agent console

See [docs/devops-agent.md](docs/devops-agent.md) for deployment and console steps.

## Notes

- The sample app under `app/` is intentionally minimal so CI/CD has a working container target.
- `terraform/envs/dev/terraform.tfvars` contains the main configurable runtime values for the `dev` stack.
- The bootstrap stack uses local state initially because it creates the remote backend used by the other stacks.
