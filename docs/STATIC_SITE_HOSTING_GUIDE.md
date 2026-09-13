# Static Documentation Hosting — GitHub Pages vs AWS S3 + CloudFront

Status: **REUSABLE LEARNING GUIDE**  
Audience: developers, platform engineers, and ChatGPT/Codex sessions building static documentation from GitHub

## What this guide teaches

A Git repository and a static website are two different things.

A repository can be **private** while the generated website is **public**. The hosting layer decides who can view the rendered site.

This guide covers:

1. **GitHub Pages** — simplest GitHub-native publishing path.
2. **AWS S3 + CloudFront** — more infrastructure control and an AWS-native CI/CD path.
3. **Private sharing options** — GitHub Enterprise private Pages, Cloudflare Pages + Access, CloudFront private content, and Netlify protected deploys.

The examples use **Material for MkDocs**, but the hosting concepts also apply to other static generators such as Docusaurus, Hugo, Jekyll, and Sphinx.

---

## 1. Minimal Material for MkDocs project

A useful starting layout is:

```text
my-docs-repo/
├── docs/
│   ├── index.md
│   ├── architecture.md
│   └── runbook.md
├── mkdocs.yml
└── requirements-docs.txt
```

`requirements-docs.txt`:

```text
mkdocs-material
```

Minimal `mkdocs.yml`:

```yaml
site_name: My Documentation

theme:
  name: material

plugins:
  - search

nav:
  - Home: index.md
  - Architecture: architecture.md
  - Runbook: runbook.md
```

Local development:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-docs.txt
mkdocs serve
```

Build exactly what the hosting system will publish:

```bash
mkdocs build --strict
```

The generated static website is placed in:

```text
site/
```

That `site/` directory is what GitHub Pages, Cloudflare Pages, S3 + CloudFront, Netlify, and similar platforms ultimately serve.

---

# Option A — GitHub Pages

## Architecture

```text
GitHub repository
      |
      v
Material for MkDocs
      |
      v
GitHub Actions
      |
      v
GitHub Pages
      |
      v
https://<owner>.github.io/<repo>/
```

## Why use it

Use GitHub Pages when you want:

- the fewest moving parts;
- documentation close to the repository;
- no separate cloud infrastructure;
- simple public project documentation;
- GitHub-native review and deployment.

## Typical setup

Configure the correct Pages URL in `mkdocs.yml`:

```yaml
site_url: https://YOUR-OWNER.github.io/YOUR-REPO/
```

A modern GitHub Pages workflow can build MkDocs and deploy the generated `site/` artifact:

```yaml
name: Docs Pages

on:
  push:
    branches: [main]
    paths:
      - "docs/**"
      - "mkdocs.yml"
      - "requirements-docs.txt"
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.x"
      - run: pip install -r requirements-docs.txt
      - run: mkdocs build --strict
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v4
        with:
          path: site

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
    steps:
      - uses: actions/deploy-pages@v4
```

Then configure the repository's Pages publishing source to **GitHub Actions**.

## Common 404 causes

If `mkdocs build --strict` succeeds but the Pages URL returns `404`, check the hosting control plane rather than immediately changing MkDocs:

- Pages is not enabled for the repository;
- the organization or plan does not permit the requested Pages configuration;
- the publishing source is not set to GitHub Actions;
- the expected project URL is wrong;
- the workflow never reached the Pages deployment step.

A successful MkDocs build proves that static HTML was generated. It does **not** prove that GitHub Pages accepted or published it.

## Private repository does not automatically mean private Pages

Repository visibility and Pages-site visibility are separate controls.

GitHub supports **privately published GitHub Pages sites for GitHub Enterprise Cloud organizations**. A privately published project site can be restricted to people who already have read access to the source repository.

Official reference:

https://docs.github.com/en/enterprise-cloud@latest/pages/getting-started-with-github-pages/changing-the-visibility-of-your-github-pages-site

For organizations that are not using the required GitHub Enterprise Cloud capability, do not assume that a private repository gives you a private documentation website.

---

# Option B — AWS S3 + CloudFront

## Architecture

```text
GitHub repository
      |
      v
