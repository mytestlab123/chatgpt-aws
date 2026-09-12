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
6. MCP-origin-specific IAM controls for selected destructive or execution actions.

## Authorized

When an owning Issue/current user instruction is active, ChatGPT may perform bounded PERSONAL/LAB work using low-cost AWS resources; create/update GitHub Issues, branches, PRs, workflows and documentation; create/update lab-only IAM roles/policies and Terraform state required by the approved experiment; validate results; and clean up temporary resources without repeated resource-by-resource approval.

Issue #18 is the active mutation authority for the dedicated OIDC + MCP CodeBuild control-plane lab.

`mytestlab123/lab1_agent` is now public and independent. This repository must not depend on it for execution, OIDC trust, or AWS state.

## MUST

- Record which execution path performed each experiment.
- Verify every AWS mutation with provider/API readback.
- Keep durable infrastructure under IaC when reproducibility matters; explicitly document any intentionally MCP-bootstrapped lab resources.
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

Detailed evidence: `docs/DRIFT_DEMO.md`.

## Completed Milestone — Issue #9

Four related outcomes are proven:

1. **ECR CI/CD** — GitHub Actions builds, pushes, verifies, and deletes a test container image through OIDC-derived AWS credentials.
2. **Event-driven automation** — S3 and EventBridge independently trigger Lambda, which writes deterministic evidence to DynamoDB and CloudWatch Logs.
3. **MCP-aware governance** — `aws:ViaAWSMCPService` prevents AWS Core MCP from deleting one retained S3 governance fixture while the GitHub OIDC path can delete equivalent temporary objects.
4. **Learning artifact** — durable Markdown evidence plus a self-contained HTML page for Amit.

Detailed evidence: `docs/AUTOMATION_CICD_LAB.md`.

## Active Milestone — Issue #18

Goal:

`GitHub Actions -> dedicated OIDC role -> CodeBuild execution`

while independently proving:

`AWS Core MCP -> CodeBuild read/diagnose = ALLOW`

and:

`AWS Core MCP -> CodeBuild StartBuild = DENY when aws:ViaAWSMCPService=true`

Authorized retained resources for this milestone:

- `github-actions-chatgpt-aws-codebuild-lab`;
- `chatgpt-aws-oidc-mcp-smoke` CodeBuild project;
- `chatgpt-aws-codebuild-smoke` service role;
- `/aws/codebuild/chatgpt-aws-oidc-mcp-smoke` one-day log group;
- `ChatGPTAwsMCPCodeBuildGuard` on the PERSONAL/LAB AWS Core identity.

The dedicated OIDC role may only start/read the dedicated CodeBuild project. The CodeBuild service role may only write the dedicated log group. No static AWS access keys are allowed.

Detailed evidence: `docs/OIDC_MCP_CODEBUILD_LAB.md`.

## Verification Standard

For future milestones use the smallest meaningful combination of:

- STS identity proof;
- Terraform validation/plan/apply for durable infrastructure where used;
- service-specific end-to-end smoke tests;
- direct provider readback;
- independent AWS MCP verification;
- cleanup or explicitly retained-state verification;
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
- Terraform provider refresh-permission lesson under least privilege.
- MCP-origin-specific IAM deny while non-MCP OIDC cleanup remains functional.
- Independent AWS MCP final verification and durable cross-session knowledge.
