# CI/CD Pipeline Examples

A comprehensive demonstration of modern CI/CD pipelines using GitHub Actions, featuring containerized applications, Infrastructure as Code (Terraform), multi-environment deployments, and security best practices.

## 🏗️ Project Structure

```
cicd-pipeline-examples/
├── .github/
│   └── workflows/          # GitHub Actions workflows
│       ├── ci.yml         # Basic CI pipeline
│       ├── docker.yml     # Docker build and push
│       ├── terraform.yml  # Infrastructure deployment
│       ├── deploy.yml     # Multi-environment deployment
│       └── security.yml   # Security scanning
├── app/                   # Sample Node.js application
│   ├── package.json
│   ├── server.js
│   └── jest.config.js
├── terraform/             # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── docker/                # Container configuration
│   ├── Dockerfile
│   └── docker-compose.yml
├── scripts/               # Automation scripts
│   └── setup.ps1
└── tests/                 # Test files
    └── app.test.js
```

## 🚀 Features

### CI/CD Pipelines
- **Continuous Integration**: Automated testing, linting, and security scanning
- **Docker Integration**: Container building, scanning, and registry pushing
- **Infrastructure as Code**: Terraform validation, planning, and deployment
- **Multi-Environment Deployment**: Dev, staging, and production workflows
- **Security Scanning**: Comprehensive security checks and compliance

### Application Stack
- **Node.js/Express**: RESTful API with health checks
- **Docker**: Containerized deployment with security best practices
- **AWS Infrastructure**: VPC, subnets, security groups via Terraform
- **Testing**: Jest unit tests with coverage reporting

### Security Features
- **Secret Scanning**: TruffleHog and GitLeaks integration
- **Code Analysis**: CodeQL static analysis
- **Dependency Scanning**: npm audit, Snyk, OWASP checks
- **Infrastructure Security**: Checkov and tfsec scanning
- **Container Security**: Trivy and Hadolint scanning

## 📋 Prerequisites

- **Node.js** 18.x or higher
- **Git** for version control
- **Docker** for containerization
- **Terraform** 1.0+ for infrastructure
- **AWS CLI** configured (for deployment)
- **GitHub account** with Actions enabled

## 🛠️ Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd cicd-pipeline-examples

# Run setup script (Windows)
.\scripts\setup.ps1

# Or manual setup
cd app && npm install && cd ..
```

### 2. Run Locally

```bash
# Start the application
cd app
npm start

# Run tests
npm test

# Run with Docker
cd docker
docker-compose up
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
cd terraform
terraform init
terraform plan
terraform apply
```

## 🔄 CI/CD Workflows

### Basic CI Pipeline (`ci.yml`)
- **Triggers**: Push to main/develop, PRs to main
- **Jobs**: Test (multiple Node versions), Security scan, Build
- **Features**: Matrix builds, test coverage, artifact upload

### Docker Pipeline (`docker.yml`)
- **Triggers**: Push to main, version tags, PRs
- **Jobs**: Multi-arch builds, vulnerability scanning, registry push
- **Features**: Buildx, caching, security scanning (Trivy, Docker Scout)

### Terraform Pipeline (`terraform.yml`)
- **Triggers**: Changes to terraform files
- **Jobs**: Validate, Plan (PR), Apply (main), Production deploy
- **Features**: Multi-environment, PR comments, security scanning

### Deployment Pipeline (`deploy.yml`)
- **Triggers**: Push to main, manual dispatch
- **Jobs**: Test, build, multi-environment deploy, notifications
- **Features**: Environment matrices, health checks, rollback capabilities

### Security Pipeline (`security.yml`)
- **Triggers**: Push, PRs, scheduled weekly scans
- **Jobs**: Secret, code, dependency, infrastructure, container scanning
- **Features**: SARIF uploads, compliance checks, security reporting

## 🌍 Multi-Environment Setup

### Environment Configuration

| Environment | Branch | Approval | URL |
|-------------|--------|----------|-----|
| Development | `develop` | None | `https://dev.example.com` |
| Staging | `main` | None | `https://staging.example.com` |
| Production | `main` | Required | `https://production.example.com` |

### Required Secrets

```bash
# AWS Configuration
AWS_ROLE_ARN                 # IAM role for OIDC
TF_STATE_BUCKET             # S3 bucket for Terraform state
TF_STATE_LOCK_TABLE         # DynamoDB table for state locking

# Security Tools
SNYK_TOKEN                  # Snyk API token

# Optional Integrations
SLACK_WEBHOOK_URL          # Slack notifications
TEAMS_WEBHOOK_URL          # Teams notifications
```

## 🔒 Security Best Practices

### Implemented Security Measures

1. **Secrets Management**
   - GitHub Secrets for sensitive data
   - OIDC for AWS authentication (no long-lived keys)
   - Environment-specific secret scoping

2. **Container Security**
   - Non-root user execution
   - Minimal base images (Alpine Linux)
   - Health checks and proper signal handling
   - Multi-stage builds for smaller attack surface

3. **Infrastructure Security**
   - Infrastructure as Code with validation
   - Security group restrictions
   - Encrypted state storage
   - Resource tagging for compliance

4. **Pipeline Security**
   - Branch protection rules
   - Required reviews for production
   - Automated security scanning
   - SARIF integration with GitHub Security

### Security Scanning Tools

- **TruffleHog**: Secret detection in commits
- **GitLeaks**: Secret detection in repositories
- **CodeQL**: Static application security testing
- **Snyk**: Dependency vulnerability scanning
- **OWASP Dependency Check**: Open source vulnerability database
- **Checkov**: Infrastructure as Code security scanning
- **tfsec**: Terraform-specific security scanning
- **Trivy**: Container vulnerability scanning
- **Hadolint**: Dockerfile best practices

## 📊 Monitoring and Observability

### Application Monitoring
- Health check endpoints (`/health`)
- Application metrics and logging
- Container health checks
- Resource usage monitoring

### Pipeline Monitoring
- Build status badges
- Test coverage reporting
- Security scan results
- Deployment notifications

## 🔧 Customization

### Adding New Environments

1. Update environment matrix in workflows
2. Create environment-specific secrets
3. Configure AWS resources per environment
4. Update health check URLs

### Adding New Services

1. Create service directory structure
2. Add Dockerfile and docker-compose configuration
3. Update CI/CD workflows
4. Add Terraform resources

### Integrating Additional Tools

1. Add workflow steps for new tools
2. Configure tool-specific secrets
3. Update security reporting
4. Add documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Development Workflow

```bash
# Create feature branch
git checkout -b feature/new-pipeline

# Make changes and test
.\scripts\setup.ps1
npm test

# Commit and push
git add .
git commit -m "Add new pipeline feature"
git push origin feature/new-pipeline
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

## 🐛 Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Node.js version compatibility
   - Verify dependencies are installed
   - Review test failures in CI logs

2. **Docker Issues**
   - Ensure Docker is running
   - Check Dockerfile syntax
   - Verify base image availability

3. **Terraform Issues**
   - Validate AWS credentials
   - Check resource permissions
   - Review Terraform state conflicts

4. **Deployment Failures**
   - Verify environment secrets
   - Check AWS resource limits
   - Review health check endpoints

### Getting Help

- Open an issue for bugs or questions
- Check the GitHub Actions logs for detailed error messages
- Review the security tab for vulnerability reports

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for demonstrating modern DevOps practices**