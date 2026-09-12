# AWS Control Paths — Fast vs Deterministic

## Short answer

Yes. **Both paths are technically possible when IAM allows them.**

The lab is not proving that MCP is incapable of mutation. We are deliberately testing whether AWS can apply **different governance to the MCP request path**.

That is why we created tests such as:

```text
GitHub OIDC -> StartBuild / StartExecution = ALLOW
AWS Core MCP -> same execution action      = DENY
AWS Core MCP -> read / diagnose / verify   = ALLOW
```

The deny is a policy choice implemented with `aws:ViaAWSMCPService=true`.

Issue #21 gave an especially clear proof: immediately after the new deny was written, IAM propagation had not completed and MCP successfully started one Step Functions execution. After propagation, the same MCP call returned explicit `AccessDenied`. This proves the capability and the governance boundary are separate concepts.

## Path A — Direct AWS Core MCP

```text
ChatGPT -> AWS Core MCP -> AWS APIs
```

Use this for the **fastest engineering feedback loop**:

- inspect what exists now;
- compare configuration across services;
- troubleshoot failures;
- read logs and CloudTrail;
- investigate permissions;
- test a hypothesis;
- perform bounded/reversible operations;
- independently verify a CI/CD deployment.

### Why it is fast

There is no need to first create a branch, write Terraform, wait for CI, merge, and deploy simply to answer:

> Why is this broken?

or:

> What is AWS actually doing right now?

MCP lets ChatGPT work against the live control plane directly.

### Where direct MCP is weaker

A direct API mutation does **not automatically become durable desired state**.

If MCP creates or edits a long-lived resource directly, then the live AWS account may know about the change while Git/Terraform does not.

That creates possible drift and makes deterministic rebuild/review harder.

## Path B — Git + IaC + GitHub Actions + OIDC

```text
ChatGPT -> Git -> Terraform/IaC -> PR -> GitHub Actions -> OIDC -> AWS
```

Use this for **long-term deterministic development and deployment**:

- persistent infrastructure;
- IAM roles and policies;
- queues, state machines, databases, networking;
- repeatable application/infrastructure deployment;
- reviewable production-style changes;
- drift detection;
- rebuild and disaster recovery;
- team handoff and audit history.

### Why this is deterministic

Git records the intended state.

Terraform/IaC converts that state into a repeatable plan.

GitHub Actions provides a consistent execution environment.

OIDC supplies short-lived AWS credentials without stored AWS access keys.

The result is:

```text
same source
   + same reviewed workflow
   + controlled identity
   = repeatable deployment
```

## Which path is faster?

| Task | Preferred path |
|---|---|
| What resources exist now? | **MCP** |
| Why did this AWS operation fail? | **MCP** |
| Read logs / CloudTrail / IAM state | **MCP** |
| Compare many AWS resources | **MCP** |
| Quick reversible experiment | **MCP** |
| Independent verification after deployment | **MCP** |
| Persistent infrastructure | **Git + IaC + OIDC** |
| Repeatable deployment | **Git + CI/CD + OIDC** |
| IAM architecture that should survive/rebuild | **Git + IaC + OIDC** |
| Drift detection / reconciliation | **Terraform/IaC** |
| Long-term production-style delivery | **Git + IaC + CI/CD + OIDC** |

## Recommended model for fast development

Do **not** force every investigation through a slow IaC loop.

Use:

```text
1. MCP      -> inspect / diagnose / test
2. Decide   -> should this change remain?
3. Git/IaC  -> encode the durable change
4. OIDC CI  -> deploy it
5. MCP      -> independently verify reality
```

This gives both speed and discipline.

A concise rule:

> **MCP is the fast live AWS engineering path. Git/IaC/OIDC is the durable delivery path.**

Or, more operationally:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

## Recommended model for long-term deterministic development

For anything expected to live beyond the experiment, default to:

```text
Git
 |
 v
Terraform / CloudFormation / CDK
 |
 v
PR + tests
 |
 v
GitHub Actions
 |
 v
OIDC short-lived AWS identity
 |
 v
AWS
 |
 v
MCP independent verification
```

This should be our normal pattern for retained AWS infrastructure.

Direct MCP can still be used during that lifecycle for:

- debugging a failed pipeline;
- reading current service state;
- validating IAM;
- checking logs;
- proving the deployed result;
- bounded operational remediation when appropriate.

## Why test MCP-specific denies?

Because technically allowing an AI agent to perform an operation and operationally choosing that it should perform the operation are different questions.

For example, without a deny and with sufficient IAM permission, both can be valid:

```text
GitHub OIDC -> states:StartExecution
AWS MCP     -> states:StartExecution
```

But an organization may deliberately choose:

```text
AI/MCP         -> investigate + recommend + verify
CI/CD identity -> perform selected deployment/execution actions
```

AWS managed MCP request context allows that distinction.

Our tests prove we can keep the AI very capable without requiring every sensitive execution path to be directly callable by the MCP identity.

For this personal lab we can choose a more permissive policy when speed is useful. The important result is that **we can choose the boundary instead of having it imposed on us**.

## Proven examples

### CodeBuild — Issue #18

```text
GitHub OIDC -> CodeBuild StartBuild = ALLOW
AWS MCP     -> CodeBuild read/logs  = ALLOW
AWS MCP     -> CodeBuild StartBuild = DENY
```

### Step Functions + SQS — Issue #21

Terraform owns:

```text
SQS queue
Step Functions state machine
Step Functions execution role
dedicated GitHub runtime OIDC role
```

GitHub OIDC successfully executed:

```text
StartExecution
      |
      v
Step Functions
      |
      v
SQS marker: OIDC-SFN-SQS-PASS
      |
      v
verify + delete marker
```

Main workflow `34687707682`, attempt 3: **PASS**.

AWS Core independently verified execution `gh-34687707682-3` as `SUCCEEDED`, including `TaskSucceeded` and `ExecutionSucceeded`, and verified the queue returned to zero messages.

After IAM propagation, direct MCP `states:StartExecution` returned explicit `AccessDenied` while MCP read/diagnose operations continued to work.

Detailed evidence: `docs/SFN_SQS_OIDC_MCP_LAB.md`.

## Practical decision rule

When deciding what ChatGPT should do next, ask one question:

> **Is this learning/operating against live AWS, or is this defining state we want to keep?**

If it is primarily **learning, diagnosis, readback, or a reversible test** → use MCP.

If it is **state we want to keep, reproduce, review, or deploy repeatedly** → put it in Git/IaC and deploy with OIDC CI/CD.

When both are useful → use the hybrid loop. That should be our default.
