# ChatGPT AWS Lab

Public personal lab/reference for working with **ChatGPT + AWS MCP + GitHub Actions + OIDC + Terraform** without requiring a local CLI for the normal workflow.

## Start here — one URL

Give a new ChatGPT/Codex/agent this file first:

**https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md**

`PROMPT.md` is the canonical portable bootstrap.

## Proven operating model

```text
ChatGPT / agent
  ├─ AWS MCP -> inspect / diagnose / verify
  └─ GitHub -> IaC -> Actions -> OIDC -> AWS
```

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

Public pull requests are credential-free. Live AWS workflows are manual, main-only, explicitly bound jobs.

## Documentation

Primary public documentation:

**https://mytestlab123.github.io/chatgpt-aws/**

Same-repo GitHub Pages is now **enabled and verified**. Cutover run `34796005818` completed build, deployment, and exact live commit verification successfully, and repository metadata reports `has_pages=true`.

The older CloudFront site and `mytestlab123/chatgpt-aws-docs` are retained temporarily as rollback/historical paths. They are no longer required for the normal public-repo publishing model.

## Template security

See `docs/PUBLIC_TEMPLATE_SECURITY.md`. A reusable public repo should also use `main` protection/rulesets, minimal Actions token permissions, exact repository-scoped AWS OIDC trust, and explicit Pages settings.

## Do not copy identities

Historical account IDs, role ARNs, resource names, workflow runs, and retained lab resources are evidence only. A new repository should create its own OIDC role/trust, state keys, variables, and resource names.

Never commit credentials, authentication state, Terraform state, or raw plan files.
