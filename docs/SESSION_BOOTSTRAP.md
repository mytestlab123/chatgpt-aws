# ChatGPT AWS Session Bootstrap

Use this when starting another ChatGPT session that should reuse the proven AWS/GitHub setup.

## Short bootstrap

> Use the connected **GitHub** and **AWS Core** apps. Do not rely on memory from another chat.
>
> 1. Read `mytestlab123/chatgpt-aws/docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`, `docs/EXPERIMENTS.md`, and `docs/DRIFT_DEMO.md` first.
> 2. Read the target repo's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR.
> 3. Verify AWS Core with STS `GetCallerIdentity` before any AWS mutation. Confirm account, principal, region, and environment match the target repo.
> 4. Verify GitHub read/write access and current repo visibility/archive state.
> 5. Use **direct AWS MCP** for discovery, troubleshooting, live readback, verification, and small reversible operations.
> 6. Use **GitHub + IaC + repo-specific OIDC** for durable infrastructure state. Never assume an OIDC role for another repo is reusable.
> 7. If `AssumeRoleWithWebIdentity` fails, inspect CloudTrail for the actual GitHub WebIdentity principal/subject before widening the trust policy.
> 8. After deployment, independently verify real AWS state through AWS MCP. If MCP changes a Terraform-managed resource, expect Terraform to detect/reconcile the drift.
> 9. Write durable evidence/learning back to GitHub so the next session does not depend on chat history.
>
> For `mytestlab123/lab1_agent`, also read `docs/CHATGPT_AWS_BOOTSTRAP.md`. Both `chatgpt-aws` and `lab1_agent` are private at the latest verification, but each repo still requires its own project authority and scoped OIDC role.

## Expected first report from the new session

Keep the first report short and factual:

- GitHub target repo: `<owner/repo>`
- Repo visibility/archive state: `<verified>`
- AWS account: `<verified account>`
- AWS principal: `<verified STS ARN>`
- AWS region/environment: `<verified>`
- AWS Core read access: `PASS | FAIL`
- GitHub write access: `PASS | FAIL`
- Existing repo-specific OIDC role/trust: `<verified / not configured>`
- Selected execution path: `MCP | GitHub/IaC/OIDC | hybrid`
- Any blocker before mutation: `<none or one blocker>`

Then continue the repository's approved milestone rather than repeating already-proven toy connectivity tests.
