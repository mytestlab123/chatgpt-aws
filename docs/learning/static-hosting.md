# Static Documentation Hosting

A private source repository and a private website are different things. Hosting decides who can view the generated site.

## Common choices

| Option | Source repo can be private | Viewer site can be private | Best fit |
|---|---:|---:|---|
| GitHub Pages | Yes, depending on plan/setup | Public by default; private publication requires eligible GitHub Enterprise capability | Simple public project docs |
| AWS S3 + CloudFront | Yes | Yes, if viewer authentication/restriction is added | AWS-native platform control |
| Cloudflare Pages + Access | Yes | Yes | Simple authenticated private docs |
| Netlify protected site | Yes | Yes, depending on plan/config | Managed static hosting |

## GitHub Pages

```text
GitHub repo
  -> MkDocs
  -> GitHub Actions
  -> GitHub Pages
```

For a public repository this is usually the smallest operational model.

Typical project URL:

```text
https://OWNER.github.io/REPOSITORY/
```

One repository has one Pages site, but that site can contain many sections and nested paths.

## AWS S3 + CloudFront

```text
GitHub
  -> MkDocs
  -> Actions + OIDC
  -> private S3 origin
  -> CloudFront
```

With S3 Block Public Access and CloudFront Origin Access Control (OAC), the **origin** is private. That does not automatically make the CloudFront viewer URL private.

For private viewer access, add an authorization model such as signed cookies/URLs or an application/identity layer.

## Two-repository publishing pattern

A useful architecture is:

```text
PRIVATE engineering repo
        |
        | curated, sanitized docs only
        v
PUBLIC docs repo
        |
        v
GitHub Pages
```

Advantages:

- implementation remains private;
- only an explicit allow-list of teaching material is published;
- public documentation has a clean history and URL;
- accidental mirroring of the private repository is avoided.

## Publishing safety rule

> **Never publish the private repository wholesale. Publish only an explicit curated documentation tree.**

Before publishing, exclude credentials, account IDs, private resource names, internal evidence, and operational details that are not needed to teach the reusable pattern.
