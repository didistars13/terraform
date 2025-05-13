# 🔐 GitHub Actions Integration with AWS (OIDC Setup)

This project uses **AWS IAM Roles with GitHub Actions OpenID Connect (OIDC)** authentication for secure, keyless Terraform deployments.
This avoids the need to store AWS access keys in GitHub secrets and enables short-lived, automatically rotated credentials.

---

## ✅ Trust Policy Setup (IAM Role)

Ensure you have the following **IAM role and trust relationship configured in AWS**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::443370714049:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:didistars13/terraform:*"
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

| Key Field | Description |
|-----------|-------------|
| `Federated` | Your OIDC provider ARN (`token.actions.githubusercontent.com`) |
| `sub`      | Must match your GitHub repo (`repo:didistars13/terraform:*`) |
| `aud`      | Must equal `sts.amazonaws.com` for AWS OIDC integration |

---

## ✅ How to Configure OIDC with GitHub Actions

### Step 1: Create OIDC Provider in AWS (if missing)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### Step 2: Create IAM Role with the above trust policy

```bash
aws iam create-role \
  --role-name github-actions-terraform \
  --assume-role-policy-document file://trust-policy.json
```

Attach needed policies (example for full admin — refine per your needs):

```bash
aws iam attach-role-policy \
  --role-name github-actions-terraform \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### Step 3: Add secret in GitHub

1. Go to your GitHub repo → Settings → Secrets and variables → Actions.
2. Create new secret:
   - Name: `AWS_ROLE_TO_ASSUME`
   - Value: `arn:aws:iam::443370714049:role/github-actions-terraform`

---

## ✅ Example usage in GitHub Action workflow

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: eu-central-1
```

Now your GitHub Actions can securely assume the IAM role via OIDC and run Terraform without needing static credentials.

---

## 🔗 References

- [GitHub OIDC with AWS Docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS OIDC Provider Setup](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
