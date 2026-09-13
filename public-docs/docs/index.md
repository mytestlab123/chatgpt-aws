# ChatGPT + AWS Learning Docs

This site contains reusable, public learning material derived from a private engineering lab.

## What is intentionally public

- AWS MCP operating patterns
- GitHub OIDC deployment patterns
- deterministic CI/CD guidance
- static documentation hosting patterns
- Cloudflare Pages + Access concepts

## What stays private

- credentials and secrets
- AWS account identifiers
- private resource names
- internal-only evidence
- private implementation details that are not needed to teach the pattern

## Core model

```text
Fast engineering loop
ChatGPT -> AWS MCP -> inspect / diagnose / experiment

Durable delivery loop
Git -> IaC -> CI/CD -> OIDC -> AWS

Verification loop
AWS MCP -> inspect the deployed result independently
```

The default engineering rule is:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**
