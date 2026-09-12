# Selective GitHub Actions Routing

Status: **VERIFIED / PASS — Issue #24**  
Environment: **PERSONAL / LAB**

## Goal

Keep the deterministic GitHub/OIDC delivery path, but stop unrelated AWS lab workflows from running for documentation-only or unrelated changes.

The rule is simple:

> **Run the workflow only when its executable inputs changed. Keep `workflow_dispatch` for deliberate regression runs.**

This improves speed and reduces unnecessary AWS/API activity without weakening the durable Git/IaC/OIDC model.

## Why this was needed

The Issue #21 final-evidence/documentation change triggered several independent AWS lab workflows even though their Terraform or runtime definitions had not changed.

That behavior was safe, but inefficient:

```text
docs/control-file change
   |
   +--> Automation CI/CD lab
   +--> CodeBuild lab
   +--> Step Functions + SQS lab
   +--> Terraform drift demo
   +--> docs workflows
```

The verified routing is now:

```text
docs-only change
   |
   +--> Docs build validation
   +--> Docs AWS site

lab-specific change
   |
   +--> that lab workflow
   +--> docs workflows only when docs/mkdocs also changed
```

## Routing matrix

| Workflow | Automatic trigger paths | Manual run |
|---|---|---|
| Automation CI/CD lab | `.github/workflows/automation-cicd-lab.yml`, `infra/automation-cicd/**` | `workflow_dispatch` |
| Terraform drift demo | `.github/workflows/terraform-drift-demo.yml`, `infra/drift-demo/**` | `workflow_dispatch` |
| Step Functions + SQS lab | `.github/workflows/sfn-sqs-oidc-mcp-lab.yml`, `infra/sfn-sqs/**` | `workflow_dispatch` |
| Dedicated OIDC CodeBuild lab | `.github/workflows/codebuild-oidc-mcp-lab.yml` | `workflow_dispatch` |
| Docs build validation | `docs/**`, `mkdocs.yml`, `requirements-docs.txt`, its own workflow | `workflow_dispatch` |
| Docs AWS site | `docs/**`, `mkdocs.yml`, `requirements-docs.txt`, `infra/docs-site/**`, its own workflow | `workflow_dispatch` |

## Why generic control files are not AWS-lab triggers

Files such as:

- `CONTEXT.md`;
- `SPEC.md`;
- `ROADMAP.md`;
- generic documentation pages;
- `mkdocs.yml`.

may describe a lab, but they do not change the executable Terraform/runtime input for the Automation, Drift, Step Functions, or CodeBuild labs.

Therefore they do not automatically invoke those AWS workflows.

If a deliberate full regression is wanted after a documentation/control-plane change, use `workflow_dispatch` on the relevant lab workflow.

## CodeBuild special case

The retained CodeBuild project/role are not Terraform-owned in this repository. The GitHub workflow is the executable runtime definition for the existing dedicated CodeBuild smoke path.

Automatic execution therefore occurs only when:

`.github/workflows/codebuild-oidc-mcp-lab.yml`

changes.

Documentation changes do not start a build. A deliberate regression build remains available through `workflow_dispatch`.

## Expected development behavior

### Fast documentation/control update

```text
edit docs / context / roadmap
        |
        v
Docs checks/deploy only
```

### Durable infrastructure update

```text
edit infra/sfn-sqs/**
        |
        v
Step Functions + SQS Terraform workflow
```

### Runtime workflow update

```text
edit .github/workflows/codebuild-oidc-mcp-lab.yml
        |
        v
Dedicated CodeBuild smoke workflow
```

### Full regression when explicitly wanted

```text
GitHub Actions -> Run workflow -> workflow_dispatch
```

## Relationship to the control-path model

Selective triggers do not change the architecture:

```text
MCP discover/diagnose
        |
        v
Git/IaC declare
        |
        v
OIDC CI/CD apply
        |
        v
MCP independently verify
```

They make the durable path faster by avoiding work unrelated to the changed source.

## Verification evidence

### Stage 1 — routing implementation

Issue #24 implementation PR: `#25`  
Merge commit: `6d9be8e5735fa2e369939b5b51f64b9a9e853b53`

Because PR #25 intentionally changed all four AWS lab workflow files plus documentation, the affected workflows were expected to run. PR validation passed:

| Workflow | PR run | Result |
|---|---:|---|
| Automation CI/CD lab | `34690052332` | PASS |
| Terraform drift demo | `34690052391` | PASS |
| Step Functions + SQS lab | `34690052534` | PASS |
| Dedicated OIDC CodeBuild lab | `34690052636` | PASS |
| Docs build validation | `34690052366` | PASS |
| Docs AWS site | `34690052412` | PASS |

This proved the narrowed workflow definitions remained valid and each lab could still be explicitly exercised when its own workflow changed.

### Stage 2 — docs-only isolation proof

Proof PR: `#26`  
Probe commit: `d7bf72a0c19c474357458b45693c3532b0cb7004`

The probe changed only this documentation file **after** PR #25 was merged.

GitHub created exactly two automatic workflow runs for that commit:

| Workflow | Run | Result |
|---|---:|---|
| Docs build validation | `34690145584` | PASS |
| Docs AWS site | `34690145541` | PASS |

No automatic workflow run was created for:

- Automation CI/CD lab;
- Dedicated OIDC CodeBuild lab;
- Deterministic Step Functions + SQS lab;
- Terraform drift demo.

That is the acceptance proof for Issue #24.

## Result

Before:

```text
docs change -> up to six workflows, including unrelated AWS labs
```

After:

```text
docs change -> two docs workflows only
lab input change -> relevant lab workflow
explicit full regression -> workflow_dispatch
```

This preserves deterministic Git/IaC/OIDC delivery while reducing unnecessary AWS executions and shortening the normal feedback loop.
