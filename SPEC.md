# Specification

Status: ACTIVE
Context: PERSONAL
Environment: LAB

## Objective

Prove, compare, and document practical ways for ChatGPT to control a personal AWS account while preserving durable Git/IaC knowledge for other ChatGPT sessions.

## Outcome

A verified hybrid operating model:

1. direct ChatGPT -> AWS Core MCP -> AWS API operations;
2. ChatGPT/GitHub -> GitHub Actions -> OIDC -> Terraform -> AWS;
3. AWS MCP independent verification and bounded live operations;
4. Terraform detection/reconciliation when a managed resource drifts.

## Authorized

While the current owning Issue remains in scope, ChatGPT may perform bounded PERSONAL/LAB work using low-cost AWS resources; create/update GitHub Issues, branches, PRs, workflows and documentation; create/update lab-only IAM roles/policies and Terraform state required by the approved experiment; perform harmless reversible drift tests; validate results; and clean up temporary resources without repeated resource-by-resource approval.

The current active milestone is Issue #5. `mytestlab123/lab1_agent` is an authorized related private repo for knowledge reuse, but its own AWS mutation/deployment must be owned by its project-specific Issue/SPEC and repo-specific OIDC trust.

## MUST

- Record which execution path performed each experiment.
- Verify every AWS mutation with provider/API readback.
- Keep durable infrastructure under IaC when reproducibility matters.
- Prefer GitHub OIDC over static AWS access keys for CI/CD.
- Use repo-specific OIDC trust/permissions unless reuse is explicitly reviewed.
- Use CloudTrail/provider evidence to diagnose federation failures before widening trust.
- Clean up temporary proof resources unless explicitly retained.
- Explicitly document retained persistent LAB resources.
- Write reusable learning back to Git for other ChatGPT sessions.

## MUST NOT

- Enter work, corporate, non-personal, or production AWS environments.
- Commit credentials, OAuth tokens, access keys, private keys, or authentication state.
- Create public application endpoints, databases with real data, or intentionally expensive resources without a new explicit milestone.
- Leave temporary experiment resources running without documenting why.
- Treat direct MCP mutation as a silent replacement for Terraform/CloudFormation/CDK when durable desired state matters.

## Current Milestone — Issue #5

Prove:

`ChatGPT -> GitHub/Terraform -> Actions/OIDC -> AWS -> AWS MCP verify -> harmless direct drift -> Terraform detects/repairs -> AWS MCP final verify`

Retained LAB resources for this milestone:

- S3 Terraform state bucket `chatgpt-aws-tfstate-063884340510`;
- IAM role `github-actions-chatgpt-aws-lab`;
- Terraform-managed SSM parameter `/chatgpt-aws/drift-demo` until the experiment is retired.

## Verification

- STS identity proof inside GitHub Actions.
- Successful Terraform init/validate/plan/apply with remote state.
- AWS MCP readback after apply.
- Direct MCP drift recorded with before/after values and versions.
- Fresh Terraform plan proves drift detection.
- Main-branch apply restores desired state.
- Final AWS MCP readback proves reconciliation.

## Stop Gates

Stop only if:

- target AWS account/repository/environment no longer matches the PERSONAL/LAB scope;
- work would enter PROD or another non-personal environment;
- a change would cause material cost, public exposure, non-recoverable data loss, or credential mutation outside this milestone;
- authentication/permissions or repo identity are ambiguous;
- cleanup/verification cannot be proven;
- validation fails in a way that makes further mutation unsafe.

## Acceptance

- Direct AWS MCP path remains verified.
- GitHub OIDC + persistent Terraform path is verified in the primary repo.
- One deliberate out-of-band drift is detected and reconciled through IaC.
- Final AWS state is independently verified through AWS MCP.
- Portable cross-session knowledge is updated with the OIDC and drift lessons.
