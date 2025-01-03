# Terraform Backend Initialization Script

## Overview
This script automates the initialization and migration process of a Terraform project with two backends:
1. A **local backend** to create an **S3 bucket**.
2. A subsequent switch to an **S3 backend** for state management.

The process ensures that resources are applied to the local backend first, then migrates the state to an S3 backend for future operations.

---

## Script Steps

### Step 1: Initialize and Apply the Local Backend to Create the S3 Bucket
```bash
echo "Step 1: Initializing local backend and creating S3 bucket..."
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
* The local backend is initialized, and the `terraform apply` command is used to create the necessary S3 bucket.

### Step 2: Capture the Bucket Name and DynamoDB Table Name from Outputs
```bash
echo "Step 2: Capturing outputs..."
bucket_name=$(terraform output -raw bucket_name)
dynamodb_table=$(terraform output -raw dynamodb_table)
```
* After the local backend is applied, the script captures the `bucket_name` and `dynamodb_table` outputs from Terraform to configure the S3 backend.

### Step 3: Update Backend Configuration to Use S3
```bash
echo "Step 3: Switching backend to S3 and migrating state..."
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
```
* The script dynamically generates the `backend.tf` configuration file, using the previously captured `bucket_name` and `dynamodb_table` to configure the S3 backend.

### Step 4: Reinitialize Terraform to Switch to S3 Backend and Migrate State
```bash
terraform init -migrate-state
```
* Terraform is reinitialized with the `-migrate-state` flag to migrate the existing state to the newly configured S3 backend.

   **NOTE:** this step requires manuall confirmation **"yes"** or **"no"**

### Step 5: Apply Resources with the S3 Backend
```bash
terraform apply -auto-approve
```
* Finally, the script applies the resources in the main Terraform configuration now that the state is managed by the S3 backend.

---

## Usage

### Prerequisites

1. **Terraform Installed**:
   * Ensure that `terraform` is installed and accessible in your system's `PATH`.

2. **Directory Structure**:
   * The script assumes the following directory structure:
     * Local Backend Directory: `../infra/aws/project/init`

### How to Run the Script
1. Navigate to your Terraform project directory and switch to `scripts` folder
   ```bash
   /repos/terraform❯ cd scripts/
   ```
2. Execute the script using:
   ```bash
   bash init.sh
   ```
3. The script will:
   * Initialize and apply the local backend.
   * Create the S3 bucket and DynamoDB table.
   * Migrate the Terraform state to the S3 backend.
   * Apply the configuration using the new S3 backend.

---

## Important Notes

* **Non-Destructive Configuration**:
  * The script keeps your Terraform configuration files intact and only modifies the backend configuration dynamically.

* **Error Handling**:
  * If any step fails (e.g., directory navigation or Terraform commands), the script will exit with an error message and halt further execution.

* **Automated State Migration**:
  * Ensure that the initial local state file (`terraform.tfstate`) exists before running the migration step.

---

## Example Output
```plaintext
Step 1: Initializing local backend and creating S3 bucket...
Terraform initialized successfully.
Terraform applied successfully.

Step 2: Capturing outputs...
Bucket Name: my-terraform-state-bucket
DynamoDB Table: my-terraform-lock-table

Step 3: Switching backend to S3 and migrating state...
Terraform initialized with S3 backend.
State migration completed successfully.

Step 4: Applying resources with the S3 backend...
No changes. Your infrastructure matches the configuration.

Migration and deployment complete!
```

