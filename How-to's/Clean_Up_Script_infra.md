
# Cleanup Backends Script

## Overview
The `cleanup_backends.sh` script is designed to streamline the cleanup process for Terraform-managed resources in `init` folder. It allows users to destroy Terraform resources in the **S3 backend** while keeping the Terraform configuration files intact.

---

## Features
- **Targeted Cleanup**:
  - Destroy resources in the **S3 backend** only.
- **Automatic or Manual Approval**:
  - Use `--auto-approve` to bypass confirmation prompts.
- **Preserves Configuration**:
  - Keeps all Terraform configuration files intact while removing temporary `.terraform/` cache directories.

---

## Usage

### Command Syntax
```bash
./destroy.sh [--auto-approve]
```

## Options
* `--auto-approve`: Automatically approve the destruction without user confirmation (optional).

## Examples
### Destroy Resources with Auto-Approve
```bash
./destroy.sh --auto-approve
```

### Destroy Resources without Auto-Approve (Manual Confirmation)
```bash
./destroy.sh
```
**NOTE:** this step requires manuall confirmation **"yes"** or **"no"**

## Prerequisites
1. **Terraform Installed**:
   * Ensure `terraform` is installed and accessible in your system's `PATH`.
2. **Correct Directory Structure**:
   * The script assumes the following directory structure:
     * Local Backend Directory: `../infra/aws/project/init`

---

## Important Notes
- **Non-Destructive Configuration**:
  - The script removes only resources and `.terraform/` cache files, leaving your configuration files intact.
- **Error Handling**:
  - If a backend directory is missing (e.g., local or remote), the script will skip it and notify you.
- **Dry Run**:
  - Consider running `terraform plan -destroy` in the respective directories to review the resources to be destroyed.
- **Backend Configuration**:
  - By default script switch backend from `s3` to `local` before **deletion**
---
