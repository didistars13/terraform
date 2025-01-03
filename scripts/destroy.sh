#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the directory for the backend
BACKEND_DIR="../infra/aws/project/init"
BACKEND_FILE="backend.tf"

# Function to display usage information
function usage() {
  echo "Usage: $0 [--auto-approve]"
  echo "Options:"
  echo "  --auto-approve  Automatically approve the destroy actions (optional)"
  exit 1
}

# Parse arguments
AUTO_APPROVE=false
if [[ "$1" == "--auto-approve" ]]; then
  AUTO_APPROVE=true
fi

# Function to destroy resources in a specific directory
function destroy_backend() {
  local dir=$1

  if [[ -d "$dir" ]]; then
    echo "Initializing Terraform with a local backend..."
    cd "$dir"

    # Create or overwrite the backend.tf file with local backend configuration
    cat <<EOF > "$BACKEND_FILE"
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
EOF

    # Initialize Terraform (now using the backend configuration in backend.tf)
    terraform init -migrate-state

    echo "Destroying resources in the current backend folder..."
    if $AUTO_APPROVE; then
      terraform destroy --auto-approve
    else
      terraform destroy
    fi
    echo "Resources in the current backend folder destroyed."
    cd - 
  else
    echo "Current backend folder '$dir' not found. Skipping..."
  fi
}

# Destroy resources in the backend
destroy_backend "$BACKEND_DIR"

# Clean up temporary files
echo "Cleaning up temporary and cache files..."
find "$BACKEND_DIR" -name ".terraform*" -exec rm -rf {} +

echo "Cleanup complete. All Terraform configuration files are intact."

echo "Resources destroyed successfully."
