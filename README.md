# Terrafrom - cloud agnostic setup
Terraform repo for AWS, Azure, GCP


## Project Initialization Process
Terraform requires an existing S3 bucket to initialize and configure the remote backend for state management. Since the backend cannot be configured until the bucket exists, a two-step process is typically required to set up the project.

To streamline this, a script has been provided to automate the initialization process. The script performs the following steps in a single run:

1. Creates the required S3 bucket using a temporary local backend.
2. Configures the Terraform project to use the S3 backend for state management.

After the script completes, the project will be fully initialized and ready for use. No further manual adjustments or configuration changes are necessary.

base64 -w 0 index.html > encoded_index.html