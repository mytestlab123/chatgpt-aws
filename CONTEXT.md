# Context

Status: ACTIVE

## Project Identity

- Project: ChatGPT AWS Lab
- Primary Repository: `mytestlab123/chatgpt-aws`
- Authorized Related Repositories:
  - `amitkarpe/assignment-cicd` for historical GitHub Actions/OIDC proofs
  - `mytestlab123/lab1_agent` is now **public and independent**; do not use it as an execution dependency for this repository
- Context: PERSONAL
- Environment: LAB

## Current Truth

- `mytestlab123/chatgpt-aws` is private and active.
- `mytestlab123/lab1_agent` is public, unarchived, and independent.
- AWS identity verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Existing repo-specific GitHub OIDC role `github-actions-chatgpt-aws-lab` remains available for the earlier Terraform/automation/docs labs.
- Persistent Terraform state bucket `chatgpt-aws-tfstate-063884340510` is retained.
- Issue #5 drift/reconciliation milestone is complete; `/chatgpt-aws/drift-demo` remains Terraform-owned.
- Issue #9 multi-service automation + CI/CD milestone is VERIFIED / PASS; detailed evidence is in `docs/AUTOMATION_CICD_LAB.md`.
- ECR repository `chatgpt-aws-cicd-lab` is retained and normally empty after smoke tests.
- S3 bucket `chatgpt-aws-automation-063884340510` is private and retains the MCP governance fixture.
- DynamoDB `chatgpt-aws-automation-events`, Lambda `chatgpt-aws-automation-recorder`, EventBridge rule, and CloudWatch log group are retained as the automation lab.
- `devsecops` has narrow MCP-specific protection for the retained S3 fixture using `aws:ViaAWSMCPService=true`.

### Documentation site

- Material for MkDocs is the documentation generator.
- Live documentation URL: `https://d36j5fck6lkl41.cloudfront.net/`.
- Docs hosting is Terraform-owned in `infra/docs-site/` and deployed by `.github/workflows/docs-aws.yml`.
- Private origin bucket: `chatgpt-aws-docs-063884340510`.
- CloudFront distribution: `E2M7VGXRFDXI7H` / `d36j5fck6lkl41.cloudfront.net`.
- CloudFront OAC: `E10YPJ26EF3Z3U` / `chatgpt-aws-docs-oac`.
- Hosting details and the GitHub Pages 404 lesson are documented in `docs/HOSTING.md`.

### Issue #18 dedicated OIDC + MCP CodeBuild lab

AWS Core MCP has created and read back the dedicated lab control plane:

- GitHub OIDC role: `github-actions-chatgpt-aws-codebuild-lab`.
- Trust is limited to `mytestlab123/chatgpt-aws` PR/main subjects and the existing GitHub OIDC provider.
- OIDC role permission is limited to starting/reading `chatgpt-aws-oidc-mcp-smoke`.
- CodeBuild project: `chatgpt-aws-oidc-mcp-smoke` (`NO_SOURCE`, `NO_ARTIFACTS`, `BUILD_GENERAL1_SMALL`).
- CodeBuild service role: `chatgpt-aws-codebuild-smoke`, restricted with `aws:SourceAccount` and the exact project ARN.
- CloudWatch log group: `/aws/codebuild/chatgpt-aws-oidc-mcp-smoke`, one-day retention.
- `devsecops` inline policy `ChatGPTAwsMCPCodeBuildGuard` explicitly denies only `codebuild:StartBuild` for this project when `aws:ViaAWSMCPService=true`.
- AWS Core MCP can read the project but its direct `StartBuild` test returned `AccessDenied` as designed.
- First project-creation attempt immediately after service-role creation hit `CodeBuild is not authorized to perform: sts:AssumeRole`; after IAM propagation/retry, project creation succeeded.

## Active Work

- Issue #18: prove the dedicated GitHub OIDC role can start the CodeBuild smoke job, then use AWS Core MCP independently to verify the successful build/log evidence while keeping MCP `StartBuild` denied.

## Next Action

1. Run PR validation for `.github/workflows/codebuild-oidc-mcp-lab.yml`.
2. Confirm the workflow assumes `github-actions-chatgpt-aws-codebuild-lab` and CodeBuild reaches `SUCCEEDED`.
3. Use AWS Core MCP to verify the latest build and CloudWatch log evidence.
4. Merge the Issue #18 PR, run the main workflow once, update durable evidence, and close Issue #18 when acceptance passes.
