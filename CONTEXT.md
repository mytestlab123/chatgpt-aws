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
- Existing AWS lab resources and historical evidence remain reference material; new repositories must create their own identities, trust, state, and resource names.
- The existing CloudFront documentation site remains live as a retained legacy path.
- Same-repo GitHub Pages target: `https://mytestlab123.github.io/chatgpt-aws/`.
- Current repository metadata reports `has_pages=false`; main run `34794184677` built and uploaded the Pages artifact successfully but deployment stopped at `actions/configure-pages` because Pages is not enabled yet.
- One-time manual setting still required: **Settings -> Pages -> Source: GitHub Actions**.
- `mytestlab123/chatgpt-aws-docs` remains a temporary legacy/rollback publishing path until same-repo Pages is verified.

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
- Pages is not enabled (`has_pages=false`);
- repository rulesets API returned no rulesets;
- branch-protection details were not readable through the connected GitHub App, so protection status remains unverified.

See `docs/PUBLIC_TEMPLATE_SECURITY.md` for the code-vs-settings checklist.

## Active work

- Issue #42: public-repo hardening and single-repo learning consolidation.
- Issue #48: reconcile public-template documentation and complete same-repo Pages migration.

## Next action

1. Enable GitHub Pages using **Settings -> Pages -> Source: GitHub Actions**.
2. Rerun or trigger the repository Pages workflow.
3. Verify that `build-info.json` matches the deployed `main` SHA and that the bootstrap/search/custom HTML pages load.
4. After same-repo Pages is stable and links are updated, archive `chatgpt-aws-docs` for a rollback window before considering deletion.

No new AWS service milestone is required to prove the operating model further; future work should reuse the existing pattern rather than repeat connectivity experiments.
