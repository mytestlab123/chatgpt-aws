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
4. Terraform detection/reconciliation when a managed resource drifts;
5. reusable automation and CI/CD patterns across several AWS services.

## Authorized

When an owning Issue/current user instruction is active, ChatGPT may perform bounded PERSONAL/LAB work using low-cost AWS resources; create/update GitHub Issues, branches, PRs, workflows and documentation; create/update lab-only IAM roles/policies and Terraform state required by the approved experiment; validate results; and clean up temporary resources without repeated resource-by-resource approval.

Current active milestone: **Issue #9 — Automation + CI/CD AWS service matrix lab**.

`mytestlab123/lab1_agent` is an authorized related private repo for knowledge reuse, but its own AWS mutation/deployment must be owned by its project-specific Issue/SPEC and repo-specific OIDC trust.

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

## Completed Milestone — Issue #5

Proven end-to-end:

`ChatGPT -> GitHub/Terraform -> Actions/OIDC -> AWS -> AWS MCP verify -> harmless direct drift -> Terraform detects/repairs -> AWS MCP final verify`

Retained LAB resources:

- S3 Terraform state bucket `chatgpt-aws-tfstate-063884340510`;
- IAM role `github-actions-chatgpt-aws-lab`;
- Terraform-managed SSM parameter `/chatgpt-aws/drift-demo`.

Final verified state: `/chatgpt-aws/drift-demo` = `desired-v1`, version `3`. Detailed evidence lives in `docs/DRIFT_DEMO.md`.

## Active Milestone — Issue #9

Prove four related outcomes in one cohesive package:

1. **ECR CI/CD** — GitHub Actions builds, pushes, verifies, and deletes a test container image through OIDC-derived AWS credentials.
2. **Event-driven automation** — S3 and EventBridge independently trigger Lambda, which writes deterministic evidence to DynamoDB and CloudWatch Logs.
3. **MCP-aware governance** — `aws:ViaAWSMCPService` prevents AWS Core MCP from deleting one retained S3 governance fixture while the GitHub OIDC path can delete equivalent temporary objects.
4. **Learning artifact** — durable Markdown evidence plus a self-contained HTML page for Amit.

Retained LAB resources may include one private ECR repository, one private S3 automation bucket with one tiny governance fixture, one DynamoDB on-demand table, one 128 MB Lambda function, one 1-day CloudWatch log group, one EventBridge rule, one Lambda execution role, and the narrowly scoped MCP guard policy.

Temporary ECR images, smoke-test S3 objects, and smoke-test DynamoDB items must be deleted after successful validation.

## Verification Standard

Use the smallest meaningful combination of:

- STS identity proof for the active execution identity;
- Terraform validation/plan/apply for durable Issue #9 infrastructure;
- GitHub Actions smoke tests for ECR, S3, EventBridge, Lambda and DynamoDB;
- direct AWS provider readback after mutation;
- explicit MCP-origin deny proof for the protected fixture;
- cleanup or explicit retained-state verification;
- cross-session documentation update.

## Stop Gates

Stop only if:

- target AWS account/repository/environment no longer matches the PERSONAL/LAB scope;
- work would enter PROD or another non-personal environment;
- a change would cause material cost, public exposure, non-recoverable data loss, or credential mutation outside the approved milestone;
- authentication/permissions or repo identity are ambiguous;
- cleanup/verification cannot be proven;
- validation fails in a way that makes further mutation unsafe.

## Acceptance Baseline Already Proven

- Direct AWS MCP read/write path.
- GitHub OIDC + persistent Terraform path in the primary repo.
- Deliberate out-of-band drift detected and reconciled through IaC.
- Final AWS state independently verified through AWS MCP.
- Portable cross-session knowledge updated with OIDC and drift lessons.
