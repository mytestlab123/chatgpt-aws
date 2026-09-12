# Automation + CI/CD AWS Service Matrix Lab

Issue: #9  
Status: **VERIFIED / PASS**  
Region: `ap-southeast-1`  
Context: PERSONAL / LAB

## Goal

Prove several reusable AWS automation and CI/CD patterns in one cohesive private lab package rather than isolated toy tests.

## Architecture

### 1. CI/CD artifact path

`GitHub Actions -> GitHub OIDC -> AWS role -> Docker build -> Amazon ECR -> verify digest -> delete test image`

Persistent resource: private ECR repository `chatgpt-aws-cicd-lab`.

### 2. Event-driven automation path

Two independent triggers feed the same recorder Lambda:

`S3 object create -> Lambda -> DynamoDB`

`EventBridge custom event -> Lambda -> DynamoDB`

CloudWatch Logs retains Lambda logs for one day. Smoke-test DynamoDB items have one-hour TTL and are also explicitly deleted after verification.

Persistent resources:

- private S3 bucket `chatgpt-aws-automation-063884340510`;
- Lambda `chatgpt-aws-automation-recorder`;
- DynamoDB table `chatgpt-aws-automation-events` using PAY_PER_REQUEST;
- EventBridge rule `chatgpt-aws-automation-events`;
- CloudWatch Logs group `/aws/lambda/chatgpt-aws-automation-recorder` with 1-day retention;
- Lambda execution role `chatgpt-aws-automation-lambda`.

### 3. MCP-aware governance path

Official AWS documentation states that managed AWS MCP servers add global condition context keys to downstream AWS requests:

- `aws:ViaAWSMCPService` — Boolean `true` for requests routed through an AWS managed MCP server;
- `aws:CalledViaAWSMCP` — identifies the specific managed MCP service principal, such as `aws-mcp.amazonaws.com`.

Issue #9 uses a deliberately narrow inline guard on the PERSONAL/LAB AWS Core identity:

- action denied: `s3:DeleteObject`;
- resource: only `mcp-guard/protected.txt` in the Issue #9 lab bucket;
- condition: `aws:ViaAWSMCPService = true`.

This proves IAM can distinguish **how a request arrived**, not only which user or role sent it.

## Terraform state

Remote state reuses the private/versioned/encrypted lab state bucket with a separate key:

`state/chatgpt-aws/automation-cicd.tfstate`

## Verified evidence

### PR validation

Implementation PR: **#10 — Build multi-service AWS automation and CI/CD lab**.

Successful PR workflow run: `34676895495`.

- GitHub OIDC authentication: PASS.
- Terraform init: PASS.
- Terraform fmt/validate: PASS.
- Initial Terraform plan: **`15 to add, 0 to change, 0 to destroy`**.

Earlier PR attempts exposed only formatting drift; the branch was corrected before merge.

### Main deployment and smoke tests

PR #10 merged at commit `0a5036045863cfc243718f512e8d3fc837affc6a`.

Main automation workflow: `34676955227`.

Attempts 1 and 2 were useful permission-discovery failures during Terraform provider refresh:

- missing `s3:GetAccelerateConfiguration`;
- missing `events:ListTagsForResource`;
- then missing `s3:GetLifecycleConfiguration`.

The repo-specific GitHub OIDC role was updated only for the named Issue #9 lab resources. The reusable lesson is that Terraform needs **provider read/refresh permissions in addition to obvious create/update/delete permissions**.

Because the failed applies had partially created resources, Terraform marked the affected S3 bucket and EventBridge rule as tainted. Attempt 3 safely reconciled the partial state.

Successful attempt: **run `34676955227`, attempt 3**.

- Terraform apply: PASS.
- Reconciliation apply result: **`9 added, 0 changed, 2 destroyed`**.
- ECR build/push/digest verification/delete: PASS.
- S3 -> Lambda -> DynamoDB: PASS.
- EventBridge -> Lambda -> DynamoDB: PASS.
- GitHub OIDC temporary S3 create/delete: PASS.
- Provider readback: PASS.

### ECR proof

Test image tag:

`run-34676955227-3`

Verified pushed digest:

`sha256:97c45707dd8b16ce4f5d3bb4a9c31682755443e3bd2628e8176365e5a08ce5f3`

The workflow then deleted the test image and verified the retained ECR repository contained **0 images**.

### Automation proof

The main workflow generated deterministic evidence IDs and polled DynamoDB until the final effect was visible.

Both paths passed:

1. `S3 events/<run>.txt -> Lambda -> DynamoDB`.
2. `EventBridge PutEvents -> rule -> Lambda -> DynamoDB`.

Smoke-test S3 objects and DynamoDB rows were deleted after verification.

### MCP-specific IAM proof

GitHub OIDC proved the non-MCP cleanup path by creating and deleting a temporary object under `mcp-guard/`.

AWS Core MCP independently tested deletion of the retained fixture:

`s3://chatgpt-aws-automation-063884340510/mcp-guard/protected.txt`

Result: **AccessDenied as designed**, with an explicit identity-policy deny.

AWS Core performed `HeadObject` before and after the denied delete. The object existed both times with the same ETag, proving the destructive MCP action was blocked and the fixture remained intact.

## Independent AWS Core final readback

After the successful workflow, AWS Core MCP independently verified:

- caller: `arn:aws:iam::063884340510:user/devsecops`;
- ECR repository exists and contains **0 images**;
- S3 public-access block: all four controls `true`;
- S3 encryption: `AES256`;
- only retained S3 object: `mcp-guard/protected.txt`;
- DynamoDB table: `ACTIVE`, PAY_PER_REQUEST, **0 smoke-test items remaining**;
- Lambda: `Active`, update status `Successful`, Python `3.12`, 128 MB, 10-second timeout;
- Lambda environment points to `chatgpt-aws-automation-events`;
- EventBridge rule: `ENABLED`, target is `chatgpt-aws-automation-recorder`;
- CloudWatch log group exists with **1-day retention**;
- Lambda execution policy allows only DynamoDB evidence writes and Lambda log writes;
- `ChatGPTAwsMCPGuard` still contains the expected `aws:ViaAWSMCPService=true` delete deny.

## What this milestone proves

1. **Real CI/CD without static AWS keys** — GitHub OIDC can build and deliver a container artifact to ECR.
2. **Reusable event-driven automation** — different producers can drive the same Lambda worker and evidence store.
3. **End-to-end tests should verify the outcome** — the workflow waited for DynamoDB evidence instead of stopping after `PutObject` or `PutEvents` returned success.
4. **Terraform remains durable desired state** — even partial failed applies were reconciled on the next run.
5. **MCP can have stricter controls than CI/CD** — an MCP-origin delete was denied while the normal OIDC cleanup path remained functional.
6. **Provider refresh permissions matter** — least privilege must include the read APIs Terraform uses to refresh existing resources.

## Cost / cleanup model

- No public endpoints.
- Lambda is 128 MB and invoked only by tests/events.
- DynamoDB is on-demand and currently empty.
- CloudWatch log retention is one day.
- ECR repository is retained but currently empty.
- S3 retains only one tiny Terraform-managed governance fixture.
- EventBridge rule matches only the lab source/detail type.

## AWS source used for MCP condition keys

AWS documentation: **How AWS MCP Server works with IAM** — the managed AWS MCP Server adds `aws:ViaAWSMCPService` and `aws:CalledViaAWSMCP` to downstream requests, enabling IAM/SCP differentiation between MCP-routed and direct API calls.
