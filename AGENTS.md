# AGENTS.md

## Canonical bootstrap

Read `PROMPT.md` first for a cold start. It is the portable entrypoint for the AWS MCP + GitHub OIDC/IaC operating model, security baseline, and new-repository bootstrap.

For warm continuation, use the named Issue/PR, latest relevant authorized delta, and current HEAD. Do not force the full bootstrap/read list on every handoff.

## Bootstrap / Recovery Order

Use this order only when the session lacks usable repository context, governing files materially changed, or state is stale/incomplete/contradictory:

1. `PROMPT.md`
2. `AGENTS.md`
3. `CONTEXT.md`
4. `INIT.md` only when repository initialization is incomplete
5. `CHATGPT.md` when ChatGPT/Codex/GitHub collaboration or connector-safety rules matter
6. `docs/PORTABLE_AWS_MCP_KNOWLEDGE.md` for detailed AWS/MCP/OIDC evidence
7. `docs/SESSION_BOOTSTRAP.md` for cross-session handoff
8. `docs/HOSTING.md` when publication/hosting matters
9. `ENV.md` when runtime/tool facts matter
10. `SPEC.md` before implementation or mutation
11. `docs/EXPERIMENTS.md` when proven-path evidence matters

## Rules

- Follow KISS: optimize for one useful outcome, not the smallest possible task.
- Preserve existing work; do not revert unrelated changes without authority.
- Keep durable code, decisions, and reports in Git. Never commit secrets, credentials, or authentication state.
- Update `CONTEXT.md` when repository identity, current truth, active Issue/PR, or next action materially changes.
- `SPEC.md` is the repository execution contract.
- Prefer one cohesive PR with related phases/tasks over micro-PRs.
- If the objective is known, `go`, `g`, `.`, `Y`, or `yes` means execute/continue within existing authority unless Amit explicitly asks for planning/review/discussion.
- Before cross-repo mutation, apply the repository-binding guard in `CHATGPT.md`.
- For AWS work in a new session, re-verify STS caller identity; Git carries knowledge, not authentication.
- For a new repository, create repository-specific AWS/OIDC identities and state. Treat this lab's IDs, ARNs, names, and historical evidence as examples only.

## Global Guidance

When available, use `~/.agent/CORE.md` as shared machine-wide guidance and `~/.agent/HOST.md` for host facts. Current user instruction plus this repository's `PROMPT.md`, `AGENTS.md`, `SPEC.md`, owning Issue/PR, and project context take precedence.
