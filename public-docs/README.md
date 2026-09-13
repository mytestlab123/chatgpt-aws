# ChatGPT + AWS Learning Docs

Public, reusable learning material extracted from a private engineering lab.

This repository is intentionally documentation-only. It does **not** mirror the private source repository and must not contain credentials, account IDs, private resource names, internal evidence, or private runbooks.

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

## Publishing

GitHub Pages is deployed by `.github/workflows/pages.yml` after Pages is enabled once in repository settings with **Source = GitHub Actions**.
