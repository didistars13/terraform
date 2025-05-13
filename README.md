# Terrafrom - cloud agnostic setup
Terraform repo for AWS, Azure, GCP


## AWS Infrastructure Setup

## Overview

This Terraform configuration provisions a **simple EC2 backend instance** along with all required supporting infrastructure using AWS.  
The setup follows a **clean modular approach**, utilizing a reusable module for VPC, networking, EC2 instance creation, and basic security configuration.

> ⚠ Note: The initial Terraform bootstrap (S3 backend creation and migration) requires a **manual initialization process using the provided GitHub Action**.

---

## Infrastructure Components

### Resources created by the project:
- **VPC with public and private subnets**
- **NAT Gateway and VPN Gateway (currently over-provisioned for a single EC2 — see optimization note below)**
- **Security Groups for SSH and HTTP**
- **EC2 instance (Amazon Linux 2) with IAM instance profile**
- **EC2 key pair created and managed by Terraform**
- **User data bootstrapping a simple HTTP server with instance metadata visualization (custom HTML served on port 80)**

---

## Modules and Files Structure

### `infra/aws/env/dev/main.tf`
- **Calls the reusable `env_setup` module.**
- Provides environment-specific variables like AZs, VPC CIDR, SSH keys, etc.

### `modules/aws/env_setup/main.tf`
- Provisions **EC2 instance, key pair, IAM profile, AMI lookup, and instance status check**.

### `modules/aws/env_setup/security.tf`
- Manages **security groups** (SSH restricted to `allowed_cidr_blocks`, HTTP open to the world).

### `modules/aws/env_setup/vpc.tf`
- Uses the **AWS VPC community module** to provision VPC, subnets, NAT, and VPN gateways.
  - ⚠ **Optimization note:**  
    Overkill for a simple EC2 instance.  
    In future iterations, consider replacing with a **custom lightweight VPC module**.

### `modules/aws/env_setup/userdata.sh`
- Bootstraps the EC2 instance.
- Installs HTTPD.
- Generates an HTML page with instance and security group metadata, populated via `curl` and `aws ec2 describe-*` API calls.

### `modules/aws/env_setup/output.tf`
- Outputs essential data like instance ID, public IP, and VPC ID.

---

## Bootstrap Process (One-Time Manual)

Terraform requires an existing **S3 bucket and DynamoDB lock table** to configure the remote backend.

### Workflow Summary:
1. Use the provided **GitHub Action `Terraform Init (Manual Bootstrap Only)`**.
2. It will:
   - Bootstrap backend using a **local state file**.
   - Create the required **S3 bucket and DynamoDB table**.
   - Migrate the state to **S3 backend**.
   - Finalize infrastructure apply using the new backend.

After this step, the project is fully initialized, and standard Terraform workflows can be used.

> **Important:**  
> Always use the `Terraform Destroy (Safe via Local Backend)` GitHub Action to tear down the infrastructure safely (it switches backend back to local to avoid state locks).

---

## Optimization Notes
- ⚡ **VPC module overuse:**  
  Current setup leverages the full-featured `terraform-aws-modules/vpc/aws`.  
  For a single EC2 instance, it's advisable to replace it with a **minimal custom VPC module** to reduce complexity and costs.

- 🚀 **User data customization:**  
  The EC2 instance runs a self-contained HTTP service displaying metadata.  
  This can be expanded into a more production-ready environment depending on the use case.

---

## Quick Commands

Convert your custom `index.html` to Base64 (if updating):
```bash
base64 -w 0 index.html > encoded_index.html