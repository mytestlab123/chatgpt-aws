# New Repository Bootstrap — ChatGPT + AWS MCP + GitHub OIDC

This is the repeatable path for starting a **new AWS repository** from the reference operating model without copying the reference lab's identities.

## Target outcome

```text
You
  ↓
ChatGPT / Codex / agent
  ├─ AWS MCP -> discover / diagnose / verify
  └─ GitHub -> IaC -> PR -> GitHub Actions -> OIDC -> AWS
                                      ↓
                               AWS MCP readback
                                      ↓
                              docs/ -> Pages
```

Core rule:

> **MCP discovers and verifies; Git/IaC declares; OIDC CI/CD applies.**

## Phase 1 — create the repository

Create the new repository from your preferred starter/template or as an empty repository if you want the smallest possible surface.

At minimum establish:

```text
AGENTS.md
CONTEXT.md
PROMPT.md
README.md
docs/
infra/
.github/workflows/
```

The new repository is authoritative. The reference repository is read-only learning material.

## Phase 2 — verify the live session

Before any AWS mutation, the agent must verify:

1. exact GitHub `OWNER/REPO`;
2. current default branch;
3. connected GitHub authority;
4. AWS STS identity through AWS MCP;
5. intended AWS Region(s).

Example AWS MCP check:

```text
STS GetCallerIdentity
```

Compare the returned account to the intended account. Do not infer identity from a previous chat, a README, a role name, or a local profile name.

## Phase 3 — establish GitHub OIDC

### Account-level provider

An AWS account can reuse the GitHub Actions OIDC provider for:

```text
https://token.actions.githubusercontent.com
```

Audience:

```text
sts.amazonaws.com
```

Verify the existing provider before creating another.

### Repository-specific role

Create a **new role for the new repository**. Scope its trust to the exact repository and approved execution path.

Conceptual trust condition:

```text
aud == sts.amazonaws.com
sub == repo:OWNER/REPO:ref:refs/heads/main
```

If you intentionally use GitHub Environments, bind trust to the exact environment subject instead.

Do not copy a role ARN, repository ID, account ID, branch subject, or trust statement from the reference lab without replacing and verifying it.

### Permissions

Start with the actions required by the new repository's Terraform/apply path. Scope resources wherever the AWS API supports resource-level permissions. Keep remote-state permissions limited to the expected bucket and key prefix.

Avoid an AdministratorAccess deployment role merely because the project is a lab. Broaden only when the experiment genuinely requires it, then document why.

## Phase 4 — configure repository variables

Typical non-secret repository variables:

```text
AWS_REGION
AWS_ALLOWED_ACCOUNT_ID
AWS_DEPLOY_ROLE_ARN
AWS_EXECUTION_REPOSITORY
AWS_LABS_ENABLED
TF_STATE_BUCKET
```

Keep secret or privacy-sensitive runtime values outside Git. Suitable stores include:

- AWS Systems Manager Parameter Store;
- AWS Secrets Manager;
- GitHub Actions secrets.

Do not use workflow-dispatch text inputs for values you do not want exposed in a public repository's workflow metadata.

## Phase 5 — Terraform structure

Prefer backend configuration that does not hardcode a reference account/resource into reusable source:

```hcl
terraform {
  backend "s3" {}
}
```

Pass the bucket, key and Region during trusted main-only execution.

PR validation should use:

```text
terraform fmt -check
terraform init -backend=false
terraform validate
```

No AWS credentials are required for this validation when the configuration does not evaluate live data during validation.

## Phase 6 — public PR path

For a public repository:

```text
feature branch
  -> pull request
  -> unit/security checks
  -> terraform validate (backend disabled)
  -> docs build
```

PR invariants:

- `contents: read` only by default;
- no `id-token: write`;
- no deployment secrets;
- no live AWS mutations;
- no `pull_request_target` for untrusted code;
- Actions pinned to immutable commit SHAs.

## Phase 7 — deliberate live apply

After review and merge:

```text
main
  -> workflow_dispatch
  -> repository/main/enablement guards
  -> short-lived GitHub OIDC credentials
  -> terraform plan -out=tfplan
  -> terraform apply tfplan
```

Validate the target account before planning/applying. Do not rely only on the role name.

## Phase 8 — AWS MCP verification

After apply, independently read back the real AWS configuration through MCP.

Examples:

- resource exists and is enabled;
- CloudFront distribution points to the intended private origin;
- S3 public-access block is enabled;
- OAC/bucket policy source ARN is correct;
- WAF is associated with the intended distribution;
- IAM role trust/permissions match the intended repository;
- application endpoint returns the expected result.

Do not call an infrastructure change complete only because Terraform exited successfully.

## Phase 9 — record durable learning

Update:

```text
CONTEXT.md        current state only
docs/             reusable learning/runbooks
PROMPT.md         compact agent bootstrap
```

Avoid recording:

- credentials;
- authentication tokens;
- raw Terraform state;
- raw plan files;
- private runtime values;
- copied account-specific identities that a future repository could mistakenly reuse.

## Private static portal example

The optional private-portal lab demonstrates two small viewer-access patterns while keeping S3 private:

```text
A. CloudFront + AWS WAF IP allowlist
B. CloudFront + CloudFront Function Basic Auth
```

The code intentionally accepts runtime values from outside Git. A future repository should use its own allowlist/authentication values and its own OIDC role/state.

## Handoff prompt for a new agent

Give the agent the reference `PROMPT.md` URL and say:

> Study this operating model, then apply it to my new repository. Treat the reference repository as read-only. Verify the exact GitHub repository and AWS STS identity first. Create new repository-specific OIDC/state/resource identities. Keep PR validation credential-free, use IaC for durable changes, use main-only OIDC for apply, and verify the final AWS state independently with AWS MCP.