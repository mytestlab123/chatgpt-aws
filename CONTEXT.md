# Context

Status: ACTIVE

## Project Identity

- Project: ChatGPT AWS Lab
- Primary Repository: `mytestlab123/chatgpt-aws`
- Authorized Related Repositories:
  - `amitkarpe/assignment-cicd` for historical GitHub Actions/OIDC proofs
  - `mytestlab123/lab1_agent` for cross-session knowledge reuse and future project-specific AWS experiments
- Context: PERSONAL
- Environment: LAB

## Current Truth

- `mytestlab123/chatgpt-aws` is private and active.
- `mytestlab123/lab1_agent` is private and unarchived.
- AWS identity verified on 2026-09-12 as `arn:aws:iam::063884340510:user/devsecops` in account `063884340510`.
- Main lab region is `ap-southeast-1`.
- Repo-specific GitHub OIDC role `github-actions-chatgpt-aws-lab` is working for PR/main workflows without static AWS keys.
- Persistent Terraform state bucket `chatgpt-aws-tfstate-063884340510` is retained.
- Issue #5 drift/reconciliation milestone is complete; `/chatgpt-aws/drift-demo` remains Terraform-owned.
- Issue #9 multi-service automation + CI/CD milestone is VERIFIED / PASS; detailed evidence is in `docs/AUTOMATION_CICD_LAB.md`.
- ECR repository `chatgpt-aws-cicd-lab` is retained and normally empty after smoke tests.
- S3 bucket `chatgpt-aws-automation-063884340510` is private and retains the MCP governance fixture.
- DynamoDB `chatgpt-aws-automation-events`, Lambda `chatgpt-aws-automation-recorder`, EventBridge rule, and CloudWatch log group are retained as the automation lab.
- `devsecops` has narrow MCP-specific protection for the retained S3 fixture using `aws:ViaAWSMCPService=true`.

### Documentation site

- Material for MkDocs is the documentation generator.
- Live documentation URL: `https://d36j5fck6lkl41.cloudfront.net/`.
- GitHub Pages is not currently enabled for this private organization repository (`has_pages=false`), so the old `mytestlab123.github.io/chatgpt-aws/` URL must not be treated as live.
- Docs hosting is Terraform-owned in `infra/docs-site/` and deployed by `.github/workflows/docs-aws.yml`.
- Private origin bucket: `chatgpt-aws-docs-063884340510`.
- CloudFront distribution: `E2M7VGXRFDXI7H` / `d36j5fck6lkl41.cloudfront.net`.
- CloudFront OAC: `E10YPJ26EF3Z3U` / `chatgpt-aws-docs-oac`.
- S3 Block Public Access is enabled on all four controls; CloudFront uses OAC with SigV4.
- Main docs workflow `34684093457`, attempt 2, passed build, Terraform reconcile, S3 sync, CloudFront invalidation, and live HTTP checks.
- Independent AWS Core readback verified the deployed distribution, OAC, private S3 policy, and all required site/search/custom HTML objects.
- Hosting details and the GitHub Pages 404 lesson are documented in `docs/HOSTING.md`.

## Active Work

- Issue #15: finalize and merge documentation-hosting evidence, then close the 404 incident as completed.

## Next Action

1. Merge the Issue #15 evidence/documentation PR after its strict MkDocs + Terraform checks pass.
2. Confirm the resulting main docs deployment passes again.
3. Keep the CloudFront URL as the authoritative human-readable docs URL.
4. Other ChatGPT sessions should consume `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md`, `docs/SESSION_BOOTSTRAP.md`, and `docs/HOSTING.md` rather than relying on chat memory.
