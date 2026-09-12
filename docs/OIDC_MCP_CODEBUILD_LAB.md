# Dedicated OIDC + MCP CodeBuild Lab

Status: **ACTIVE / Issue #18**  
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

## GitHub workflow

Workflow:

`.github/workflows/codebuild-oidc-mcp-lab.yml`

The workflow:

1. requests a GitHub OIDC token;
2. assumes `github-actions-chatgpt-aws-codebuild-lab`;
3. runs STS `GetCallerIdentity`;
4. calls CodeBuild `StartBuild` for only `chatgpt-aws-oidc-mcp-smoke`;
5. polls `BatchGetBuilds` until a terminal state;
6. requires `SUCCEEDED`.

No static AWS access key or GitHub secret is required.

## Verification after the workflow

AWS Core MCP should independently verify:

- OIDC role trust and inline permissions;
- CodeBuild project configuration;
- latest build ID/status;
- CloudWatch log group and stream/event evidence;
- MCP `StartBuild` remains denied.

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
