# Cloudflare Pages + Access

Cloudflare Pages can build static sites from Git repositories, including private repositories. Cloudflare Access can then add a login gate for viewers.

## Architecture

```text
Private Git repository
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
      v
Authorized user
```

## Important distinction

A private Git repository protects source code. It does **not** automatically make the Pages website private.

For private viewer access, configure Cloudflare Access for the `*.pages.dev` hostname or the custom domain.

## Typical setup

1. Connect the repository to Cloudflare Pages.
2. Set build command, for example:

   ```text
   pip install -r requirements-docs.txt && mkdocs build --strict
   ```

3. Set output directory:

   ```text
   site
   ```

4. Deploy and verify the public Pages build works.
5. In Cloudflare Zero Trust, create an Access application for the hostname.
6. Add an allow policy for the intended email, domain, group, or identity provider.
7. Test in an incognito browser: unauthenticated access should be challenged.
8. Test an authorized identity: the site should open after authentication.

## When to choose it

Cloudflare Pages + Access is attractive for a small private documentation portal because it combines:

```text
Git-based publishing
+ static hosting/CDN
+ viewer authentication
```

without requiring you to build a full application login system.
