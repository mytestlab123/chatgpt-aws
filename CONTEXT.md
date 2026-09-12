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
- Issue #18 dedicated OIDC + MCP CodeBuild control-plane milestone is VERIFIED / PASS; detailed evidence is in `docs/OIDC_MCP_CODEBUILD_LAB.md`.

### Issue #18 verified control split

Retained resources:

- GitHub OIDC role: `github-actions-chatgpt-aws-codebuild-lab`.
- CodeBuild project: `chatgpt-aws-oidc-mcp-smoke`.
- CodeBuild service role: `chatgpt-aws-codebuild-smoke`.
- CloudWatch log group: `/aws/codebuild/chatgpt-aws-oidc-mcp-smoke`, one-day retention.
- MCP-specific guard: `ChatGPTAwsMCPCodeBuildGuard` on `devsecops`.

Verified behavior:

- GitHub OIDC PR workflow `34685896954`: PASS.
- Follow-up PR workflow `34685971536`: PASS.
- PR #19 merged at `0849745c54404d65cb98906282e8d5a111380621`.
- Main workflow `34686033076`: PASS.
- Latest CodeBuild build `chatgpt-aws-oidc-mcp-smoke:7a4529bf-0248-4157-a0d6-6adef2881b6f`: `SUCCEEDED`.
- AWS Core MCP independently read the project/build/logs and found 52 latest-build log events with `OIDC-CODEBUILD-PASS` and a successful BUILD phase.
- A fresh AWS Core MCP `StartBuild` attempt remained explicitly denied by `aws:ViaAWSMCPService=true` while the GitHub OIDC path remained allowed.
- The OIDC execution role is limited to start/read operations for the single dedicated CodeBuild project.
- The CodeBuild service role trust includes `codebuild.amazonaws.com`, `aws:SourceAccount`, and the exact project ARN.

### Documentation site

- Material for MkDocs is the documentation generator.
- Live documentation URL: `https://d36j5fck6lkl41.cloudfront.net/`.
- Docs hosting is Terraform-owned in `infra/docs-site/` and deployed by `.github/workflows/docs-aws.yml`.
- Private origin bucket: `chatgpt-aws-docs-063884340510`.
- CloudFront distribution: `E2M7VGXRFDXI7H` / `d36j5fck6lkl41.cloudfront.net`.
- Hosting details are documented in `docs/HOSTING.md`.

## Active Work

- Issue #18 final evidence/documentation PR only. The AWS and GitHub execution proof itself is complete.

## Next Action

1. Merge the final Issue #18 evidence PR after docs/CI checks pass.
2. Close Issue #18 as completed.
3. Keep the dedicated OIDC/CodeBuild/MCP resources for the next governance/automation experiment.
4. Next useful direction: add another execution target or approval boundary while keeping the same pattern — GitHub OIDC executes, MCP observes/diagnoses, selected MCP mutations are denied.
