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
5. reusable automation and CI/CD patterns across several AWS services;
6. MCP-origin-specific IAM controls for selected destructive actions.

## Authorized

When an owning Issue/current user instruction is active, ChatGPT may perform bounded PERSONAL/LAB work using low-cost AWS resources; create/update GitHub Issues, branches, PRs, workflows and documentation; create/update lab-only IAM roles/policies and Terraform state required by the approved experiment; validate results; and clean up temporary resources without repeated resource-by-resource approval.

Issue #9 implementation is complete. After its final evidence PR/steady-state validation is merged, a new AWS mutation milestone should have a new owning Issue or explicit user instruction.

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

Final verified state: `/chatgpt-aws/drift-demo` = `desired-v1`, version `3`. Detailed evidence: `docs/DRIFT_DEMO.md`.

## Completed Milestone — Issue #9

Four related outcomes are proven:

1. **ECR CI/CD** — GitHub Actions builds, pushes, verifies, and deletes a test container image through OIDC-derived AWS credentials.
2. **Event-driven automation** — S3 and EventBridge independently trigger Lambda, which writes deterministic evidence to DynamoDB and CloudWatch Logs.
3. **MCP-aware governance** — `aws:ViaAWSMCPService` prevents AWS Core MCP from deleting one retained S3 governance fixture while the GitHub OIDC path can delete equivalent temporary objects.
4. **Learning artifact** — durable Markdown evidence plus a self-contained HTML page for Amit.

Key evidence:

- PR #10 merged.
- PR workflow `34676895495`: Terraform plan `15 to add, 0 to change, 0 to destroy`.
- Main workflow `34676955227`, attempt 3: Terraform apply + all CI/CD/automation smoke tests + provider readback PASS.
- ECR pushed digest was verified, then the test image was deleted; final image count 0.
- S3 and EventBridge triggers each produced verifiable DynamoDB evidence, then smoke-test data was removed.
- GitHub OIDC S3 cleanup path: PASS.
- AWS Core MCP delete of `mcp-guard/protected.txt`: explicit `AccessDenied` as designed.
- AWS Core HeadObject before/after proved the protected fixture remained present and unchanged.
- Independent final readback verified ECR, S3, DynamoDB, Lambda, EventBridge, CloudWatch Logs, Lambda IAM policy and MCP guard state.

Retained LAB resources:

- private ECR repository `chatgpt-aws-cicd-lab` — currently empty;
- private S3 bucket `chatgpt-aws-automation-063884340510` — only tiny governance fixture retained;
- DynamoDB `chatgpt-aws-automation-events` — PAY_PER_REQUEST and empty after cleanup;
- Lambda `chatgpt-aws-automation-recorder` — Python 3.12, 128 MB;
- EventBridge rule `chatgpt-aws-automation-events`;
- 1-day CloudWatch log group;
- Lambda execution role `chatgpt-aws-automation-lambda`;
- narrow `ChatGPTAwsMCPGuard` policy on the PERSONAL/LAB AWS Core identity.

Detailed evidence: `docs/AUTOMATION_CICD_LAB.md`.  
Educational view: `docs/AMIT_AUTOMATION_CICD_LAB.html`.

## Verification Standard

For future milestones use the smallest meaningful combination of:

- STS identity proof;
- Terraform validation/plan/apply for durable infrastructure;
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
