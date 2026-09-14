# ChatGPT + AWS Agent Bootstrap

Use this file as the **single entrypoint** for another agent working from this repository.

## Start here

1. Read `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, and the active Issue/PR.
2. Verify the exact GitHub repository and current AWS identity before making changes.
3. Read `docs/PUBLIC_TEMPLATE_SECURITY.md` for the public-repository security model.
4. Read `docs/CONTROL_PATHS.md` and `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` for detailed AWS MCP + GitHub OIDC/IaC guidance.

## Core model

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

> **Git carries knowledge; authentication does not. Re-verify identity and authority in every new session.**

`mytestlab123/chatgpt-aws` is a **public personal LAB/reference repository**. Treat everything committed here as public.

Public pull requests are credential-free. Live AWS workflows are deliberate, main-only, explicitly bound jobs using short-lived identities.

## Reuse rules

Reuse the architecture, tests, documentation patterns, and safety checks. Do **not** copy this lab's account identifiers, role identifiers, state keys, resource names, or historical execution evidence into another repository.

For a new project, create repository-specific identities, trust, state, configuration, and resource names. The new repository becomes authoritative.

Use one public repository for personal/lab work only when all source, IaC, evidence, and documentation are safe to disclose. Keep sensitive/company/customer/government/production engineering private and publish only intentional material when needed.

## Standard delivery loop

```text
1. Verify GitHub + AWS identity
2. Inspect/diagnose with AWS MCP
3. Define durable state in IaC
4. Open/update PR
5. Run credential-free validation
6. Merge reviewed change
7. Manually execute the main-only OIDC workflow when needed
8. Verify real AWS state independently with MCP
9. Record reusable learning in docs/
```

## Documentation

This public repository owns its documentation directly:

`docs/ + mkdocs.yml -> GitHub Actions -> GitHub Pages`

Live site:

**https://mytestlab123.github.io/chatgpt-aws/**

GitHub Pages is enabled and verified. The first successful same-repo cutover was workflow run `34796005818` attempt 2; build, deploy, and exact live commit verification all passed.

The previous CloudFront site and `mytestlab123/chatgpt-aws-docs` are retained only as rollback/historical examples for now. Do not depend on them for the normal single-public-repo model.

## One-URL handoff

`https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md`

Suggested instruction:

> Read this first and use the repository's operating model. Verify repository and AWS identity before changes, do not reuse identities from the reference lab, keep public PR validation unprivileged, and verify final AWS state independently.
