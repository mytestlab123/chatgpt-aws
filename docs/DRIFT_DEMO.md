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

The state bucket is private, versioned, encrypted, and tagged for this LAB.

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

This mutation is intentionally harmless and exists only to prove drift detection and repair.

## Next verification

This PR exists to trigger a fresh Terraform plan against the remote S3 state. Expected plan: restore the SSM parameter to Terraform's desired value `desired-v1`.

After the drift plan is captured, merging this PR to `main` will run Terraform apply and reconcile the parameter. AWS Core MCP will then verify the final state.
