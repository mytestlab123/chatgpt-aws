# Step Functions + SQS OIDC/MCP Lab

Status: **VERIFIED / PASS — Issue #21**  
Environment: **PERSONAL / LAB**  
Region: `ap-southeast-1`

## Goal

Prove the recommended long-term split:

```text
Git + Terraform + GitHub OIDC = durable desired state and execution
AWS Core MCP                  = fast inspect / diagnose / verify
```

This lab is independent of `lab1_agent`.

## Final architecture

```text
GitHub PR
   |
   v
Terraform plan
   |
main merge
   |
   v
GitHub Actions -> infrastructure OIDC role
   |
   v
Terraform apply
   |
   +--> SQS queue
   +--> Step Functions state machine
   +--> Step Functions service role
   +--> dedicated GitHub runtime OIDC role

GitHub Actions -> dedicated runtime OIDC role
   |
   v
Step Functions StartExecution
   |
   v
SQS SendMessage
   |
   v
workflow verifies marker + deletes message

AWS Core MCP
   |
   +--> inspect state machine / execution / IAM / queue
   +--> StartExecution deliberately DENIED for this lab
```

## Terraform-owned durable resources

Terraform directory: `infra/sfn-sqs/`  
Terraform state: `state/chatgpt-aws/sfn-sqs.tfstate`

Retained resources:

- SQS queue `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions state machine `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions service role `chatgpt-aws-sfn-sqs-smoke`;
- dedicated GitHub runtime OIDC role `github-actions-chatgpt-aws-sfn-lab`.

The existing `github-actions-chatgpt-aws-lab` role remains the infrastructure deployment identity. Its permissions are scoped to the named Issue #21 resources.

## PR proof

PR #22:

`https://github.com/mytestlab123/chatgpt-aws/pull/22`

Successful PR workflow:

`34687644771` — **PASS**

Terraform plan:

```text
Plan: 6 to add, 0 to change, 0 to destroy.
```

All documentation and existing lab checks also passed before merge.

## Main deterministic deployment proof

PR #22 squash merge:

`e7a4172d6a8148513f379d9780f8b2569d72e504`

Main workflow:

`34687707682`, attempt 3 — **PASS**

The final successful attempt proved both jobs:

```text
terraform = SUCCESS
smoke     = SUCCESS
```

### Why three attempts?

This produced useful least-privilege evidence.

The first main apply exposed a missing Terraform provider/API permission:

`states:ValidateStateMachineDefinition`

After adding it, the next apply created the state machine but exposed another provider read permission:

`states:ListStateMachineVersions`

After adding that narrowly, the third attempt reconciled the partial Terraform state and passed end-to-end.

Reusable lesson:

> Terraform least privilege includes the provider's validation and refresh/read APIs, not only obvious create/update/delete operations.

## GitHub OIDC runtime proof

The dedicated runtime role:

`github-actions-chatgpt-aws-sfn-lab`

successfully started the state machine from GitHub Actions.

Verified GitHub execution:

`arn:aws:states:ap-southeast-1:063884340510:execution:chatgpt-aws-sfn-sqs-smoke:gh-34687707682-3`

Final status:

`SUCCEEDED`

Independent AWS Core MCP history contained:

```text
ExecutionStarted
TaskStateEntered
TaskScheduled
TaskStarted
TaskSucceeded
TaskStateExited
PassStateEntered
PassStateExited
ExecutionSucceeded
```

This independently proves that Step Functions executed the SQS task and completed successfully.

## SQS final-effect proof

The state machine sent:

```text
marker = OIDC-SFN-SQS-PASS
source = step-functions
```

The GitHub workflow received the marker and deleted the test message.

AWS Core MCP independently verified the queue returned to:

```text
ApproximateNumberOfMessages           = 0
ApproximateNumberOfMessagesNotVisible = 0
```

## MCP-specific governance proof

The PERSONAL/LAB AWS Core identity has the narrow inline policy:

`ChatGPTAwsMCPSfnGuard`

which denies only:

```json
{
  "Effect": "Deny",
  "Action": "states:StartExecution",
  "Resource": "arn:aws:states:ap-southeast-1:063884340510:stateMachine:chatgpt-aws-sfn-sqs-smoke",
  "Condition": {
    "Bool": {
      "aws:ViaAWSMCPService": "true"
    }
  }
}
```

Final control split:

```text
GitHub OIDC -> StartExecution                 = ALLOW / PASS
AWS Core MCP -> Describe/GetHistory/IAM/SQS  = ALLOW / PASS
AWS Core MCP -> StartExecution                = DENY / PASS
```

The direct MCP `StartExecution` call returned explicit `AccessDenied` after IAM policy propagation.

### IAM propagation lesson

The first negative test was made immediately after `PutUserPolicy`. It was still allowed and produced one test execution/message because the new IAM deny had not propagated yet.

The test message was deleted. After a short propagation wait, the same MCP `StartExecution` operation returned the expected explicit deny and the queue remained empty.

Reusable rule:

> After changing IAM, do not use the first immediate authorization result as final evidence. Re-read the policy, allow for IAM propagation, retry, and verify the downstream state.

This is also direct evidence that **MCP mutation is technically possible when IAM permits it**. The deny is our governance choice, not an AWS Core limitation.

## What Issue #21 proves

For fast work:

```text
AWS MCP -> inspect / diagnose / test / verify
```

For durable deterministic work:

```text
Git -> Terraform/IaC -> PR -> GitHub Actions -> OIDC -> AWS
```

Then independently:

```text
AWS MCP -> verify actual AWS state and final effect
```

Preferred rule:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

Detailed education: `docs/CONTROL_PATHS.md`.

## Retained resources

Retained intentionally for later PERSONAL/LAB testing:

- Terraform state `state/chatgpt-aws/sfn-sqs.tfstate`;
- SQS queue `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions state machine `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions service role `chatgpt-aws-sfn-sqs-smoke`;
- GitHub runtime OIDC role `github-actions-chatgpt-aws-sfn-lab`;
- narrow MCP guard `ChatGPTAwsMCPSfnGuard`.
