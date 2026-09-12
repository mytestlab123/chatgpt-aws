# Initialization

Status: NOT_INITIALIZED

Use this file only for first-time repository setup or when Amit explicitly asks to reinitialize the project.

## Short Interview

Ask only what is still unknown, normally 3-6 questions:

1. What problem, product, learning goal, or operational outcome does this repository own?
2. Is the context `PERSONAL` or `WORK`?
3. Which environment applies: `LOCAL`, `LAB`, `DEV`, `NONPROD`, or `PROD`?
4. What runtime, cloud, major tools, profiles, or external services are required?
5. What is the first useful milestone/outcome?
6. What hard boundaries or approval gates matter, if any?

Prefer discovering answers from existing repository/runtime truth before asking Amit.

## Initialize

After the interview, update only the files that need project-specific truth:

- `README.md` — purpose and start-here guidance
- `CONTEXT.md` — repository identity, current truth, active work
- `SPEC.md` — execution authority, scope, milestones, stop gates
- `ENV.md` — project runtime/tool/cloud dependencies
- `ROADMAP.md` — only useful future milestones

Then set this file to:

`Status: INITIALIZED`

Do not repeat the interview on normal future work. Reinitialize only when Amit asks or the repository's fundamental purpose/context changes.
