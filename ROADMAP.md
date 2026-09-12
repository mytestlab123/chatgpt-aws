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
- Issue #24: selective GitHub Actions routing so unrelated docs/control changes no longer start AWS lab workflows; explicit `workflow_dispatch` regression remains available.

## Now

The core control paths are stable:

```text
MCP discover/diagnose
        -> Git/IaC declare
        -> OIDC CI/CD apply
        -> MCP independently verify
```

Automatic GitHub Actions are now scoped to relevant executable inputs. Evidence: `docs/WORKFLOW_ROUTING.md`.

## Next

- Consume the stable knowledge from another repository/session without repeating connectivity experiments; keep repository-specific OIDC authority independent.
- Add another AWS service only when it teaches a genuinely new automation, governance, or deterministic-delivery lesson.
- Prefer a realistic application/developer workflow over another isolated service connectivity proof.

## Later

- Add a UI/control surface after backend execution, governance, deterministic delivery, and selective CI routing are stable.
