# ChatGPT + AWS Lab

A public, reusable, evidence-backed lab for working with **ChatGPT + AWS MCP + GitHub OIDC + Terraform**.

<div class="grid cards" markdown>

-   **One-URL agent bootstrap**

    Start a new ChatGPT/Codex/agent session without depending on chat memory.

    [Open PROMPT.md →](PROMPT.md)

-   **Public template security**

    Separate what repository code enforces from GitHub/AWS settings that must be configured outside Git.

    [Open security checklist →](PUBLIC_TEMPLATE_SECURITY.md)

-   **Portable AWS + MCP knowledge**

    Detailed evidence for control paths, OIDC lessons, drift handling, and cross-session reuse.

    [Open portable knowledge →](PORTABLE_AWS_MCP_KNOWLEDGE.md)

-   **Static documentation hosting**

    GitHub Pages vs AWS S3 + CloudFront, plus private-sharing options.

    [Open hosting guide →](STATIC_SITE_HOSTING_GUIDE.md)

-   **Automation + CI/CD lab**

    ECR, S3, EventBridge, Lambda, DynamoDB, CloudWatch, GitHub OIDC, and MCP-aware IAM.

    [Open automation lab →](AUTOMATION_CICD_LAB.md)

-   **Terraform drift demo**

    Direct AWS MCP drift detected and repaired through the GitHub/OIDC/Terraform desired-state path.

    [Open drift demo →](DRIFT_DEMO.md)

</div>

## Operating model

```text
                         ChatGPT
                        /       \
                       /         \
              AWS MCP             GitHub
                 |                  |
          inspect / verify       PR + IaC
                 |                  |
                 |             GitHub Actions
                 |                  |
                 |                OIDC
                 |                  |
                 +-------- AWS -----+
```

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

## Public-repository safety model

```text
Pull request
  -> credential-free tests / validation / docs build

Reviewed main
  -> deliberate manual workflow
  -> short-lived OIDC
  -> AWS
  -> MCP independent readback
```

This separation matters because unreviewed public PR code should not receive the AWS execution identity merely to make CI convenient.

## Verified labs

| Lab | What it proves | Status |
|---|---|---|
| Direct AWS MCP | Authenticated AWS reads and bounded writes | ✅ Verified |
| GitHub OIDC | Short-lived AWS credentials without stored AWS keys | ✅ Verified |
| Terraform persistent state | Durable IaC through GitHub Actions + OIDC | ✅ Verified |
| Drift detection | MCP drift detected and repaired by Terraform | ✅ Verified |
| ECR CI/CD | Build → push → verify → cleanup | ✅ Verified |
| S3 automation | S3 → Lambda → DynamoDB | ✅ Verified |
| EventBridge automation | EventBridge → Lambda → DynamoDB | ✅ Verified |
| MCP-aware IAM | Selected actions denied specifically on the MCP path | ✅ Verified |
| Public PR boundary | PR validation without AWS OIDC/live AWS | ✅ Verified |

## Documentation migration

This repository is now **public**, so the preferred long-term documentation path is the same repository:

`docs/ -> Material for MkDocs -> GitHub Actions -> GitHub Pages`

Target URL: `https://mytestlab123.github.io/chatgpt-aws/`

The site build and artifact upload are working. GitHub Pages itself still needs the one-time repository setting **Settings -> Pages -> Source: GitHub Actions**. Until the new site is live and verified, the existing CloudFront site and `chatgpt-aws-docs` remain intact.

## Repository role

`mytestlab123/chatgpt-aws` is the **public primary reference repository**. Other sessions/repos may reuse its patterns, but must independently verify GitHub access, AWS identity, repository authority, and repo-specific OIDC trust before mutation.
