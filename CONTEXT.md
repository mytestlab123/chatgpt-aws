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
- Issue #21 deterministic Step Functions + SQS OIDC/MCP milestone is VERIFIED / PASS.
- Documentation site is live at `https://d36j5fck6lkl41.cloudfront.net/` and Terraform-owned in `infra/docs-site/`.

## Control-path decision

The preferred long-term model is:

- **AWS Core MCP** for fastest discovery, troubleshooting, live readback, independent verification, and bounded reversible experiments.
- **Git + Terraform/IaC + GitHub Actions + OIDC** for durable deterministic infrastructure and deployment.
- Preferred hybrid loop: **MCP discover/diagnose -> Git/IaC declare -> OIDC CI/CD apply -> MCP independently verify**.
- MCP-specific IAM denies are deliberate governance tests, not a limitation of AWS Core MCP. When IAM permits it, MCP mutations are technically possible.

Detailed guidance: `docs/CONTROL_PATHS.md`.

## Completed Work — Issue #21

PR #22 implemented Terraform-owned Step Functions + SQS and a dedicated runtime OIDC role.

- PR plan workflow `34687644771`: **PASS** — `6 to add, 0 to change, 0 to destroy`.
- main workflow `34687707682`, attempt 3: **PASS**.
- GitHub OIDC execution `gh-34687707682-3`: `SUCCEEDED`.
- AWS Core independently verified `TaskSucceeded`, `ExecutionSucceeded`, IAM trust/policies, and final SQS cleanup.
- `ChatGPTAwsMCPSfnGuard` now denies only MCP-routed `states:StartExecution` for the named lab state machine after IAM propagation.

Detailed evidence: `docs/SFN_SQS_OIDC_MCP_LAB.md`.

## Active Work — Issue #24

Goal: make the deterministic GitHub/OIDC delivery path faster and less noisy by scoping each automatic AWS lab workflow to the files that can actually change its behavior.

Implementation rule:

- Automation CI/CD lab -> its workflow + `infra/automation-cicd/**`;
- Terraform drift demo -> its workflow + `infra/drift-demo/**`;
- Step Functions + SQS lab -> its workflow + `infra/sfn-sqs/**`;
- dedicated CodeBuild smoke -> its workflow only;
- documentation changes -> documentation workflows;
- `workflow_dispatch` remains available for deliberate regression runs.

No new AWS resources are required for Issue #24.

Detailed design/evidence: `docs/WORKFLOW_ROUTING.md`.

## Next Action

1. Validate and merge the Issue #24 routing implementation PR.
2. Create a docs-only proof PR after merge.
3. Confirm only documentation workflows are automatically created for that proof commit.
4. Record the run IDs/evidence in `docs/WORKFLOW_ROUTING.md` and close Issue #24.
