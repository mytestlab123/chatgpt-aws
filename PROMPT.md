# ChatGPT + AWS Agent Bootstrap

Use this file as the **single entrypoint** for another ChatGPT, Codex, or compatible agent working on AWS infrastructure.

## Core model

```text
User
  -> ChatGPT / agent
       -> AWS MCP: inspect, diagnose, test, verify
       -> GitHub -> PR -> Actions -> OIDC -> IaC -> AWS
```

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

> **Git carries knowledge; authentication does not. Re-verify identity and authority in every new session.**

## Start every session with these checks

1. Read the target repo's `PROMPT.md`, `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, and active Issue/PR when present.
2. Verify GitHub access and the exact repository that owns the objective.
3. Verify AWS MCP with STS `GetCallerIdentity` and confirm account, principal, region, and environment.
4. Inspect current AWS state and the MCP/tool surface available in this session.
5. Stop and reconcile any identity, repository, authority, or state mismatch before mutation.

Never assume a previous session's OAuth, IAM principal, plugin availability, or AWS state still applies.

## Never copy AWS identities from this reference repo

Historical account IDs, role names, ARNs, resource names, and run IDs in this repository are evidence only.

For every new repository:

- create a new repository-specific GitHub OIDC role;
- scope trust to the intended repository and required branch/PR/environment;
- use new Terraform state keys and resource names;
- verify actual OIDC claims with STS/CloudTrail when federation fails;
- do not widen trust to an organization wildcard merely to make authentication work.

## Repository mode

### One public repository — preferred for personal labs

Use one public repo when **everything committed is safe to disclose**.

```text
repo/
├── PROMPT.md
├── AGENTS.md
├── docs/
├── infra/
├── tests/
├── mkdocs.yml
└── .github/workflows/
```

This keeps code, IaC, learning, Actions, and GitHub Pages in one trust boundary and removes the need for a cross-repository publishing token.

### Private/sensitive work

Keep the engineering repo private when implementation, evidence, identifiers, architecture, logs, customer information, or infrastructure details should not be public. If public learning is still wanted, publish only an explicit curated/allowlisted subset.

Repository visibility never replaces IAM or review controls.

## Security baseline

| Area | Baseline |
|---|---|
| AWS credentials | Prefer MCP OAuth and GitHub OIDC; no long-lived AWS keys in GitHub |
| OIDC trust | Bind to the exact repo and intended refs/environment |
| IAM | Least privilege, including Terraform provider read/refresh APIs |
| Terraform state | Protected remote backend; never commit state |
| PR path | Validate/test/plan only; no durable apply from unreviewed PR code |
| Apply path | Use repo-specific OIDC after the approved delivery gate |
| MCP | Discovery, diagnosis, bounded experiments, independent verification |
| Public data | Assume committed public content is permanently public |
| Evidence | Verify final effects, not only successful API responses |
| Cleanup | Delete temporary tests or explicitly document retained resources |

For higher-risk operations, it can be useful to let CI/OIDC execute while MCP remains read-only or is explicitly denied for selected actions.

## Choose the control path

Use **AWS MCP** for inventory, troubleshooting, CloudTrail/log analysis, cross-service readback, bounded reversible experiments, drift checks, and independent verification.

Use **Git + IaC + GitHub Actions + OIDC** for durable infrastructure, IAM architecture, networking, databases, persistent resources, and anything that should be reviewed, rebuilt, drift-checked, or destroyed reproducibly.

Do not silently replace desired-state IaC with direct MCP mutation when reproducibility matters.

## Standard delivery loop

```text
1. Inspect with MCP
2. Define desired state in IaC
3. Open/update one cohesive PR
4. PR: fmt/validate/test/plan
5. Review evidence
6. Merge approved PR
7. Main/manual: assume repo-specific OIDC role
8. Apply / execute
9. Independently read back with MCP
10. Run functional smoke test
11. Clean temporary evidence/data
12. Update docs with reusable learning
```

A green pipeline is not enough; verify the real AWS result whenever practical.

## Workflow and IAM lessons

- Least privilege must include provider refresh/read APIs as well as mutation APIs.
- Failed applies can leave partial state; reconcile through IaC.
- IAM changes may need a short propagation retry; do not respond by widening policy.
- Trust policy is as important as permission policy.
- Verify the assumed AWS identity inside the workflow before provisioning.
- Prefer separate service/runtime roles where appropriate.
- Use workflow path filters so unrelated docs changes do not trigger AWS labs.
- Protect `main` and require relevant CI for serious/shared repositories.
- If the user says `go` and scope is already clear, execute rather than restarting planning.

## Documentation

For one public repo:

```text
docs/ + mkdocs.yml -> GitHub Actions -> GitHub Pages
```

For a private source repo, a second public docs repo is optional. If used: publish an explicit allowlist, scan it, preview the public diff, use a review-gated destination PR, and let the public repo own its Pages workflow.

## `chatgpt-aws-docs` retirement

`mytestlab123/chatgpt-aws-docs` is currently only a publication target because `mytestlab123/chatgpt-aws` is still private.

There is no documentation to manually merge back: the curated source already lives under `chatgpt-aws/public-docs/`, while deeper source knowledge is under `chatgpt-aws/docs/`.

**Do not delete `chatgpt-aws-docs` yet.** Retire it only after:

1. `chatgpt-aws` is deliberately audited and made public, or a new public template repo is created;
2. GitHub Pages is enabled in the replacement repo;
3. the replacement Pages workflow succeeds;
4. important links are updated and verified;
5. optionally archive the old repo for a rollback window, then delete it.

## Bootstrap a new AWS repo from this model

1. Read this file and the target repository.
2. Decide public-lab vs private/sensitive mode.
3. Verify GitHub and AWS MCP identity.
4. Create a **new repo-specific OIDC role/trust**; never reuse this repo's role ARN.
5. Configure remote IaC state for persistent infrastructure.
6. Add PR validate/plan and main/manual OIDC apply workflows.
7. Implement the smallest useful milestone.
8. Verify through AWS MCP and a functional smoke test.
9. Write learning to `docs/` and publish with GitHub Pages when the repo is public.

The target repository becomes authoritative. This repository supplies patterns, not execution authority.

## Stop conditions

Stop and reconcile when the AWS account/principal/region is wrong, the target repo is wrong, mutation authority is unclear, a plan contains unexpected destroy/replacement, sensitive data may be published, or validation cannot prove the intended final state.

Do not solve an identity/trust failure by broadly weakening IAM.

## One-URL handoff

Give another agent this URL:

`https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md`

Then say:

> Read this first and use it as the operating model. Verify GitHub and AWS MCP identity before mutation. Do not reuse account IDs, role ARNs, or resource names from the reference repo. Use MCP for discovery/verification and GitHub OIDC + IaC for durable changes.
