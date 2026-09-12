# ChatGPT AWS Lab

Personal LAB for proving how ChatGPT can inspect, mutate, and provision AWS through two independent control paths.

## Documentation

The `docs/` knowledge base is published with **Material for MkDocs**.

- Site: `https://mytestlab123.github.io/chatgpt-aws/`
- Source: `docs/`
- Configuration: `mkdocs.yml`
- Build/deploy workflow: `.github/workflows/docs-pages.yml`

The existing Markdown paths remain stable so other ChatGPT sessions can continue to reference files such as `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` and `docs/SESSION_BOOTSTRAP.md` directly.

### One-time GitHub Pages setup

For first publication, an administrator must enable Pages for this repository:

`Settings -> Pages -> Build and deployment -> Source -> GitHub Actions`

The connected GitHub app can manage repository files and workflows but does not expose the Pages administration setting. After the one-time setting is enabled, pushes to `main` that change the docs/config automatically build and deploy the site.

> GitHub Pages is publicly accessible even when the source repository is private. Review the documentation content before publishing exact environment/account details publicly.

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
8. Read `ENV.md` for the active tool/cloud surface.

For another ChatGPT session working on `mytestlab123/lab1_agent`, use this repository as the private AWS knowledge source and read `lab1_agent/docs/CHATGPT_AWS_BOOTSTRAP.md` in that target repository.

Keep experiments temporary, reversible, low-cost, and evidence-backed. Never commit credentials or authentication state.
