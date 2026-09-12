# Step Functions + SQS OIDC/MCP Lab

Status: **ACTIVE / Issue #21**  
Environment: **PERSONAL / LAB**  
Region: `ap-southeast-1`

## Goal

Prove the recommended long-term split:

```text
Git + Terraform + GitHub OIDC = durable desired state and execution
AWS Core MCP                  = fast inspect / diagnose / verify
```

This lab is independent of `lab1_agent`.

## Architecture

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
   +--> dedicated GitHub execution OIDC role

GitHub Actions -> dedicated execution OIDC role
   |
   v
Step Functions StartExecution
   |
   v
SQS SendMessage
   |
   v
workflow receives marker + deletes message

AWS Core MCP
   |
   +--> inspect state machine / execution / IAM / queue
   +--> StartExecution deliberately denied for this lab
```

## Durable Terraform resources

Terraform directory:

`infra/sfn-sqs/`

Planned retained resources:

- SQS queue `chatgpt-aws-sfn-sqs-smoke`;
- Step Functions state machine `chatgpt-aws-sfn-sqs-smoke`;
- service role `chatgpt-aws-sfn-sqs-smoke`;
- dedicated GitHub execution role `github-actions-chatgpt-aws-sfn-lab`.

Terraform state:

`state/chatgpt-aws/sfn-sqs.tfstate`

The existing `github-actions-chatgpt-aws-lab` role is the infrastructure deployment identity. Its permissions were extended only for this named queue/state machine and the two named IAM roles required by Issue #21.

## Runtime execution role

The dedicated GitHub role is intended only for this lab's runtime operations:

- start the named state machine;
- describe its executions/history;
- read and delete the marker message from the named SQS queue.

It does not own general AWS deployment permissions.

## State machine behavior

The state machine uses the optimized Step Functions -> SQS integration:

```text
Start
  |
  v
SendQueueMessage
  marker = OIDC-SFN-SQS-PASS
  |
  v
Complete
  |
  v
SUCCEEDED
```

The GitHub workflow waits for `SUCCEEDED`, receives the queue message, checks the marker, and deletes the message.

## MCP governance test

After Terraform creates the state machine, AWS Core will install a narrow guard on the PERSONAL/LAB MCP identity:

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

Expected control split:

```text
GitHub OIDC -> StartExecution = ALLOW
AWS Core MCP -> StartExecution = DENY
AWS Core MCP -> Describe/GetHistory/queue readback = ALLOW
```

The deny is a deliberate governance experiment, not an AWS MCP limitation.

## Why this lab matters

Issue #18 proved the split with CodeBuild. Issue #21 extends it to orchestration and messaging while putting the durable resources under Terraform.

That makes the model closer to long-term engineering practice:

> **Use MCP for speed of understanding. Use Git/IaC/OIDC for deterministic state. Use MCP again to verify reality.**

Detailed decision guidance: `docs/CONTROL_PATHS.md`.
