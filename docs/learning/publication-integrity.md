# Publication Integrity

A green deployment is useful, but it is stronger to verify each promotion stage independently.

## Review-time preview

Before any cross-repository write, compare the curated documentation tree with the current public `main` branch. Report added, changed, and removed files. This preview is read-only.

## Deterministic provenance

CI creates a JSON evidence file containing the source revision, SHA256 for each allowlisted file, and an aggregate digest. The evidence contains no wall-clock timestamp, so the same revision and content produce the same result.

## Promotion verification

After an eligible promotion run, a separate workflow checks out the exact private source revision and verifies that:

1. the destination sync branch contains the exact curated tree;
2. destination-owned `.github/` configuration remains outside the sync comparison;
3. an open public pull request exists from the deterministic sync branch to public `main`.

This proves what is proposed for publication without pretending that the public site has already changed.

## Destination validation and live site

The public repository owns the pull-request build and Pages deployment.

```text
private promotion
      -> public sync branch
      -> public PR
      -> public PR validation
      -> merge to public main
      -> GitHub Pages deployment
```

Live-site verification belongs after the destination PR is merged because only then has the publication become part of public `main`.

## No-op behavior

If public `main` already matches the curated source, the publisher should not create another destination commit or another review PR. Deterministic provenance makes repeated validation easier to reason about.

If an open destination PR already exists, later promotions should update that same PR rather than create duplicates.

## Recovery

Before merge, close the destination PR or correct the private curated source and rerun the promotion.

After merge, revert the public commit if necessary, then correct the private curated source before the next promotion.

## Core lesson

> **Preview the change, fingerprint the source, verify the promotion branch and PR, then let the destination own release and deployment.**
