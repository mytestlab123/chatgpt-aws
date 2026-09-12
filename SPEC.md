# Specification

Status: ACTIVE
Context: PERSONAL
Environment: LAB

## Objective

Prove, compare, and document practical ways for ChatGPT to control a personal AWS account while preserving durable Git/IaC knowledge for other ChatGPT sessions.

## Outcome

A verified hybrid operating model:

1. direct ChatGPT -> AWS Core MCP -> AWS API operations;
2. ChatGPT/GitHub -> GitHub Actions -> OIDC -> Terraform/AWS services;
3. AWS MCP independent verification and bounded live operations;
4. Terraform detection/reconciliation when a managed resource drifts;
5. reusable automation and CI/CD patterns across several AWS services;
6. MCP-origin-specific IAM controls for selected destructive or execution actions;
7. selective GitHub Actions routing so deterministic delivery does not execute unrelated AWS labs.

## Authorized

When an owning Issue/current user instruction is active, ChatGPT may perform bounded PERSONAL/LAB work using low-cost AWS resources; create/update GitHub Issues, branches, PRs, workflows and documentation; create/update lab-only IAM roles/policies and Terraform state required by the approved experiment; validate results; and clean up temporary resources without repeated resource-by-resource approval.

Issue #24 is complete. New AWS architecture/mutation beyond maintaining the retained labs should have a new owning Issue or current explicit user instruction.

`mytestlab123/lab1_agent` is public and independent. This repository must not depend on it for execution, OIDC trust, or AWS state.

## MUST

- Record which execution path performed each experiment.
- Verify every AWS mutation with provider/API readback.
- Keep durable infrastructure under IaC when reproducibility matters.
- Prefer GitHub OIDC over static AWS access keys for CI/CD.
- Use repo-specific/purpose-specific OIDC trust and permissions unless reuse is explicitly reviewed.
- Use CloudTrail/provider evidence to diagnose federation failures before widening trust.
- Treat IAM policy changes as eventually consistent; re-read/retry before declaring a new allow/deny control proven.
- Clean up temporary proof resources unless explicitly retained.
- Explicitly document retained persistent LAB resources.
- Write reusable learning back to Git for other ChatGPT sessions.
- Route automatic GitHub Actions by executable inputs when a narrower trigger is sufficient; retain `workflow_dispatch` for deliberate regression runs.

## MUST NOT

- Enter work, corporate, non-personal, or production AWS environments.
- Commit credentials, OAuth tokens, access keys, private keys, or authentication state.
- Create public application endpoints, databases with real data, or intentionally expensive resources without a new explicit milestone.
- Leave temporary experiment resources running without documenting why.
- Treat direct MCP mutation as a silent replacement for Terraform/CloudFormation/CDK when durable desired state matters.
- Start unrelated AWS lab workflows automatically merely because a generic documentation/control file changed when that file is not an executable input to the lab.

## Control-Path Rule

Both execution methods are technically valid when IAM allows them.

Preferred use:

- **AWS Core MCP** = fastest inspect, troubleshoot, compare, verify, and bounded/reversible operations.
- **Git + IaC + GitHub Actions + OIDC** = long-term deterministic infrastructure and deployment.

Preferred durable loop:

`MCP discover/diagnose -> Git/IaC declare -> OIDC CI/CD apply -> MCP independently verify`

MCP-specific explicit denies used by these labs are deliberate governance experiments. They prove that an organization can allow an AI/MCP path to inspect/diagnose while reserving selected execution/deployment actions for a CI/CD identity. They do not mean AWS Core MCP is inherently unable to mutate those services.

Detailed education: `docs/CONTROL_PATHS.md`.

## Completed Milestone — Issue #5

Proven end-to-end:

`ChatGPT -> GitHub/Terraform -> Actions/OIDC -> AWS -> AWS MCP verify -> harmless direct drift -> Terraform detects/repairs -> AWS MCP final verify`

Detailed evidence: `docs/DRIFT_DEMO.md`.

## Completed Milestone — Issue #9

Proven ECR CI/CD, S3/EventBridge -> Lambda -> DynamoDB automation, MCP-specific S3 governance, and independent MCP readback.

Detailed evidence: `docs/AUTOMATION_CICD_LAB.md`.

## Completed Milestone — Issue #18

Proven control split:

