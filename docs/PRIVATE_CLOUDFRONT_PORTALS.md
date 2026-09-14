# Private CloudFront Static Portals

This lab keeps the S3 origin private and demonstrates two small viewer-access patterns in front of CloudFront.

## What this proves

```text
private S3
   ↑
CloudFront Origin Access Control
   ↑
CloudFront
   ├─ Pattern A: AWS WAF IP allowlist
   └─ Pattern B: CloudFront Function Basic Auth
```

A private S3 bucket **does not by itself make the CloudFront viewer URL private**. Viewer authorization must be enforced separately.

## Comparison

| Pattern | Best for | Strength | Operational cost | Main limitation |
|---|---|---:|---:|---|
| CloudFront + AWS WAF IP allowlist | Fixed office/VPN/home egress | High for fixed-network access | Low | Breaks when client public IP changes |
| CloudFront Function Basic Auth | Personal lab/demo portal | Moderate | Very low | Shared password, no MFA/user lifecycle |
| CloudFront signed cookies/URLs | Expiring access to many private objects | High | Medium | Needs an issuer/authentication flow |
| Cognito/enterprise IdP | Multiple named users, MFA, lifecycle | High | Higher | More components than a small static lab needs |

The repository implements and tests the first two patterns only.

## Shared origin security

Both examples use:

- a dedicated S3 bucket;
- all four S3 Block Public Access controls;
- BucketOwnerEnforced object ownership;
- server-side encryption;
- a CloudFront Origin Access Control (OAC);
- a bucket policy that permits only the matching CloudFront distribution ARN to read objects;
- HTTPS at the viewer edge.

This prevents direct public S3 access and prevents a different CloudFront distribution from reusing the bucket policy grant.

## Pattern A — AWS WAF IP allowlist

```text
browser
  ↓
CloudFront
  ↓
AWS WAF Web ACL
  ├─ configured IPv4 /32 -> ALLOW
  └─ everything else    -> BLOCK
  ↓
private S3 through OAC
```

For CloudFront-scoped AWS WAF resources, WAF API operations use the `us-east-1` endpoint. The Terraform example therefore uses an aliased `us-east-1` provider for the IP set and Web ACL while the S3 origin can remain in another Region.

The allowed address is a runtime variable. A personal/office address must **not** be committed to this public repository. The manual workflow loads it from an external parameter and passes it to Terraform only during trusted execution.

### What to verify

- IP set contains exactly the intended CIDR(s).
- Web ACL default action is `BLOCK`.
- The only allow rule references the intended IP set.
- The CloudFront distribution has the Web ACL ARN associated.
- Requests from a non-allowed network receive HTTP 403.
- A request from the allowlisted network receives the portal HTML.

## Pattern B — CloudFront Function Basic Auth

```text
browser
  ↓ Authorization: Basic ...
CloudFront Function (viewer-request)
  ├─ verifier matches -> request continues
  └─ no/mismatch      -> 401 + WWW-Authenticate
  ↓
private S3 through OAC
```

The repository does **not** store the raw username/password in Git or Terraform source.

The trusted workflow:

1. reads the username/password from an external parameter store;
2. masks them in the Actions log;
3. builds the normal HTTP Basic `Authorization` header in memory;
4. computes a SHA-256 digest;
5. passes only the digest to Terraform;
6. deploys a CloudFront Function that hashes each incoming Authorization header and compares the digest.

The public source therefore contains the verification algorithm but not the runtime credential.

### Why hash the complete Authorization header?

CloudFront Functions provides the `crypto` module with SHA-256 support. Hashing the complete header avoids embedding the reversible Base64 credential string in repository source or function code.

This is still a **lab/simple portal** pattern. A verifier exposed in public source can support offline password guessing, so use a strong unique password. For enterprise users, MFA, revocation, user lifecycle, and audit requirements, prefer Cognito/enterprise IdP or another real authentication layer.

### What to verify

- no Authorization header -> HTTP 401;
- wrong Authorization header -> HTTP 401;
- correct credentials -> HTTP 200 and the expected portal marker;
- direct S3 access is not public;
- the CloudFront Function is associated on `viewer-request`.

## Terraform and workflow

Terraform:

```text
infra/private-portals/main.tf
```

Manual live workflow:

```text
.github/workflows/private-portals-lab.yml
```

PRs only run credential-free repository/Terraform validation. The live workflow is `workflow_dispatch`, `main`-only, repository-bound, and opt-in, with OIDC scoped to the live job.

Expected external runtime parameters:

```text
/agent-private-portals/allowed-cidr
/agent-private-portals/basic-user
/agent-private-portals/basic-password
```

Expected non-secret repository variable in addition to the standard AWS variables:

```text
TF_STATE_BUCKET
```

Do not put the password or personal IP into workflow-dispatch text inputs on a public repository.

## Verification model

The preferred durable loop is:

```text
PR
  -> credential-free validate
  -> merge
  -> manual main-only OIDC apply
  -> live HTTP checks
  -> AWS MCP readback of S3/OAC/CloudFront/WAF/function associations
```

AWS MCP is also useful for bounded experiments and independent readback, but persistent infrastructure should remain declared in IaC.

## Cleanup

These are lab resources. When no longer needed, destroy the Terraform stack rather than leaving unused CloudFront distributions, WAF resources, and buckets running.

If a test uses temporary MCP-created proof resources, delete those proof resources after the evidence is recorded; do not confuse them with the Terraform-managed steady state.