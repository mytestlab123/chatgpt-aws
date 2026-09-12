# ChatGPT AWS Session Bootstrap

Use this when starting another ChatGPT session that should reuse the proven AWS/GitHub setup for `mytestlab123/chatgpt-aws`.

## Short bootstrap

> Use the connected **GitHub** and **AWS Core** apps. Do not rely on memory from another chat.
>
> 1. Read `mytestlab123/chatgpt-aws/docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`, `docs/EXPERIMENTS.md`, `docs/DRIFT_DEMO.md`, `docs/AUTOMATION_CICD_LAB.md`, `docs/OIDC_MCP_CODEBUILD_LAB.md`, and `docs/HOSTING.md` first.
> 2. Read this repo's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR.
> 3. Verify AWS Core with STS `GetCallerIdentity` before any AWS mutation. Confirm account, principal, region, and environment match this PERSONAL/LAB repository.
> 4. Verify GitHub read/write access and current repository state.
> 5. Use **direct AWS MCP** for discovery, troubleshooting, live readback, verification, and small reversible operations.
> 6. Use **GitHub + IaC + repo-specific OIDC** for durable infrastructure state and CI/CD execution. Never assume an OIDC role for another repo is reusable.
> 7. For execution paths that should remain CI/CD-only, use MCP-specific IAM conditions such as `aws:ViaAWSMCPService` to allow MCP observation while denying selected MCP mutations.
> 8. Issue #18 proves this split with CodeBuild: GitHub OIDC can `StartBuild`; AWS Core MCP can read project/build/logs but receives `AccessDenied` for `StartBuild` on the dedicated project.
> 9. If `AssumeRoleWithWebIdentity` fails, inspect CloudTrail for the actual GitHub WebIdentity principal/subject before widening the trust policy.
> 10. For Terraform least privilege, include provider **read/refresh APIs** as well as create/update/delete APIs.
> 11. Verify the **final effect**, not only API acceptance. Poll/read downstream evidence such as build status, DynamoDB rows, logs, or service state.
> 12. After deployment, independently verify real AWS state through AWS MCP.
> 13. Write durable evidence/learning back to GitHub so the next session does not depend on chat history.
>
> `mytestlab123/lab1_agent` is now **public and independent**. Do not use it as an execution dependency or assume any of this repo's OIDC roles apply to it.

## Expected first report from the new session

Keep the first report short and factual:

- GitHub target repo: `mytestlab123/chatgpt-aws`
- Repo visibility/archive state: `<verified>`
- AWS account: `<verified account>`
- AWS principal: `<verified STS ARN>`
- AWS region/environment: `<verified>`
- AWS Core read access: `PASS | FAIL`
- GitHub write access: `PASS | FAIL`
- Existing repo-specific OIDC role/trust: `<verified>`
- Selected execution path: `MCP | GitHub/IaC/OIDC | hybrid`
- Any blocker before mutation: `<none or one blocker>`

Then continue the repository's approved milestone rather than repeating already-proven connectivity tests.
