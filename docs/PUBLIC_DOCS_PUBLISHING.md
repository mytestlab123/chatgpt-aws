# Public Documentation Publishing

Status: **DESTINATION LIVE / REVIEW-GATED CURATED PROMOTION**

## Goal

Keep the engineering repository private while publishing only reviewed learning material to the public docs repository and GitHub Pages.

```text
PRIVATE chatgpt-aws
        -> curated public-docs/
        -> PUBLIC sync/chatgpt-aws
        -> PUBLIC pull request
        -> PUBLIC main
        -> GitHub Pages
```

Live site: `https://mytestlab123.github.io/chatgpt-aws-docs/`

## Controls

1. `public-docs/PUBLISH_ALLOWLIST.txt` defines every file allowed to leave the private repo.
2. `scripts/validate_public_docs.py` rejects missing/unexpected files, symlinks, binary/non-UTF-8 content, and common private-data patterns.
3. `scripts/build_publication_manifest.py` creates deterministic SHA256 provenance.
4. `.github/workflows/public-docs-integrity.yml` performs read-only dry-run and promotion verification.
5. `.github/workflows/publish-public-docs.yml` updates only the public sync branch and opens or refreshes one public PR.
6. `chatgpt-aws-docs` owns its own PR build and Pages deployment workflow.

## Review-time path

```text
curated change
 -> allowlist + safety scan
 -> provenance digest
 -> mkdocs build --strict
 -> read-only diff against public main
```

No cross-repository write credential is needed for this preview.

## Review-gated promotion

The publisher no longer pushes directly to public `main`.

It uses one deterministic destination branch:

```text
sync/chatgpt-aws
```

For an eligible manual or enabled-main run it:

1. starts from current public `main`;
2. applies the exact curated tree while preserving destination `.github/`;
3. pushes only `sync/chatgpt-aws`;
4. creates a destination PR if none exists, otherwise updates the same open PR;
5. verifies the remote promotion branch SHA.

If public `main` already matches the curated source, no new destination commit or PR is required.

## Credential boundary

`PUBLIC_DOCS_TOKEN` is stored only in the private repo's GitHub settings. For the current fine-grained token model, restrict it to `mytestlab123/chatgpt-aws-docs` with:

- **Contents: read/write** for the sync branch;
- **Pull requests: read/write** for the destination PR.

For a larger team, prefer a GitHub App installation token over a personal token lifecycle.

## Two approval questions

```text
PRIVATE source review
  -> May this content leave the private repository?

PUBLIC destination PR
  -> May this exact change become the public site's main branch?
```

Those are separate governance decisions.

## Integrity after promotion

After a successful promoter run, the integrity workflow independently checks the exact private source revision, rebuilds provenance, compares the destination sync branch with the curated tree, and confirms an open PR exists from `sync/chatgpt-aws` to `main`.

It does not claim Pages changed yet. The public repository owns PR validation, merge, and Pages deployment.

## Recovery

Before merge, close the public PR or fix the curated private source and rerun promotion.

After merge, revert the public commit if urgent rollback is required, then fix the private curated source before the next promotion.

Do not permanently repair only the public copy; a later sync can reintroduce the problem.

## Repository creation lesson

For a docs-only repository, prefer an **EMPTY repository** unless template contracts are intentionally required.

## Learning rule

> **Approval to leave a private repository and approval to become a public site's `main` branch are separate decisions.**
