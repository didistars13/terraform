# 🛠️ Terraform Init (Manual Bootstrap Only)

## Overview

This GitHub Action initializes and bootstraps the Terraform environment by:
- Creating the S3 backend and DynamoDB lock table using a local backend.
- Migrating the Terraform state to S3.
- Running a final apply using the S3 backend.

### ⚠ Important Notes
- This action is **meant to be run manually and only once per environment**.
- It is a **destructive setup step** and should not be used casually.
- Requires explicit input confirmation (`YES_I_UNDERSTAND`) before execution.

---

## Workflow Summary

1. Bootstrap infrastructure using **local backend**.
2. Create **S3 bucket and DynamoDB table**.
3. Migrate state to **S3 backend** using `-migrate-state`.
4. Apply Terraform with the **S3 backend**.

---

## Inputs

| Input     | Description                                        | Required |
|-----------|----------------------------------------------------|----------|
| confirm   | Type `YES_I_UNDERSTAND` to confirm execution       | ✅       |

---

## Environment Variables & Secrets

| Variable                | Description                          |
|-------------------------|--------------------------------------|
| AWS_ROLE_TO_ASSUME      | IAM role to assume (GitHub OIDC)     |
| TF_BACKEND_BUCKET       | Name of the target S3 bucket         |
| TF_BACKEND_KEY          | Terraform state key in the bucket    |
| TF_BACKEND_REGION       | AWS region of the S3 backend         |
| TF_BACKEND_LOCK_TABLE   | DynamoDB lock table name             |

---

## Usage

This workflow must be triggered manually from the GitHub Actions UI:
- Go to **Actions > Terraform Init (Manual Bootstrap Only) > Run workflow**.
- Type `YES_I_UNDERSTAND` to confirm.

---

## ⚠ Warnings
- Intended only for **initial backend bootstrap**.
- Do not run this workflow in environments with an already existing backend.
