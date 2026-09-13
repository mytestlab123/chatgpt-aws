# Documentation Hosting

Status: **VERIFIED / PASS**  
Verified: **2026-09-12**

## Live site

`https://d36j5fck6lkl41.cloudfront.net/`

The documentation source remains the repository's `docs/` directory and is rendered with **Material for MkDocs**.

!!! info "Reusable learning guide"
    This file is the implementation/evidence record for **this repository**. For a beginner-friendly tutorial comparing **GitHub Pages vs AWS S3 + CloudFront**, including private-sharing choices such as **GitHub Enterprise private Pages, Cloudflare Pages + Access, CloudFront signed content, and Netlify protection**, read [Static Documentation Hosting — GitHub Pages vs AWS S3 + CloudFront](STATIC_SITE_HOSTING_GUIDE.md).

## Working architecture

```text
ChatGPT / developer
        |
        v
GitHub docs/*.md + mkdocs.yml
        |
        v
GitHub Actions
        |
        | OIDC (no static AWS keys)
        v
Terraform ---------------------> AWS
        |                         |
        |                         +-- private S3 bucket
        |                         |   chatgpt-aws-docs-063884340510
        |                         |
        |                         +-- CloudFront distribution
        |                             E2M7VGXRFDXI7H
        |                             d36j5fck6lkl41.cloudfront.net
        |
        +-- mkdocs build --strict
        +-- aws s3 sync site/ ... --delete
        +-- CloudFront invalidation
        +-- live curl verification
```

CloudFront accesses the private S3 REST origin through Origin Access Control (OAC). S3 Block Public Access remains enabled on all four controls.

## Why the original GitHub Pages URL returned 404

Material for MkDocs itself was not the problem.

`mkdocs build --strict` passed repeatedly, but repository metadata reported:

```text
has_pages: false
```

`actions/configure-pages@v5` therefore failed with:

```text
Get Pages site failed
Not Found
```

The connected GitHub app can edit repository files/workflows but does not expose the repository Pages administration setting. A private organization repository can also be subject to GitHub plan/organization Pages restrictions.

The reusable lesson is:

> Separate the documentation generator from its hosting target. Material for MkDocs can build once and be published to GitHub Pages, S3 + CloudFront, or another static host.

## Why `use_directory_urls: false`

The site uses a **private S3 REST endpoint** behind CloudFront, not the public S3 website endpoint.

CloudFront's default root object solves `/`, but it does not automatically turn every `/page/` request into `/page/index.html` for an S3 REST origin.

Therefore `mkdocs.yml` uses:

```yaml
use_directory_urls: false
```

MkDocs emits links such as:

```text
SESSION_BOOTSTRAP.html
DRIFT_DEMO.html
AUTOMATION_CICD_LAB.html
```

This avoids subdirectory 404s without adding Lambda@Edge or CloudFront Functions.

## Retained AWS resources

| Resource | Value |
|---|---|
| S3 bucket | `chatgpt-aws-docs-063884340510` |
| CloudFront distribution | `E2M7VGXRFDXI7H` |
| CloudFront domain | `d36j5fck6lkl41.cloudfront.net` |
| Origin Access Control | `E10YPJ26EF3Z3U` / `chatgpt-aws-docs-oac` |
| Terraform state | `s3://chatgpt-aws-tfstate-063884340510/state/chatgpt-aws/docs-site.tfstate` |
| IaC | `infra/docs-site/main.tf` |
| CI/CD | `.github/workflows/docs-aws.yml` |

## Verification evidence

PR #16 validated the design before merge:

```text
mkdocs build --strict: PASS
Terraform validate: PASS
Terraform plan: 7 to add, 0 to change, 0 to destroy
GitHub OIDC STS identity: PASS
```

Main workflow run `34684093457`, attempt 2, completed successfully after one least-privilege correction.

The first attempt successfully created the infrastructure and uploaded the site, but the CloudFront invalidation waiter exposed one missing read permission:

```text
cloudfront:GetInvalidation
```

That permission was added to the existing `DocsSiteCloudFront` statement on `github-actions-chatgpt-aws-lab`. The rerun then passed end-to-end.

The workflow live-tests:

- `/`
- `/SESSION_BOOTSTRAP.html`
- `/PORTABLE_AWS_MCP_KNOWLEDGE.html`
- `/EXPERIMENTS.html`
- `/DRIFT_DEMO.html`
- `/AUTOMATION_CICD_LAB.html`
- `/AMIT_AUTOMATION_CICD_LAB.html`
- `/search/search_index.json`

It also asserts expected content in the home page, custom visual HTML page, and search index.

Independent AWS Core readback verified:

- CloudFront distribution status: `Deployed` and enabled;
- default root object: `index.html`;
- private S3 bucket exists in `ap-southeast-1`;
- all four S3 public-access-block controls are `true`;
- OAC signing behavior is `always`;
- bucket policy permits CloudFront service read using the exact distribution condition;
- 54 generated objects are present;
- all navigation pages, the custom HTML page, and `search/search_index.json` are present.

## Normal update flow

For documentation changes:

```text
edit docs/*.md
      -> PR
      -> strict MkDocs build + Terraform plan
      -> merge main
      -> Terraform reconcile
      -> S3 sync
      -> CloudFront invalidate
      -> live URL checks
```

No manual S3 upload and no long-lived AWS access key are required.

## For another ChatGPT session

Do not assume the old GitHub Pages URL is the live site.

Use this order:

1. Read repo authority files (`AGENTS.md`, `CONTEXT.md`, `SPEC.md`).
2. Read `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`.
3. Read this file for the docs hosting path.
4. Verify AWS identity before mutation.
5. Treat `infra/docs-site/` as desired state for hosting resources.
6. Treat `.github/workflows/docs-aws.yml` as the publication and live-verification path.
7. Use AWS Core for independent readback; do not silently mutate Terraform-owned hosting resources through MCP.

## GitHub Pages later

GitHub Pages remains optional. If it is eventually enabled for the repository, Material can be deployed there too. Do not change the Markdown knowledge layout just to switch hosting targets.
