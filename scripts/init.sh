#!/bin/bash

# Set working directory to the 'init' folder
cd ../infra/aws/project/init

# Step 1: Initialize and apply the configuration with the local backend to create the S3 bucket
echo "Step 1: Initializing local backend and creating S3 bucket..."
cat <<EOF > backend.tf
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
EOF

terraform init
terraform apply -auto-approve

# Step 2: Capture the bucket name and DynamoDB table name from outputs
echo "Step 2: Capturing outputs..."
bucket_name=$(terraform output -raw bucket_name)
dynamodb_table=$(terraform output -raw dynamodb_table)

# Step 3: Update backend configuration to use S3
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

# Reinitialize Terraform to switch to the S3 backend and migrate state
terraform init -migrate-state

# Step 4: Apply the resources to verify everything is working
echo "Step 4: Applying resources with the S3 backend..."
terraform apply -auto-approve

echo "Migration and deployment complete!"
