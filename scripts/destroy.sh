#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the directories for local and S3 backend
LOCAL_BACKEND_DIR="../infra/aws/project/init"
S3_BACKEND_DIR="../infra/aws/project/run"

# Function to display usage information
function usage() {
  echo "Usage: $0 [all|local|s3] [--auto-approve]"
  echo "Options:"
  echo "  all             Destroy resources in both local and S3 backends"
  echo "  local           Destroy resources in the local backend only"
  echo "  s3              Destroy resources in the S3 backend only"
  echo "  --auto-approve  Automatically approve the destroy actions"
  exit 1
}

# Parse arguments
if [[ $# -lt 1 ]]; then
  usage
fi

TARGET=$1
AUTO_APPROVE=false
if [[ "$2" == "--auto-approve" ]]; then
  AUTO_APPROVE=true
fi

# Function to destroy resources in a specific directory
function destroy_backend() {
  local dir=$1
  local name=$2

  if [[ -d "$dir" ]]; then
    echo "Destroying resources in the $name backend folder..."
    cd "$dir"
    if $AUTO_APPROVE; then
      terraform destroy --auto-approve
    else
      terraform destroy
    fi
    echo "Resources in the $name backend folder destroyed."
    cd -
  else
    echo "$name backend folder '$dir' not found. Skipping..."
  fi
}

# Perform cleanup based on the selected target
case $TARGET in
  all)
    destroy_backend "$LOCAL_BACKEND_DIR" "local"
    destroy_backend "$S3_BACKEND_DIR" "S3"
    ;;
  local)
    destroy_backend "$LOCAL_BACKEND_DIR" "local"
    ;;
  s3)
    destroy_backend "$S3_BACKEND_DIR" "S3"
    ;;
  *)
    usage
    ;;
esac

# Clean up temporary files
echo "Cleaning up temporary and cache files..."
if [[ $TARGET == "all" || $TARGET == "local" ]]; then
  find "$LOCAL_BACKEND_DIR" -name ".terraform*" -exec rm -rf {} +
fi
if [[ $TARGET == "all" || $TARGET == "s3" ]]; then
  find "$S3_BACKEND_DIR" -name ".terraform*" -exec rm -rf {} +
fi

echo "Cleanup complete. All Terraform configuration files are intact."

echo "Selected resources destroyed successfully."
