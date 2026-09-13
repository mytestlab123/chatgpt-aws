# Public Documentation Publishing

Status: **DESTINATION LIVE / AUTOMATION VALIDATION IN PROGRESS**

## Goal

Keep the engineering repository private while publishing only reviewed learning material to the public documentation repository and GitHub Pages site.

```text
PRIVATE chatgpt-aws
        |
        | reviewed public-docs/ tree
        v
PUBLIC chatgpt-aws-docs
        |
        v
GitHub Pages
```

Live site:

```text
https://mytestlab123.github.io/chatgpt-aws-docs/
```

## Publication controls

The private source uses four layers:

1. `public-docs/PUBLISH_ALLOWLIST.txt` defines every file permitted in the curated tree.
2. `scripts/validate_public_docs.py` rejects missing or unexpected files, symlinks, non-UTF-8 or binary content, and common private-data patterns.
3. `.github/workflows/publish-public-docs.yml` validates every relevant pull request before publication.
4. The public repository owns its own `.github/` Pages workflow; the private publisher updates documentation content only.

## Validation path

```text
public-docs change
        |
        v
allowlist check
        |
        v
public-safety scan
        |
        v
mkdocs build --strict
```

Pull-request validation does not modify the public repository.

## Publication path

Publishing is manual by default. Optional automatic publishing can be enabled through a repository variable. Cross-repository authorization is configured in GitHub settings and is never committed to source.

After synchronization the workflow verifies that destination `main` points to the exact commit it created.

## Ownership boundary

```text
private repo -> decides WHAT content is safe to publish
public repo  -> decides HOW that content is deployed to Pages
```

The publisher deliberately preserves destination `.github/` configuration.

## Recovery

The curated private tree is authoritative. If public content is incorrect, fix `public-docs/` and republish. If an urgent rollback is required, revert the destination commit and then correct the curated source before the next publication.

## Repository creation lesson

For a documentation-only repository, prefer an **EMPTY repository** unless template contracts are intentionally required. Starting from a general project template is workable but introduces unrelated files that later need reconciliation.
