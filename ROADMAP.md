# Roadmap

## Completed

- Direct AWS Core MCP read/write proofs.
- GitHub Actions -> OIDC -> AWS proof without static AWS keys.
- Terraform provisioning/destroy proof with independent AWS MCP cleanup verification.
- Cross-session portable AWS MCP/GitHub knowledge pack.
- Persistent Terraform state + repo-specific OIDC in `mytestlab123/chatgpt-aws`.
- Direct AWS MCP drift -> Terraform detection -> GitHub/OIDC/Terraform repair -> independent AWS MCP final verification.

## Now — Issue #9

- Prove ECR as a real CI/CD artifact path from GitHub Actions OIDC.
- Prove S3 and EventBridge as independent automation triggers into Lambda + DynamoDB + CloudWatch Logs.
- Prove an MCP-origin-specific destructive-action deny with `aws:ViaAWSMCPService` while the non-MCP GitHub OIDC path still cleans up.
- Publish the evidence as reusable Markdown plus a self-contained HTML learning page.

## Next

- Consume this expanded knowledge from the separate `mytestlab123/lab1_agent` ChatGPT session.
- Consider Step Functions / CodeBuild only if they add a new operational lesson beyond the Issue #9 patterns.

## Later

- Add a UI/control surface after the backend AWS execution and governance paths are stable.
