# Context

Status: ACTIVE

## Project Identity

- Project: ChatGPT AWS Lab
- Primary Repository: `mytestlab123/chatgpt-aws`
- Authorized Related Repositories:
  - `amitkarpe/assignment-cicd` for historical GitHub Actions/OIDC proofs
  - `mytestlab123/lab1_agent` for cross-session knowledge reuse and future project-specific AWS experiments
- Context: PERSONAL
- Environment: LAB

## Current Truth

- `mytestlab123/chatgpt-aws` is private and active.
- `mytestlab123/lab1_agent` is private and unarchived.
- ChatGPT has authenticated GitHub write access to both lab repositories.
- AWS Core MCP is authenticated and can execute AWS API calls under the current IAM identity.
- AWS identity verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Direct AWS MCP read/write proofs and the persistent Terraform drift/reconciliation milestone are complete.
- GitHub OIDC provider `token.actions.githubusercontent.com` exists in the personal AWS account.
- Repo-specific OIDC role `github-actions-chatgpt-aws-lab` is working for PR/main workflows.
- Persistent Terraform state bucket `chatgpt-aws-tfstate-063884340510` is retained.
- Issue #5 is closed; final `/chatgpt-aws/drift-demo` state is `desired-v1`, version `3`.
- Issue #9 is the active multi-service automation + CI/CD milestone.
- The GitHub OIDC role policy was expanded only for Issue #9 lab resources/services.
- The `devsecops` user has a narrow inline deny named `ChatGPTAwsMCPGuard` that denies `s3:DeleteObject` on the retained governance fixture only when `aws:ViaAWSMCPService=true`.
- Official AWS documentation confirms `aws:ViaAWSMCPService` is Boolean and `aws:CalledViaAWSMCP` identifies the specific managed MCP service principal.

## Active Work

- Issue: #9 — Automation + CI/CD AWS service matrix lab
- Branch: `issue-9-automation-cicd-lab`
- PR: `<pending>`
- Current package:
  1. ECR container build/push/verify/delete through GitHub Actions OIDC.
  2. S3 -> Lambda -> DynamoDB automation proof.
  3. EventBridge -> Lambda -> DynamoDB automation proof.
  4. MCP-specific S3 delete deny + non-MCP OIDC delete proof.
  5. Durable evidence and a self-contained HTML learning page for Amit.

## Next Action

1. Open the Issue #9 PR and let the PR workflow validate Terraform formatting, validation, and plan.
2. Fix only real validation/permission failures inside the same PR.
3. Merge after a clean plan; main workflow then applies infrastructure and runs ECR + automation smoke tests.
4. Use AWS Core MCP for independent readback and the protected-object delete-deny proof.
5. Update Markdown/HTML with actual run IDs and results, then close Issue #9 when acceptance is fully proven.
