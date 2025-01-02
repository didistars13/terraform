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
echo "Initializing local backend and creating S3 bucket..."
cd ../infra/aws/project/init
terraform init
terraform apply -auto-approve
```
* The local backend is initialized, and the `terraform apply` command is used to create the necessary S3 bucket.
### Step 2: Capture the Bucket Name from the Output
```bash
bucket_name=$(terraform output -raw bucket_name)
dynamodb_table=$(terraform output -raw dynamodb_table)
```
* After the local backend is applied, the script captures the `bucket_name` and `dynamodb_table` outputs from Terraform to configure the S3 backend
### Step 3: Switch to the Main Folder and Update Backend Config Dynamically
```bash
echo "Switching backend to S3 and migrating state..."
cd ../run

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
* The script dynamically generates the `backend.tf` configuration file in the `run` directory, using the previously captured `bucket_name` and `dynamodb_table` to configure the S3 backend.
### Step 4: Reinitialize Terraform to Switch to S3 Backend and Migrate State
```bash
terraform init -migrate-state
```
* Terraform is reinitialized with the `-migrate-state` flag to migrate the existing state to the newly configured S3 backend.
### Step 5: Apply Resources in the Main Configuration
```bash
terraform apply -auto-approve
```
* Finally, the script applies the resources in the main Terraform configuration now that the state is managed by the S3 backend.

## Usage
To run the script, follow these steps:

1. Ensure Terraform is installed and configured on your system.
2. Clone or navigate to your Terraform project directory.
3. Run the script to automatically initialize and migrate the backend:
    ```bash
    ./init.sh
    ```
### Prerequisites
1. Terraform Installed:
* Ensure that `terraform` is installed and accessible in your system's `PATH`.
2. Directory Structure:
* The script assumes the following directory structure:
  * Local Backend Directory: `../infra/aws/project/init`
  * Main Directory: `../run`

## Important Notes
* Non-Destructive Configuration:
  * The script keeps your Terraform configuration files intact and only modifies the backend configuration.
* Error Handling:
  * If any step fails (e.g., directory navigation or Terraform commands), the script will exit with an error message and halt further execution.

---

### How to Use It:
**Run the Script**:
- Execute the script using:
  ```bash
  bash scripts/init.sh
  ```
- Ensure that the paths and environment are correctly set up.