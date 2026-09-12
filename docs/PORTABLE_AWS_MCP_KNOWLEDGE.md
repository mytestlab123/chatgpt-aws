# Portable ChatGPT + AWS MCP Knowledge

Status: **VERIFIED**
Last verified: **2026-09-12**
Source of truth: **private** `mytestlab123/chatgpt-aws`

## Purpose

This file is the durable cross-session knowledge base for using ChatGPT with the connected **AWS Core / AWS managed MCP Server** and **GitHub**.

It is intentionally written so another ChatGPT session can become productive without relying on conversation memory.

> **Important:** knowledge is portable; authentication is not. A new ChatGPT session must still have the AWS Core and GitHub apps available/authorized and must re-verify the active AWS identity before any mutation.

## Current verified environment

These are environment facts verified from AWS APIs on 2026-09-12.

- AWS account: `063884340510`
- AWS Core caller: `arn:aws:iam::063884340510:user/devsecops`
- Main lab region: `ap-southeast-1`
- GitHub Actions OIDC provider: `arn:aws:iam::063884340510:oidc-provider/token.actions.githubusercontent.com`
- Existing proof role: `arn:aws:iam::063884340510:role/github-actions-assignment-cicd-chatgpt-lab`
- Existing proof-role inline policy: `ChatGPTLabSSMProof`
- `mytestlab123/chatgpt-aws`: private at last verification
- `mytestlab123/lab1_agent`: public at last verification

The current GitHub OIDC proof role is intentionally repository-bound to `amitkarpe/assignment-cicd`. **Do not assume it can be used by `chatgpt-aws` or `lab1_agent`.** A new repository needs its own scoped role or an explicitly reviewed trust-policy change.

No static AWS access key is required by the proven GitHub Actions path.

## First action in every new ChatGPT session

Before trusting any saved environment fact, use AWS Core to call STS `GetCallerIdentity` and verify:

1. the AWS account is the expected personal LAB account;
2. the caller identity is understood;
3. the intended region/environment matches the repository contract.

If the account or principal differs, stop and reconcile before mutation.

Then use GitHub to read the target repository's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR before making repository or cloud changes.

## What AWS Core / AWS MCP actually provides

The connected AWS Core app is not only a documentation/search integration and is not limited to a small list of fixed service wrappers.

The managed AWS MCP execution surface includes a sandboxed script capability that can make authenticated AWS SDK calls. In this ChatGPT integration that has been used through the equivalent of `call_boto3(...)` inside a managed script execution tool.

AWS documentation describes the managed AWS MCP Server as able to generate/execute calls across the broad AWS API surface (15,000+ APIs). Effective capability is still limited by:

- the authenticated IAM principal and all IAM/SCP/resource-policy controls;
- service and region availability;
- the SDK/MCP operation exposed by the current integration;
- ChatGPT/client confirmation and approval behavior for consequential actions.

### Tooling model to remember

When available in the ChatGPT session:

- use the AWS MCP script/execution tool for multi-service or multi-call work, verification, diagnosis, filtering, comparisons, and cleanup checks;
- use AWS documentation search for exact current service behavior rather than relying only on model memory;
- use AWS skills/workflows when relevant, especially IAM, deployment, serverless, containers, databases, observability, CDK, and CloudFormation;
- use the S3 presigned-URL tool when an AWS operation needs file upload/download rather than trying to push local file bytes through normal API calls;
- poll long-running AWS MCP tasks when the tool returns a task identifier.

A future ChatGPT session should first discover the actual AWS Core tool surface exposed to that session rather than assuming every tool name is identical.

## Proven direct AWS MCP capabilities

### Representative read proof

Read calls succeeded against all of these service families:

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

This demonstrates a broad generic AWS API execution surface, not only a few service-specific read tools.

### Direct SSM mutation proof

The following lifecycle was completed entirely through ChatGPT -> AWS Core MCP -> AWS:

1. create a temporary SSM parameter;
2. read it back;
3. delete it;
4. verify a subsequent read returned `ParameterNotFound`.

Temporary resource used: `/chatgpt-aws-lab/mcp-write-proof-20260912`.

Final state: **absent**.

### Direct S3 infrastructure proof

The following lifecycle was completed through direct AWS MCP APIs in `ap-southeast-1`:

1. create a temporary S3 bucket;
2. add `project`, `direction`, and `owner` tags;
3. put a small proof object;
4. verify object metadata and bucket tags;
5. delete the object;
6. delete the bucket;
7. verify `HeadBucket` returned 404.

Proof bucket: `chatgpt-aws-mcp-proof-340510-5732d9248e`.

Final state: **absent**.

## Proven GitHub Actions + OIDC + Terraform path

### OIDC proof

Repository: `amitkarpe/assignment-cicd`

- PR #1: merged
- GitHub Actions run: `34672912194`
- GitHub Actions obtained temporary AWS credentials using OIDC.
- Workflow called STS, created/read/deleted a temporary SSM parameter, and verified cleanup.
- No stored AWS access key/secret was needed.

### Terraform provisioning proof

Repository: `amitkarpe/assignment-cicd`

- Issue #2 / PR #3: completed and merged
- GitHub Actions run: `34673717208`
- Terraform created one temporary S3 bucket using the dedicated OIDC role.
- Workflow verified the bucket.
- Terraform destroyed it.
- Workflow cleanup verification passed.
- AWS MCP independently checked afterward and confirmed `HeadBucket` returned 404.

