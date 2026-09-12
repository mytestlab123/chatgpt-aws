# Environment

Status: NOT_READY

Record project-specific runtime and dependency truth here. Keep machine-specific facts in the active `~/.agent/HOST.md` profile when available instead of duplicating host configuration in every repository.

## Runtime

- Primary host/profile: `~/.agent/HOST.md` when available
- Working directory: `<repo path>`
- Runtime: `<local | container | AWS | mixed>`

## Development Tools

List only tools this project actually depends on, for example:

- Python: `<version / not required>`
- Node.js / npm: `<version / not required>`
- Docker/Podman: `<required / not required>`
- Terraform/Terragrunt: `<required / not required>`
- Nextflow: `<required / not required>`

## Cloud

- Provider: `<AWS / none / other>`
- AWS profile: `<profile or N/A>`
- Region: `<region or N/A>`
- Account/environment alias: `<personal lab / dev / nonprod / prod / N/A>`

Never infer execution authority from an AWS profile name. Authority comes from `SPEC.md` and the active Issue/instruction.

## External Dependencies

- `<service, MCP, model platform, database, API, or N/A>`

## Credentials And Secrets

Use approved local, cloud, or secret-management mechanisms. Never commit credentials, tokens, private keys, or raw secrets.

## Readiness

Set `Status` to `READY` only when the dependencies needed for the current milestone are known and usable. Use `PARTIAL` when missing dependencies do not block the approved work.
