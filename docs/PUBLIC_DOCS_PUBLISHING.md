# Public Documentation Publishing

Status: **LEGACY / OPTIONAL PRIVATE-TO-PUBLIC PATTERN**

## Current role

`mytestlab123/chatgpt-aws` is now public, so this repository no longer needs a second public repository merely to publish its own documentation.

The preferred path for this repo is now:

```text
PUBLIC chatgpt-aws
        -> docs/ + mkdocs.yml
        -> GitHub Actions
        -> GitHub Pages
```

The two-repository design below remains valuable when the **engineering source must stay private** but a reviewed subset of learning material may be public.

## Original private-to-public model

```text
PRIVATE engineering repo
        -> curated publication tree
        -> PUBLIC sync branch
        -> PUBLIC pull request
        -> PUBLIC main
        -> GitHub Pages
```

For this lab, the historical destination is:

`https://mytestlab123.github.io/chatgpt-aws-docs/`

## Controls learned

1. An explicit allowlist defines which files may leave the private repository.
2. A safety scan rejects unexpected files, symlinks, binary/non-UTF-8 content, and common credential/private-data patterns.
3. A deterministic SHA256 manifest records provenance.
4. Review-time validation performs a read-only preview against the public destination.
5. Promotion updates a deterministic sync branch, not public `main` directly.
6. The destination repository owns its own PR validation and Pages deployment.

## Review-time path

```text
curated change
 -> allowlist + safety scan
 -> provenance digest
 -> strict docs build
 -> read-only public diff
```

## Review-gated promotion

The publisher uses a deterministic destination branch:

```text
sync/chatgpt-aws
```

For an eligible promotion it:

1. starts from current public `main`;
2. applies the exact curated tree while preserving destination workflow ownership;
3. pushes only the sync branch;
4. creates or refreshes one destination PR;
5. verifies the remote promotion branch SHA.

If public `main` already matches the curated source, no new destination commit or PR is required.

## Credential boundary

Cross-repository publication needs a narrowly scoped credential, such as a fine-grained token or GitHub App installation token, limited to the destination repository and only the permissions required for the sync branch/PR.

That extra credential is one reason a **single public repo is simpler** when confidentiality separation is no longer needed.

## Two approval questions

```text
PRIVATE source review
  -> May this content leave the private repository?

PUBLIC destination PR
  -> May this exact change become the public site's main branch?
```

Those remain separate governance decisions for private-source projects.

## Integrity after promotion

After a promotion, independently rebuild provenance, compare the destination sync branch with the curated tree, and confirm the expected destination PR exists.

Do not claim Pages changed merely because promotion succeeded; the public destination owns merge and deployment.

## Recovery

Before merge, close/fix the destination PR or correct the private curated source and rerun promotion.

After merge, revert the public commit when urgent rollback is required, then fix the private source before the next promotion.

Do not permanently repair only the public copy; a later sync can reintroduce the problem.

## Repository creation lesson

For a docs-only repository, prefer an **EMPTY repository** unless template contracts are intentionally required.

## Learning rule

> **Use one public repo when everything may be public. Use the two-repo publishing pattern only when the private/public boundary is real and intentional.**
