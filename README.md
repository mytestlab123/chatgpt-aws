# ChatGPT AWS Lab

Public personal lab/reference for working with **ChatGPT + AWS MCP + GitHub Actions + OIDC + Terraform** without requiring a local CLI for the normal workflow.

## Start here — one URL

Give a new ChatGPT/Codex/agent this file first:

**https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md**

`PROMPT.md` is the canonical portable bootstrap. It explains identity checks, AWS MCP vs GitHub OIDC/IaC, public-repo safety, and how to bootstrap a new repository without copying this lab's identities.

## Proven operating model

```text
ChatGPT / agent
  ├─ AWS MCP -> inspect / diagnose / verify
  └─ GitHub -> IaC -> Actions -> OIDC -> AWS
```

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

Public pull requests are intentionally credential-free. Live AWS workflows are manual, main-only, explicitly bound jobs.

## Documentation

Source: `docs/` + `mkdocs.yml`

Same-repo GitHub Pages target:

`https://mytestlab123.github.io/chatgpt-aws/`

Current migration status:

- repository is **public**;
- strict Material build and Pages artifact upload pass;
- same-repo Pages still needs the one-time repository setting **Settings -> Pages -> Source: GitHub Actions**;
- the existing CloudFront docs site remains available at `https://d36j5fck6lkl41.cloudfront.net/` until the new Pages site is verified;
- `mytestlab123/chatgpt-aws-docs` remains a temporary legacy/rollback publication path and should not be deleted yet.

## Template security

Code controls are only part of the boundary. For a reusable public repo also configure `main` protection/rulesets, minimal Actions token permissions, exact repository-scoped AWS OIDC trust, and Pages settings.

See `docs/PUBLIC_TEMPLATE_SECURITY.md`.

## Do not copy identities

Historical account IDs, role ARNs, resource names, workflow runs, and retained lab resources in this repository are evidence only. A new repository should create its own OIDC role/trust, state keys, variables, and resource names.

Keep experiments reversible, low-cost, reviewable, and evidence-backed. Never commit credentials, authentication state, Terraform state, or raw plan files.
