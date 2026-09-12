# Dedicated OIDC + MCP CodeBuild Lab

Status: **VERIFIED / COMPLETE**  
Environment: **PERSONAL / LAB**  
Region: `ap-southeast-1`

## Goal

Prove a clean separation between two independent control paths in the same AWS account:

```text
GitHub Actions -> repo-specific OIDC role -> CodeBuild StartBuild
AWS Core MCP   -> CodeBuild read/diagnose, but StartBuild explicitly denied
```

This experiment is fully independent of `lab1_agent`.

## Dedicated resources

- GitHub OIDC role: `github-actions-chatgpt-aws-codebuild-lab`
- CodeBuild project: `chatgpt-aws-oidc-mcp-smoke`
- CodeBuild service role: `chatgpt-aws-codebuild-smoke`
- CloudWatch log group: `/aws/codebuild/chatgpt-aws-oidc-mcp-smoke`
- AWS Core user guard policy: `ChatGPTAwsMCPCodeBuildGuard`

The GitHub OIDC role trusts only `mytestlab123/chatgpt-aws` PR/main subjects and can only start/read the dedicated CodeBuild project.

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
- AWS Core MCP can inspect the project, builds, IAM configuration, and logs.
- AWS Core MCP cannot start the build.

This proves a useful control model: **CI/CD executes; MCP observes and diagnoses**.

## Bootstrap evidence

AWS Core MCP created the dedicated lab resources and read them back.

Verified caller:

`arn:aws:iam::063884340510:user/devsecops`

The first CodeBuild `CreateProject` attempt returned `CodeBuild is not authorized to perform: sts:AssumeRole` immediately after the service role was created. The trust policy was correct. After a short IAM propagation delay and retry, project creation succeeded. Keep this IAM eventual-consistency behavior in mind for automated bootstrap flows.

## GitHub OIDC positive tests

### PR proof

PR #19 workflow run:

`34685896954` — **PASS**

Build:

`chatgpt-aws-oidc-mcp-smoke:11d15aa7-5e10-467a-885c-c0c4e6ddf5a2` — **SUCCEEDED**

A second PR run after the evidence update also passed:

`34685971536` — **PASS**

Build:

`chatgpt-aws-oidc-mcp-smoke:87016ace-b5ea-4781-bb16-c5604cc1a415` — **SUCCEEDED**

### Main proof

After PR #19 was squash-merged at commit:

`0849745c54404d65cb98906282e8d5a111380621`

the main workflow ran again:

`34686033076` — **PASS**

Latest CodeBuild build:

`chatgpt-aws-oidc-mcp-smoke:7a4529bf-0248-4157-a0d6-6adef2881b6f` — **SUCCEEDED**

The workflow successfully:

1. obtained a GitHub OIDC token;
2. assumed `github-actions-chatgpt-aws-codebuild-lab`;
3. verified the assumed identity with STS;
4. called `StartBuild` for only `chatgpt-aws-oidc-mcp-smoke`;
5. polled `BatchGetBuilds` until completion;
6. required `SUCCEEDED`.

No static AWS access key or GitHub secret was required.

## Independent AWS Core verification

After the main workflow completed, AWS Core MCP independently verified:

- caller remains `arn:aws:iam::063884340510:user/devsecops`;
- dedicated OIDC role trust is restricted to the repository PR/main subjects;
- OIDC role permissions are limited to `StartBuild`, `BatchGetBuilds`, and `BatchGetProjects` for the single project ARN;
- CodeBuild service role trust includes `codebuild.amazonaws.com`, `aws:SourceAccount`, and the exact project ARN;
- the latest build ID matches the main GitHub-triggered build;
- latest build status is `SUCCEEDED`;
- CloudWatch contains 52 events for the latest build;
- logs contain `OIDC-CODEBUILD-PASS`;
- BUILD phase is `SUCCEEDED`;
- `ChatGPTAwsMCPCodeBuildGuard` is still present;
- a fresh MCP `StartBuild` attempt still returns explicit `AccessDenied` as designed.

This readback used the MCP path, independent of the GitHub workflow credentials.

## Workflow

`.github/workflows/codebuild-oidc-mcp-lab.yml`

GitHub permissions:

- `id-token: write`
- `contents: read`

AWS permissions are scoped to the dedicated CodeBuild project.

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
