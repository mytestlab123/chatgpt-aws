# Documentation Hosting

Status: **VERIFIED / SAME-REPO GITHUB PAGES**  
Last checked: **2026-09-14**

## Primary site

`https://mytestlab123.github.io/chatgpt-aws/`

Architecture:

```text
docs/ + mkdocs.yml
        -> public PR: credential-free strict build
        -> reviewed main
        -> GitHub Actions
        -> GitHub Pages
```

## Verification evidence

After the one-time repository setting **Settings -> Pages -> Source: GitHub Actions** was enabled, workflow run `34796005818` attempt 2 completed successfully.

Verified stages:

- unit/public-safety checks: PASS;
- backend-free Terraform validation: PASS;
- strict Material build: PASS;
- Pages artifact upload: PASS;
- `actions/configure-pages`: PASS;
- Pages deployment: PASS;
- exact live commit verification: PASS.

Repository metadata also reports:

```text
has_pages: true
```

The workflow writes `build-info.json` containing the repository name and exact source commit SHA, then verifies the live site serves that same revision. It also checks the home page, `PROMPT.html`, downloadable `PROMPT.md`, custom HTML content, the public-template security guide, and the search index.

This prevents a stale but reachable site from being mistaken for a successful deployment.

## Why one public repo is preferred here

When source code and documentation are both intentionally public, a separate publication repository adds a cross-repo credential and synchronization path without adding a confidentiality boundary.

Steady state:

```text
PUBLIC chatgpt-aws
  -> code + IaC + docs + tests
  -> GitHub Pages
```

## Retained legacy paths

The previous AWS-hosted documentation remains available at:

`https://d36j5fck6lkl41.cloudfront.net/`

The older `mytestlab123/chatgpt-aws-docs` repository also remains available as historical evidence of a review-gated private-to-public publishing model.

Neither is required for the normal public single-repo path now. Keep them for a short rollback window, then prefer **archive first, delete later** if they are no longer needed.

The private-to-public two-repo pattern is still valid for genuinely private engineering repositories.

## Reusable hosting lesson

> Separate a successful documentation build from a verified live deployment.

For a public learning/template repo, same-repo GitHub Pages is the simplest architecture when everything committed is safe to disclose. For private or sensitive engineering, retain a private source boundary and publish only an intentional subset.

For a broader comparison, read `STATIC_SITE_HOSTING_GUIDE.md`.
