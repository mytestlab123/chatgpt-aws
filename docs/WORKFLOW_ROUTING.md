# Selective GitHub Actions Routing

Status: **ACTIVE / Issue #24**  
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

The preferred routing is:

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

Therefore they should not automatically invoke those AWS workflows.

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

They make the durable path faster by avoiding work that is unrelated to the changed source.

## Verification plan

Issue #24 acceptance uses two stages:

1. **Routing implementation PR** — because it changes the lab workflow files themselves, the affected lab workflows are expected to run and validate the new YAML/routing definitions.
2. **Docs-only proof PR** — after the routing change is merged, change only documentation and verify that only documentation workflows start automatically. No Automation, CodeBuild, Step Functions/SQS, or drift-demo run should be created for that commit.

Final run IDs and proof will be recorded here before Issue #24 is closed.
