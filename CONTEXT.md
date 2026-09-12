# Context

Status: ACTIVE

## Project Identity

- Project: ChatGPT AWS Lab
- Primary Repository: `mytestlab123/chatgpt-aws`
- Authorized Related Repositories:
  - `amitkarpe/assignment-cicd` for historical GitHub Actions/OIDC proofs
  - `mytestlab123/lab1_agent` is **public and independent**; do not use it as an execution dependency for this repository
- Context: PERSONAL
- Environment: LAB

## Current Truth

- `mytestlab123/chatgpt-aws` is private and active.
- `mytestlab123/lab1_agent` is public, unarchived, and independent.
- AWS identity verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Existing repo-specific GitHub OIDC role `github-actions-chatgpt-aws-lab` remains the Terraform/infrastructure deployment identity.
- Persistent Terraform state bucket `chatgpt-aws-tfstate-063884340510` is retained.
- Issue #5 drift/reconciliation milestone is VERIFIED / PASS.
- Issue #9 multi-service automation + CI/CD milestone is VERIFIED / PASS.
- Issue #18 dedicated OIDC + MCP CodeBuild control-plane milestone is VERIFIED / PASS.
- Documentation site is live at `https://d36j5fck6lkl41.cloudfront.net/` and Terraform-owned in `infra/docs-site/`.

## Control-path decision

The preferred long-term model is now explicit:

- **AWS Core MCP** for fastest discovery, troubleshooting, live readback, independent verification, and bounded reversible experiments.
- **Git + Terraform/IaC + GitHub Actions + OIDC** for durable deterministic infrastructure and deployment.
- Use the hybrid loop: MCP discovers/verifies; Git/IaC declares; OIDC CI/CD applies; MCP verifies reality again.
- MCP-specific IAM denies are deliberate governance tests, not a limitation of AWS Core MCP. When IAM permits it, MCP mutations are technically possible.

Detailed guidance: `docs/CONTROL_PATHS.md`.

## Active Work — Issue #21

Goal: prove the hybrid recommendation with Terraform-owned Step Functions + SQS and a dedicated runtime OIDC role.

Planned durable resources:

- SQS queue `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions state machine `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions service role `chatgpt-aws-sfn-sqs-smoke`;
- dedicated GitHub runtime role `github-actions-chatgpt-aws-sfn-lab`.

Execution model:

- existing `github-actions-chatgpt-aws-lab` -> Terraform plan/apply;
- dedicated `github-actions-chatgpt-aws-sfn-lab` -> StartExecution + execution readback + SQS verification/cleanup;
- AWS Core MCP -> independent read/diagnose/verify;
- AWS Core MCP `states:StartExecution` -> deliberately denied only for this lab through `aws:ViaAWSMCPService=true` after the state machine is deployed.

The primary Terraform role was extended only for the named queue/state machine and the two named IAM roles needed by Issue #21.

## Next Action

1. Validate the Issue #21 Terraform plan in PR.
2. Merge after plan/docs checks pass.
3. Apply on `main` through the existing Terraform OIDC role.
4. Run the dedicated Step Functions execution OIDC smoke test and verify the SQS marker/cleanup.
5. Install the narrow MCP StartExecution guard, then prove MCP read/diagnose remains allowed while direct MCP StartExecution is denied.
6. Write final execution IDs/evidence back to Git and close Issue #21.
