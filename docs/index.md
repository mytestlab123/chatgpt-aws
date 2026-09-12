# ChatGPT + AWS Lab

A reusable, evidence-backed lab for working with **ChatGPT + AWS Core MCP + GitHub + OIDC + Terraform**.

<div class="grid cards" markdown>

-   **Start another ChatGPT session**

    Reuse the verified AWS/GitHub setup without depending on previous-chat memory.

    [Open session bootstrap →](SESSION_BOOTSTRAP.md)

-   **Portable AWS + MCP knowledge**

    The durable source of truth for identities, execution paths, OIDC lessons, drift handling, and cross-session reuse.

    [Open portable knowledge →](PORTABLE_AWS_MCP_KNOWLEDGE.md)

-   **Automation + CI/CD lab**

    ECR, S3, EventBridge, Lambda, DynamoDB, CloudWatch, GitHub OIDC, and MCP-aware IAM in one tested lab.

    [Open automation lab →](AUTOMATION_CICD_LAB.md)

-   **Terraform drift demo**

    See direct AWS MCP drift detected and repaired through the GitHub/OIDC/Terraform desired-state path.

    [Open drift demo →](DRIFT_DEMO.md)

</div>

## Operating model

```text
                         ChatGPT
                        /       \
                       /         \
              AWS Core MCP       GitHub
                   |               |
            inspect / verify     PR + IaC
                   |               |
                   |          GitHub Actions
                   |               |
                   |             OIDC
                   |               |
                   +------ AWS ----+
```

### Use AWS Core MCP when

- discovering live AWS state;
- troubleshooting and cross-service inspection;
- reading logs, CloudTrail, IAM, and provider state;
- making bounded reversible lab changes;
- independently verifying what CI/CD or Terraform deployed.

### Use GitHub + IaC + OIDC when

- the resource should have durable desired state;
- changes should be reviewed and reproducible;
- Terraform drift detection matters;
- the same deployment should be repeatable by another ChatGPT session.

!!! tip "Default pattern"
    Prefer **GitHub/IaC for durable state** and **AWS Core MCP for live verification and operations**.

## Visual learning page

The repository also contains a self-contained visual walkthrough of the automation + CI/CD experiment.

[Open Amit's visual Automation + CI/CD lab →](AMIT_AUTOMATION_CICD_LAB.html)

## Verified labs

| Lab | What it proves | Status |
|---|---|---|
| Direct AWS MCP | Authenticated AWS reads and bounded writes | ✅ Verified |
| GitHub OIDC | GitHub Actions can obtain short-lived AWS credentials without stored AWS keys | ✅ Verified |
| Terraform persistent state | Durable IaC through GitHub Actions + OIDC | ✅ Verified |
| Drift detection | MCP drift is detected and repaired by Terraform | ✅ Verified |
| ECR CI/CD | Build → push → verify → cleanup | ✅ Verified |
| S3 automation | S3 → Lambda → DynamoDB | ✅ Verified |
| EventBridge automation | EventBridge → Lambda → DynamoDB | ✅ Verified |
| MCP-aware IAM | Destructive action denied specifically when routed through AWS managed MCP | ✅ Verified |

## Repository role

`mytestlab123/chatgpt-aws` is the **private primary knowledge source**. Other ChatGPT sessions and repos, including `mytestlab123/lab1_agent`, should consume the portable knowledge here but must independently verify their own GitHub access, AWS identity, and repo-specific OIDC authority before mutation.
