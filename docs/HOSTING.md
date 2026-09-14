# Documentation Hosting

Status: **MIGRATING TO SAME-REPO GITHUB PAGES**  
Last checked: **2026-09-14**

## Preferred target

Because `mytestlab123/chatgpt-aws` is now public, the preferred long-term path is:

```text
docs/ + mkdocs.yml
        -> public PR: credential-free strict build
        -> reviewed main
        -> GitHub Actions
        -> GitHub Pages
```

Target URL:

`https://mytestlab123.github.io/chatgpt-aws/`

## Current blocker

Main workflow run `34794184677` proved:

- unit/public-safety checks: PASS;
- backend-free Terraform validation: PASS;
- strict Material build: PASS;
- Pages artifact upload: PASS;
- Pages deployment: BLOCKED at `actions/configure-pages`.

Repository metadata currently reports:

```text
has_pages: false
```

The deployment log says Pages must be enabled and configured to build using GitHub Actions.

One-time setting:

```text
Settings
  -> Pages
  -> Build and deployment
  -> Source
  -> GitHub Actions
```

`actions/configure-pages` cannot self-enable Pages with the normal workflow `GITHUB_TOKEN`; its `enablement` option requires a separate token/app with the required administration/Pages permissions. This repository intentionally does not introduce such a credential just to automate a one-time setting.

## Existing verified fallback

The previous AWS-hosted documentation remains live:

`https://d36j5fck6lkl41.cloudfront.net/`

Architecture:

```text
GitHub main
  -> GitHub Actions + OIDC
  -> Terraform
  -> private S3
  -> CloudFront OAC
```

It remains a verified retained path while same-repo Pages is being enabled. No CloudFront/S3 deletion is part of the migration milestone.

## Why one public repo is now preferred

When source code and documentation are both intentionally public, a separate publication repository adds a cross-repo credential and synchronization path without adding a confidentiality boundary.

For this repo, the simpler steady state is:

```text
PUBLIC chatgpt-aws
  -> code + IaC + docs + tests
  -> GitHub Pages
```

The older `chatgpt-aws-docs` repository remains useful as historical evidence of a review-gated private-to-public publishing design. That pattern is still appropriate when the engineering source is genuinely private.

## Migration acceptance

Do not call same-repo Pages complete until the main workflow verifies the exact deployed revision.

The workflow writes `build-info.json` containing:

- repository name;
- exact source commit SHA.

Live verification also checks:

- `/`;
- `PROMPT.html`;
- `downloads/PROMPT.md`;
- `AMIT_AUTOMATION_CICD_LAB.html`;
- `search/search_index.json`.

This prevents a stale but reachable Pages site from being mistaken for a successful deployment.

## When `chatgpt-aws-docs` can be retired

Only after:

1. same-repo Pages is enabled;
2. the Pages workflow succeeds on `main`;
3. exact SHA verification passes;
4. key links are updated;
5. the new site is stable for a short rollback window.

Prefer **archive first, delete later**.

## Reusable hosting lesson

> Separate the documentation generator from its hosting target, and separate a successful build from a verified live deployment.

Material for MkDocs can be published to GitHub Pages, S3 + CloudFront, or another static host. Hosting choice should follow visibility, authentication, and operational requirements rather than changing the knowledge layout.

For a broader comparison, read `STATIC_SITE_HOSTING_GUIDE.md`.
