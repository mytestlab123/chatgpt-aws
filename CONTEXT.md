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
- PR #7 merged; main workflow `34675632976` applied successfully and provider readback passed.
- Independent AWS Core MCP final verification confirmed `/chatgpt-aws/drift-demo` is restored to `desired-v1`, version `3`.
- CloudTrail exposed an ID-enriched GitHub WebIdentity principal during the initial OIDC trust failure; the reusable troubleshooting lesson is documented in `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`.
- Full drift/reconciliation evidence is in `docs/DRIFT_DEMO.md`.

## Active Work

- Issue: #5 — ready to close after final evidence commit/PR.
- Current milestone: persistent IaC + AWS MCP drift detection and repair is **PASS**.

## Next Action

1. Merge the final evidence update and close Issue #5.
2. Next preferred milestone: test MCP-specific IAM controls using `aws:ViaAWSMCPService` / `aws:CalledViaAWSMCP`.
3. In parallel or afterward, let the separate `lab1_agent` ChatGPT session consume this private knowledge and create its own repo-specific OIDC role only when its project milestone requires AWS deployment.
