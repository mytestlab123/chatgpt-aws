# Documentation Hosting

Status: **VERIFIED / SAME-REPO GITHUB PAGES**  
Last checked: **2026-09-14**

## Primary site

`https://mytestlab123.github.io/chatgpt-aws/`

Architecture:

```text
docs/ + mkdocs.yml
        -> public PR: credential-free strict build
        -> reviewed main
        -> GitHub Actions
        -> GitHub Pages
```

## Verification evidence

After the one-time repository setting **Settings -> Pages -> Source: GitHub Actions** was enabled, the Pages workflow completed build, deployment, and exact live-commit verification successfully.

Verified stages:

- unit/public-safety checks: PASS;
- backend-free Terraform validation: PASS;
- strict Material build: PASS;
- Pages artifact upload: PASS;
- Pages configuration: PASS;
- Pages deployment: PASS;
- exact live commit verification: PASS.

The workflow writes `build-info.json` containing the repository name and exact source commit SHA, then verifies the live site serves that same revision. This prevents a stale but reachable site from being mistaken for a successful deployment.

## Why one public repo is preferred here

When source code and documentation are both intentionally public, a separate publication repository adds a cross-repo credential and synchronization path without adding a confidentiality boundary.

Steady state:

```text
PUBLIC repository
  -> code + IaC + docs + tests
  -> GitHub Pages
```

## Private static portal patterns

A private S3 origin does **not** automatically make a CloudFront viewer URL private. Viewer access control is a separate layer.

This repository includes two optional learning patterns in `infra/private-portals/`:

| Pattern | Best fit | Main trade-off |
|---|---|---|
| CloudFront + AWS WAF IP allowlist | Fixed office/VPN/home egress | Access breaks when the viewer public IP changes |
| CloudFront Function Basic Auth | Small personal lab/demo portal | Shared password; no MFA or user lifecycle |

Both patterns keep S3 private with Block Public Access and CloudFront Origin Access Control.

### Pattern A — WAF allowlist

```text
browser
  -> CloudFront
  -> AWS WAF
       allowed runtime /32 -> ALLOW
       everything else     -> BLOCK
  -> private S3 through OAC
```

CloudFront-scope WAF resources are managed through the `us-east-1` WAF endpoint. The Terraform example uses a `us-east-1` provider alias for the IP set and Web ACL while the S3 origin can stay in another Region.

The personal/office CIDR is supplied only at trusted runtime. It is not committed to the public repository.

Verify:

- Web ACL default action is BLOCK;
- the allow rule references the intended IP set;
- the distribution is associated with that Web ACL;
- a request from outside the allowlist returns HTTP 403;
- a request from the allowlisted network returns the portal page.

### Pattern B — Basic Auth

```text
browser
  -> Authorization header
  -> CloudFront Function viewer-request
       verifier match -> continue
       missing/wrong  -> 401
  -> private S3 through OAC
```

The raw credential is not stored in Git or Terraform source. Trusted execution derives a SHA-256 verifier for the complete HTTP Authorization header and passes only that verifier to Terraform. The edge function hashes the incoming header before comparison.

This avoids embedding the reversible Basic credential string in public source, but the verifier can still support offline password guessing. Use a strong unique password and treat this as a small lab pattern. For named users, MFA, revocation, lifecycle, or stronger auditability, prefer Cognito/enterprise IdP or a signed-cookie architecture.

### Durable implementation path

```text
public PR
  -> credential-free Terraform validation
  -> merge
  -> manual main-only GitHub OIDC apply
  -> HTTP smoke tests
  -> AWS MCP independent readback
```

Runtime access values belong outside Git, such as SSM Parameter Store, Secrets Manager, or GitHub Actions secrets. Do not put them into public workflow-dispatch text inputs.

## Retained legacy paths

The previous AWS-hosted documentation remains available as a historical/rollback path, and the older dedicated public-docs repository remains historical evidence of a review-gated private-to-public publishing model.

Neither is required for the normal public single-repo path now. Keep them for a short rollback window, then prefer **archive first, delete later** if they are no longer needed.

The private-to-public two-repo pattern is still valid for genuinely private engineering repositories.

## Reusable hosting lesson

> Separate a successful documentation build from a verified live deployment, and separate private origin access from private viewer access.

For a public learning/template repo, same-repo GitHub Pages is the simplest architecture when everything committed is safe to disclose. For private or sensitive engineering, retain a private source boundary and choose a deliberate viewer-access control.

For a broader comparison, read `STATIC_SITE_HOSTING_GUIDE.md`.
