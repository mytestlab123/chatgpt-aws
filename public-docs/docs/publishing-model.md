# Publishing from a Private Repository to Public GitHub Pages

A useful documentation pattern is to separate the engineering repository from the public learning site.

```text
PRIVATE source repository
        |
        | explicit curated files only
        v
PUBLIC documentation sync branch
        |
        v
PUBLIC pull request
        |
        v
PUBLIC main
        |
        v
GitHub Pages
```

## Why use two repositories?

The private repository can keep implementation details, cloud evidence, resource identifiers, and internal runbooks. The public repository contains only material that was intentionally selected for sharing.

The important rule is:

> Do not mirror the private repository. Publish an explicit allowlist.

## Recommended control flow

```text
1. Edit curated documentation in the private repository.
2. Validate the publication allowlist.
3. Scan the curated files for obvious secret/private-data mistakes.
4. Build the documentation with `mkdocs build --strict`.
5. Compare the curated tree with the current public repository read-only.
6. On approved main/manual execution, update one automation-owned sync branch.
7. Create or refresh one public pull request against `main`.
8. Let the public repository run its own pull-request validation.
9. Merge the public PR only when that destination-side review is accepted.
10. Let the public repository's own GitHub Pages workflow deploy the site.
```

This adds a useful boundary:

```text
private approval      -> may this content leave the private repository?
public PR approval    -> may this exact change become the public site's main branch?
```

The Pages workflow remains owned by the public repository. The cross-repository publisher only updates documentation content on its dedicated sync branch and creates or updates the destination PR. It does not manage destination workflow configuration.

## Cross-repository credential

A normal GitHub Actions `GITHUB_TOKEN` is scoped to the repository where the workflow runs. Publishing to a different repository therefore needs a separate narrowly scoped identity.

For a small lab, a fine-grained personal access token can be restricted to the single public documentation repository with:

- **Contents: read and write** for the sync branch;
- **Pull requests: read and write** for the destination review PR.

Store it as a repository secret in the private source repository; never commit it.

For a larger team, prefer a GitHub App installation token so the publishing identity is centrally managed and not tied to one person's PAT lifecycle.

## One stable sync branch

Use one deterministic destination branch, for example:

```text
sync/chatgpt-aws
```

A rerun refreshes that branch from current public `main`, reapplies the curated tree, and updates the same open destination PR. This avoids duplicate publication PRs.

If the curated source already matches public `main`, the publisher should create no new destination commit and no new PR.

## Automatic vs manual promotion

A safe progression is:

```text
private PR  -> validate + dry-run only
private main -> validate; promote only when explicitly enabled
manual      -> validate + promote to public review PR
public PR   -> destination-owned validation
public main -> Pages deployment
```

This keeps automatic cross-repository mutation separate from automatic public release.

## Rollback

Before the destination PR is merged, simply close it or correct the curated private source and rerun the promotion.

After merge, revert the destination commit if an urgent rollback is required, then correct the curated source before the next promotion.

Do not fix the public copy permanently while leaving the private curated source wrong, otherwise the next promotion can reintroduce the problem.

## Repository creation lesson

For a dedicated documentation-only repository, starting with an **empty repository** is usually simplest.

Use a project template only when you intentionally want its extra repository contracts, files, and workflows. Otherwise those template files become cleanup work and may be accidentally published.
