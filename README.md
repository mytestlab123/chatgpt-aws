# ChatGPT AWS Lab

Personal LAB for proving how ChatGPT can inspect, mutate, and provision AWS through two independent control paths.

## Documentation

The `docs/` knowledge base is published with **Material for MkDocs**.

- **Live site:** `https://d36j5fck6lkl41.cloudfront.net/`
- Source: `docs/`
- Configuration: `mkdocs.yml`
- AWS hosting IaC: `infra/docs-site/`
- Build/deploy workflow: `.github/workflows/docs-aws.yml`
- Hosting evidence/runbook: `docs/HOSTING.md`

The source repository remains private. The generated documentation is served publicly through CloudFront from a private S3 bucket protected by Origin Access Control (OAC).

The existing Markdown paths remain stable so other ChatGPT sessions can continue to reference files such as `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` and `docs/SESSION_BOOTSTRAP.md` directly.

### Why not GitHub Pages?

Material for MkDocs builds correctly, but this private organization repository currently reports GitHub Pages as disabled (`has_pages=false`). The connected GitHub app cannot change that repository administration setting. Rather than leave the docs behind a 404, the verified publication path is now:

`GitHub main -> GitHub Actions -> OIDC -> Terraform -> private S3 -> CloudFront`

`.github/workflows/docs-pages.yml` remains only as a strict MkDocs build-validation workflow. GitHub Pages can be revisited later without changing the Markdown source.

## Directions

1. **Direct MCP:** ChatGPT -> AWS Core MCP -> AWS APIs.
2. **GitOps/IaC:** ChatGPT -> GitHub -> GitHub Actions -> OIDC -> Terraform -> AWS.

The direct MCP experiments live here. The minimal GitHub/OIDC proof lives in `amitkarpe/assignment-cicd` and is referenced from `docs/EXPERIMENTS.md`.

## Start Here

1. Open the Material docs site for the human-friendly view.
2. Read `AGENTS.md`.
3. Read `CONTEXT.md` for current truth.
4. Read `SPEC.md` before AWS mutation.
5. Read `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` for the reusable cross-session AWS/GitHub operating model and verified environment facts.
6. Read `docs/SESSION_BOOTSTRAP.md` when starting another ChatGPT session.
7. Read `docs/EXPERIMENTS.md` for verified results and comparison.
8. Read `docs/HOSTING.md` for the documentation publication path and 404 troubleshooting lesson.
9. Read `ENV.md` for the active tool/cloud surface.

For another ChatGPT session working on `mytestlab123/lab1_agent`, use this repository as the private AWS knowledge source and read `lab1_agent/docs/CHATGPT_AWS_BOOTSTRAP.md` in that target repository.

Keep experiments temporary, reversible, low-cost, and evidence-backed. Never commit credentials or authentication state.
