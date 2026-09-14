# Context

Status: ACTIVE

## Project identity

- Project: ChatGPT AWS Lab
- Primary repository: `mytestlab123/chatgpt-aws`
- Visibility: **public**
- Context: PERSONAL
- Environment: LAB
- Canonical agent entrypoint: `PROMPT.md`

## Current truth

- `mytestlab123/chatgpt-aws` is public and active.
- PR #43 hardened the public-repo workflow model: PR checks are credential-free; live AWS workflows are manual, main-only, explicitly bound OIDC jobs.
- Repository checks include pinned GitHub Actions, non-persistent checkout credentials, public-content pattern checks, unit tests, backend-free Terraform validation, strict MkDocs build, and Pages freshness tooling.
- Existing AWS lab resources and historical evidence are reference material; new repositories must create their own identities, trust, state, and resource names.
- Same-repo GitHub Pages is enabled and live at `https://mytestlab123.github.io/chatgpt-aws/`.
- Workflow run `34796005818` attempt 2 completed build, Pages deployment, and exact live commit verification successfully.
- Repository metadata reports `has_pages=true`.
- The older CloudFront documentation path and `mytestlab123/chatgpt-aws-docs` remain temporary rollback/historical paths, not the preferred publishing architecture.

## Control-path decision

Preferred model:

- **AWS MCP** for discovery, troubleshooting, live readback, bounded experiments, and independent verification.
- **Git + Terraform/IaC + GitHub Actions + OIDC** for durable deterministic infrastructure and reviewed execution.
- Preferred hybrid loop: **MCP discover/diagnose -> Git/IaC declare -> OIDC CI/CD apply -> MCP independently verify**.

For this public repo, unreviewed PR code must not receive the AWS execution identity. Credential-free PR validation and deliberate main-only execution are separate paths.

## Repository-settings gap

Repository code cannot prove all security settings.

Observed on 2026-09-14:

- repository is public;
- GitHub Pages is enabled and verified;
- repository rulesets API returned no rulesets;
- branch-protection details were not readable through the connected GitHub App, so protection status remains unverified.

See `docs/PUBLIC_TEMPLATE_SECURITY.md` for the code-vs-settings checklist.

## Active work

- Issue #50 records the verified same-repo Pages cutover and final documentation status.
- Issue #42 can close after the status update is merged and the resulting main revision is verified live.

## Next action

1. Keep `PROMPT.md` as the one-URL bootstrap for future sessions/repos.
2. Reuse the public-repo workflow safety model instead of repeating connectivity experiments.
3. Keep the legacy docs repo/CloudFront path for a short rollback window; archive before considering deletion.
4. For any future AWS mutation milestone, create/use a dedicated Issue and verify the session's AWS identity first.
