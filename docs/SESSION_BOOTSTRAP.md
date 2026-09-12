# ChatGPT AWS Session Bootstrap

Use this when starting another ChatGPT session that should reuse the proven AWS/GitHub setup.

## Short bootstrap

> Use the connected **GitHub** and **AWS Core** apps. Do not rely on memory from another chat.
>
> 1. Read `mytestlab123/chatgpt-aws/docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` and `docs/EXPERIMENTS.md` first.
> 2. Read the target repo's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR.
> 3. Verify AWS Core with STS `GetCallerIdentity` before any AWS mutation. Confirm the account/environment matches the target repo.
> 4. Use **direct AWS MCP** for discovery, troubleshooting, live readback, verification, and small reversible operations.
> 5. Use **GitHub + IaC + OIDC** for durable infrastructure state.
> 6. After any deployment, independently verify the real AWS state through AWS MCP. After cleanup, prove temporary resources are absent.
> 7. Write durable learning/evidence back to GitHub so the next session does not depend on chat history.
>
> For `mytestlab123/lab1_agent`, also read `docs/CHATGPT_AWS_BOOTSTRAP.md`. Do not assume the existing `assignment-cicd` OIDC role is valid for `lab1_agent`.

## Expected first report from the new session

Keep the first report short and factual:

- GitHub target repo: `<owner/repo>`
- Repo visibility: `<private/public>`
- AWS account: `<verified account>`
- AWS principal: `<verified STS ARN>`
- AWS region/environment: `<verified>`
- AWS Core read access: `PASS | FAIL`
- GitHub write access: `PASS | FAIL`
- Selected execution path for the current milestone: `MCP | GitHub/IaC/OIDC | hybrid`
- Any blocker before mutation: `<none or one blocker>`

Then continue with the repository's approved milestone rather than repeating already-proven connectivity tests.
