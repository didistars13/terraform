#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the directory for the backend
BACKEND_DIR="../infra/aws/project/init"
BACKEND_FILE="backend.tf"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
    clear
    echo -e "\n========== Step 1: Switching backend to local ==========\n"
    pushd "$dir" > /dev/null

    echo "Writing local backend configuration to $BACKEND_FILE..."
    cat <<EOF > "$BACKEND_FILE"
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
EOF

    echo "Initializing Terraform with local backend..."
    export AWS_PROFILE=terraform
    terraform init -migrate-state

    clear
    echo -e "\n========== Step 2: Destroying resources ==========\n"
    if $AUTO_APPROVE; then
      terraform destroy --auto-approve
    else
      terraform destroy
    fi
    echo -e "\n${GREEN}✔ Resources destroyed successfully in $dir${NC}\n"

    sleep 2
    clear

    echo -e "\n========== Step 3: Sanity check – verify destruction ==========\n"
    if terraform state list | grep .; then
      echo -e "${RED}✖ Warning: Some resources still appear in the state.${NC}"
      terraform state list
    else
      echo -e "${GREEN}✔ Sanity check passed: No resources found in state.${NC}"
    fi

    popd > /dev/null
    sleep 2
    clear
  else
    echo -e "${RED}✖ Directory '$dir' not found. Skipping...${NC}"
  fi
}

# Execute destruction
destroy_backend "$BACKEND_DIR"

# Step 4: Clean up cache and .terraform files
echo -e "\n========== Step 4: Cleaning up cache files ==========\n"
find "$BACKEND_DIR" -name ".terraform*" -exec rm -rf {} +

echo -e "\n✅ ${GREEN}Cleanup complete. All Terraform configuration files are intact.${NC}\n"
