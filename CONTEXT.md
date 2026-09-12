# Context

Status: ACTIVE

## Project Identity

- Project: ChatGPT AWS Lab
- Primary Repository: `mytestlab123/chatgpt-aws`
- Authorized Related Repositories:
  - `amitkarpe/assignment-cicd` for the proven GitHub Actions/OIDC comparison path
  - `mytestlab123/lab1_agent` for cross-session knowledge reuse/bootstrap requested by Amit
- Context: PERSONAL
- Environment: LAB

## Current Truth

- ChatGPT has authenticated GitHub write access to the lab repositories used by this milestone.
- AWS Core MCP is authenticated and can execute AWS API calls under the current IAM identity.
- Current AWS identity was re-verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Direct MCP read tests passed across STS, EC2, S3, IAM, Lambda, CloudFormation, ECS, ECR, SSM, CloudWatch, DynamoDB, and Logs.
- Direct MCP mutation tests passed for temporary SSM and S3 lifecycles with cleanup verified.
- `amitkarpe/assignment-cicd` PR #1 proved GitHub Actions -> OIDC -> AWS and is merged.
- `amitkarpe/assignment-cicd` Issue #2 / PR #3 proved GitHub Actions -> OIDC -> Terraform -> temporary S3 -> destroy; workflow run `34673717208` passed and independent AWS MCP cleanup verification passed.
- The GitHub OIDC provider `token.actions.githubusercontent.com` exists in the personal AWS account.
- The existing role `github-actions-assignment-cicd-chatgpt-lab` is repository-bound to the assignment-cicd proof and must not be assumed reusable by another repository.
- `mytestlab123/chatgpt-aws` is private.
- `mytestlab123/lab1_agent` is currently public; only public-safe bootstrap guidance should be copied there until visibility/trust is deliberately changed.

## Active Work

- Issue: #3
- Branch: `portable-aws-mcp-knowledge`
- Current milestone: publish a portable private AWS MCP/GitHub knowledge pack and a public-safe `lab1_agent` bootstrap so another ChatGPT session can reuse the proven operating model without relying on chat memory.

## Next Action

- Complete and merge Issue #3 knowledge changes, then use `lab1_agent` as the first cross-session consumer before starting the next AWS provisioning experiment.
