# Reusable AWS Agent Template Checklist

Use this checklist when creating a **new repository** from the patterns in this reference lab.

The new repository becomes authoritative. Reuse the operating model, not this lab's live identities or resource names.

## 1. Replace repository identity

- [ ] Set the new GitHub `OWNER/REPO`.
- [ ] Set a new project/resource prefix.
- [ ] Set the intended AWS Region(s).
- [ ] Set tags for project, environment, owner/purpose, and `managed-by`.
- [ ] Set the new documentation URL and repository URL.
- [ ] Remove historical run IDs, distribution IDs, resource names, and test evidence copied from a reference repo.

## 2. Verify every session before changes

- [ ] Confirm the exact GitHub repository and default branch.
- [ ] Confirm the connected GitHub account/app has the required repository access.
- [ ] Call AWS STS `GetCallerIdentity` through AWS MCP and confirm the intended account.
- [ ] Confirm the intended AWS Region before creating regional resources.
- [ ] Treat authentication as session-specific. Git carries knowledge; authentication does not.

## 3. Create repository-specific GitHub OIDC

- [ ] Reuse an account-level GitHub OIDC provider only when its issuer/audience are correct.
- [ ] Create a **new role for the new repository**; do not copy a role ARN from the reference lab.
- [ ] Scope the trust condition to the exact repository and approved ref/environment.
- [ ] Give the role only the permissions required by that repository's Terraform/apply path.
- [ ] Scope remote-state access to the intended bucket/key prefix.
- [ ] Do not use long-lived AWS access keys in GitHub.

## 4. Configure GitHub without committing live values

Typical repository variables:

- `AWS_REGION`
- `AWS_ALLOWED_ACCOUNT_ID`
- `AWS_DEPLOY_ROLE_ARN`
- `AWS_EXECUTION_REPOSITORY`
- `AWS_LABS_ENABLED`
- `TF_STATE_BUCKET`

Secrets or privacy-sensitive runtime values belong in an external secret/configuration store such as SSM Parameter Store, Secrets Manager, or GitHub Actions secrets. Do not place them in Terraform source, Markdown, workflow inputs on a public repository, or committed `.tfvars` files.

## 5. Keep public pull requests unprivileged

- [ ] Default workflow permission is `contents: read`.
- [ ] PR validation does **not** request `id-token: write`.
- [ ] PR validation does not read deployment secrets.
- [ ] Do not use `pull_request_target` for untrusted code.
- [ ] Pin third-party Actions to full commit SHAs.
- [ ] Use `persist-credentials: false` on checkout.
- [ ] Run Terraform formatting/validation with the backend disabled on PRs.

## 6. Make live AWS execution deliberate

- [ ] Live AWS workflows use `workflow_dispatch` only.
- [ ] Require `refs/heads/main`.
- [ ] Bind the job to the expected `github.repository`.
- [ ] Require an explicit enablement variable.
- [ ] Scope `id-token: write` to the AWS job only.
- [ ] Generate a saved Terraform plan and apply that exact plan.
- [ ] Do not print raw plan/state contents when they can include sensitive values.

## 7. Verify independently with AWS MCP

After an OIDC/IaC apply:

- [ ] Read back the created resources through AWS MCP.
- [ ] Verify important policy/trust/association fields, not only resource existence.
- [ ] Run an application-level smoke test when possible.
- [ ] Record exact evidence in the repo without copying secrets or authentication state.

## 8. Documentation and handoff

- [ ] Keep `PROMPT.md` as the one-URL agent entrypoint.
- [ ] Keep `CONTEXT.md` current-only.
- [ ] Put durable learning in `docs/`.
- [ ] Publish public docs only when all committed source/evidence is safe to disclose.
- [ ] For private docs, use an authenticated/allowlisted delivery pattern rather than assuming a private S3 origin makes the viewer site private.

## 9. Optional private static portal patterns

This reference includes two deliberately small examples:

1. **CloudFront + AWS WAF IP allowlist** — good for fixed office/VPN/home egress.
2. **CloudFront Function Basic Auth** — good for a small lab/demo, not a substitute for enterprise identity.

For both patterns:

- keep S3 private;
- use CloudFront Origin Access Control;
- keep runtime access values outside Git;
- treat Basic Auth as a lab pattern and use a strong unique password over HTTPS;
- prefer Cognito/enterprise IdP or signed-cookie architectures when user lifecycle, MFA, revocation, or audit requirements matter.

## Definition of ready

A new repository is ready when a fresh agent can start from its repository plus the reference `PROMPT.md`, verify GitHub/AWS identity, open a credential-free PR, merge validated IaC, execute a deliberate main-only OIDC deployment, verify the result through AWS MCP, and publish sanitized learning without requiring a developer workstation CLI.