# Portable ChatGPT + AWS MCP Knowledge

Status: **VERIFIED**
Last verified: **2026-09-12**
Source of truth: **private** `mytestlab123/chatgpt-aws`

## Purpose

This is the durable cross-session knowledge base for using ChatGPT with the connected **AWS Core / AWS managed MCP Server** and **GitHub**.

It is written so another ChatGPT session can continue useful AWS work without relying on conversation memory.

> **Core rule:** Git carries knowledge; authentication does not. Every new ChatGPT session must re-verify AWS Core and GitHub access before mutation.

## Current verified environment

Verified through live GitHub/AWS APIs on 2026-09-12:

- AWS account: `063884340510`
- AWS Core caller: `arn:aws:iam::063884340510:user/devsecops`
- Main lab region: `ap-southeast-1`
- GitHub Actions OIDC provider: `arn:aws:iam::063884340510:oidc-provider/token.actions.githubusercontent.com`
- Primary repo: `mytestlab123/chatgpt-aws` — **private, active**
- Cross-session consumer repo: `mytestlab123/lab1_agent` — **private, active**
- Primary repo-specific OIDC role: `arn:aws:iam::063884340510:role/github-actions-chatgpt-aws-lab`
- Primary Terraform state bucket: `chatgpt-aws-tfstate-063884340510`
- Persistent drift-demo resource: SSM parameter `/chatgpt-aws/drift-demo`

Historical proof role `github-actions-assignment-cicd-chatgpt-lab` remains bound to `amitkarpe/assignment-cicd`; do not assume a role for one repository is reusable by another repository.

No static AWS access key is required by the proven GitHub Actions paths.

## First action in every new ChatGPT session

Before trusting saved environment facts:

1. Use AWS Core to call STS `GetCallerIdentity`.
2. Confirm the expected personal LAB account and principal.
3. Confirm the intended region/environment.
4. Use GitHub to verify target repo visibility/state and read/write access.
5. Read the target repo's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR.
6. Discover the AWS Core tool/skill surface actually exposed in that session.

If the account, principal, repository, or authority differs, reconcile before mutation.

## What AWS Core / AWS MCP actually provides

AWS Core is not only a documentation/search connector and is not limited to a small list of fixed service wrappers.

The managed AWS MCP execution surface includes a sandboxed script capability that can make authenticated AWS SDK calls. In this ChatGPT integration, multi-call work has been executed through a managed script tool using `call_boto3(...)`-style calls.

AWS documentation describes the managed AWS MCP Server as able to generate/execute calls across the broad AWS API surface (15,000+ APIs). Effective capability is still constrained by:

- authenticated IAM identity and IAM/SCP/resource-policy controls;
- service/region availability;
- SDK/MCP operation support in the current integration;
- client confirmation/approval behavior for consequential actions.

### Tooling model

When available:

- use AWS MCP script execution for multi-service/multi-call work, verification, diagnosis, filtering, comparison, and cleanup checks;
- use AWS documentation search for current service behavior instead of relying only on model memory;
- use AWS skills/workflows for relevant domains, especially IAM, deployment, serverless, containers, databases, observability, CDK, and CloudFormation;
- use the S3 presigned-URL tool for AWS operations requiring file upload/download;
- poll long-running MCP tasks when a task ID is returned.

## Proven direct AWS MCP capabilities

### Representative read proof

Authenticated reads succeeded against:

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

This demonstrates a broad generic AWS API execution surface rather than a few service-specific read tools.

### Temporary SSM mutation proof

Entirely through ChatGPT -> AWS Core MCP -> AWS:

1. create a temporary SSM parameter;
2. read it;
3. delete it;
4. verify `ParameterNotFound`.

Temporary resource: `/chatgpt-aws-lab/mcp-write-proof-20260912`.
Final state: **absent**.

### Temporary S3 infrastructure proof

Direct AWS MCP lifecycle in `ap-southeast-1`:

1. create bucket;
2. tag bucket;
3. put proof object;
4. verify object metadata/tags;
5. delete object;
6. delete bucket;
7. verify `HeadBucket` returned 404.

Proof bucket: `chatgpt-aws-mcp-proof-340510-5732d9248e`.
Final state: **absent**.

## Proven GitHub Actions + OIDC + Terraform paths

### Historical disposable proof

Repository: `amitkarpe/assignment-cicd`

- PR #1 / workflow `34672912194`: GitHub OIDC -> STS -> temporary SSM lifecycle: **PASS**.
- Issue #2 / PR #3 / workflow `34673717208`: Terraform -> temporary S3 -> destroy: **PASS**.
- AWS MCP independently confirmed cleanup.

