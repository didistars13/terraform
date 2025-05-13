# Terraform Backend Initialization Script

## Overview

This script automates the initialization and migration process of a Terraform project with two backends:
1. A **local backend** to create an **S3 bucket** and **DynamoDB table**.
2. A subsequent switch to an **S3 backend** for remote state management.

The process ensures that Terraform resources are first created locally, then the state is migrated to S3 and locked using DynamoDB, enabling secure and collaborative infrastructure management.

---

## Script Steps

### ✅ Step 1: Initialize and Apply the Local Backend

```bash
cd ../infra/aws/project/init
cat <<EOF > backend.tf
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
EOF

terraform init
terraform apply -auto-approve
```

This initializes a local backend and deploys an S3 bucket and a DynamoDB table needed for remote state and locking.

---

### ✅ Step 2: Capture Bucket and Table Names Dynamically

```bash
bucket_name=$(terraform output -raw main_bucket)
dynamodb_table=$(terraform output -raw dynamodb_table)
```

These outputs are used in the next step to configure the S3 backend.

---

### ✅ Step 3: Configure and Migrate to the S3 Backend

```bash
cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket         = "$bucket_name"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "$dynamodb_table"
  }
}
EOF

terraform init -migrate-state
```

The script replaces the local backend with a remote S3 configuration and triggers a state migration.

> **Note:** The `-migrate-state` step may prompt for confirmation. Make sure to allow it (`yes`) if prompted.

---

### ✅ Step 4: Apply Resources with the S3 Backend

```bash
terraform apply -auto-approve
```

Once the remote backend is in place, the infrastructure is applied again to ensure consistency and state integrity.

---

### ✅ Step 5: Sanity Check – Validate & List State Resources

```bash
terraform validate
terraform state list
```

- Runs `terraform validate` to ensure configuration is syntactically and logically correct.
- Lists all resources currently in the state file.
- If no resources are found, a warning is shown.

---

## Usage Instructions

### 🔧 Prerequisites

- **Terraform installed** and available in your system's `PATH`.
- **AWS credentials** available via `AWS_PROFILE=terraform` or exported via environment variables.
- **Directory structure**:
  ```
  /infra
    /aws
      /project
        /init
          env_modules.tf
          ...
    /modules
  /scripts
    init.sh
  ```

### 🚀 Running the Script

1. Navigate to the scripts folder:
   ```bash
   cd scripts/
   ```

2. Run the script:
   ```bash
   bash init.sh
   ```

This will:
- Deploy initial resources with a local backend
- Dynamically reconfigure Terraform to use S3
- Migrate the state
- Re-apply and validate the configuration

---

## Example Output

```plaintext
========== Step 1: Initialize local backend and create S3 bucket ==========

Terraform has been successfully initialized!
Terraform applied successfully.

========== Step 2: Capturing Terraform outputs ==========

Bucket name: my-env-tfstate-bucket
DynamoDB table name: my-env-lock-table

========== Step 3: Switching backend to S3 and migrating state ==========
Waiting for resources to become available.....

Terraform initialized with S3 backend.
State migration completed.

========== Step 4: Applying resources with the S3 backend ==========

Apply complete! No changes needed.

========== Step 5: Sanity check: validate and inspect resources ==========

✔ Terraform configuration is valid.
aws_s3_bucket.main
aws_dynamodb_table.lock_table

✅ Migration, deployment, and validation complete!
```

---

## Notes

- ✅ The script ensures **safe and reversible** configuration changes.
- ⛔ Do not run this script if you already have a working remote backend unless you're initializing a new environment.
- 🛡️ Sanity checks help verify infrastructure health post-migration.
