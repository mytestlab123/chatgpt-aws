# ChatGPT + AWS Agent Bootstrap — v1

Use this file as the **single entrypoint** for another ChatGPT/Codex/agent session.

## Mission

Operate AWS from conversation without depending on a developer workstation CLI for the normal workflow:

```text
You
  ↓
ChatGPT / agent
  ├─ AWS MCP -> inspect / diagnose / bounded experiment / verify
  └─ GitHub -> IaC -> PR -> GitHub Actions -> OIDC -> AWS
                                      ↓
                               AWS MCP readback
                                      ↓
                              docs/ -> Pages
```

Core rule:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

> **Git carries knowledge; authentication does not. Re-verify identity and authority in every new session.**

## First actions in every session

1. Determine whether this repository is the target or only a reference.
2. Read `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, and the active Issue/PR in the **target** repository.
3. Verify the exact GitHub `OWNER/REPO` and default branch.
4. Verify AWS identity with STS `GetCallerIdentity` through AWS MCP.
5. Verify the intended Region(s).
6. Do not mutate AWS until repository/account/Region authority is clear.

If using this repository as a reference for a different project, treat the reference repository as read-only. The new repository becomes authoritative.

## Reuse, never clone live identity

Reuse:

- control-path architecture;
- security checks;
- workflow patterns;
- Terraform structure;
- documentation structure;
- verification habits.

Do **not** copy:

- AWS account identifiers;
- IAM role ARNs or trust subjects;
- Terraform state bucket/key identities;
- retained lab resource names;
- historical workflow/resource IDs;
- runtime credentials or access values.

Start with:

- `TEMPLATE_CHECKLIST.md`
- `NEW_REPO_BOOTSTRAP.md`
- `docs/PUBLIC_TEMPLATE_SECURITY.md`
- `docs/CONTROL_PATHS.md`

## Standard delivery loop

```text
1. Verify GitHub + AWS identity
2. Inspect/diagnose with AWS MCP
3. Define desired durable state in IaC
4. Open/update PR
5. Run credential-free validation
6. Merge reviewed change
7. Deliberately run main-only OIDC apply
8. Verify real AWS state independently with MCP
9. Run an application-level smoke test
10. Record reusable learning in docs/
```

## Public repository invariants

Public PRs are untrusted input.

- default Actions permission: `contents: read`;
- no PR `id-token: write`;
- no deployment secrets in PR jobs;
- no live AWS mutation from PRs;
- no `pull_request_target` for untrusted code;
- pin external Actions to immutable commit SHAs;
- checkout uses `persist-credentials: false`;
- do not commit `.env`, `.tfstate`, raw plan files, access keys, passwords, tokens, private runtime values, or authentication state.

Live AWS workflows are deliberate:

- `workflow_dispatch` only;
- `refs/heads/main` only;
- bound to the exact expected repository;
- require an explicit enablement variable;
- use short-lived GitHub OIDC credentials;
- scope `id-token: write` only to the live AWS job;
- plan first and apply the saved plan.

## GitHub OIDC rule for a new repository

Create a **new repository-specific role**. Reuse the account-level GitHub OIDC provider only after verifying issuer/audience.

Conceptual trust:

```text
aud == sts.amazonaws.com
sub == repo:OWNER/REPO:ref:refs/heads/main
```

If GitHub Environments are intentionally used, bind trust to the exact environment subject instead.

Never reuse this reference lab's role identity in another repository.

## Private documentation / portal option

For public learning, use the same-repo Material + GitHub Pages path.

For private static content, this repository also demonstrates:

1. CloudFront + AWS WAF IP allowlist;
2. CloudFront + CloudFront Function Basic Auth.

Both keep S3 private through Origin Access Control and keep runtime access values outside Git. Read `docs/HOSTING.md` for the concise design and `infra/private-portals/` for the Terraform example.

Treat Basic Auth as a small lab/demo pattern. Prefer Cognito/enterprise IdP or signed-cookie designs when you need named users, MFA, revocation, lifecycle, or stronger auditability.

## Documentation

Durable learning belongs in `docs/` and the repository's MkDocs site. `CONTEXT.md` is current-only; do not turn it into an ever-growing history file.

## One-URL handoff

Canonical reference URL:

`https://github.com/mytestlab123/chatgpt-aws/blob/main/PROMPT.md`

Suggested instruction to another agent:

> Read this first. Apply its operating model to my target repository. Verify the target GitHub repository and AWS STS identity before changes. Treat the reference repository as read-only, create new repository-specific OIDC/state/resource identities, keep public PR validation credential-free, use IaC plus main-only OIDC for durable AWS changes, verify final state independently with AWS MCP, and document reusable learning.