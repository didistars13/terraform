# Cleanup Backends Script

## Overview
The `cleanup_backends.sh` script is designed to streamline the cleanup process for Terraform-managed resources in projects with multiple backends. It allows users to destroy Terraform resources in either a **local backend**, an **S3 backend**, or both, without deleting the Terraform configuration files.

---

## Features
- **Targeted Cleanup**:
  - Destroy resources in the **local backend** only.
  - Destroy resources in the **S3 backend** only.
  - Destroy resources in **both backends**.
- **Automatic or Manual Approval**:
  - Use `--auto-approve` to bypass confirmation prompts.
- **Preserves Configuration**:
  - Keeps all Terraform configuration files intact while removing temporary `.terraform/` cache directories.

---

## Usage

### Command Syntax
```bash
./cleanup_backends.sh [all|local|s3] [--auto-approve]
```
## Options
* `all`: Destroy resources in both local and S3 backends.
* `local`: Destroy resources in the local backend only.
* `s3`: Destroy resources in the S3 backend only.
* `--auto-approve`: Automatically approve destruction without user confirmation.

## Examples
### Destroy All Backends
```bash
./cleanup_backends.sh all
```
### Destroy Only Local Backend
```bash
./cleanup_backends.sh local
```
### Destroy Only S3 Backend with Auto-Approve
```bash
./cleanup_backends.sh s3 --auto-approve
```

## Prerequisites
1. Terraform Installed:
* Ensure `terraform` is installed and accessible in your system's `PATH`.
2. Correct Directory Structure:
* The script assumes the following directory structure:
  * Local Backend Directory: `../infra/aws/project/init`
  * S3 Backend Directory: `../infra/aws/project/run`

## Important Notes
* Non-Destructive Configuration:
  * The script removes only resources and `.terraform/` cache files, leaving your configuration files intact.
* Error Handling:
  * If a backend directory is missing, the script will skip it and notify you.
* Dry Run:
  * Consider running `terraform plan -destroy` in the respective directories to review the resources to be destroyed.
