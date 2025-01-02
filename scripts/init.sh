#!/bin/bash

# Step 1: Initialize and apply the local backend to create the S3 bucket
echo "Initializing local backend and creating S3 bucket..."
cd ../infra/aws/project/init
terraform init
terraform apply -auto-approve

# Step 2: Capture the bucket name from the output
bucket_name=$(terraform output -raw bucket_name)
dynamodb_table=$(terraform output -raw dynamodb_table)

# Step 3: Switch to the main folder, update backend config dynamically
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

# Step 4: Reinitialize Terraform to switch to S3 backend and migrate state
terraform init -migrate-state

# Step 5: Apply the resources in the main configuration
terraform apply -auto-approve