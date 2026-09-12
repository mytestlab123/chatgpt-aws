# ChatGPT -> AWS experiments

This lab compares two deliberately different execution directions. The goal is not to force one winner; each path is useful for a different class of work.

## Why `amitkarpe/assignment-cicd` was used first

It was already connected, tiny, and intentionally described as a CI/CD concepts sandbox, so it offered a low-blast-radius place to prove GitHub Actions + OIDC without touching active AWS projects. It is not intended to become the main ChatGPT/AWS project.

`mytestlab123/chatgpt-aws` is now the primary lab and owns the comparison, direct MCP experiments, and future architecture decisions.

## Direction A - GitHub Actions + OIDC + IaC

Path:

`ChatGPT -> GitHub -> GitHub Actions -> GitHub OIDC -> AWS IAM role -> AWS`

### Proof A1 - OIDC without stored AWS keys

Repository: `amitkarpe/assignment-cicd`

- PR #1: merged.
- GitHub Actions run: `34672912194`.
- Result: PASS.
- GitHub obtained temporary AWS credentials through OIDC.
- Workflow called STS, created a temporary SSM parameter, read it, deleted it, and verified cleanup.
- No AWS access key/secret was stored in GitHub.

### Proof A2 - Terraform provisioning

Repository: `amitkarpe/assignment-cicd`

- Issue #2 / PR #3: merged.
- GitHub Actions run: `34673717208`.
- Result: PASS.
- Terraform created one temporary S3 bucket using the OIDC role, verified it, then destroyed it.
- The workflow's cleanup check passed.
- Independent AWS MCP readback also confirmed `HeadBucket` returns 404 for the proof bucket after destroy.
- IAM permission was restricted to the proof bucket prefix.

### Strengths

- Durable desired state and code review.
- Repeatable plan/apply/destroy path.
- Git history and CI evidence.
- AWS credentials remain short-lived through OIDC.
- Best fit for infrastructure that should persist or be rebuilt later.

### Limits

- More steps and latency for small operational questions.
- CI/IaC tooling becomes part of the execution path.
- Runtime diagnosis still benefits from direct AWS readback.

## Direction B - direct ChatGPT + AWS Core MCP

Path:

`ChatGPT -> AWS Core MCP -> AWS APIs`

The AWS Core integration exposes a sandboxed script tool that can call AWS APIs. AWS documentation describes the managed AWS MCP Server as supporting AWS API execution across the broad AWS API surface; actual calls remain constrained by the connected IAM identity and service/API support.

### Proof B1 - broad read surface

PASS across representative reads from:

- STS
- EC2
- S3
- IAM
- Lambda
- CloudFormation
- ECS
- ECR
- SSM
- CloudWatch
- DynamoDB
- CloudWatch Logs

This disproved the idea that the integration is only a small set of fixed service-specific read tools.

### Proof B2 - temporary SSM mutation

PASS:

1. create parameter;
2. read parameter;
3. delete parameter;
4. verify `ParameterNotFound`.

No resource remained.

### Proof B3 - temporary S3 infrastructure lifecycle

PASS in `ap-southeast-1`:

1. create temporary S3 bucket;
2. add project/direction/owner tags;
3. put a small proof object;
4. read object metadata and bucket tags;
5. delete object;
6. delete bucket;
7. verify `HeadBucket` returns 404.

Proof bucket was `chatgpt-aws-mcp-proof-340510-5732d9248e` and is confirmed absent.

### Strengths

- Fastest path for inspection, diagnosis, verification, inventory, and bounded changes.
- No extra CI hop is required.
- Can combine many AWS service calls in one MCP script.
- Uses the IAM identity connected to AWS Core and normal AWS authorization.
- AWS-managed MCP calls can be controlled using MCP-specific IAM condition keys such as `aws:ViaAWSMCPService` and `aws:CalledViaAWSMCP`.

### Limits

- Direct API mutation does not automatically produce durable IaC state.
- A successful API call is not a replacement for repeatable deployment code.
- Effective capability can be broad when the connected IAM identity is broad; the AWS permission model remains the real boundary.

## Current recommendation

Use both paths as one control system:

- **Direct AWS MCP:** discovery, troubleshooting, live readback, verification, and small reversible operations.
- **GitHub + IaC + OIDC:** durable infrastructure creation/change, repeatability, review, and rebuild/destroy contracts.

Preferred full loop:

`ChatGPT -> GitHub/IaC -> GitHub Actions/OIDC -> AWS -> AWS MCP independent verification`

A future ChatGPT Site can sit above these paths as a UI, but should not replace the durable IaC source of truth.

## Next experiments

1. Test a persistent low-cost IaC stack, then have AWS MCP independently verify its deployed state and detect deliberate drift.
2. Test an IAM policy that treats MCP-originated calls differently from normal human/API calls.
3. Only after the backend paths are stable, prototype a ChatGPT Site as the UI/control surface.
