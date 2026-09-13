# Publication Integrity and Provenance

A documentation pipeline should prove three things: what changed, what was published, and what is live.

## Review before publishing

On a pull request, compare the curated public documentation tree with the current public documentation repository. This preview is read-only and should report added, modified, and deleted files.

## Provenance manifest

Generate a deterministic JSON manifest for every publication. It records the source repository, source commit, SHA256 for each allowlisted file, and one aggregate content digest.

The manifest does not use the current time. The same source commit and the same curated files therefore produce the same manifest.

## Repository verification

After publication, verify that destination `main` points to the commit created by the publisher. This proves the repository update landed as expected.

## Live Pages verification

GitHub Pages deploys asynchronously. Poll the live manifest and compare its source commit and content digest with the expected values. This proves the rendered site has caught up with the repository publication.

## No-op behavior

Rerunning the same source revision should not create another destination commit when the curated files and manifest are unchanged.

## Ownership boundary

The private repository decides what content is safe to publish. The public repository owns its GitHub Pages deployment workflow. The publisher preserves the destination `.github/` directory.

## Recovery

If verification fails, compare the curated source, destination repository, and live manifest. Correct the private source of truth, publish again, and repeat repository and live-site verification.

For an urgent rollback, revert the destination publication first, then fix the curated private source before the next publish.

## Core lesson

> **A successful workflow proves the pipeline ran. Provenance plus live verification proves what actually became public.**