This first proved the path without stored AWS access keys.

### Primary persistent IaC proof

Repository: `mytestlab123/chatgpt-aws`

Persistent LAB bootstrap:

- Terraform state bucket: `chatgpt-aws-tfstate-063884340510`
  - private public-access block;
  - versioning enabled;
  - AES256 encryption;
  - LAB/project tags.
- Repo-specific OIDC role: `github-actions-chatgpt-aws-lab`.
- Terraform resource: SSM parameter `/chatgpt-aws/drift-demo`.
- Terraform desired value: `desired-v1`.

PR #6:

- OIDC authentication: **PASS**.
- Terraform PR plan: `1 to add, 0 to change, 0 to destroy`.
- Main workflow `34675429394`: Terraform apply + provider readback: **PASS**.
- Independent AWS MCP readback: value `desired-v1`, SSM version `1`.

This proves a persistent desired-state workflow in the primary repo:

`ChatGPT -> GitHub -> GitHub Actions -> OIDC -> Terraform remote state -> AWS -> AWS MCP verification`

## Proven drift detection pattern

After the persistent Terraform deployment, ChatGPT used direct AWS MCP to make one harmless out-of-band update:

- before: value `desired-v1`, version `1`;
- direct MCP update: value `drifted-by-mcp`, version `2`.

PR #7 triggered a fresh Terraform plan using the same remote S3 state.

Workflow `34675498728` proved:

- OIDC authentication: **PASS**;
- state refresh found the live resource;
- Terraform classified the change as `~ update in-place`;
- exact result: `Plan: 0 to add, 1 to change, 0 to destroy.`

This proves the preferred responsibility split:

- AWS MCP can inspect or make bounded operational changes;
- Terraform remains the durable desired state;
- GitHub Actions detects out-of-band drift;
- reconciliation should return through the IaC path;
- AWS MCP independently verifies final AWS state.

Detailed evidence: `docs/DRIFT_DEMO.md`.

## Important GitHub OIDC trust learning

The first `chatgpt-aws` OIDC attempt failed with `sts:AssumeRoleWithWebIdentity` AccessDenied even though a conventional repo-name `sub` pattern had been configured.

CloudTrail was the useful diagnostic source. Failed events showed the actual WebIdentity principal/user string in this environment as:

`repo:mytestlab123@58461665/chatgpt-aws@1366899390:pull_request`

The IDs are the immutable GitHub organization/repository IDs observed for this repo.

The working role trust currently accepts the required audience plus the relevant repository subjects, including the ID-enriched form observed in CloudTrail. After aligning the trust, the workflow successfully assumed:

`arn:aws:sts::063884340510:assumed-role/github-actions-chatgpt-aws-lab/GitHubActions`

### Reusable OIDC troubleshooting procedure

For another repo/session:

1. Create/verify the GitHub OIDC provider.
2. Scope the role trust to the intended repo/branch/PR/environment; never use an unconstrained GitHub `sub`.
3. Run the smallest OIDC identity proof first (`sts get-caller-identity`).
4. If `AssumeRoleWithWebIdentity` fails, inspect CloudTrail `AssumeRoleWithWebIdentity` events.
5. Compare the actual WebIdentity principal/subject with the trust conditions.
6. Adjust trust to the observed legitimate repo identity rather than blindly widening to `repo:ORG/*`.
7. Re-run and verify the assumed-role ARN before provisioning.

AWS documentation recommends restricting GitHub OIDC role trust to intended repositories/branches and supports immutable GitHub identity claims. In this LAB, live CloudTrail evidence was essential for matching the current GitHub identity format.

## Decision rule: which path to use

Use **direct AWS MCP** when the main job is:

- inventory/discovery;
- diagnosis/troubleshooting;
- logs/CloudTrail investigation;
- live provider readback;
- cross-service checks;
- bounded, reversible, low-cost operational changes;
- independent verification after a deployment system runs.

Use **GitHub + IaC + OIDC** when infrastructure should have durable desired state:

- networking;
- ECS/EKS/Lambda/application infrastructure;
- databases;
- IAM architecture;
- persistent buckets/queues/tables/parameters;
- anything expected to be reviewed, rebuilt, drift-checked, or destroyed reproducibly.

Preferred durable loop:

`ChatGPT -> GitHub/IaC -> GitHub Actions/OIDC -> AWS -> AWS MCP verification`

