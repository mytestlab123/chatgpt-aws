# Dedicated OIDC + MCP CodeBuild Lab

Status: **VERIFIED ON PR / Issue #18**  
Environment: **PERSONAL / LAB**  
Region: `ap-southeast-1`

## Goal

Prove a clean separation between two independent control paths in the same AWS account:

```text
GitHub Actions -> repo-specific OIDC role -> CodeBuild StartBuild
AWS Core MCP   -> CodeBuild read/diagnose, but StartBuild explicitly denied
```

This experiment does not depend on `lab1_agent`.

## Dedicated resources

- GitHub OIDC role: `github-actions-chatgpt-aws-codebuild-lab`
- CodeBuild project: `chatgpt-aws-oidc-mcp-smoke`
- CodeBuild service role: `chatgpt-aws-codebuild-smoke`
- CloudWatch log group: `/aws/codebuild/chatgpt-aws-oidc-mcp-smoke`
- AWS Core user guard policy: `ChatGPTAwsMCPCodeBuildGuard`

The GitHub OIDC role trusts only `mytestlab123/chatgpt-aws` PR/main subjects and has permission only to start/read the dedicated CodeBuild project.

The CodeBuild service role trusts `codebuild.amazonaws.com` and is restricted with `aws:SourceAccount` plus the exact CodeBuild project ARN.

## MCP-specific control

The current AWS Core IAM user has a narrow explicit deny:

```json
{
  "Effect": "Deny",
  "Action": "codebuild:StartBuild",
  "Resource": "arn:aws:codebuild:ap-southeast-1:063884340510:project/chatgpt-aws-oidc-mcp-smoke",
  "Condition": {
    "Bool": {
      "aws:ViaAWSMCPService": "true"
    }
  }
}
```

Effect:

- GitHub Actions using the dedicated OIDC role can start the build.
- AWS Core MCP can inspect the project/build/logs.
- AWS Core MCP cannot start the build.

This gives a useful operating model: **CI/CD executes; MCP observes and diagnoses**.

## Bootstrap evidence

AWS Core MCP created the dedicated lab resources and immediately read them back.

Verified caller:

`arn:aws:iam::063884340510:user/devsecops`

The first CodeBuild `CreateProject` attempt returned `CodeBuild is not authorized to perform: sts:AssumeRole` immediately after the new service role was created. AWS documentation lists service-role trust/existence as causes for this error. The role trust was correct; after IAM propagation and a short retry, project creation succeeded. This is an IAM eventual-consistency lesson worth retaining for automated bootstrap flows.

## MCP negative test

AWS Core MCP successfully read the dedicated project and then attempted `codebuild:StartBuild`.

Result: **AccessDenied as designed** because of the MCP-specific explicit deny.

This is intentionally a negative test and does not indicate broken CodeBuild permissions for the OIDC path.

## GitHub OIDC positive test

PR #19 workflow run:

`34685896954` — **PASS**

The workflow successfully:

1. obtained a GitHub OIDC token;
2. assumed `github-actions-chatgpt-aws-codebuild-lab`;
3. verified the assumed identity with STS;
4. called `StartBuild` for `chatgpt-aws-oidc-mcp-smoke`;
5. waited for the build to complete;
6. required `SUCCEEDED`.

CodeBuild build ID:

`chatgpt-aws-oidc-mcp-smoke:11d15aa7-5e10-467a-885c-c0c4e6ddf5a2`

Final status: **SUCCEEDED**.

All PR checks also passed:

- Dedicated OIDC CodeBuild lab: PASS
- Docs build validation: PASS
- Docs AWS site: PASS
- Automation CI/CD lab: PASS
- Terraform drift demo: PASS

No static AWS access key or GitHub secret was required.

## Independent AWS Core verification

After the GitHub workflow completed, AWS Core MCP independently verified:

- latest build ID matched the GitHub-triggered build;
- CodeBuild status was `SUCCEEDED`;
- CloudWatch log stream existed;
- 52 log events were present;
- logs contained the marker `OIDC-CODEBUILD-PASS`;
- logs contained STS/build identity evidence;
- BUILD and POST_BUILD phases were `SUCCEEDED`.

This readback used the MCP path, independent of the GitHub workflow credentials.

## Workflow

`.github/workflows/codebuild-oidc-mcp-lab.yml`

The workflow has only the GitHub permissions needed for OIDC and repository read:

- `id-token: write`
- `contents: read`

The AWS role itself is scoped to the dedicated CodeBuild project.

## Retained resources

These resources are intentionally retained for later OIDC/MCP governance tests:

- dedicated GitHub OIDC role;
- dedicated CodeBuild project;
- dedicated CodeBuild service role;
- one-day CloudWatch log group;
- narrow MCP StartBuild deny.

The CodeBuild project uses `BUILD_GENERAL1_SMALL`, `NO_SOURCE`, and `NO_ARTIFACTS` to keep the smoke test small and inexpensive.

## Cleanup

When this lab is no longer useful, remove in this order:

1. CodeBuild project;
2. CloudWatch log group;
3. CodeBuild service-role inline policy and role;
4. GitHub OIDC-role inline policy and role;
5. `ChatGPTAwsMCPCodeBuildGuard` from `devsecops`.
