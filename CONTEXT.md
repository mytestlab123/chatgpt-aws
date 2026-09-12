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
- Issue #24 selective GitHub Actions workflow routing is VERIFIED / PASS.
- Documentation site is live at `https://d36j5fck6lkl41.cloudfront.net/` and Terraform-owned in `infra/docs-site/`.

## Control-path decision

The preferred long-term model is:

- **AWS Core MCP** for fastest discovery, troubleshooting, live readback, independent verification, and bounded reversible experiments.
- **Git + Terraform/IaC + GitHub Actions + OIDC** for durable deterministic infrastructure and deployment.
- Preferred hybrid loop: **MCP discover/diagnose -> Git/IaC declare -> OIDC CI/CD apply -> MCP independently verify**.
- MCP-specific IAM denies are deliberate governance tests, not a limitation of AWS Core MCP. When IAM permits it, MCP mutations are technically possible.
- Automatic GitHub Actions should be scoped to executable inputs; `workflow_dispatch` remains available for deliberate regression.

Detailed guidance: `docs/CONTROL_PATHS.md` and `docs/WORKFLOW_ROUTING.md`.

## Completed Work — Issue #21

PR #22 implemented Terraform-owned Step Functions + SQS and a dedicated runtime OIDC role.

- PR plan workflow `34687644771`: **PASS** — `6 to add, 0 to change, 0 to destroy`.
- main workflow `34687707682`, attempt 3: **PASS**.
- GitHub OIDC execution `gh-34687707682-3`: `SUCCEEDED`.
- AWS Core independently verified `TaskSucceeded`, `ExecutionSucceeded`, IAM trust/policies, and final SQS cleanup.
- `ChatGPTAwsMCPSfnGuard` denies only MCP-routed `states:StartExecution` for the named lab state machine after IAM propagation.

Detailed evidence: `docs/SFN_SQS_OIDC_MCP_LAB.md`.

## Completed Work — Issue #24

PR #25 scoped AWS lab workflow triggers to executable inputs and retained `workflow_dispatch` for explicit regression.

- PR #25 merged as `6d9be8e5735fa2e369939b5b51f64b9a9e853b53`.
- All six expected implementation-PR workflows passed, including the four changed AWS lab workflows and both docs workflows.
- PR #26 then changed only `docs/WORKFLOW_ROUTING.md` as the isolation probe.
- Probe commit `d7bf72a0c19c474357458b45693c3532b0cb7004` created exactly two automatic runs: Docs build validation `34690145584` and Docs AWS site `34690145541`; both passed.
- No Automation CI/CD, CodeBuild, Step Functions/SQS, or drift-demo run was created for that docs-only probe commit.
- PR #26 merged as `856cd25e3071483056513f3738d089f14bca4647`; the merge push also created exactly two workflows, both documentation workflows.

No new AWS resources were introduced by Issue #24.

Detailed evidence: `docs/WORKFLOW_ROUTING.md`.

## Active Work

No AWS mutation milestone is currently open after Issue #24 closeout. A future AWS architecture/mutation goal should have a new owning Issue or explicit current instruction.

## Next Action

- Reuse the stable hybrid model and selective workflow routing from future sessions/repos rather than repeating connectivity or unrelated regression work.
- Add another AWS service only when it teaches a genuinely new automation, governance, or deterministic-delivery lesson.
