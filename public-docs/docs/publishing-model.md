# Publishing from a Private Repository to Public GitHub Pages

A useful documentation pattern is to separate the engineering repository from the public learning site.

```text
PRIVATE source repository
        |
        | explicit curated files only
        v
PUBLIC documentation repository
        |
        v
GitHub Actions
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
5. On approved main/manual execution, push only the curated tree to the public repository.
6. Let the public repository's own GitHub Pages workflow deploy the site.
```

Keeping the Pages workflow owned by the public repository is useful because the cross-repository publisher only needs permission to update documentation content. It does not need to manage the destination repository's workflow configuration.

## Cross-repository credential

A normal GitHub Actions `GITHUB_TOKEN` is scoped to the repository where the workflow runs. Publishing to a different repository therefore needs a separate narrowly scoped identity.

For a small lab, a fine-grained personal access token can be restricted to the single public documentation repository with the minimum repository-content write permission needed for the push. Store it as a repository secret in the private source repository; never commit it.

For a larger team, prefer a GitHub App installation token so the publishing identity is centrally managed and not tied to one person's PAT lifecycle.

## Automatic vs manual publishing

A safe progression is:

```text
PR       -> validate only
main     -> validate; publish only when explicitly enabled
manual   -> validate + publish
```

This gives you a deterministic preview before any public change while still allowing automatic publication later.

## Rollback

The public documentation repository is ordinary Git history. If a published change is wrong:

1. revert the destination commit, or fix the curated source;
2. republish the corrected tree;
3. let GitHub Pages redeploy.

Do not fix the public copy permanently while leaving the private curated source wrong, otherwise the next publication will reintroduce the problem.

## Repository creation lesson

For a dedicated documentation-only repository, starting with an **empty repository** is usually simplest.

Use a project template only when you intentionally want its extra repository contracts, files, and workflows. Otherwise those template files become cleanup work and may be accidentally published.
