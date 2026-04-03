# Runbook

## Bootstrap Order

1. Apply `terraform/bootstrap/state-backend`.
2. Record the output bucket and DynamoDB table names.
3. Update local/backend config for `terraform/envs/dev`.
4. Apply `dev`.
5. Verify alarms, logs, ECS service health, and RDS connectivity.

## GitHub Setup

Create GitHub environment(s):

- `dev`

Create repository variables:

- `AWS_REGION`
- `TF_STATE_BUCKET`
- `TF_LOCK_TABLE`

Create repository or environment secrets:

- `AWS_ROLE_TERRAFORM`
- `AWS_ROLE_DEPLOY`
- `AWS_ROLE_READONLY`

## GitHub Operating Flow

Use a PR-first workflow for infrastructure changes:

1. Create a branch from `main`
2. Push the branch
3. Open a pull request into `main`
4. Wait for the Terraform PR check to complete
5. Merge only after the plan looks correct
6. Let the merge to `main` trigger the real `dev` apply

App changes under `app/` are deployed through the `deploy-app` workflow after merge to `main`.

## Local Terraform Workflow

```powershell
terraform -chdir=terraform/envs/dev init `
  -backend-config="bucket=<state-bucket>" `
  -backend-config="dynamodb_table=<lock-table>" `
  -backend-config="region=<aws-region>" `
  -backend-config="key=dev/terraform.tfstate"

terraform -chdir=terraform/envs/dev plan
terraform -chdir=terraform/envs/dev apply
```

## Rollback

1. Identify the prior good image tag in ECR or the GitHub Actions deployment run.
2. Re-run the deploy workflow with that image tag.
3. Confirm target health on the ALB and inspect CloudWatch logs.

## Drift Detection

The scheduled GitHub Actions drift workflow runs `terraform plan -detailed-exitcode`.

- Exit code `0`: no drift
- Exit code `2`: drift or unapplied change detected
- Exit code `1`: workflow failure