This proves the full path:

`ChatGPT -> GitHub -> GitHub Actions -> GitHub OIDC -> AWS role -> Terraform -> AWS -> AWS MCP independent verification`

## Decision rule: which path to use

Use **direct AWS MCP** when the main need is:

- inventory/discovery;
- diagnosis/troubleshooting;
- logs or CloudTrail investigation;
- live provider readback;
- cross-service checks;
- bounded, reversible, low-cost operational changes;
- independent verification after another deployment system runs.

Use **GitHub + IaC + OIDC** when the change should have durable desired state:

- VPC/networking;
- ECS/EKS/Lambda/application infrastructure;
- databases;
- IAM architecture;
- persistent buckets/queues/tables;
- infrastructure expected to be rebuilt, reviewed, or destroyed reproducibly.

Preferred durable loop:

`ChatGPT -> GitHub/IaC -> GitHub Actions/OIDC -> AWS -> AWS MCP verification`

Do not use direct API mutation as a silent replacement for Terraform/CloudFormation/CDK when durable infrastructure state matters.

## IAM and control lessons

Normal AWS authorization remains the primary boundary: identity policies, resource policies, permissions boundaries, SCPs, service conditions, and role trust.

AWS-managed MCP calls also carry MCP-specific context that can distinguish AI/MCP-originated operations from normal console/CLI/API activity:

- `aws:ViaAWSMCPService`
- `aws:CalledViaAWSMCP`

These can be used to allow/deny classes of actions only when they arrive through an AWS managed MCP server.

For IAM work, use the AWS IAM skill/guidance when available and verify trust + permission policies through live AWS APIs before reporting success.

CloudTrail should be treated as the audit source for downstream AWS API activity.

## GitHub OIDC lessons

- Prefer GitHub OIDC to long-lived AWS access keys for CI/CD.
- The trust policy is as important as the IAM permissions policy.
- Bind roles to the intended repository/branch/environment/subject rather than assuming one lab role should work everywhere.
- Keep deployment permissions narrow enough to the lab milestone, then widen only when a real use case needs it.
- Always verify the assumed AWS identity inside the workflow before provisioning.
- After apply, perform AWS provider readback; after destroy, verify the resource is actually absent.

### Public-repository caution

`mytestlab123/lab1_agent` is currently public. Do **not** add a mutation-capable AWS OIDC deployment workflow there by default while it is public.

Preferred sequence:

1. keep the repository private while experimenting with AWS write paths;
2. create a repo-specific scoped OIDC role/workflow;
3. prove the workflow;
4. only then consider making the repo public after reviewing workflow triggers, IAM trust, permissions, environment-specific details, and committed history.

This is why environment-specific account/principal/role details stay in private `chatgpt-aws` for now.

## Cross-session operating procedure

For any new ChatGPT session working on an AWS repository:

1. **Load repository authority** — read `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, current Issue/PR.
2. **Load shared AWS knowledge** — read this file and `docs/EXPERIMENTS.md` from `mytestlab123/chatgpt-aws`.
3. **Verify connections** — confirm GitHub can read/write the target repo and AWS Core is authenticated.
4. **Verify AWS identity** — call STS `GetCallerIdentity`; do not trust conversation memory alone.
5. **Choose execution path** — direct MCP for live operations; GitHub + IaC + OIDC for durable state.
6. **Execute the smallest useful milestone** — not a toy connectivity test if the path is already proven.
7. **Provider readback** — independently verify what actually happened in AWS.
8. **Cleanup or explicitly retain** — prove temporary resources are absent; document persistent resources.
9. **Write learning back to Git** — update the owning Issue/PR/docs so the next session does not depend on chat memory.

## `lab1_agent` reuse contract

Another ChatGPT session working on `mytestlab123/lab1_agent` should:

1. read `lab1_agent/docs/CHATGPT_AWS_BOOTSTRAP.md`;
2. use the connected GitHub app to read this private source-of-truth file;
3. authenticate/verify AWS Core separately in that session;
4. read the `lab1_agent` project contracts before AWS mutation;
5. avoid reusing `github-actions-assignment-cicd-chatgpt-lab` because its trust is for a different repository;
6. if `lab1_agent` will deploy to AWS, first make it private or explicitly review the security/trust model for public-repo workflows, then create a scoped `lab1_agent` OIDC role.

## What is portable vs session-specific

### Portable through Git

- architecture decisions;
- API/MCP capability findings;
- exact verified experiments;
- role/trust design patterns;
- run IDs and PR evidence;
- resource naming conventions;
- operating procedure;
- cleanup/verification discipline.

### Must be re-established in each session

- AWS Core OAuth/login state;
- active AWS IAM principal;
- GitHub app access to private repositories;
- available plugin/MCP tool schemas;
- current resource state;
- current repository Issue/PR authority.

## Before making this repository public

Do a publication pass first:

- replace account IDs and principal/role ARNs with placeholders if they are no longer useful publicly;
- review resource names and workflow history for environment details;
- confirm no secrets/tokens/authentication state ever entered Git history;
- review OIDC trust policies and workflow triggers independently of repository visibility;
- keep the reusable architectural lessons and proof approach.

The eventual public version should teach the pattern without requiring readers to inherit this account's identifiers.
