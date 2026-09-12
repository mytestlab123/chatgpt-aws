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
- Persistent automation/CI-CD lab resources: private ECR/S3, Lambda, DynamoDB, EventBridge, CloudWatch Logs, and Lambda IAM role documented in `docs/AUTOMATION_CICD_LAB.md`.

Historical proof role `github-actions-assignment-cicd-chatgpt-lab` remains bound to `amitkarpe/assignment-cicd`; do not assume a role for one repository is reusable by another repository.

No static AWS access key is required by the proven GitHub Actions paths.

## First action in every new ChatGPT session

Before trusting saved environment facts:

1. Use AWS Core to call STS `GetCallerIdentity`.
2. Confirm the expected personal LAB account and principal.
3. Confirm the intended region/environment.
4. Use GitHub to verify target repo visibility/state and read/write access.
5. Read the target repo's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR.
6. Read the relevant shared evidence docs, especially `docs/DRIFT_DEMO.md` and `docs/AUTOMATION_CICD_LAB.md`.
7. Discover the AWS Core tool/skill surface actually exposed in that session.

If the account, principal, repository, or authority differs, reconcile before mutation.

## What AWS Core / AWS MCP actually provides

AWS Core is not only a documentation/search connector and is not limited to a small list of fixed service wrappers.

The managed AWS MCP execution surface includes a sandboxed script capability that can make authenticated AWS SDK calls. In this ChatGPT integration, multi-call work has been executed through a managed script tool using `call_boto3(...)`-style calls.

Effective capability is constrained by:

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

Authenticated reads succeeded against STS, EC2, S3, IAM, Lambda, CloudFormation, ECS, ECR, SSM, CloudWatch, DynamoDB, and CloudWatch Logs.

### Temporary SSM mutation proof

ChatGPT -> AWS Core MCP -> AWS completed create/read/delete/absence verification for:

`/chatgpt-aws-lab/mcp-write-proof-20260912`

Final state: **absent**.

### Temporary S3 infrastructure proof

Direct AWS MCP completed create/tag/object/read/delete/bucket-delete/404 verification for a temporary S3 bucket.

Final state: **absent**.

## Proven GitHub Actions + OIDC + Terraform paths

### Historical disposable proof

Repository: `amitkarpe/assignment-cicd`

- workflow `34672912194`: GitHub OIDC -> STS -> temporary SSM lifecycle: **PASS**.
- workflow `34673717208`: Terraform -> temporary S3 -> destroy: **PASS**.
- AWS MCP independently confirmed cleanup.

### Primary persistent IaC proof

Repository: `mytestlab123/chatgpt-aws`

- Terraform state bucket: `chatgpt-aws-tfstate-063884340510`.
- Repo-specific OIDC role: `github-actions-chatgpt-aws-lab`.
- Terraform resource: `/chatgpt-aws/drift-demo` = `desired-v1`.
- PR #6 plan: `1 to add, 0 to change, 0 to destroy`.
- Main workflow `34675429394`: apply + provider readback: **PASS**.

This proves:

`ChatGPT -> GitHub -> GitHub Actions -> OIDC -> Terraform remote state -> AWS -> AWS MCP verification`

## Proven drift detection pattern

AWS MCP deliberately changed `/chatgpt-aws/drift-demo` from `desired-v1` version 1 to `drifted-by-mcp` version 2.

PR #7 workflow `34675498728` detected:

`Plan: 0 to add, 1 to change, 0 to destroy.`

GitHub/OIDC/Terraform reconciled the resource, and AWS MCP independently verified final value `desired-v1`, version 3.

Detailed evidence: `docs/DRIFT_DEMO.md`.

## Proven multi-service automation + CI/CD pattern

Issue #9 / PR #10 extended the same hybrid model across ECR, S3, EventBridge, Lambda, DynamoDB, CloudWatch Logs, and IAM.

### ECR CI/CD

