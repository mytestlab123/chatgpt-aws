# Publication Integrity

A green deployment is useful, but it is stronger to verify the result independently.

## Review-time preview

Before publication, compare the curated documentation tree with the current public repository. Report added, changed, and removed files. This preview is read-only.

## Deterministic provenance

CI creates a JSON evidence file containing the source revision, SHA256 for each allowlisted file, and an aggregate digest. The evidence contains no wall-clock timestamp, so the same revision and content produce the same result.

## Repository verification

After an eligible publication run, a separate workflow checks out the exact source revision and compares its curated documentation with the public repository. Destination-owned `.github/` files are excluded from this comparison.

## Live-site smoke test

The verification workflow also requests the home page and key documentation routes. This checks availability after the Pages deployment. It is a smoke test rather than a byte-for-byte HTML comparison because MkDocs renders Markdown into HTML.

## No-op behavior

If the destination already matches the curated source, the publisher should not create another destination commit. Deterministic provenance makes repeated validation easier to reason about.

## Recovery

If a check fails, compare the source revision, the public repository, and the public routes. Correct the curated source, publish again, and repeat verification.

## Core lesson

> **Preview the change, fingerprint the source, verify the repository, and check the live routes.**
