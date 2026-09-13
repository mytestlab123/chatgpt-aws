# GitHub OIDC + AWS

GitHub Actions can access AWS without storing long-lived AWS access keys.

## Flow

```text
GitHub Actions
    |
    | requests OIDC token
    v
GitHub OIDC provider
    |
    v
AWS STS AssumeRoleWithWebIdentity
    |
    v
short-lived AWS role session
    |
    v
Terraform / AWS CLI / SDK
```

## Why use it

- no static AWS access keys in repository secrets
- short-lived credentials
- trust can be limited to a specific repository, branch, pull request, or environment
- AWS CloudTrail records the assumed role activity
- deployment permissions can be separated by repository or workload

## Recommended trust design

Keep the trust relationship narrow:

```text
repository A -> role A
repository B -> role B
```

Do not reuse one broad GitHub role across unrelated repositories simply because it is convenient.

## Practical troubleshooting

When `AssumeRoleWithWebIdentity` fails:

1. confirm the workflow has `id-token: write`;
2. verify the AWS OIDC provider and audience;
3. inspect the actual web-identity subject in CloudTrail;
4. compare it with the role trust policy;
5. adjust only to the legitimate subject you actually observed;
6. avoid replacing a precise trust policy with a broad organization wildcard.

## Deterministic delivery

Use OIDC as the authentication mechanism for the durable path:

```text
Git -> pull request -> tests -> merge -> Actions -> OIDC -> AWS
```

OIDC handles authentication. Terraform/CDK/CloudFormation still defines the desired state.
