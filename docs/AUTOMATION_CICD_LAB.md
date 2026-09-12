# Automation + CI/CD AWS Service Matrix Lab

Issue: #9
Status: **IN PROGRESS**
Region: `ap-southeast-1`
Context: PERSONAL / LAB

## Goal

Prove several reusable AWS automation and CI/CD patterns in one cohesive private lab package rather than isolated toy tests.

## Architecture

### CI/CD artifact path

`GitHub Actions -> GitHub OIDC -> AWS role -> Docker build -> Amazon ECR -> verify -> delete test image`

Persistent resource: private ECR repository `chatgpt-aws-cicd-lab`.

### Event-driven automation path

Two independent triggers feed the same recorder Lambda:

`S3 object create -> Lambda -> DynamoDB`

`EventBridge custom event -> Lambda -> DynamoDB`

CloudWatch Logs retains Lambda logs for one day. Smoke-test DynamoDB items have TTL and are also explicitly deleted by the workflow after verification.

Persistent resources:

- private S3 bucket `chatgpt-aws-automation-<account-id>`;
- Lambda `chatgpt-aws-automation-recorder`;
- DynamoDB table `chatgpt-aws-automation-events` using PAY_PER_REQUEST;
- EventBridge rule `chatgpt-aws-automation-events`;
- CloudWatch Logs group `/aws/lambda/chatgpt-aws-automation-recorder` with 1-day retention;
- Lambda execution role `chatgpt-aws-automation-lambda`.

### MCP-aware governance path

Official AWS documentation states that managed AWS MCP servers add global condition context keys to downstream AWS requests:

- `aws:ViaAWSMCPService` — Boolean `true` for requests routed through an AWS managed MCP server;
- `aws:CalledViaAWSMCP` — string identifying the specific MCP service principal, such as `aws-mcp.amazonaws.com`.

Issue #9 uses a deliberately narrow user-policy guard:

- principal: existing PERSONAL/LAB AWS Core identity;
- action denied: `s3:DeleteObject`;
- resource: only `mcp-guard/protected.txt` in the Issue #9 lab bucket;
- condition: `aws:ViaAWSMCPService = true`.

Expected proof:

1. GitHub Actions OIDC can create/delete an equivalent temporary object because it is not an MCP-routed request.
2. AWS Core MCP can read the retained protected fixture but receives `AccessDenied` if it tries to delete it.
3. The protected fixture remains present after the denied operation.

This shows the control can differentiate *how* an AWS request arrived, not only which IAM identity is involved.

## Terraform state

Remote state reuses the private/versioned/encrypted lab state bucket with a separate key:

`state/chatgpt-aws/automation-cicd.tfstate`

## Validation sequence

1. PR: OIDC identity -> Terraform init -> fmt -> validate -> plan.
2. Main: Terraform apply.
3. ECR: build -> push -> describe digest -> delete image -> verify repo empty.
4. S3 automation: upload `events/<run>.txt` -> poll deterministic DynamoDB key -> delete object/item.
5. EventBridge automation: `PutEvents` -> poll deterministic DynamoDB key -> delete item.
6. GitHub OIDC creates/deletes a temporary object under `mcp-guard/`.
7. Provider readback verifies ECR, S3 public-access block, retained guard fixture, Lambda, DynamoDB, EventBridge and CloudWatch Logs.
8. AWS Core MCP independently verifies the retained state and tests the MCP-specific delete deny.

## Cost / cleanup model

- No public endpoints.
- Lambda is 128 MB and only invoked by smoke tests.
- DynamoDB is on-demand; smoke-test rows are explicitly deleted and also have one-hour TTL.
- CloudWatch log retention is one day.
- ECR test images are deleted by the workflow; the empty repository is retained.
- S3 smoke-test objects are deleted; one tiny Terraform-managed governance fixture is retained.
- EventBridge rule only matches the lab source/detail type.

## Evidence

Pending PR/main workflow execution. Actual run IDs, exact Terraform plan, smoke-test results, MCP deny evidence, and final provider readback will be appended here before Issue #9 is closed.

## AWS source used for MCP condition keys

AWS documentation: **How AWS MCP Server works with IAM** — the managed AWS MCP Server adds `aws:ViaAWSMCPService` and `aws:CalledViaAWSMCP` to downstream requests, enabling IAM/SCP differentiation between MCP-routed and direct API calls.
