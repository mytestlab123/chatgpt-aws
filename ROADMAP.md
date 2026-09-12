# Roadmap

## Completed

- Direct AWS Core MCP read/write proofs.
- GitHub Actions -> OIDC -> AWS proof without static AWS keys.
- Terraform provisioning/destroy proof with independent AWS MCP cleanup verification.
- Cross-session portable AWS MCP/GitHub knowledge pack.
- Persistent Terraform state + repo-specific OIDC in `mytestlab123/chatgpt-aws`.
- Direct AWS MCP drift -> Terraform detection -> GitHub/OIDC/Terraform repair -> independent AWS MCP final verification.
- Issue #9 multi-service automation + CI/CD lab:
  - ECR build/push/verify/delete through GitHub OIDC;
  - S3 -> Lambda -> DynamoDB automation;
  - EventBridge -> Lambda -> DynamoDB automation;
  - CloudWatch evidence and provider readback;
  - live `aws:ViaAWSMCPService` destructive-action deny proof;
  - self-contained Amit learning HTML.

## Now

- Finalize Issue #9 evidence/steady-state checks and close the Issue.

## Next

- Consume this expanded knowledge from the separate `mytestlab123/lab1_agent` ChatGPT session instead of repeating connectivity experiments.
- Consider Step Functions / CodeBuild only if they add a genuinely new automation or governance lesson beyond the proven Issue #9 patterns.

## Later

- Add a UI/control surface after the backend AWS execution and governance paths are stable.
