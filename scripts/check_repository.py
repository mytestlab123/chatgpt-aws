"""Small public-repository guardrails; not a substitute for a history/IAM audit."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

import yaml

SECRET_PATTERNS = (
    re.compile(r"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"),
    re.compile(r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b"),
    re.compile(r"\bgithub_pat_[A-Za-z0-9_]{30,}\b"),
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----"),
    re.compile(r"(?i)aws_secret_access_key\s*[:=]\s*['\"]?[A-Za-z0-9/+=]{30,}"),
    re.compile(r"(?i)\b(?:password|passwd|basic_auth_password)\s*[:=]\s*['\"]?[^'\"\s]{16,}"),
    re.compile(r"(?i)authorization\s*:\s*basic\s+[A-Za-z0-9+/=]{16,}"),
)
AWS_GUARDS = (
    "github.event_name == 'workflow_dispatch'",
    "github.ref == 'refs/heads/main'",
    "github.repository == vars.AWS_EXECUTION_REPOSITORY",
    "vars.AWS_LABS_ENABLED == 'true'",
)
PUBLIC_ENTRYPOINTS = {
    'README.md',
    'CONTEXT.md',
    'docs/index.md',
    'docs/HOSTING.md',
}
STALE_PUBLIC_CLAIMS = (
    'source repository currently remains private',
    '`mytestlab123/chatgpt-aws` is private and active',
    'private primary knowledge source',
    'while this repository is private',
)
REUSABLE_TEMPLATE_FILES = {
    'PROMPT.md',
    'TEMPLATE_CHECKLIST.md',
    'NEW_REPO_BOOTSTRAP.md',
    'docs/PRIVATE_CLOUDFRONT_PORTALS.md',
    'infra/private-portals/main.tf',
    '.github/workflows/private-portals-lab.yml',
}
TEMPLATE_LIVE_PATTERNS = (
    re.compile(r"\b\d{10,14}\b"),
    re.compile(r"arn:aws:iam::\d{12}:role/"),
    re.compile(r"github-actions-chatgpt-aws", re.I),
    re.compile(r"chatgpt-aws-tfstate-", re.I),
    re.compile(r"chatgpt-aws-docs-\d", re.I),
    re.compile(r"\bd[a-z0-9]{8,}\.cloudfront\.net\b", re.I),
)


def text_errors(name: str, text: str) -> list[str]:
    # Never print a matched credential or its surrounding source line.
    return [f"{name}: possible credential pattern {i + 1}"
            for i, pattern in enumerate(SECRET_PATTERNS) if pattern.search(text)]


def template_errors(name: str, text: str) -> list[str]:
    """Reusable files must not accidentally carry live lab/account identifiers."""
    if name not in REUSABLE_TEMPLATE_FILES:
        return []
    return [f"{name}: reusable template contains live/reference identifier pattern {i + 1}"
            for i, pattern in enumerate(TEMPLATE_LIVE_PATTERNS) if pattern.search(text)]


def entrypoint_errors(name: str, text: str) -> list[str]:
    """Prevent public-facing status pages from reverting to the old private-repo claim."""
    if name not in PUBLIC_ENTRYPOINTS:
        return []
    lowered = text.lower()
    return [f'{name}: stale private-repository status claim'
            for phrase in STALE_PUBLIC_CLAIMS if phrase.lower() in lowered]


def workflow_errors(name: str, text: str) -> list[str]:
    data = yaml.load(text, Loader=yaml.BaseLoader)
    if not isinstance(data, dict):
        return [f"{name}: workflow must be a mapping"]
    errors = []
    if data.get('permissions') != {'contents': 'read'}:
        errors.append(f"{name}: default permissions must be contents: read only")
    triggers = data.get('on', {})
    if 'pull_request_target' in triggers or 'workflow_run' in triggers:
        errors.append(f"{name}: privileged event chains require separate review")
    for job_name, job in data.get('jobs', {}).items():
        steps = job.get('steps', [])
        aws = any('aws-actions/configure-aws-credentials@' in s.get('uses', '') for s in steps)
        if aws:
            if set(triggers) != {'workflow_dispatch'}:
                errors.append(f"{name}/{job_name}: AWS must be manual-only")
            if not all(guard in job.get('if', '') for guard in AWS_GUARDS):
                errors.append(f"{name}/{job_name}: missing AWS main/repo/opt-in guard")
            if job.get('permissions') != {'contents': 'read', 'id-token': 'write'}:
                errors.append(f"{name}/{job_name}: scope AWS OIDC to the live job")
        if job.get('permissions', {}).get('id-token') == 'write' and not aws:
            if job.get('permissions', {}).get('pages') != 'write':
                errors.append(f"{name}/{job_name}: unexpected non-AWS OIDC job")
            condition = job.get('if', '')
            if "github.ref == 'refs/heads/main'" not in condition or "github.event_name != 'pull_request'" not in condition:
                errors.append(f"{name}/{job_name}: Pages deployment must exclude PRs and non-main")
        for step in steps:
            action = step.get('uses', '')
            if action and not action.startswith('./') and not re.fullmatch(r'[^@]+@[0-9a-f]{40}', action):
                errors.append(f"{name}: action is not pinned to a full commit SHA")
            if action.startswith('actions/checkout@') and step.get('with', {}).get('persist-credentials') != 'false':
                errors.append(f"{name}: checkout must not retain credentials")
    return errors


def check(root: Path) -> list[str]:
    files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).decode().split('\0')
    errors = []
    for name in filter(None, files):
        path = root / name
        if path.is_symlink():
            errors.append(f'{name}: tracked symlinks require a separate publication review')
            continue
        if re.search(r'(?:^|/)(?:\.env|[^/]*\.tfstate(?:\..*)?|tfplan|plan\.txt)$', name):
            errors.append(f'{name}: environment/state/plan file must not be committed')
        raw = path.read_bytes()
        try:
            text = raw.decode('utf-8')
        except UnicodeDecodeError:
            errors.append(f'{name}: binary files need an explicit scan strategy')
            continue
        errors.extend(text_errors(name, text))
        errors.extend(template_errors(name, text))
        errors.extend(entrypoint_errors(name, text))
        if name.startswith('.github/workflows/') and name.endswith(('.yml', '.yaml')):
            errors.extend(workflow_errors(name, text))
    return errors


if __name__ == '__main__':
    problems = check(Path(__file__).resolve().parents[1])
    print('\n'.join(problems) if problems else 'PASS: current tracked files, reusable template, and workflow guardrails')
    raise SystemExit(bool(problems))
