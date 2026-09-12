# ChatGPT AWS Lab

Personal LAB for proving how ChatGPT can inspect, mutate, and provision AWS through two independent control paths.

## Directions

1. **Direct MCP:** ChatGPT -> AWS Core MCP -> AWS APIs.
2. **GitOps/IaC:** ChatGPT -> GitHub -> GitHub Actions -> OIDC -> Terraform -> AWS.

The direct MCP experiments live here. The minimal GitHub/OIDC proof lives in `amitkarpe/assignment-cicd` and is referenced from `docs/EXPERIMENTS.md`.

## Start Here

1. Read `AGENTS.md`.
2. Read `CONTEXT.md` for current truth.
3. Read `SPEC.md` before AWS mutation.
4. Read `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` for the reusable cross-session AWS/GitHub operating model and verified environment facts.
5. Read `docs/SESSION_BOOTSTRAP.md` when starting another ChatGPT session.
6. Read `docs/EXPERIMENTS.md` for verified results and comparison.
7. Read `ENV.md` for the active tool/cloud surface.

For another ChatGPT session working on `mytestlab123/lab1_agent`, use this repository as the private AWS knowledge source and read `lab1_agent/docs/CHATGPT_AWS_BOOTSTRAP.md` in that target repository.

Keep experiments temporary, reversible, low-cost, and evidence-backed. Never commit credentials or authentication state.
