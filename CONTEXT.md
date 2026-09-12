# Context

Status: ACTIVE

## Project Identity

- Project: ChatGPT AWS Lab
- Primary Repository: `mytestlab123/chatgpt-aws`
- Authorized Related Repository: `amitkarpe/assignment-cicd` for the GitHub Actions/OIDC comparison path
- Context: PERSONAL
- Environment: LAB

## Current Truth

- ChatGPT has authenticated GitHub write access to both lab repositories.
- AWS Core MCP is authenticated and can execute AWS API calls under the current IAM identity.
- Direct MCP read tests passed across STS, EC2, S3, IAM, Lambda, CloudFormation, ECS, ECR, SSM, CloudWatch, DynamoDB, and Logs.
- Direct MCP mutation tests passed for temporary SSM and S3 lifecycles with cleanup verified.
- `amitkarpe/assignment-cicd` PR #1 proved GitHub Actions -> OIDC -> AWS and is merged.
- `amitkarpe/assignment-cicd` Issue #2 / PR #3 own the Terraform provisioning proof.

## Active Work

- Issue: #1
- Branch: `direction-b-direct-mcp`
- Current milestone: document direct MCP proof and compare it with GitHub OIDC + Terraform.

## Next Action

- Finish and validate Issue #1 documentation, then use the comparison to choose the default operating model for future AWS builds.