Successful PR plan workflow: `34676895495`.

Initial plan:

`15 to add, 0 to change, 0 to destroy`

Successful main workflow: `34676955227`, attempt 3.

The workflow:

1. assumed the repo-specific role with GitHub OIDC;
2. applied Terraform;
3. built a tiny Docker image;
4. pushed it to `chatgpt-aws-cicd-lab`;
5. verified digest `sha256:97c45707dd8b16ce4f5d3bb4a9c31682755443e3bd2628e8176365e5a08ce5f3`;
6. deleted the test image;
7. verified the retained ECR repository contained zero images.

This is a real artifact pipeline without stored AWS access keys.

### Event-driven automation

Two independent triggers were proven end-to-end:

`S3 events/* -> Lambda -> DynamoDB`

`EventBridge PutEvents -> rule -> Lambda -> DynamoDB`

The workflow polled deterministic DynamoDB keys. This is important: acceptance checked the **final effect**, not only that S3/EventBridge accepted an API call.

Smoke-test objects and DynamoDB rows were deleted afterward. Independent AWS Core readback confirmed the table was ACTIVE, PAY_PER_REQUEST, and empty.

### Terraform least-privilege lesson

The first main attempts exposed missing provider refresh permissions such as:

- `s3:GetAccelerateConfiguration`;
- `s3:GetLifecycleConfiguration`;
- `events:ListTagsForResource`.

The reusable rule is:

> Terraform least privilege must include both mutation permissions and the provider read/refresh APIs used to inspect existing state.

Failed applies can leave partial/tainted resources. A later successful Terraform apply safely reconciled this lab state.

Detailed evidence: `docs/AUTOMATION_CICD_LAB.md`.

## Proven MCP-specific IAM control

AWS-managed MCP calls carry context that can distinguish MCP-originated requests from normal console/CLI/API/CI-CD activity:

- `aws:ViaAWSMCPService`
- `aws:CalledViaAWSMCP`

Official AWS documentation defines `aws:ViaAWSMCPService` as a Boolean indicating that the request is routed through an AWS managed MCP server; `aws:CalledViaAWSMCP` can identify the specific MCP service principal.

Issue #9 proved this live with a narrow explicit deny:

- action: `s3:DeleteObject`;
- resource: only `s3://chatgpt-aws-automation-063884340510/mcp-guard/protected.txt`;
- condition: `aws:ViaAWSMCPService = true`.

Results:

- GitHub Actions OIDC created/deleted an equivalent temporary object: **PASS**.
- AWS Core MCP attempted to delete the protected fixture: **AccessDenied as designed**.
- `HeadObject` succeeded before and after; the ETag was unchanged.

This proves the same AWS environment can permit normal approved CI/CD cleanup while imposing stricter controls specifically on MCP-originated destructive actions.

## Important GitHub OIDC trust learning

An early `chatgpt-aws` OIDC attempt failed with `sts:AssumeRoleWithWebIdentity` AccessDenied. CloudTrail showed the actual WebIdentity principal in this environment as:

`repo:mytestlab123@58461665/chatgpt-aws@1366899390:pull_request`

The working role trust was aligned to the legitimate observed repository identity instead of being widened to an organization wildcard.

Reusable procedure:

1. Verify the GitHub OIDC provider.
2. Scope role trust to intended repo/branch/PR/environment.
3. Run STS `GetCallerIdentity` as the smallest identity proof.
4. If federation fails, inspect CloudTrail `AssumeRoleWithWebIdentity` events.
5. Compare actual WebIdentity principal/claims with trust conditions.
6. Adjust only to the observed legitimate identity.
7. Re-run and verify the assumed-role ARN before provisioning.

## Decision rule: which execution path to use

Use **direct AWS MCP** for:

- inventory/discovery;
- diagnosis/troubleshooting;
- CloudTrail/log investigation;
- live provider readback;
- cross-service checks;
- bounded, reversible, low-cost operations;
- independent verification after another deployment system runs.

