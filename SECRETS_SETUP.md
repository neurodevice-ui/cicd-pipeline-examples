# 🔐 Secrets Configuration Guide

This guide helps you set up all the necessary secrets for your CI/CD pipeline to function properly.

## 📋 Required Secrets

### ✅ Already Created (Placeholder Values)
- `AWS_ROLE_ARN` - AWS IAM Role for OIDC authentication
- `TF_STATE_BUCKET` - S3 bucket for Terraform state storage
- `TF_STATE_LOCK_TABLE` - DynamoDB table for Terraform state locking

### 🔧 Optional but Recommended
- `SNYK_TOKEN` - For advanced security scanning

## 🚀 Step-by-Step Setup

### 1. AWS Configuration (Required for Terraform)

#### A. Create AWS IAM Role for GitHub Actions

1. **Log in to AWS Console** → IAM → Roles → Create Role

2. **Select trusted entity**: Web identity

3. **Configure the identity provider**:
   - Identity provider: `token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`

4. **Add condition** (replace with your repo):
   ```json
   {
     "StringEquals": {
       "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
       "token.actions.githubusercontent.com:sub": "repo:neurodevice-ui/cicd-pipeline-examples:ref:refs/heads/main"
     }
   }
   ```

5. **Attach policies**:
   - `PowerUserAccess` (for demo) or custom policy with required permissions
   - `IAMReadOnlyAccess`

6. **Role name**: `GitHubActionsRole`

7. **Copy the Role ARN** (looks like: `arn:aws:iam::123456789012:role/GitHubActionsRole`)

#### B. Create S3 Bucket for Terraform State

1. **AWS Console** → S3 → Create bucket

2. **Bucket settings**:
   - Name: `your-org-terraform-state-unique-name` (must be globally unique)
   - Region: `us-west-2` (or your preferred region)
   - Block all public access: ✅ Enabled
   - Versioning: ✅ Enabled
   - Server-side encryption: ✅ Enabled

#### C. Create DynamoDB Table for State Locking

1. **AWS Console** → DynamoDB → Create table

2. **Table settings**:
   - Table name: `terraform-state-lock`
   - Partition key: `LockID` (String)
   - Use default settings

### 2. Update GitHub Secrets

Run these commands with your actual values:

```powershell
# Update AWS Role ARN (replace with your actual ARN)
gh secret set AWS_ROLE_ARN --body "arn:aws:iam::YOUR-ACCOUNT-ID:role/GitHubActionsRole"

# Update Terraform state bucket (replace with your bucket name)
gh secret set TF_STATE_BUCKET --body "your-org-terraform-state-unique-name"

# Update Terraform lock table (replace with your table name)
gh secret set TF_STATE_LOCK_TABLE --body "terraform-state-lock"
```

### 3. Optional: Snyk Token (For Enhanced Security Scanning)

1. **Sign up at** https://snyk.io/ (free tier available)

2. **Get API token**:
   - Go to Account Settings → API Token
   - Copy the token

3. **Add to GitHub**:
   ```powershell
   gh secret set SNYK_TOKEN --body "your-snyk-api-token"
   ```

### 4. Verify Configuration

```powershell
# Check all secrets are set
gh secret list

# Test repository connection
gh repo view
```

## 🧪 Testing Your Setup

### Test Basic CI Pipeline (No AWS required)

1. **Make a small change** to trigger CI:
   ```powershell
   # Edit README or add a comment
   echo "# Test change" >> README.md
   git add README.md
   git commit -m "Test CI pipeline"
   git push
   ```

2. **Check workflow execution**:
   ```powershell
   gh run list
   gh run watch  # Watch latest run in real-time
   ```

### Test Full Pipeline (Requires AWS setup)

Only after completing AWS setup:

```powershell
# Make changes to Terraform files to trigger infrastructure pipeline
git add .
git commit -m "Test infrastructure pipeline"
git push
```

## 🔧 Alternative Configuration Methods

### Method 1: GitHub Web Interface

1. Go to: https://github.com/neurodevice-ui/cicd-pipeline-examples/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret manually

### Method 2: Using Environment Files (Local Development)

Create a `.env.secrets` file (DO NOT commit this):

```bash
# .env.secrets (local only - never commit)
AWS_ROLE_ARN=arn:aws:iam::123456789012:role/GitHubActionsRole
TF_STATE_BUCKET=your-terraform-state-bucket
TF_STATE_LOCK_TABLE=terraform-state-lock
SNYK_TOKEN=your-snyk-token
```

Then use the setup script to read from this file.

## 🚨 Security Best Practices

### ✅ Do:
- Use OIDC for AWS (no long-lived keys)
- Rotate secrets regularly
- Use least-privilege IAM policies
- Enable MFA on AWS account
- Use environment-specific secrets for production

### ❌ Don't:
- Commit secrets to code
- Use overly broad IAM permissions
- Share secrets in plain text
- Use same secrets across environments

## 🐛 Troubleshooting

### Common Issues:

1. **AWS Role Trust Relationship**
   - Verify the condition matches your repository exactly
   - Check the role has necessary permissions

2. **S3 Bucket Access**
   - Ensure bucket exists and is accessible
   - Check region consistency

3. **DynamoDB Table**
   - Verify table exists with correct partition key
   - Check region matches Terraform backend config

4. **Secret Values**
   - No leading/trailing spaces
   - Correct format for ARNs and names

### Validation Commands:

```powershell
# Check if secrets are set
gh secret list

# View repository info
gh repo view

# Check recent workflow runs
gh run list --limit 5

# View logs of latest run
gh run view --log
```

## 📞 Getting Help

- **AWS Issues**: Check AWS CloudTrail for detailed error logs
- **GitHub Actions**: Review workflow logs in the Actions tab
- **Terraform**: Enable TF_LOG=DEBUG for detailed logging

## 🔄 Updating Secrets

To update any secret:

```powershell
gh secret set SECRET_NAME --body "new-value"
```

## 🎯 Quick Start Commands

Copy and modify these commands with your actual values:

```powershell
# Required AWS secrets (update with your values)
gh secret set AWS_ROLE_ARN --body "arn:aws:iam::YOUR-ACCOUNT:role/GitHubActionsRole"
gh secret set TF_STATE_BUCKET --body "your-unique-bucket-name"
gh secret set TF_STATE_LOCK_TABLE --body "terraform-state-lock"

# Optional security token
gh secret set SNYK_TOKEN --body "your-snyk-token"

# Verify
gh secret list
```

---

**Next Step**: After configuring secrets, test your pipeline by making a commit!