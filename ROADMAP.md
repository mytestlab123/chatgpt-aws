# Roadmap

## Completed

- Direct AWS Core MCP read/write proofs.
- GitHub Actions -> OIDC -> AWS proof without static AWS keys.
- Terraform provisioning/destroy proof with independent AWS MCP cleanup verification.
- Cross-session portable AWS MCP/GitHub knowledge pack.
- Persistent Terraform state + repo-specific OIDC in `mytestlab123/chatgpt-aws`.
- Direct AWS MCP drift -> Terraform detection -> GitHub/OIDC/Terraform repair -> independent AWS MCP final verification.

## Now

- Test MCP-specific IAM controls using `aws:ViaAWSMCPService` / `aws:CalledViaAWSMCP` so MCP-originated actions can have different permissions from normal human/API actions.

## Next

- Use `mytestlab123/lab1_agent` as the first independent ChatGPT-session consumer of the shared AWS knowledge and, when its own project scope is ready, create a repo-specific OIDC deployment role.

## Later

- Add a ChatGPT Site or other UI/control surface after the backend AWS execution and governance paths are stable.