Material for MkDocs
      |
      v
GitHub Actions
      |
      | GitHub OIDC
      v
AWS deployment role
      |
      +----> Terraform / IaC
      |
      +----> private S3 bucket
                    ^
                    |
             CloudFront OAC
                    |
                    v
               CloudFront
                    |
                    v
      https://xxxxx.cloudfront.net/
```

## Why use it

Use S3 + CloudFront when you want:

- an AWS-native deployment path;
- infrastructure managed by Terraform/CDK/CloudFormation;
- a private S3 origin;
- CloudFront caching and custom domains;
- AWS WAF or other AWS edge controls;
- deployment through GitHub OIDC instead of static AWS access keys;
- more control over future authentication and distribution design.

## Important distinction: private origin vs private website

This architecture commonly uses:

- **S3 Block Public Access = enabled**;
- **CloudFront Origin Access Control (OAC)**;
- an S3 bucket policy allowing only the intended CloudFront distribution.

That makes the **S3 origin private**.

It does **not automatically make the CloudFront website private to viewers**.

If anyone can reach the CloudFront hostname and no viewer authentication/restriction is configured, the rendered website is still public.

## Recommended deployment flow

```text
edit docs/*.md
      |
      v
Pull Request
      |
      +--> mkdocs build --strict
      +--> terraform plan
      |
      v
merge main
      |
      +--> GitHub OIDC -> AWS
      +--> terraform apply/reconcile
      +--> aws s3 sync site/ s3://... --delete
      +--> CloudFront invalidation
      +--> live HTTP checks
```

No long-lived AWS access keys are required when GitHub Actions assumes an AWS role using OIDC.

## S3 REST origin and MkDocs URLs

With a private S3 **REST** origin behind CloudFront, the simplest MkDocs configuration is often:

```yaml
use_directory_urls: false
```

That creates links such as:

```text
architecture.html
runbook.html
```

instead of relying on requests such as:

```text
/architecture/
```

being translated to:

```text
/architecture/index.html
```

This avoids a common source of CloudFront/S3 REST-origin 404s without requiring Lambda@Edge or a CloudFront Function for path rewriting.

## Minimal Terraform building blocks

A reusable Terraform implementation usually contains:

```text
aws_s3_bucket
aws_s3_bucket_public_access_block
aws_s3_bucket_server_side_encryption_configuration
aws_cloudfront_origin_access_control
aws_cloudfront_distribution
aws_s3_bucket_policy
```

The S3 policy should allow the CloudFront service principal to read objects only when the request belongs to the intended distribution.

## CloudFront cache invalidation

After uploading a new static build:

```bash
aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths '/*'
```

If CI waits for completion, the AWS role also needs the read permission required to check invalidation status.

---

# Public hosting comparison

| Question | GitHub Pages | AWS S3 + CloudFront |
|---|---|---|
| Simplest setup | **Best** | More components |
| GitHub-native | **Yes** | GitHub + AWS |
| Infrastructure as Code | Limited hosting control | **Excellent** |
| Private S3 origin | N/A | **Yes, with OAC** |
| Custom CDN controls | Limited | **Strong** |
| AWS WAF integration | No | **Yes** |
| OIDC-to-AWS learning | No AWS required | **Excellent** |
| Custom auth possibilities | Depends on GitHub plan | **Many, but you design them** |
| Best for public OSS docs | **Usually GitHub Pages** | Often unnecessary |
| Best for AWS platform lab | Good docs host | **Better learning value** |

---

# Private documentation sharing options

## First rule

> **Private source code does not imply a private generated website.**

Always evaluate these separately:

```text
1. Who can read the Git repository?
2. Who can access the rendered website?
```

## Decision matrix

| Option | Can source repo be private? | Can rendered site be private? | Authentication model | Complexity | Good fit |
|---|---:|---:|---|---|---|
| GitHub Enterprise Cloud private Pages | Yes | **Yes** | GitHub/repository access | Low | Enterprise already using GitHub |
| Cloudflare Pages + Cloudflare Access | Yes | **Yes** | Cloudflare Access policies / IdP | Low-Medium | Small teams, internal docs, external sharing with login |
| S3 + CloudFront + signed cookies/URLs | Yes | **Yes** | CloudFront signatures | Medium-High | AWS-native restricted content |
| S3 + CloudFront + application authentication | Yes | **Yes** | Cognito/custom IdP/app session | High | Full AWS application-style access control |
| Netlify protected/private deploy | Yes | **Yes** | Team login, SSO, or password options | Low-Medium | Fast managed private sharing |

---

# Private option 1 — GitHub Enterprise Cloud private Pages

GitHub Enterprise Cloud can publish eligible Pages project sites **privately**.

Conceptually:

```text
Private GitHub repository
        |
        v
GitHub Pages
        |
        v
GitHub authentication
        |
        v
repository-authorized readers only
```

This is the cleanest option when:

- your organization already pays for GitHub Enterprise Cloud;
- the same GitHub users who can read the repository should read the site;
- you do not need a separate identity layer.

Official reference:

https://docs.github.com/en/enterprise-cloud@latest/pages/getting-started-with-github-pages/changing-the-visibility-of-your-github-pages-site

---

# Private option 2 — Cloudflare Pages + Cloudflare Access

Cloudflare Pages supports Git integration with **private as well as public GitHub repositories**.

Official reference:

https://developers.cloudflare.com/pages/get-started/git-integration/

However, the important distinction remains:

> Connecting a private GitHub repository to Cloudflare Pages protects the **source repository**, not automatically the **website visitors**.

For viewer privacy, put **Cloudflare Access** in front of the Pages hostname/custom domain.

Architecture:

```text
Private GitHub repository
        |
        v
Cloudflare Pages build
        |
        v
Pages deployment
        |
        v
Cloudflare Access
        |
        +--> Access policy
        +--> identity provider / allowed users
        |
        v
Authorized browser
```

Cloudflare documents how to enable Access for the `*.pages.dev` domain and how to create an Access application for a custom domain.

Official references:

https://developers.cloudflare.com/pages/platform/known-issues/#enable-access-on-your-pagesdev-domain

https://developers.cloudflare.com/cloudflare-one/access-controls/applications/choose-application-type/

### Practical setup sequence

1. Connect the private GitHub repository to Cloudflare Pages.
2. Build the static site, for example:

   ```text
   Build command: mkdocs build --strict
   Output directory: site
   ```

3. Enable a Cloudflare Access policy for the Pages project.
4. Define who can authenticate through the Access policy.
5. If using a custom domain, create the corresponding Access application/policy for that hostname as documented by Cloudflare.
6. Verify that unauthenticated users get the Access login flow rather than the website.
7. Verify an authorized user can reach the rendered docs.

### Why this is attractive

For a small private knowledge portal, Cloudflare Pages + Access can be considerably simpler than building a complete login system in AWS.

You get:

```text
Git-based publishing
+ CDN/static hosting
+ viewer authentication gate
```

without writing an authentication application.

---

# Private option 3 — AWS CloudFront signed URLs or signed cookies

CloudFront can require **signed URLs** or **signed cookies** for private content.

Official AWS references:

https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PrivateContent.html

https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-choosing-signed-urls-cookies.html

General choice:

- **Signed URL** — useful when restricting individual files or links.
- **Signed cookies** — usually better when users need access to many files without changing every URL, which fits a documentation website more naturally.

Architecture:

```text
User
  |
  v
authentication / authorization service
  |
  +--> creates CloudFront signed cookie
  |
  v
CloudFront
  |
  v
private S3 origin through OAC
```

This is AWS-native and powerful, but it requires a trusted component to authenticate the user and issue the signed URL/cookie.

Therefore it is not as simple as Cloudflare Access for a small internal docs site.

---

# Private option 4 — AWS CloudFront + full application authentication

For a more application-like internal portal, you can place an authentication flow in front of CloudFront using AWS services or another identity provider.

Possible building blocks include:

```text
CloudFront
+ Cognito or external IdP
+ Lambda@Edge / application authorization logic
+ private S3 origin
```

This gives more control over users, groups, sessions, and application behavior, but it is substantially more complex than static hosting alone.

Use it when authentication itself is part of the platform requirement, not merely because the docs repository happens to be private.

---

# Private option 5 — Netlify protected/private deploys

Netlify also provides managed access-control options for hosted sites, including protected/private deploy patterns, team login, SSO-related options, and password protection depending on configuration/plan.

Official reference:

https://docs.netlify.com/manage/security/secure-access-to-sites/password-protection/

Architecture:

```text
Private Git repository
      |
      v
Netlify build
      |
      v
Netlify visitor protection
      |
      v
Authorized user
```

This is useful if you prefer a managed static-hosting service and do not specifically need AWS or Cloudflare.

---

# Which private-sharing option should I choose?

## If you already have GitHub Enterprise Cloud

Use:

```text
GitHub private Pages
```

It is the smallest operational model when repository readers and site readers are the same people.

## If you want the simplest standalone private docs portal

Strong candidate:

```text
Cloudflare Pages + Cloudflare Access
```

Especially useful when you want a login gate without building an authentication application.

## If your organization is AWS-first

Use:

```text
private S3 + CloudFront
```

Then choose the viewer control according to the requirement:

```text
simple restricted content
    -> signed URLs / signed cookies

full user/group/session application
    -> Cognito / IdP + authorization layer
```

## If you want managed hosting with built-in protection controls

Evaluate:

```text
Netlify protected/private deploys
```

---

# Recommended learning progression

For a learner, do these in order:

```text
1. Material for MkDocs locally
        |
2. GitHub Pages public site
        |
3. GitHub Actions build/deploy
        |
4. AWS S3 + CloudFront public viewer path
        |
5. GitHub OIDC -> AWS deployment
        |
6. private viewer authentication
        |
7. custom domain / WAF / advanced controls
```

Do not start with Cognito, Lambda@Edge, signed cookies, or a large Zero Trust design before you have proven that the static site itself builds and publishes correctly.

---

# Troubleshooting checklist

## Build succeeds, website returns 404

Check in this order:

```text
1. Did mkdocs build --strict succeed?
2. Does site/index.html exist?
3. Did the hosting deployment step run?
4. Is the hosting service actually enabled?
5. Is the expected hostname correct?
6. Is the generated path compatible with the origin?
7. Is the CDN serving an older cached response?
```

## S3 is private but CloudFront page is public

That is expected unless viewer access control is configured.

OAC answers:

> Can visitors bypass CloudFront and read S3 directly?

It does **not** answer:

> Which visitors are allowed to use the CloudFront URL?

Those are different security controls.

## Cloudflare Pages came from a private repository but anyone can open it

That is also possible and expected unless viewer access is gated.

Add Cloudflare Access policies to the Pages/custom hostname when the rendered website itself must be private.

---

# KISS recommendation

Use the smallest solution that matches the audience:

```text
PUBLIC docs, GitHub-centric
    -> GitHub Pages

PUBLIC docs, AWS learning/platform ownership
    -> private S3 origin + CloudFront

PRIVATE docs, GitHub Enterprise already available
    -> GitHub Enterprise private Pages

PRIVATE docs, simplest separate identity gate
    -> Cloudflare Pages + Cloudflare Access

PRIVATE docs, AWS-native control required
    -> CloudFront signed cookies/URLs or an AWS authentication layer
```

The static generator does not need to change when the hosting target changes.

Keep:

```text
docs/*.md
mkdocs.yml
```

as the source of truth, then choose the publication target independently.

---

# This repository's proven example

`mytestlab123/chatgpt-aws` currently uses:

```text
Material for MkDocs
      -> GitHub Actions
      -> GitHub OIDC
      -> Terraform
      -> private S3 origin
      -> CloudFront OAC
      -> public CloudFront viewer URL
```

The implementation-specific evidence is intentionally kept separate in:

`docs/HOSTING.md`

That file contains the actual retained resource names, workflow evidence, 404 investigation, and verification results for this lab.

This guide is the reusable tutorial; `HOSTING.md` is the real-world implementation record.
