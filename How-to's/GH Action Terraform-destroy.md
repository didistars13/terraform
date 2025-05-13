# 🧨 Terraform Destroy (Safe via Local Backend)

## Overview

This GitHub Action safely destroys all Terraform-managed infrastructure by:
- Migrating the state from S3 backend to local backend.
- Executing `terraform destroy` using the local backend.
- Performing sanity checks and cleaning up Terraform files.

### ⚠ Important Notes
- This action is **intended for safe, manual destruction of infrastructure**.
- It switches the backend to **local** to avoid remote backend conflicts or locks.
- Requires explicit input confirmation (`YES_I_UNDERSTAND`) before execution.

---

## Workflow Summary

1. Initialize from **S3 backend**.
2. Migrate state to **local backend**.
3. Run `terraform destroy` locally.
4. Verify state is empty and clean up files.

---

## Inputs

| Input     | Description                                        | Required |
|-----------|----------------------------------------------------|----------|
| confirm   | Type `YES_I_UNDERSTAND` to confirm destruction     | ✅       |

---

## Environment Variables & Secrets

| Variable                | Description                          |
|-------------------------|--------------------------------------|
| AWS_ROLE_TO_ASSUME      | IAM role to assume (GitHub OIDC)     |
| TF_BACKEND_BUCKET       | Name of the S3 backend bucket        |
| TF_BACKEND_KEY          | Terraform state key in the bucket    |
| TF_BACKEND_REGION       | AWS region of the S3 backend         |
| TF_BACKEND_LOCK_TABLE   | DynamoDB lock table name             |

---

## Usage

This workflow must be triggered manually from the GitHub Actions UI:
- Go to **Actions > Terraform Destroy (Safe via Local Backend) > Run workflow**.
- Type `YES_I_UNDERSTAND` to confirm.

---

## ⚠ Warnings
- Ensure you truly intend to **remove all infrastructure**.
- Always double-check the environment and confirmation string before running.
