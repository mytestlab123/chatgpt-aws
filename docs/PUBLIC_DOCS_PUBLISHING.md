# Public Documentation Mirror

Status: **SOURCE IMPLEMENTED / DESTINATION REPOSITORY PENDING**

## Goal

Keep the engineering repository private while publishing only reusable learning material to a separate public repository and GitHub Pages site.

```text
PRIVATE mytestlab123/chatgpt-aws
        |
        | explicit curated tree only
        v
    public-docs/
        |
        v
PUBLIC mytestlab123/chatgpt-aws-docs
        |
        v
GitHub Pages
```

## Safety boundary

The publisher copies only `public-docs/`. It never mirrors the private repository root.

Do not place account identifiers, credentials, secrets, private endpoints, private-only evidence, or internal runbooks in `public-docs/`.

## Source files

- curated public source: `public-docs/`
- public Pages workflow template: `public-docs/.github/workflows/pages.yml`
- private publisher: `.github/workflows/publish-public-docs.yml`

## One-time setup still required

The connected GitHub tool does not currently expose repository creation or repository-secret creation.

Create this repository once in GitHub:

```text
Owner: mytestlab123
Repository: chatgpt-aws-docs
Visibility: Public
Initialize with README: Yes
```

Then configure a narrowly scoped cross-repository publishing credential in the private source repository under the secret name expected by the workflow:

```text
PUBLIC_DOCS_TOKEN
```

The credential should be limited to the public destination repository and must never be committed to either repository.

Optional private-repository variable:

```text
PUBLIC_DOCS_AUTOPUBLISH=true
```

Without that variable, publishing stays manual through `workflow_dispatch`; validation still runs automatically.

## First publish

Run:

```text
Actions -> Publish curated public docs -> Run workflow
```

The workflow validates the Material site, checks out the destination, replaces its contents with the curated `public-docs/` tree, commits, and pushes to `main`.

## Enable GitHub Pages once

In the public destination repository:

```text
Settings -> Pages -> Build and deployment -> Source = GitHub Actions
```

Expected site:

```text
https://mytestlab123.github.io/chatgpt-aws-docs/
```

## Long-term flow

```text
edit public-docs/* in private repo
        |
        v
PR validation
        |
        v
merge main
        |
        v
publish curated tree
        |
        v
public chatgpt-aws-docs
        |
        v
GitHub Pages
```
