# Setup script for CI/CD Pipeline Examples
# This script sets up the local development environment

param(
    [switch]$SkipDocker = $false,
    [switch]$SkipTerraform = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "Setup Script for CI/CD Pipeline Examples" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\setup.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -SkipDocker     Skip Docker setup"
    Write-Host "  -SkipTerraform  Skip Terraform setup"
    Write-Host "  -Help           Show this help message"
    exit 0
}

Write-Host "🚀 Setting up CI/CD Pipeline Examples..." -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js 18 or higher." -ForegroundColor Red
    exit 1
}

# Check Git
try {
    $gitVersion = git --version
    Write-Host "✅ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git not found. Please install Git." -ForegroundColor Red
    exit 1
}

# Check Docker
if (-not $SkipDocker) {
    try {
        $dockerVersion = docker --version
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Docker not found. Skipping Docker setup." -ForegroundColor Yellow
        $SkipDocker = $true
    }
}

# Check Terraform
if (-not $SkipTerraform) {
    try {
        $terraformVersion = terraform --version
        Write-Host "✅ Terraform found: $terraformVersion" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Terraform not found. Skipping Terraform setup." -ForegroundColor Yellow
        $SkipTerraform = $true
    }
}

# Setup Node.js application
Write-Host "Setting up Node.js application..." -ForegroundColor Yellow
Set-Location app
if (Test-Path package-lock.json) {
    npm ci
} else {
    npm install
}
Write-Host "✅ Node.js dependencies installed" -ForegroundColor Green

# Run tests
npm test
Write-Host "✅ Tests passed" -ForegroundColor Green

Set-Location ..

# Setup Docker
if (-not $SkipDocker) {
    Write-Host "Setting up Docker..." -ForegroundColor Yellow
    Set-Location docker
    docker-compose build
    Write-Host "✅ Docker images built" -ForegroundColor Green
    Set-Location ..
}

# Setup Terraform
if (-not $SkipTerraform) {
    Write-Host "Setting up Terraform..." -ForegroundColor Yellow
    Set-Location terraform
    terraform fmt
    terraform init -backend=false
    terraform validate
    Write-Host "✅ Terraform configuration validated" -ForegroundColor Green
    Set-Location ..
}

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    @"
# Environment Configuration
NODE_ENV=development
PORT=3000

# AWS Configuration (for Terraform)
# AWS_REGION=us-west-2
# AWS_PROFILE=default

# Docker Configuration
DOCKER_BUILDKIT=1
COMPOSE_DOCKER_CLI_BUILD=1
"@ | Out-File -FilePath ".env" -Encoding utf8
    Write-Host "✅ .env file created" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review and configure .env file"
Write-Host "2. Run 'npm start' in the app directory to start the application"
Write-Host "3. Run 'docker-compose up' in the docker directory to run with Docker"
Write-Host "4. Configure AWS credentials for Terraform deployment"
Write-Host ""
Write-Host "Available scripts:" -ForegroundColor Cyan
Write-Host "- .\scripts\test.ps1       Run all tests"
Write-Host "- .\scripts\build.ps1      Build all components"
Write-Host "- .\scripts\deploy.ps1     Deploy to specified environment"