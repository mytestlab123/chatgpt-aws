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
- AWS identity verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Repo-specific GitHub OIDC role `github-actions-chatgpt-aws-lab` is working for PR/main workflows without static AWS keys.
- Persistent Terraform state bucket `chatgpt-aws-tfstate-063884340510` is retained.
- Issue #5 drift/reconciliation milestone is complete; `/chatgpt-aws/drift-demo` remains `desired-v1`, version `3` at last verification.
- Issue #9 multi-service automation + CI/CD milestone is **VERIFIED / PASS**.
- PR #10 merged at `0a5036045863cfc243718f512e8d3fc837affc6a`.
- Successful PR validation run: `34676895495`, initial plan `15 to add, 0 to change, 0 to destroy`.
- Successful main run: `34676955227`, attempt 3.
- Main smoke tests passed for ECR, S3 -> Lambda -> DynamoDB, EventBridge -> Lambda -> DynamoDB, non-MCP OIDC S3 cleanup, and provider readback.
- AWS Core independently verified the retained automation stack and cleanup state.
- ECR repository `chatgpt-aws-cicd-lab` is retained and empty.
- S3 bucket `chatgpt-aws-automation-063884340510` is private/AES256 and retains only `mcp-guard/protected.txt`.
- DynamoDB `chatgpt-aws-automation-events` is ACTIVE/PAY_PER_REQUEST and empty after smoke-test cleanup.
- Lambda `chatgpt-aws-automation-recorder` is Active, Python 3.12, 128 MB, 10-second timeout.
- EventBridge rule `chatgpt-aws-automation-events` is ENABLED and targets the recorder Lambda.
- CloudWatch log group has 1-day retention.
- `devsecops` has narrow inline deny `ChatGPTAwsMCPGuard` for deleting only the retained protected fixture when `aws:ViaAWSMCPService=true`.
- AWS Core MCP delete of the fixture returned explicit `AccessDenied`; HeadObject before/after proved the fixture remained unchanged.
- Full technical evidence: `docs/AUTOMATION_CICD_LAB.md`.
- Educational view for Amit: `docs/AMIT_AUTOMATION_CICD_LAB.html`.

## Active Work

- Final evidence PR for Issue #9: branch `issue-9-final-evidence`.
- Goal: prove steady-state Terraform plan is clean, merge the evidence, run one final repeatable main smoke test, then close Issue #9.

## Next Action

1. Open the final evidence PR and confirm the automation Terraform PR plan reports no changes.
2. Merge the evidence PR after checks pass.
3. Confirm the final main automation workflow passes again.
4. Perform one final AWS Core readback of the retained governance fixture/empty ECR/DynamoDB cleanup state.
5. Close Issue #9.
6. Next useful consumer milestone: let the separate `lab1_agent` ChatGPT session reuse these patterns instead of repeating connectivity experiments.
