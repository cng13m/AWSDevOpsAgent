# AWS DevOps Agent Stack

This repo now includes a separate Terraform stack for AWS DevOps Agent onboarding:

- `terraform/devops-agent`

It is intentionally separate from the app infrastructure stack so you can test AWS DevOps Agent without coupling service onboarding to day-to-day web app Terraform changes.

## What It Creates

- A dedicated IAM role for the Agent Space to investigate resources in this AWS account
- An optional IAM role for the AWS DevOps Agent web app
- An Agent Space
- A primary AWS account association for the current account in `monitor` mode

## What It Is Used For

- Investigating AWS alarms and incidents in the `dev` environment
- Inspecting logs, metrics, topology, and recent infrastructure state in AWS
- Detecting when expected CI/CD context is missing, such as no connected GitHub pipeline source
- Providing AWS-side operational checks separate from Terraform and GitHub Actions

## What It Does Not Create

- GitHub app registration inside AWS DevOps Agent
- GitHub repository association inside the Agent Space
- Cross-account source associations

GitHub integration still needs to be completed in the AWS DevOps Agent console because the service uses an account-level GitHub app registration flow.

## Deploy

Use the same remote state bucket and lock table you already created:

```bash
terraform -chdir=terraform/devops-agent init -backend-config="bucket=aws-web-platform-tf-state" -backend-config="dynamodb_table=aws-web-platform-tf-locks" -backend-config="region=us-east-1" -backend-config="key=devops-agent/terraform.tfstate"
terraform -chdir=terraform/devops-agent plan
terraform -chdir=terraform/devops-agent apply
```

## After Apply

1. Open the AWS DevOps Agent console in `us-east-1`
2. Open the created Agent Space
3. Verify the AWS account association is healthy
4. If you want repository and deployment-awareness, register GitHub in the DevOps Agent console and then connect `cng13m/AWSDevOpsAgent` to the Agent Space

## Security Note

The operator web app role is trusted by the AWS DevOps Agent service principal with a same-account restriction. Users access the web app through the AWS DevOps Agent console flow rather than assuming that IAM role directly.
