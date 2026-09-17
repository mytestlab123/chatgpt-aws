# Context

Status: ACTIVE
Updated: 2026-09-17

## Project identity

- Project: ChatGPT AWS Lab
- Primary repository: `mytestlab123/chatgpt-aws`
- Current merged `main`: `2f413633332caf34d45b7896191b3276533061c4`
- Visibility: **public**
- Context: PERSONAL
- Environment: LAB
- Canonical cold-start entrypoint: `PROMPT.md`

## Current truth

- `mytestlab123/chatgpt-aws` is public and active.
- Public-repo workflow model remains credential-free PR checks plus deliberate main-only live AWS workflows with explicit OIDC binding.
- Same-repo GitHub Pages remains the preferred documentation architecture.
- The older CloudFront documentation path and `mytestlab123/chatgpt-aws-docs` remain rollback/historical paths, not the preferred publishing architecture.
- Historical AWS lab resources and proof records are examples/evidence; current AWS identity and runtime state must be re-verified before any new live action.

## Control-path decision

Preferred model:

- **AWS MCP** for discovery, troubleshooting, live readback, bounded experiments, and independent verification.
- **Git + Terraform/IaC + GitHub Actions + OIDC** for durable deterministic infrastructure and reviewed execution.
- Preferred hybrid loop: **MCP discover/diagnose -> Git/IaC declare -> OIDC CI/CD apply -> MCP independently verify**.

For this public repo, unreviewed PR code must not receive the AWS execution identity. Credential-free PR validation and deliberate main-only execution are separate paths.

## Repository-settings gap

Repository code cannot prove all security settings. Current repository settings must be verified separately when a task depends on them; historical observations are not standing proof.

## Active work

- Issue #53 — simplify bootstrap routing and warm continuation.

## Current boundary

- This governance issue is documentation-only.
- No AWS, Terraform, OIDC, workflow, Pages, CloudFront, repository-visibility or external-resource mutation is authorized by it.

## Next action

Review Issue #53 / its PR. Future AWS milestones must use a dedicated owning Issue and re-verify the session's AWS identity first.

## Continuation

For a known objective, use the named Issue/PR, latest relevant authorized delta, and current HEAD. Use `PROMPT.md` plus the broader bootstrap set only when a real cold-start/recovery trigger applies.
