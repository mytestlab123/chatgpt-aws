# Public Documentation Publishing

Status: **DESTINATION LIVE / CURATED PUBLISHING + INTEGRITY CHECKS**

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

The private source uses these controls:

1. `public-docs/PUBLISH_ALLOWLIST.txt` defines every source-controlled file permitted in the curated tree.
2. `scripts/validate_public_docs.py` rejects missing or unexpected files, symlinks, non-UTF-8 or binary content, and common private-data patterns.
3. `.github/workflows/publish-public-docs.yml` validates relevant pull requests and performs the controlled cross-repository publication path.
4. The public repository owns its own `.github/` Pages workflow; the private publisher updates documentation content only.
5. `.github/workflows/public-docs-integrity.yml` adds read-only preview and post-publication verification.

## Pull-request validation and dry-run

```text
public-docs change
        |
        v
allowlist + safety validation
        |
        v
provenance manifest
        |
        v
mkdocs build --strict
        |
        v
read-only diff against public repository
```

The dry-run does not need the cross-repository publishing credential. It clones the public repository read-only and reports the files that a publication would add, change, or delete.

## Deterministic provenance

`scripts/build_publication_manifest.py` calculates SHA256 for every allowlisted public file and produces one aggregate content digest together with the source repository and source commit.

The manifest contains no current timestamp. The same source revision and curated tree produce the same evidence, which makes repeated validation understandable and supports no-op reasoning.

The preview workflow stores this manifest as short-lived CI evidence rather than adding it to the curated source tree.

## Publication path

Publishing remains manual by default. Optional automatic publishing can be enabled with the existing repository variable. Cross-repository authorization stays in GitHub settings and is never committed to source.

After synchronization, the publisher verifies that destination `main` points to the exact commit it created.

## Independent verification

After an eligible successful publisher run, the integrity workflow can independently:

1. check out the exact private source revision used by the publisher;
2. validate the curated tree again;
3. rebuild provenance evidence;
4. compare the public repository content with the curated source while ignoring destination-owned `.github/` configuration;
5. smoke-test key GitHub Pages routes.

This separates two questions:

```text
Did the publishing workflow run successfully?

Does the destination repository and public site now reflect the intended documentation?
```

## Ownership boundary

```text
private repo -> decides WHAT content is safe to publish
public repo  -> decides HOW that content is deployed to Pages
```

The publisher deliberately preserves destination `.github/` configuration.

## Recovery

The curated private tree is authoritative. If public content is incorrect, fix `public-docs/` and republish. If an urgent rollback is required, revert the destination publication and then correct the curated source before the next publish.

If integrity verification fails, compare the exact private source revision, destination repository, and live Pages routes before retrying. Do not repair only the public copy and leave the private source wrong.

## Repository creation lesson

For a documentation-only repository, prefer an **EMPTY repository** unless template contracts are intentionally required. Starting from a general project template is workable but introduces unrelated files that later need reconciliation.

## Learning rule

> **A green publisher run shows that the pipeline executed. A dry-run, deterministic provenance, destination comparison, and live-site smoke test provide stronger evidence of what became public.**