Use **GitHub + IaC + OIDC** for durable infrastructure:

- networking;
- application infrastructure;
- databases;
- IAM architecture;
- persistent buckets/queues/tables/parameters;
- anything expected to be reviewed, rebuilt, drift-checked, or destroyed reproducibly.

Preferred durable loop:

`ChatGPT -> GitHub/IaC -> GitHub Actions/OIDC -> AWS -> AWS MCP verification`

Do not use direct API mutation as a silent replacement for Terraform/CloudFormation/CDK when durable desired state matters.

## IAM and MCP control lessons

- Normal IAM authorization remains the primary boundary.
- MCP-specific condition keys can add an additional request-path boundary.
- Use narrow explicit denies for high-risk MCP operations when appropriate.
- For IAM work, use the AWS IAM skill/guidance when available and verify trust + permission policies through live APIs.
- CloudTrail is the primary audit/diagnostic source for downstream AWS API activity and federation failures.

## GitHub OIDC lessons

- Prefer OIDC to long-lived AWS access keys.
- Trust policy is as important as permissions policy.
- Use repo-specific roles by default.
- Restrict subjects rather than allowing broad organization wildcards.
- Verify STS identity inside the workflow before provisioning.
- Include Terraform provider refresh/read permissions, not only create/update/delete APIs.
- After apply, perform provider readback and independent AWS MCP readback.
- After temporary tests, verify cleanup.

## Repository visibility model

Both active lab repositories are private:

- `mytestlab123/chatgpt-aws`
- `mytestlab123/lab1_agent`

Private visibility does **not** automatically authorize deployment. `lab1_agent` should still get its own scoped OIDC role/trust and project-specific Issue/SPEC authority.

## Cross-session operating procedure

For a new ChatGPT session working on an AWS repo:

1. **Load repo authority** — `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, active Issue/PR.
2. **Load shared AWS knowledge** — this file plus relevant evidence docs (`EXPERIMENTS`, `DRIFT_DEMO`, `AUTOMATION_CICD_LAB`).
3. **Verify connections** — GitHub read/write and AWS Core auth.
4. **Verify AWS identity** — STS `GetCallerIdentity`.
5. **Choose path** — direct MCP for live ops; GitHub + IaC + OIDC for durable state.
6. **Use repo-specific OIDC trust** for durable deployment.
7. **Execute the smallest useful milestone** instead of repeating proven connectivity tests.
8. **Verify final effects** — not only API acceptance.
9. **Provider/AWS MCP readback** — independently verify actual AWS state.
10. **Clean up or explicitly retain** every test resource/data item.
11. **Write learning back to Git** so the next session does not depend on chat memory.

## `lab1_agent` reuse contract

Another ChatGPT session working on `mytestlab123/lab1_agent` should:

1. read `lab1_agent/docs/CHATGPT_AWS_BOOTSTRAP.md`;
2. use GitHub to read this private source of truth;
3. authenticate/verify AWS Core separately;
4. read `lab1_agent` project contracts and active Issue/PR;
5. reuse the hybrid execution model and the Issue #9 automation lessons;
6. **not** reuse `github-actions-assignment-cicd-chatgpt-lab` or `github-actions-chatgpt-aws-lab` by assumption;
7. create a scoped `lab1_agent` OIDC role when its own durable AWS deployment milestone is authorized;
8. use CloudTrail first if federation fails.

## What is portable vs session-specific

### Portable through Git

- architecture decisions;
- MCP/API capability findings;
- verified experiments;
- OIDC trust/debug patterns;
- Terraform provider-permission lessons;
- run IDs and PR evidence;
- event-driven automation patterns;
- MCP-specific IAM control pattern;
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
- keep the reusable architecture, OIDC troubleshooting, drift/reconciliation, automation, and MCP-governance lessons.
