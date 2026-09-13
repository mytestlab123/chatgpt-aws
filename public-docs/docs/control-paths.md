# AWS Control Paths: Fast vs Deterministic

Two AWS control paths are useful, and they solve different problems.

## Path 1 — ChatGPT + AWS MCP

```text
ChatGPT
  -> AWS MCP
  -> AWS APIs
```

Best for:

- inventory and discovery
- diagnostics
- CloudTrail / logs / IAM investigation
- cross-service verification
- bounded, reversible experiments
- independent checks after deployment

This path is fast because it avoids the full commit/PR/pipeline cycle.

## Path 2 — Git + IaC + OIDC

```text
Git
  -> Terraform / CDK / CloudFormation
  -> pull request
  -> CI/CD
  -> GitHub OIDC
  -> AWS
```

Best for:

- persistent infrastructure
- repeatable deployments
- production-style changes
- review and audit history
- rebuildability
- drift detection and reconciliation

## Recommended hybrid

```text
Discover / diagnose with MCP
          |
          v
Decide what should persist
          |
          v
Declare it in Git + IaC
          |
          v
Apply through CI/CD + OIDC
          |
          v
Verify independently with MCP
```

## Why test DENY rules for MCP?

MCP can make AWS changes **when IAM allows them**. A deliberate deny test proves that the organization can distinguish MCP-originated calls from another automation path and selectively govern sensitive mutations.

The lesson is not “MCP cannot deploy.” The lesson is:

> **MCP is capable, and IAM decides what it is allowed to do.**
