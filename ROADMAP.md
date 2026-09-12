# Roadmap

## Completed

- Direct AWS Core MCP read/write proofs.
- GitHub Actions -> OIDC -> AWS proof without static AWS keys.
- Terraform provisioning/destroy proof with independent AWS MCP cleanup verification.
- Cross-session portable AWS MCP/GitHub knowledge pack.
- Persistent Terraform state + repo-specific OIDC in `mytestlab123/chatgpt-aws`.
- Issue #5: direct AWS MCP drift -> Terraform detection -> GitHub/OIDC/Terraform repair -> independent AWS MCP final verification.
- Issue #9: multi-service automation + CI/CD across ECR, S3, EventBridge, Lambda, DynamoDB, CloudWatch, and MCP-specific S3 governance.
- Issue #18: dedicated GitHub OIDC -> CodeBuild execution with AWS MCP read/diagnose and MCP-specific `StartBuild` deny.
- Issue #21: Terraform-owned Step Functions + SQS, dedicated runtime OIDC execution, AWS MCP independent verification, and MCP-specific `StartExecution` deny.
- Fast-vs-deterministic control-path guidance published in `docs/CONTROL_PATHS.md`.

## Now — Issue #24

Make the deterministic GitHub/OIDC path faster by scoping automatic workflow triggers to executable inputs only.

Target behavior:

- docs/control-file changes -> docs workflows only;
- `infra/automation-cicd/**` -> Automation CI/CD lab;
- `infra/drift-demo/**` -> Terraform drift demo;
- `infra/sfn-sqs/**` -> Step Functions + SQS lab;
- CodeBuild lab workflow changes -> dedicated CodeBuild smoke;
- `workflow_dispatch` remains available for explicit regression runs.

Evidence and routing rules: `docs/WORKFLOW_ROUTING.md`.

## Next

- Complete an independent docs-only proof after Issue #24 routing is merged and confirm no unrelated AWS lab workflows start automatically.
- Consume the stable knowledge from a separate repository/session without repeating connectivity experiments; keep repository-specific OIDC authority independent.
- Add another AWS service only when it teaches a genuinely new automation, governance, or deterministic-delivery lesson.

## Later

- Add a UI/control surface after backend execution, governance, deterministic delivery, and selective CI routing are stable.
