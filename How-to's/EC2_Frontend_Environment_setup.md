# Terraform Environment Setup

This repository provides a Terraform configuration for creating AWS environments (`dev`, `stage`, `prod`, etc.) with an EC2 instance and supporting infrastructure. The configuration is modular and can be reused for multiple environments by making minimal changes.

## Structure

### `main.tf`
Defines the core infrastructure module and uses locals to set environment-specific values.

```hcl
module "dev_ec2" {
  source              = "../../../../modules/aws/env_setup"
  ami                 = local.ami
  azs                 = local.azs
  env                 = local.env
  instance_type       = local.instance_type
  instance_name       = local.instance_name
  key_name            = local.key_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  private_key         = local.private_key
  private_subnets     = local.private_subnets
  public_key          = local.public_key
  public_subnets      = local.public_subnets
  region              = local.region
  user_data           = local.user_data
  vpc_cidr            = local.vpc_cidr
  vpc_name            = local.vpc_name
  tags = {
    Environment = "dev"
  }
}
```

### `locals.tf`
Defines environment-specific values such as `ami`, `subnets`, `region`, and `user_data`.

### `terraform.tfvars`
Specifies variables such as `allowed_cidr_blocks`.

```hcl
allowed_cidr_blocks = [
  "X.X.X.X/32",
  "Y.Y.Y.Y/32",
  ...
]
```

### `terraform {}` block
Defines the backend configuration for storing the Terraform state in an S3 bucket with DynamoDB for state locking.

### Outputs
The following outputs are available:
- `public_ip`: The public IP address of the EC2 instance.
- `instance_id`: The ID of the created EC2 instance.
- `vpc_id`: The ID of the created VPC.
- `igw_id`: The ID of the created Internet Gateway.

## How to Use

### Prerequisites
- Terraform installed ([Download Terraform](https://www.terraform.io/downloads))
- AWS credentials with sufficient permissions configured (e.g., `~/.aws/credentials`)
- SSH key pair available for EC2 instance access.

### Steps to Create a DEV Environment

1. **Clone this repository**:
   ```bash
   git clone https://github.com/didistars13/terraform.git
   cd terraform/infra/aws/env/dev
   ```

2. **Adjust Local Configuration**:
   Modify the values in `locals.tf` to match the desired environment.

3. **Adjust Variables**:
   Update `terraform.tfvars` with the allowed CIDR blocks for SSH access.

4. **Initialize Terraform**:
   Run the following command to initialize Terraform and set up the backend:
   ```bash
   terraform init
   ```

5. **Plan Infrastructure**:
   Generate and review an execution plan:
   ```bash
   terraform plan
   ```

6. **Apply Changes**:
   Apply the configuration to create the infrastructure:
   ```bash
   terraform apply
   ```

7. **View Outputs**:
   After successful deployment, note the output values such as `public_ip` and `instance_id`.

### Creating Additional Environments

To create another environment (e.g., `stage`, `prod`, `etc`):
1. Copy folder `dev` under the `terraform/infra/aws/env` path and rename it to `stage`, `prod`, `etc`
1. Modify `module` block in `main.tf` and rename it (e.g., `stage_ec2`).
2. Update `locals.tf` with the new environment-specific values.
3. Adjust `terraform.tfvars` as needed for the new environment.

Example for `stage`:
```hcl
module "stage_ec2" {
  source              = "../../../../modules/aws/env_setup"
  ami                 = local.ami
  azs                 = local.azs
  env                 = "stage"
  instance_type       = local.instance_type
  instance_name       = "stage_instance"
  key_name            = "stage_deployer"
  allowed_cidr_blocks = var.allowed_cidr_blocks
  private_key         = "~/.ssh/stage_deployer"
  private_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_key          = file("~/.ssh/stage_deployer.pub")
  public_subnets      = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  region              = "eu-central-1"
  user_data           = file("./userdata.yaml")
  vpc_cidr            = "10.1.0.0/16"
  vpc_name            = "stage_vpc"
  tags = {
    Environment = "stage"
  }
}
```

### Destroy Infrastructure
To tear down the infrastructure for an environment:
```bash
terraform destroy
```

## User Data
The user data script installs and configures an Apache web server:
```yaml
#cloud-config
packages:
  - httpd
runcmd:
  - systemctl start httpd
  - sudo systemctl enable httpd
  - echo "<html><h1>Hello, World</h1></html>" > /var/www/html/index.html
```

## Notes
- Ensure the S3 bucket and DynamoDB table used for the backend are created beforehand.

  | **NOTE**: S3 backet and dynamodb table name have to be takedn from the output of the init project
  
  ```hcl
  ❯ cd ../../project/init
  ❯ terraform output
  dev_bucket_name = "dev-aws328-tfstate"
  dev_state_lock_table = "dev-state-lock"
  dynamodb_table = "state-lock"
  force_destroy = true
  main_bucket = "init-aws328-tfstate"
  ```
- Replace `source` paths with appropriate relative or remote module paths.
- Review and customize security settings such as `allowed_cidr_blocks`.

## License
This project is licensed under the [MIT License](LICENSE).