Do not use direct API mutation as a silent replacement for Terraform/CloudFormation/CDK when durable infrastructure state matters.

## IAM and MCP control lessons

Normal AWS authorization remains the primary boundary: identity policies, resource policies, permissions boundaries, SCPs, service conditions, and role trust.

AWS-managed MCP calls also carry MCP-specific context that can distinguish MCP-originated operations from normal console/CLI/API activity:

- `aws:ViaAWSMCPService`
- `aws:CalledViaAWSMCP`

These can allow/deny classes of actions specifically when they arrive through an AWS-managed MCP server.

For IAM work, use the AWS IAM skill/guidance when available and verify trust + permission policies through live AWS APIs before reporting success.

CloudTrail is the audit/diagnostic source for downstream AWS activity and proved especially valuable for OIDC federation failures.

## GitHub OIDC lessons

- Prefer OIDC to long-lived AWS access keys for CI/CD.
- The trust policy is as important as the role permissions policy.
- Use a repo-specific role by default.
- Restrict PR/main/environment subjects rather than allowing an organization wildcard unless deliberately required.
- Use immutable GitHub IDs/claims where supported and verify actual current token/principal behavior.
- Always run STS `GetCallerIdentity` inside the workflow before provisioning.
- Keep deployment permissions narrow enough for the milestone.
- After apply, perform AWS provider readback.
- After destroy, verify the resource is absent.
- When OIDC fails, use CloudTrail evidence before broadening trust.

## Repository visibility model

Both active lab repositories are now private:

- `mytestlab123/chatgpt-aws`
- `mytestlab123/lab1_agent`

This removes the earlier public-repo limitation for `lab1_agent`, but **does not automatically authorize deployment**. A `lab1_agent` AWS deployment path should still get its own scoped OIDC role/trust and project-specific SPEC/Issue authority.

Before eventually making either repository public, review:

- workflow triggers;
- OIDC trust policies;
- IAM permissions;
- committed history and environment details;
- any account/principal/resource identifiers worth redacting.

## Cross-session operating procedure

For a new ChatGPT session working on an AWS repo:

1. **Load repo authority** — `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, active Issue/PR.
2. **Load shared AWS knowledge** — this file, `docs/EXPERIMENTS.md`, and `docs/DRIFT_DEMO.md` when present.
3. **Verify connections** — GitHub read/write and AWS Core auth.
4. **Verify AWS identity** — STS `GetCallerIdentity`.
5. **Choose path** — direct MCP for live ops; GitHub + IaC + OIDC for durable state.
6. **Use a repo-specific OIDC role** for durable deployment; do not reuse a role merely because it exists.
7. **Execute the smallest useful milestone** rather than re-running toy connectivity tests already proven.
8. **Provider readback** — independently verify actual AWS state.
9. **Drift discipline** — if a direct MCP mutation touches a Terraform-managed resource, expect Terraform to detect/reconcile it.
10. **Write learning back to Git** so the next chat does not depend on memory.

## `lab1_agent` reuse contract

Another ChatGPT session working on `mytestlab123/lab1_agent` should:

1. read `lab1_agent/docs/CHATGPT_AWS_BOOTSTRAP.md`;
2. use GitHub to read this private source of truth;
3. authenticate/verify AWS Core separately;
4. read `lab1_agent` project contracts and active Issue/PR;
5. use the same hybrid execution model;
6. **not** reuse `github-actions-assignment-cicd-chatgpt-lab` or `github-actions-chatgpt-aws-lab` by assumption;
7. create a scoped `lab1_agent` OIDC role when its own durable AWS deployment milestone is authorized;
8. use CloudTrail as the first diagnostic source if federation fails.

## What is portable vs session-specific

### Portable through Git

- architecture decisions;
- MCP/API capability findings;
- verified experiments;
- OIDC trust/debug patterns;
- run IDs and PR evidence;
- resource naming conventions;
- drift/reconciliation procedure;
- cleanup/verification discipline.

### Must be re-established in each session

- AWS Core OAuth/login state;
- active AWS IAM principal;
- GitHub app access;
- available MCP/plugin schemas;
- current AWS resource state;
- current repository Issue/PR authority.

## Before making this repository public

Do a publication pass first:

- replace account IDs and principal/role ARNs with placeholders if not useful publicly;
- review resource names and workflow history for environment details;
- confirm no secrets/tokens/authentication state entered Git history;
- review OIDC trust and workflow triggers independently of repo visibility;
- keep the reusable architecture, OIDC troubleshooting, and drift-reconciliation lessons.