`GitHub Actions -> dedicated repo OIDC role -> CodeBuild StartBuild = ALLOW`

`AWS Core MCP -> CodeBuild read/diagnose = ALLOW`

`AWS Core MCP -> CodeBuild StartBuild = DENY when aws:ViaAWSMCPService=true`

Detailed evidence: `docs/OIDC_MCP_CODEBUILD_LAB.md`.

## Completed Milestone — Issue #21

Proven durable-state path:

`Git/Terraform -> infrastructure OIDC role -> Step Functions + SQS durable state = PASS`

Proven runtime path:

`GitHub Actions -> dedicated runtime OIDC role -> Step Functions StartExecution -> SQS marker/cleanup = PASS`

Proven independent MCP path:

`AWS Core MCP -> state machine / execution / IAM / SQS readback = PASS`

Proven governance path after IAM propagation:

`AWS Core MCP -> Step Functions StartExecution = DENY when aws:ViaAWSMCPService=true`

Detailed evidence: `docs/SFN_SQS_OIDC_MCP_LAB.md`.

## Completed Milestone — Issue #24

Goal: reduce unnecessary GitHub Actions/AWS work while preserving deterministic delivery.

Implemented routing:

- `.github/workflows/automation-cicd-lab.yml` or `infra/automation-cicd/**` -> Automation CI/CD lab;
- `.github/workflows/terraform-drift-demo.yml` or `infra/drift-demo/**` -> Terraform drift demo;
- `.github/workflows/sfn-sqs-oidc-mcp-lab.yml` or `infra/sfn-sqs/**` -> Step Functions + SQS lab;
- `.github/workflows/codebuild-oidc-mcp-lab.yml` -> dedicated CodeBuild smoke;
- documentation inputs -> documentation workflows;
- every AWS lab workflow retains `workflow_dispatch` for explicit regression.

Acceptance proof:

- PR #25 merged as `6d9be8e5735fa2e369939b5b51f64b9a9e853b53` after all expected implementation workflows passed.
- PR #26 docs-only probe commit `d7bf72a0c19c474357458b45693c3532b0cb7004` created exactly two automatic runs: Docs build validation `34690145584` and Docs AWS site `34690145541`; both passed.
- No Automation, CodeBuild, Step Functions/SQS, or drift-demo run was created for that probe commit.
- PR #26 merged as `856cd25e3071483056513f3738d089f14bca4647`; the merge push also created exactly two workflows, both documentation workflows.

Detailed evidence: `docs/WORKFLOW_ROUTING.md`.

## Verification Standard

For future milestones use the smallest meaningful combination of:

- STS identity proof;
- Terraform validation/plan/apply for durable infrastructure;
- service-specific end-to-end smoke tests;
- direct provider readback;
- independent AWS MCP verification;
- cleanup or explicitly retained-state verification;
- IAM propagation-aware authorization verification;
- workflow-trigger evidence when CI routing is part of the milestone;
- cross-session documentation update.

## Stop Gates

Stop only if:

- target AWS account/repository/environment no longer matches the PERSONAL/LAB scope;
- work would enter PROD or another non-personal environment;
- a change would cause material cost, public exposure, non-recoverable data loss, or credential mutation outside the approved milestone;
- authentication/permissions or repo identity are ambiguous;
- cleanup/verification cannot be proven;
- validation fails in a way that makes further mutation unsafe.

## Acceptance Baseline Now Proven

- Direct AWS MCP read/write path.
- GitHub OIDC + persistent Terraform path in the primary repo.
- Out-of-band drift detection/reconciliation through IaC.
- ECR CI/CD artifact flow without static AWS keys.
- S3 and EventBridge event-driven automation through Lambda/DynamoDB.
- Terraform provider validation/read/refresh permission lessons under least privilege.
- MCP-origin-specific IAM deny while non-MCP OIDC cleanup/execution remains functional.
- Dedicated CI/CD-only execution path where GitHub OIDC can start CodeBuild while AWS MCP remains read/diagnose-only for that action.
- Terraform-owned orchestration/messaging where GitHub OIDC can start Step Functions while AWS MCP independently verifies and is selectively blocked from direct execution.
- Selective GitHub Actions routing that avoids unrelated AWS lab execution for docs-only changes while preserving manual regression.
- Independent AWS MCP final verification and durable cross-session knowledge.
