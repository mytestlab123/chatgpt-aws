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

PR #22:

`https://github.com/mytestlab123/chatgpt-aws/pull/22`

PR plan workflow `34687644771`: **PASS**  
Terraform plan: `6 to add, 0 to change, 0 to destroy`.

PR #22 squash merge:

`e7a4172d6a8148513f379d9780f8b2569d72e504`

Main workflow `34687707682`, attempt 3: **PASS**.

Retained Terraform-owned resources:

- SQS queue `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions state machine `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions service role `chatgpt-aws-sfn-sqs-smoke`;
- dedicated GitHub runtime role `github-actions-chatgpt-aws-sfn-lab`;
- Terraform state `state/chatgpt-aws/sfn-sqs.tfstate`.

GitHub OIDC execution:

`arn:aws:states:ap-southeast-1:063884340510:execution:chatgpt-aws-sfn-sqs-smoke:gh-34687707682-3`

Final status: `SUCCEEDED`.

AWS Core MCP independently verified `TaskSucceeded`, `ExecutionSucceeded`, runtime/service IAM trust and policies, and final SQS message counts of zero after workflow cleanup.

The PERSONAL/LAB AWS Core identity now has narrow policy `ChatGPTAwsMCPSfnGuard`, denying only `states:StartExecution` for this named state machine when `aws:ViaAWSMCPService=true`.

A first immediate test after `PutUserPolicy` was still allowed because IAM propagation had not completed; its one test message was cleaned up. After a short wait, the same MCP `StartExecution` returned explicit `AccessDenied`, and the queue remained empty.

Terraform least-privilege lessons from the first two main attempts:

- `states:ValidateStateMachineDefinition` is needed by the provider before create/update;
- `states:ListStateMachineVersions` is needed by provider refresh/readback.

Detailed evidence: `docs/SFN_SQS_OIDC_MCP_LAB.md`.

## Active Work

- Issue #21 final evidence/documentation PR only; no new AWS architecture change is required.

## Next Action

1. Merge the Issue #21 final evidence PR after checks pass.
2. Confirm the Material docs deploy and the new control-path/lab pages are live.
3. Close Issue #21 as completed.
4. For the next AWS milestone, continue the hybrid model rather than repeating connectivity proofs.
