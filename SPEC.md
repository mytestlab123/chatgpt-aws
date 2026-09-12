# Specification

Status: ACTIVE
Context: PERSONAL
Environment: LAB

## Objective

Prove, compare, and document practical ways for ChatGPT to control a personal AWS account.

## Outcome

A verified two-path lab:

1. direct ChatGPT -> AWS Core MCP -> AWS API operations;
2. ChatGPT/GitHub -> GitHub Actions -> OIDC -> Terraform -> AWS.

## Authorized

While Issue #1 remains in scope, ChatGPT may perform bounded personal-LAB experiments using temporary, reversible, low-cost AWS resources; create/update GitHub Issues, branches, PRs, workflows, and documentation; create or update lab-only IAM roles/policies required by these experiments; verify results; and clean up experiment resources without repeated resource-by-resource approval.

`amitkarpe/assignment-cicd` is authorized only for the related GitHub/OIDC/IaC proof.

## MUST

- Record which execution path performed each experiment.
- Verify every cloud mutation with provider readback.
- Clean up temporary proof resources unless explicitly retained.
- Keep durable learning and code in Git.
- Prefer OIDC over stored AWS access keys for GitHub Actions.

## MUST NOT

- Enter work, corporate, non-personal, or production AWS environments.
- Commit credentials, OAuth tokens, access keys, private keys, or authentication state.
- Create public application endpoints, databases with real data, or intentionally expensive resources for this milestone.
- Leave temporary experiment resources running without documenting why.

## Phases / Milestones

- Phase 1: prove direct AWS MCP read/write and cleanup.
- Phase 2: prove GitHub Actions OIDC and Terraform provisioning/cleanup.
- Phase 3: compare strengths, limits, controls, and choose the default operating model.

## Verification

- AWS API readback for direct MCP operations.
- Successful GitHub Actions job and STS identity for OIDC.
- Terraform apply + provider/AWS verification + destroy for IaC.
- Final AWS readback confirms temporary proof resources are absent.

## Stop Gates

Stop only if the target account/repository is not this personal lab, the experiment would create material cost/public exposure/non-recoverable data, authentication or permissions no longer match expected scope, cleanup cannot be verified, or validation fails in a way that makes further mutation unsafe.

## Acceptance

- Both paths have at least one real AWS mutation proof.
- Temporary resources are cleaned up.
- Learning is documented with a clear recommendation for future use.
