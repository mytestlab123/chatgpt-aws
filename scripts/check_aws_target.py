"""Fail before requesting OIDC when this clone has not been explicitly bound."""
from __future__ import annotations

import os
import re


def validate(env: dict[str, str]) -> list[str]:
    errors = []
    if env.get('GITHUB_EVENT_NAME') != 'workflow_dispatch' or env.get('GITHUB_REF') != 'refs/heads/main':
        errors.append('Live AWS runs require a manual dispatch of main.')
    repo = env.get('GITHUB_REPOSITORY', '')
    if not repo or repo != env.get('AWS_EXECUTION_REPOSITORY'):
        errors.append('Set AWS_EXECUTION_REPOSITORY to this exact owner/repository.')
    if env.get('AWS_LABS_ENABLED') != 'true':
        errors.append('AWS_LABS_ENABLED is not explicitly true.')
    account = env.get('AWS_ALLOWED_ACCOUNT_ID', '')
    if not re.fullmatch(r'\d{12}', account):
        errors.append('AWS_ALLOWED_ACCOUNT_ID must be a 12-digit account identifier.')
    role = env.get('AWS_ROLE_ARN', '')
    match = re.fullmatch(r'arn:aws(?:-us-gov|-cn)?:iam::(\d{12}):role/[A-Za-z0-9_+=,.@/-]+', role)
    if not match or match.group(1) != account:
        errors.append('AWS_ROLE_ARN must belong to the explicitly allowed account.')
    if not re.fullmatch(r'[a-z]{2}(?:-[a-z]+)+-\d+', env.get('AWS_REGION', '')):
        errors.append('AWS_REGION must be set explicitly.')
    return errors


if __name__ == '__main__':
    errors = validate(dict(os.environ))
    print('\n'.join(errors) if errors else 'PASS: repository/account/role binding (no AWS API called)')
    raise SystemExit(bool(errors))
