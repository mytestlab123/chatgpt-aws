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
- AWS identity last verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Direct AWS MCP read/write proofs are complete, including temporary SSM/S3 lifecycles with cleanup.
- Historical `assignment-cicd` OIDC/Terraform proofs passed and are documented in `docs/EXPERIMENTS.md`.
- GitHub OIDC provider `token.actions.githubusercontent.com` exists in the personal AWS account.
- Primary repo-specific OIDC role `github-actions-chatgpt-aws-lab` is working for `mytestlab123/chatgpt-aws` PR/main workflows.
- Persistent Terraform state bucket `chatgpt-aws-tfstate-063884340510` is private, versioned, encrypted, and retained for this LAB.
- PR #6 deployed Terraform-managed SSM parameter `/chatgpt-aws/drift-demo`; main workflow `34675429394` passed and AWS MCP verified value `desired-v1`, version `1`.
- AWS MCP deliberately changed the parameter to `drifted-by-mcp`, version `2`.
- PR #7 workflow `34675498728` detected the drift with exact plan `0 to add, 1 to change, 0 to destroy`.
- CloudTrail exposed an ID-enriched GitHub WebIdentity principal during the initial OIDC trust failure; the reusable troubleshooting lesson is documented in `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`.

## Active Work

- Issue: #5 — persistent IaC + AWS MCP drift detection and repair
- PR: #7 — verify and reconcile AWS MCP drift
- Branch: `verify-drift-reconcile`
- Current milestone: merge the proven drift-detection change so the normal main-branch Terraform apply restores desired state, then independently verify final state through AWS Core MCP.

## Next Action

1. Merge PR #7 after its drift plan and documentation are reviewable.
2. Wait for the main-branch Terraform apply.
3. Verify `/chatgpt-aws/drift-demo` is restored to `desired-v1` through AWS Core MCP.
4. Record final evidence and close Issue #5.
5. Next milestone: test MCP-specific IAM controls or consume this knowledge from the separate `lab1_agent` ChatGPT session.
