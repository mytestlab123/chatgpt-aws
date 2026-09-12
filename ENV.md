# Environment

Status: READY

## Runtime

- Runtime: mixed ChatGPT tools + GitHub Actions + AWS
- Primary interaction: ChatGPT web chat

## Development Tools

- GitHub connected app: required
- AWS Core MCP: required for direct path
- GitHub Actions: required for GitOps path
- Terraform: required only for GitOps/IaC proof
- Docker: not required for current milestone

## Cloud

- Provider: AWS
- Region: `ap-southeast-1` for lab resource proofs
- Account/environment alias: personal LAB
- AWS authentication for direct path: AWS Core MCP OAuth/IAM session
- AWS authentication for GitHub path: GitHub Actions OIDC -> dedicated IAM role

## External Dependencies

- AWS managed MCP Server / AWS Core app
- GitHub Actions
- HashiCorp Terraform provider for AWS

## Credentials And Secrets

No static AWS credentials are required for the proven OIDC path. Never commit credentials, tokens, private keys, or authentication state.
