# GitHub Secrets Setup Script
# This script helps configure all necessary secrets for the CI/CD pipeline

param(
    [switch]$Interactive = $false,
    [switch]$Help = $false,
    [switch]$List = $false,
    [switch]$Test = $false
)

if ($Help) {
    Write-Host "GitHub Secrets Setup Script" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\setup-secrets.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Interactive    Prompt for secret values interactively"
    Write-Host "  -List          List current secrets"
    Write-Host "  -Test          Test pipeline with a sample commit"
    Write-Host "  -Help          Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup-secrets.ps1 -List"
    Write-Host "  .\setup-secrets.ps1 -Interactive"
    Write-Host "  .\setup-secrets.ps1 -Test"
    exit 0
}

Write-Host "🔐 GitHub Secrets Configuration Tool" -ForegroundColor Green

# Function to check if GitHub CLI is authenticated
function Test-GitHubAuth {
    try {
        $null = gh auth status 2>&1
        return $true
    } catch {
        return $false
    }
}

# Function to list current secrets
function Show-CurrentSecrets {
    Write-Host "📋 Current Repository Secrets:" -ForegroundColor Yellow
    try {
        gh secret list
        return $true
    } catch {
        Write-Host "❌ Failed to list secrets. Ensure you're authenticated with GitHub CLI." -ForegroundColor Red
        return $false
    }
}

# Function to set a secret with validation
function Set-GitHubSecret {
    param(
        [string]$Name,
        [string]$Value,
        [string]$Description = ""
    )
    
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Host "⚠️ Skipping $Name - no value provided" -ForegroundColor Yellow
        return $false
    }
    
    try {
        gh secret set $Name --body $Value
        Write-Host "✅ Set secret: $Name" -ForegroundColor Green
        if ($Description) {
            Write-Host "   Description: $Description" -ForegroundColor Gray
        }
        return $true
    } catch {
        Write-Host "❌ Failed to set secret: $Name" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Red
        return $false
    }
}

# Function for interactive setup
function Start-InteractiveSetup {
    Write-Host "🚀 Interactive Secret Configuration" -ForegroundColor Cyan
    Write-Host "Enter values for each secret (press Enter to skip):" -ForegroundColor Yellow
    Write-Host ""
    
    # AWS Role ARN
    Write-Host "1. AWS_ROLE_ARN" -ForegroundColor Cyan
    Write-Host "   Format: arn:aws:iam::123456789012:role/GitHubActionsRole" -ForegroundColor Gray
    $awsRoleArn = Read-Host "   Enter AWS Role ARN"
    
    # Terraform State Bucket
    Write-Host ""
    Write-Host "2. TF_STATE_BUCKET" -ForegroundColor Cyan
    Write-Host "   Format: your-unique-bucket-name" -ForegroundColor Gray
    $tfStateBucket = Read-Host "   Enter Terraform state bucket name"
    
    # Terraform State Lock Table
    Write-Host ""
    Write-Host "3. TF_STATE_LOCK_TABLE" -ForegroundColor Cyan
    Write-Host "   Format: terraform-state-lock" -ForegroundColor Gray
    $tfStateLockTable = Read-Host "   Enter Terraform state lock table name"
    
    # Snyk Token (Optional)
    Write-Host ""
    Write-Host "4. SNYK_TOKEN (Optional)" -ForegroundColor Cyan
    Write-Host "   Get from: https://snyk.io/ → Account Settings → API Token" -ForegroundColor Gray
    $snykToken = Read-Host "   Enter Snyk API token (optional)"
    
    # Set the secrets
    Write-Host ""
    Write-Host "Setting secrets..." -ForegroundColor Yellow
    
    $results = @()
    $results += Set-GitHubSecret -Name "AWS_ROLE_ARN" -Value $awsRoleArn -Description "AWS IAM Role for OIDC authentication"
    $results += Set-GitHubSecret -Name "TF_STATE_BUCKET" -Value $tfStateBucket -Description "S3 bucket for Terraform state"
    $results += Set-GitHubSecret -Name "TF_STATE_LOCK_TABLE" -Value $tfStateLockTable -Description "DynamoDB table for Terraform state locking"
    
    if (-not [string]::IsNullOrWhiteSpace($snykToken)) {
        $results += Set-GitHubSecret -Name "SNYK_TOKEN" -Value $snykToken -Description "Snyk API token for security scanning"
    }
    
    # Summary
    $successCount = ($results | Where-Object { $_ -eq $true }).Count
    $totalCount = $results.Count
    
    Write-Host ""
    Write-Host "📊 Summary: $successCount/$totalCount secrets configured successfully" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
}

# Function to test the pipeline
function Test-Pipeline {
    Write-Host "🧪 Testing CI/CD Pipeline" -ForegroundColor Cyan
    
    # Check if we're in a git repository
    try {
        $null = git rev-parse --git-dir 2>&1
    } catch {
        Write-Host "❌ Not in a Git repository" -ForegroundColor Red
        return
    }
    
    # Create a test commit
    $testFile = "test-pipeline-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    $testContent = @'
# Pipeline Test

This file was created to test the CI/CD pipeline.

- Created: {0}
- Purpose: Trigger GitHub Actions workflows
- Status: Testing

This file can be safely deleted after testing.
'@ -f (Get-Date)
    
    Write-Host "Creating test file: $testFile" -ForegroundColor Yellow
    $testContent | Out-File -FilePath $testFile -Encoding utf8
    
    Write-Host "Committing and pushing..." -ForegroundColor Yellow
    try {
        git add $testFile
        git commit -m "Test CI/CD pipeline - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git push
        
        Write-Host "✅ Test commit pushed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🔍 Monitor your workflow:" -ForegroundColor Cyan
        Write-Host "   gh run list                    # List recent runs"
        Write-Host "   gh run watch                   # Watch latest run"
        Write-Host "   gh run view --log              # View logs"
        Write-Host "   Or visit: $(gh repo view --web)/actions" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ Failed to push test commit: $_" -ForegroundColor Red
    }
}

# Main script logic
if (-not (Test-GitHubAuth)) {
    Write-Host "❌ GitHub CLI is not authenticated." -ForegroundColor Red
    Write-Host "Please run: gh auth login" -ForegroundColor Yellow
    exit 1
}

if ($List) {
    Show-CurrentSecrets
    exit 0
}

if ($Test) {
    Test-Pipeline
    exit 0
}

if ($Interactive) {
    Start-InteractiveSetup
    Write-Host ""
    Show-CurrentSecrets
} else {
    # Default behavior - show current status and guide
    Write-Host "📋 Current Secret Status:" -ForegroundColor Yellow
    Show-CurrentSecrets
    
    Write-Host ""
    Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Run with -Interactive to configure secrets interactively:"
    Write-Host "   .\setup-secrets.ps1 -Interactive" -ForegroundColor Green
    Write-Host ""
    Write-Host "2. Or manually set secrets using gh CLI:"
    Write-Host "   gh secret set AWS_ROLE_ARN --body 'arn:aws:iam::123456789012:role/GitHubActionsRole'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. For detailed setup instructions, see: SECRETS_SETUP.md" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. Test your pipeline:"
    Write-Host "   .\setup-secrets.ps1 -Test" -ForegroundColor Green
}

Write-Host ""
Write-Host "📚 For detailed AWS setup instructions, see SECRETS_SETUP.md" -ForegroundColor Cyan