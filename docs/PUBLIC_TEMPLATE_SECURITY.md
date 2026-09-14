# Public Repository Template Security

This page separates **controls enforced by repository code** from **settings outside Git** that a future AWS repository must configure deliberately.

## Why this matters

A public repository can safely hold IaC, workflows, tests, and documentation for a personal/lab project, but visibility does not provide an AWS security boundary by itself.

The intended model is:

```text
PUBLIC PR
  -> no AWS credentials
  -> tests / validation / docs build

REVIEWED main
  -> deliberate manual workflow
  -> short-lived GitHub OIDC
  -> AWS
  -> AWS MCP verification
```

## v1 reusable entrypoints

Use these repository-root files when bootstrapping another project:

- `PROMPT.md` — canonical one-URL agent handoff;
- `TEMPLATE_CHECKLIST.md` — values, identities, settings, and evidence that must be replaced or reverified;
- `NEW_REPO_BOOTSTRAP.md` — AWS MCP identity verification through repository-specific OIDC, Terraform delivery, and independent readback.

The reusable-template scanner applies stricter checks to these entrypoints and the private-portal example so reference account identifiers, IAM role ARNs, old lab resource names, static credentials, or unsafe workflow patterns do not silently become copy/paste defaults.

## Controls enforced in this repo

| Control | Current implementation |
|---|---|
| PR AWS credentials | Public PR checks do not request AWS OIDC |
| Live AWS trigger | Manual `workflow_dispatch` only |
| Ref guard | Live AWS jobs require `main` |
| Repository binding | Live jobs require the configured execution repository to match the actual repository |
| Account/role binding | Preflight validates the configured account and role relationship before AWS access |
| Job permissions | Default workflow permission is `contents: read`; OIDC is job-scoped |
| Action supply chain | External Actions are pinned to full commit SHAs |
| Checkout credentials | `persist-credentials: false` |
| Terraform PR validation | Backend-free fmt/validate; no live AWS identity required |
| Public-file scan | Common credential/state/plan patterns are rejected from the tracked tree |
| Reusable-template scan | Copyable v1 files reject reference-account/role/resource identities and credential patterns |
| Documentation | Strict MkDocs build, local-link/output checks, exact deployment marker |
| Pages verification | Live check requires the exact repository + source commit in `build-info.json` |

These are code-level controls. They do not prove the settings below.

## Settings outside Git

### GitHub

Recommended defaults for a reusable public template:

1. Keep default GitHub Actions token permissions minimal.
2. Do not allow workflows to approve pull requests unless there is a reviewed need.
3. Configure **Settings -> Pages -> Source: GitHub Actions** when publishing from the same repo.
4. Review organization-level Actions policies because they can narrow or widen what workflows may use.
5. For production/team repositories, enable a `main` ruleset or branch protection and require validation before merge.

### Accepted risk in this reference lab

This personal, owner-operated learning repository intentionally leaves `main` unprotected. That means a repository owner with write access can bypass the PR path and write directly to `main`.

This is an **accepted lab risk**, not a blocker for the v1 reference architecture. The security model still relies on separate live-AWS workflow guards: manual dispatch, exact repository binding, `main` ref checking, explicit lab enablement, short-lived OIDC, target-account validation, and independent AWS MCP readback.

Do not copy this acceptance blindly into shared, production, customer, government, or other sensitive repositories. In those environments, protect `main` and require reviewed CI checks.

### AWS

1. Create a **new OIDC role for each target repository/purpose**.
2. Scope trust to the exact repository and intended ref/environment.
3. Grant the smallest service/resource permissions needed.
4. Include Terraform provider read/refresh permissions when Terraform is used.
5. Keep state in a protected remote backend; do not copy this lab's state key or role ARN.
6. Review SCPs, permission boundaries, and resource policies separately.
7. Use CloudTrail and STS identity evidence when federation fails; do not fix failures by broad wildcard trust.

## Current reference-repo observation

Observed on **2026-09-14**:

| Item | Observation |
|---|---|
| Repository visibility | Public |
| Pages | Enabled and verified; same-repo Pages is the primary public docs path |
| Pages deployment | Build, deploy, and exact live-commit verification pass on `main` |
| Branch protection | `main` reports `protected: false`; explicitly accepted for this owner-operated personal lab |
| Public PR validation | Credential-free repository, documentation, unit, and backend-free Terraform checks |
| Live AWS from PR | Disallowed by repository workflow guardrails |

## Private static portal rule

A private S3 origin is not the same as a private viewer site.

The optional `infra/private-portals/` lab demonstrates two small viewer controls:

- CloudFront + AWS WAF IP allowlist;
- CloudFront + CloudFront Function Basic Auth.

Both keep runtime access values outside Git and keep S3 private through OAC. Basic Auth is a lab/simple-portal pattern, not an enterprise identity system. See `HOSTING.md` for the concise comparison and security caveats.

## Public data rule

A current-tree scanner helps prevent common mistakes, but it is **not** a full Git-history, secret-scanning, IAM, or organization-policy audit.

Before making a formerly private repository public, separately review Git history, releases/artifacts, Issues/PR comments, Actions logs, and any external systems that may have copied repository data.

## Reuse rule

> **Reuse the architecture and tests. Recreate the identities, trust, state, and resource names.**
