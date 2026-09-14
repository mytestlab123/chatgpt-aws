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
| Documentation | Strict MkDocs build, local-link/output checks, exact deployment marker |
| Pages verification | Live check requires the exact repository + source commit in `build-info.json` |

These are code-level controls. They do not prove the settings below.

## Settings outside Git

### GitHub

Recommended for a reusable public template:

1. **Protect `main`** using a ruleset or branch protection.
2. Require the repository validation workflow before merge.
3. Keep default GitHub Actions token permissions minimal.
4. Do not allow workflows to approve pull requests unless there is a reviewed need.
5. Configure **Settings -> Pages -> Source: GitHub Actions** when publishing from the same repo.
6. Review organization-level Actions policies because they can narrow or widen what workflows may use.

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
| Pages | `has_pages=false` |
| Pages build/artifact | Passed on main run `34794184677` |
| Pages deploy | Blocked because Pages is not enabled/configured yet |
| Repository rulesets | Rulesets API returned `[]` |
| Branch protection | Not readable through the connected GitHub App; treat as unverified |
| Public PR validation | Passed in PR #43 |
| Live AWS from PR | Removed by PR #43 |

The Pages failure is a repository setting issue, not a MkDocs build failure.

## One-time Pages step

In this repository:

```text
Settings
  -> Pages
  -> Build and deployment
  -> Source
  -> GitHub Actions
```

Then rerun **Repository checks and Pages** on `main`.

Do not call the migration complete until the workflow verifies:

- `build-info.json` contains the exact `main` commit SHA;
- `PROMPT.html` loads;
- `downloads/PROMPT.md` loads;
- the custom HTML lab page loads;
- the search index contains the bootstrap page.

## Public data rule

A current-tree scanner helps prevent common mistakes, but it is **not** a full Git-history, secret-scanning, IAM, or organization-policy audit.

Before making a formerly private repository public, separately review Git history, releases/artifacts, Issues/PR comments, Actions logs, and any external systems that may have copied repository data.

## Reuse rule

> **Reuse the architecture and tests. Recreate the identities, trust, state, and resource names.**
