# ChatGPT AWS Lab

Personal LAB for proving how ChatGPT can inspect, mutate, provision, verify, and document AWS through two independent control paths.

## Start Here — One URL

For a new ChatGPT/Codex/agent session, start with:

**`PROMPT.md`**  
`https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md`

`PROMPT.md` is the canonical portable bootstrap. It explains the verified operating model, startup identity checks, AWS MCP vs GitHub OIDC/IaC decision, security baseline, single-public-repository mode, and how to bootstrap a new AWS repository without copying this lab's identities.

After that, read repository-specific authority such as `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, and the active Issue/PR as needed.

## Documentation

The `docs/` knowledge base is published with **Material for MkDocs**.

- **Live site:** `https://d36j5fck6lkl41.cloudfront.net/`
- Source: `docs/`
- Configuration: `mkdocs.yml`
- AWS hosting IaC: `infra/docs-site/`
- Build/deploy workflow: `.github/workflows/docs-aws.yml`
- Hosting evidence/runbook: `docs/HOSTING.md`

The source repository currently remains private. The generated documentation is served publicly through CloudFront from a private S3 bucket protected by Origin Access Control (OAC).

The existing Markdown paths remain stable so other sessions can continue to reference files such as `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` and `docs/SESSION_BOOTSTRAP.md` directly.

## Proven control paths

1. **Direct MCP:** ChatGPT -> AWS Core MCP -> AWS APIs for discovery, diagnosis, bounded experiments, and independent verification.
2. **GitOps/IaC:** ChatGPT -> GitHub -> GitHub Actions -> OIDC -> Terraform -> AWS for durable reviewed state.

Preferred rule:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

## Template direction

For a personal learning project, one **public** repository can contain IaC, workflows, docs, and GitHub Pages when all committed content is safe for public disclosure.

For private/company/sensitive work, keep the engineering repository private and publish only an intentional curated subset when public documentation is required.

Do not reuse this lab's AWS account IDs, role ARNs, resource names, or OIDC roles in another repository. Create new repo-specific trust and state.

## Current docs-repository transition

`mytestlab123/chatgpt-aws-docs` remains a publication target while this repository is private. The curated source already exists under `public-docs/`, so there is nothing to manually merge back before a future consolidation.

Do not delete the docs repository until a replacement public repository is live, GitHub Pages is verified there, and links are updated. See `PROMPT.md` for the retirement checklist.

Keep experiments reversible, low-cost, reviewable, and evidence-backed. Never commit credentials or authentication state.
