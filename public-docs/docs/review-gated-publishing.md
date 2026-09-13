# Review-Gated Public Documentation Publishing

A cross-repository documentation publisher does not need to write directly to the public repository's `main` branch.

A safer and more reviewable model is:

```text
PRIVATE engineering repository
        |
        | curated + validated docs
        v
PUBLIC docs sync branch
        |
        v
PUBLIC pull request
        |
        | destination-owned CI
        v
merge to public main
        |
        v
GitHub Pages deployment
```

## Why add a second review gate?

The private repository answers:

> Is this content approved to leave the private engineering repository?

The public repository answers:

> Is this exact public-site change ready to become the published version?

Those are related but different decisions.

## Stable promotion branch

Use one deterministic branch such as:

```text
sync/chatgpt-aws
```

Each publication refreshes that branch from the current public `main`, applies the curated documentation tree, and force-updates only that automation-owned branch.

The workflow never pushes directly to public `main`.

## One PR, updated repeatedly

The publisher searches for an existing open pull request from the stable sync branch to `main`.

- If no PR exists, create one.
- If a PR already exists, update the branch and refresh the same PR metadata.
- If the curated source already matches public `main`, create no new commit and no new PR.

This avoids a stream of duplicate publication PRs.

## Destination-owned validation

The public documentation repository owns its own workflow configuration. Its pull-request workflow runs `mkdocs build --strict` before the publication PR is merged.

The private publisher deliberately does not overwrite the destination `.github/` directory.

## Credential boundary

A workflow's normal `GITHUB_TOKEN` cannot write to an unrelated repository. Cross-repository promotion therefore needs a separate identity.

For a small lab, a fine-grained token can be restricted to only the public docs repository with:

- **Contents: read and write** — update the sync branch;
- **Pull requests: read and write** — create or update the destination PR.

Store the token as a private source-repository secret. Never put it in the curated docs tree.

For a larger team, prefer a GitHub App installation token so the publishing identity is not tied to one person's token lifecycle.

## Provenance

The destination PR should identify the private source revision used to build the promotion. The private pipeline can also calculate a deterministic content digest before the cross-repository write.

This creates a chain of evidence:

```text
private source commit
        -> curated content digest
        -> destination sync commit
        -> destination PR
        -> destination CI
        -> public main
        -> GitHub Pages
```

## Recovery

Before merge, recovery is simple: close the destination PR or correct the curated private source and rerun the promotion.

After merge, revert the public repository commit if an urgent rollback is required, then correct the private curated source before the next promotion.

Do not permanently repair only the public copy; otherwise a later sync can reintroduce the bad content.

## Core lesson

> **Separate approval to leave the private repository from approval to become the public site's `main` branch.**
