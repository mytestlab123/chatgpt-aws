# Cloudflare Pages + Access Private Site Lab

Status: **BLOCKED AT MCP TOOL DISCOVERY**  
Date: **2026-09-13**

## Goal

Prove a simple private documentation path:

```text
private GitHub repository
        |
        v
Cloudflare Pages
        |
        v
Cloudflare Access
        |
        v
authorized browser only
```

The intended test site is deliberately small. The purpose is to learn the control path, not to replace the existing AWS S3 + CloudFront documentation site yet.

## ChatGPT + Cloudflare MCP setup tested

Configured custom ChatGPT app:

```text
Name: Cloudflare custome
MCP endpoint: https://mcp.cloudflare.com/mcp
Authentication: OAuth
ChatGPT mode: Developer mode
```

OAuth completed successfully and ChatGPT reports the app as found/connected.

However, the current ChatGPT session still exposes **no callable Cloudflare MCP functions** under the app namespace. Cloudflare's API MCP normally exposes Code Mode tools such as `search` and `execute`; those definitions are not currently available to this session.

Therefore this lab has **not created a Cloudflare Pages project yet**. Do not record the private-site deployment as PASS until a live Cloudflare action succeeds.

## Expected execution once MCP actions are exposed

1. Read-only inventory first:

   ```text
   list Cloudflare accounts
   list Pages projects
   list Zero Trust / Access configuration
   ```

2. Create one small Pages project for testing.
3. Publish a minimal static page.
4. Put Cloudflare Access in front of the Pages hostname.
5. Allow only the selected test identity/email.
6. Verify unauthenticated browser access receives an Access login/challenge.
7. Verify the authorized identity can open the page.
8. Record exact project name, hostname, Access application/policy, and cleanup steps here.

## KISS target configuration

For a Material for MkDocs repository:

```text
Build command:
  pip install -r requirements-docs.txt && mkdocs build --strict

Output directory:
  site
```

For the first proof, a one-file static site is also acceptable if it allows us to prove viewer authentication faster.

## Important learning

> A successful OAuth connection is not the same thing as usable MCP tool discovery.

There are three separate states:

```text
1. app registered
2. OAuth authorized
3. callable MCP tools exposed to ChatGPT
```

The first two can be healthy while the third is still missing.

## Troubleshooting order

If ChatGPT shows the app as connected but no Cloudflare actions appear:

1. Open ChatGPT Settings -> Plugins / Apps -> `Cloudflare custome`.
2. Refresh/update the app's actions/tool definitions if that control is available.
3. Confirm the MCP endpoint remains `https://mcp.cloudflare.com/mcp`.
4. Re-authorize OAuth if needed.
5. Start a new ChatGPT chat and explicitly select or `@mention` the app.
6. Test a read-only request first.
7. Only after `search` / `execute` (or equivalent callable Cloudflare tools) appear should ChatGPT attempt Pages or Access mutations.

## Security model for the future test

Use read-only inventory first. For writes, keep the scope bounded to the temporary Pages project and Access application created for this lab. Do not modify unrelated Workers, DNS zones, R2, D1, or production Access policies.

## Completion criteria

This lab becomes **VERIFIED / PASS** only when all of these are true:

```text
Cloudflare MCP read call        PASS
Pages project creation          PASS
static page deployment          PASS
Access policy creation          PASS
unauthenticated request blocked PASS
authorized browser allowed      PASS
durable evidence documented     PASS
```

Until then, status remains BLOCKED AT MCP TOOL DISCOVERY.
