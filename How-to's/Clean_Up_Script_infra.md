# Terraform Backend Cleanup Script

## Overview

The `destroy.sh` script is designed to **safely and cleanly destroy Terraform-managed resources** in the `init` directory. It handles the transition from a remote S3 backend back to a local backend, ensuring resources are destroyed correctly and that no residual state or cache files remain.

---

## Script Steps

### ✅ Step 1: Switch Backend to Local

```bash
cat <<EOF > backend.tf
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
EOF

terraform init -migrate-state
```

Switches from S3 backend to local, allowing safe destruction of resources while avoiding remote state lock issues.

---

### ✅ Step 2: Destroy Resources

```bash
terraform destroy --auto-approve
```

Destroys all infrastructure defined in the module. If `--auto-approve` is not used, manual confirmation is required.

---

### ✅ Step 3: Sanity Check – Ensure All Resources Are Destroyed

```bash
terraform state list
```

Checks if any resources are still present in the Terraform state. If the list is empty, destruction was successful.

---

### ✅ Step 4: Clean Up Cache Files

```bash
find ../infra/aws/project/init -name ".terraform*" -exec rm -rf {} +
```

Deletes `.terraform/` directories and any related cache or temp files, keeping your configuration clean and ready for future deployments.

---

## Usage

### 🔧 Command Syntax

```bash
./destroy.sh [--auto-approve]
```

### 🔁 Options

- `--auto-approve`: Automatically approve destruction (optional).
- Without the flag, you will be prompted to type `yes` or `no`.

---

## Examples

### Destroy with Auto-Approve

```bash
./destroy.sh --auto-approve
```

### Destroy with Manual Confirmation

```bash
./destroy.sh
```

---

## Prerequisites

- **Terraform installed** and accessible via your system `PATH`.
- **AWS credentials** properly configured (via `AWS_PROFILE=terraform` or env vars).
- **Directory structure**:
  ```
  /infra
    /aws
      /project
        /init
          backend.tf
          ...
  /scripts
    destroy.sh
  ```

---

## Important Notes

- ✅ **Non-destructive to configuration**: Your `.tf` files are preserved.
- ⚠️ **State migration**: The script forcibly switches backend to local before running `destroy`.
- 🧪 **Post-destroy check**: The script performs a `terraform state list` to ensure full cleanup.
- 🧹 **Cleans `.terraform` cache**: Prevents conflicts in future Terraform runs.

---

## Example Output

```plaintext
========== Step 1: Switching backend to local ==========

Terraform initialized with local backend.

========== Step 2: Destroying resources ==========

Plan: 0 to add, 0 to change, 10 to destroy.
...
Destroy complete!

========== Step 3: Sanity check – verify destruction ==========

No resources found in state.

========== Step 4: Cleaning up cache files ==========

✔ Cleanup complete. All configuration files are intact.
```
