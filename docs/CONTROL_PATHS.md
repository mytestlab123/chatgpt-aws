# AWS Control Paths — Fast vs Deterministic

## Short answer

Yes. **Both paths are valid.** The difference is not that one path is "allowed" and the other is "wrong". The lab is deliberately testing **when to use each path and how IAM can distinguish them**.

The CodeBuild deny test proved this policy choice:

```text
GitHub OIDC -> StartBuild      = ALLOW
AWS Core MCP -> StartBuild     = DENY
AWS Core MCP -> Read/Diagnose  = ALLOW
```

We created that deny **on purpose**. AWS Core MCP can perform mutations when IAM allows them. The deny proves that AWS can apply stricter controls specifically to requests routed through the managed MCP service by using `aws:ViaAWSMCPService`.

## The two useful paths

### Path A — Direct AWS Core MCP

```text
ChatGPT -> AWS Core MCP -> AWS APIs
```

Best for **speed while exploring and operating**:

- inspect live resources;
- search/compare configuration;
- troubleshoot failures;
- read CloudTrail and logs;
- verify deployments independently;
- run a small reversible test;
- perform bounded one-off operations when durable desired state is not needed.

Advantages:

- fastest feedback loop;
- no repository/workflow change required for every investigation;
- excellent for multi-service diagnostics;
- ideal independent verifier after CI/CD runs.

Trade-off:

A direct API mutation is not automatically a durable specification. If ChatGPT changes a resource directly, the desired state exists in the live account unless that change is also represented in Git/IaC.

### Path B — Git + IaC + GitHub Actions + OIDC

```text
ChatGPT -> Git -> Terraform -> GitHub Actions -> OIDC -> AWS
```

Best for **deterministic development and deployment**:

- persistent infrastructure;
- IAM architecture;
- application environments;
- queues, state machines, databases, networking;
- repeatable CI/CD;
- reviewable production-style changes;
- drift detection and repair;
- rebuild/destroy from source control.

Advantages:

- Git is the durable desired state;
- PRs show exactly what changes;
- the same workflow can be replayed;
- Terraform can detect out-of-band drift;
- OIDC avoids static AWS credentials;
- roll-forward/rollback reasoning is clearer.

Trade-off:

It has more steps than a direct API call, so it is slower for exploratory troubleshooting.

## Recommended operating model

Use a **hybrid**, not one path exclusively.

```text
              FAST LOOP
ChatGPT -> AWS MCP -> inspect / diagnose / verify
                   |
                   | findings
                   v
              DURABLE LOOP
ChatGPT -> Git/IaC -> PR -> OIDC -> AWS
                   |
                   v
             AWS MCP verify
```

### During fast development

Use MCP aggressively for **read, discovery, diagnosis, verification, and harmless experiments**.

Once the experiment becomes something we intend to retain, move the durable state into Terraform/Git and let CI/CD own deployment.

A useful rule:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

This is not an absolute technical restriction. It is the preferred operating model for long-lived work.

## Why test an MCP-specific deny?

Because the two methods can be governed independently.

Without the deny, both of these can be technically possible when IAM permits them:

```text
GitHub OIDC -> StartBuild
AWS Core MCP -> StartBuild
```

Issue #18 deliberately changed that to:

```text
GitHub OIDC -> StartBuild      ALLOW
AWS Core MCP -> StartBuild     DENY
AWS Core MCP -> inspect logs   ALLOW
```

That proves an enterprise can say:

- AI/MCP may investigate;
- a reviewed CI/CD identity performs the deployment/execution action;
- the AI can then verify the result independently.

For a personal lab, we may choose to allow more MCP mutations when speed is useful. The important learning is that **the boundary is controllable**.

## Which is faster?

| Task | Preferred path |
|---|---|
| What exists right now? | MCP |
| Why did this fail? | MCP |
| Read logs / CloudTrail / configs | MCP |
| Quick reversible test | MCP |
| Create something temporary for investigation | MCP can be appropriate |
| Persistent AWS infrastructure | Git + Terraform + OIDC |
| Repeatable deployment | Git + Terraform/CI + OIDC |
| IAM architecture that must be reviewed | Git + IaC + OIDC |
| Drift detection | Terraform/IaC |
| Independent post-deploy proof | MCP |

## Development lifecycle recommendation

### Phase 1 — Explore quickly

```text
MCP -> discover -> inspect -> test hypothesis
```

### Phase 2 — Decide what should remain

If the resource/configuration should survive the experiment, represent it in Git/IaC.

### Phase 3 — Deploy deterministically

```text
PR -> tests -> OIDC -> Terraform/app deployment
```

### Phase 4 — Independently verify

```text
AWS MCP -> provider readback -> logs -> final effect
```

### Phase 5 — Diagnose drift/failure

Use MCP for rapid diagnosis, then fix the durable source in Git rather than silently patching long-lived infrastructure out of band.

## Current lab direction

Issue #21 demonstrates this recommended long-term model with Step Functions and SQS:

```text
Terraform owns:
  SQS
  Step Functions
  Step Functions execution role
  dedicated GitHub OIDC execution role

GitHub OIDC executes:
  StartExecution
  verify execution
  receive/delete the test SQS message

AWS Core MCP:
  inspect state machine
  inspect execution history
  inspect SQS
  inspect IAM
  independently verify final state

MCP StartExecution:
  deliberately denied for this one lab resource
```

This gives us fast AI-assisted operations without giving up deterministic infrastructure and deployment history.
