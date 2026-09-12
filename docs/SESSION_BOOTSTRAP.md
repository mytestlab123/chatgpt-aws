# ChatGPT AWS Session Bootstrap

Use this when starting another ChatGPT session that should reuse the proven AWS/GitHub setup for `mytestlab123/chatgpt-aws`.

## Short bootstrap

> Use the connected **GitHub** and **AWS Core** apps. Do not rely on memory from another chat.
>
> 1. Read `docs/CONTROL_PATHS.md`, `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`, `docs/EXPERIMENTS.md`, `docs/DRIFT_DEMO.md`, `docs/AUTOMATION_CICD_LAB.md`, `docs/OIDC_MCP_CODEBUILD_LAB.md`, `docs/SFN_SQS_OIDC_MCP_LAB.md`, and `docs/HOSTING.md` first.
> 2. Read this repo's `AGENTS.md`, `CONTEXT.md`, `SPEC.md`, `ENV.md`, and active Issue/PR.
> 3. Verify AWS Core with STS `GetCallerIdentity` before any AWS mutation. Confirm account, principal, region, and environment match this PERSONAL/LAB repository.
> 4. Verify GitHub read/write access and current repository state.
> 5. Use **direct AWS MCP** for the fastest discovery, troubleshooting, live readback, verification, and bounded reversible operations.
> 6. Use **GitHub + IaC + repo/purpose-specific OIDC** for durable infrastructure and deterministic deployment/execution.
> 7. Preferred loop: **MCP discover/diagnose -> Git/IaC declare -> OIDC CI/CD apply -> MCP independently verify**.
> 8. MCP-specific denies are deliberate governance choices, not an inherent AWS MCP limitation. Issue #18 proves the split with CodeBuild; Issue #21 proves it with Step Functions + SQS.
> 9. After changing IAM, allow for propagation before treating an immediate authorization test as final evidence. Issue #21 showed an immediate MCP call could still succeed before a new explicit deny propagated; a later retry returned the expected `AccessDenied`.
> 10. If `AssumeRoleWithWebIdentity` fails, inspect CloudTrail for the actual GitHub WebIdentity principal/subject before widening the trust policy.
> 11. For Terraform least privilege, include provider **validation/read/refresh APIs** as well as create/update/delete APIs. Issue #21 required `states:ValidateStateMachineDefinition` and `states:ListStateMachineVersions` in addition to obvious Step Functions mutation permissions.
> 12. Verify the **final effect**, not only API acceptance. Poll/read downstream evidence such as build status, execution history, queue state, DynamoDB rows, logs, or service state.
> 13. After deployment, independently verify real AWS state through AWS MCP.
> 14. Write durable evidence/learning back to GitHub so the next session does not depend on chat history.
>
> `mytestlab123/lab1_agent` is **public and independent**. Do not use it as an execution dependency or assume any of this repo's OIDC roles apply to it.

## Current proven operating rule

```text
FAST LIVE AWS WORK
ChatGPT -> AWS Core MCP -> inspect / diagnose / test / verify

DURABLE DETERMINISTIC WORK
ChatGPT -> Git/IaC -> PR -> GitHub Actions -> OIDC -> AWS

FINAL PROOF
AWS Core MCP -> independent readback of actual AWS state
```

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
