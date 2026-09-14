# ChatGPT + AWS Agent Bootstrap

Use this file as the **single entrypoint** for another agent working from this repository.

## Start here

1. Read `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, and the active Issue/PR.
2. Verify the exact GitHub repository and current AWS identity before making changes.
3. Read `docs/PUBLIC_TEMPLATE_SECURITY.md` for the public-repository security model.
4. Read `docs/CONTROL_PATHS.md` and `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` for the detailed AWS MCP + GitHub OIDC/IaC operating model and evidence.

## Core model

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

> **Git carries knowledge; authentication does not. Re-verify identity and authority in every new session.**

`mytestlab123/chatgpt-aws` is a **public personal LAB/reference repository**. Treat everything committed here as public.

Public pull requests are intentionally credential-free. Reviewed live AWS work uses deliberate repository-controlled delivery with short-lived identities, followed by independent verification.

## Reuse rules

Reuse the architecture, tests, documentation patterns, and safety checks. Do **not** copy this lab's account identifiers, role identifiers, state keys, resource names, or historical execution evidence into another repository.

For a new project, create repository-specific identities, trust, state, configuration, and resource names. The new repository becomes authoritative.

Use one public repository for personal/lab work only when all source, IaC, evidence, and documentation are safe to disclose. Keep sensitive/company/customer/government/production engineering private and publish only intentional material when needed.

## Documentation

Preferred path for this public repo:

`docs/ + mkdocs.yml -> GitHub Actions -> GitHub Pages`

Target: `https://mytestlab123.github.io/chatgpt-aws/`

As of 2026-09-14, the build is ready but GitHub Pages still needs the one-time setting **Settings -> Pages -> Source: GitHub Actions**. Keep the existing CloudFront site and `chatgpt-aws-docs` intact until same-repo Pages is verified.

## One-URL handoff

`https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md`

Suggested instruction:

> Read this first and use the repository's documented operating model. Verify repository and AWS identity before changes, do not reuse identities from the reference lab, keep public PR validation unprivileged, and verify final AWS state independently.
