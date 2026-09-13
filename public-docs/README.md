# ChatGPT + AWS Learning Docs

Public, reusable learning material extracted from a private engineering lab.

This repository is intentionally documentation-only. It does **not** mirror the private source repository and must not contain credentials, account IDs, private resource names, internal evidence, or private runbooks.

Live site:

`https://mytestlab123.github.io/chatgpt-aws-docs/`

## Local preview

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-docs.txt
mkdocs serve
```

## Build

```bash
mkdocs build --strict
```

## Publishing model

The private source publishes an explicit allowlisted documentation tree into this repository. This repository owns its own `.github/` GitHub Pages workflow, so content synchronization and site deployment remain separate responsibilities.

See **Private to Public Publishing** in the documentation site for the reusable pattern.
