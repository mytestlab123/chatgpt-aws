# Persistent IaC + AWS MCP Drift Demo

Issue: #5

## Goal

Prove the durable loop:

`ChatGPT -> GitHub/Terraform -> GitHub Actions/OIDC -> AWS -> AWS Core MCP verify -> direct MCP drift -> Terraform detects/repairs -> AWS MCP verifies final state`

## Persistent lab resources

- Terraform state bucket: `chatgpt-aws-tfstate-063884340510`
- GitHub OIDC role: `github-actions-chatgpt-aws-lab`
- Managed SSM parameter: `/chatgpt-aws/drift-demo`
- Region: `ap-southeast-1`

The state bucket is private, versioned, AES256 encrypted, public access blocked, and tagged for this LAB.

## Initial deployment proof

PR #6 added the Terraform configuration and GitHub Actions workflow.

- PR plan: PASS
- Plan result: `1 to add, 0 to change, 0 to destroy`
- Main push workflow run: `34675429394`
- GitHub Actions assumed `github-actions-chatgpt-aws-lab` using OIDC.
- Terraform apply: PASS
- Provider readback: PASS
- Independent AWS Core MCP readback: PASS

Initial observed state:

- value: `desired-v1`
- SSM version: `1`

## Deliberate drift

ChatGPT used direct AWS Core MCP to update the existing parameter outside Terraform:

- before: `desired-v1`, version `1`
- after: `drifted-by-mcp`, version `2`

This mutation was intentionally harmless and existed only to prove drift detection and repair.

## Drift detection proof

PR #7 triggered a fresh Terraform plan against the remote S3 state.

- Workflow run: `34675498728`
- OIDC authentication: PASS
- Terraform init/validate: PASS
- Terraform state refresh found the live SSM parameter at version `2`.
- Terraform classified the resource as `~ update in-place`.
- Exact plan result: `Plan: 0 to add, 1 to change, 0 to destroy.`

This proves Terraform detected the out-of-band AWS MCP mutation while retaining the configured desired value `desired-v1` as source of truth.

## Reconciliation proof

PR #7 was merged to `main`.

- Main workflow run: `34675632976`
- GitHub OIDC authentication: PASS
- Terraform init/validate: PASS
- Terraform apply: PASS
- Workflow provider readback: PASS
- Independent AWS Core MCP readback: PASS

Final observed state through AWS Core MCP:

- value: `desired-v1`
- SSM version: `3`
- final action: Terraform restored desired state after the direct MCP drift.

## Result

**PASS.** The complete hybrid loop is proven:

1. Terraform created persistent desired state.
2. AWS MCP independently verified it.
3. AWS MCP introduced one bounded out-of-band change.
4. Terraform detected the drift.
5. GitHub Actions/OIDC/Terraform reconciled it.
6. AWS MCP independently verified the repaired state.

This is the default operating model for future durable AWS lab infrastructure.
