# Roadmap

## Now

- Complete Issue #5: persistent Terraform + repo-specific GitHub OIDC + direct AWS MCP drift detection/reconciliation.
- Record the final repair evidence and cross-session learning.

## Next

- Test MCP-specific IAM controls using `aws:ViaAWSMCPService` / `aws:CalledViaAWSMCP` so MCP-originated actions can have different permissions from normal human/API actions.
- Use `mytestlab123/lab1_agent` as the first independent ChatGPT-session consumer of the shared AWS knowledge and, when its own project scope is ready, give it a repo-specific OIDC deployment role.

## Later

- Add a ChatGPT Site or other UI/control surface after the backend AWS execution and governance paths are stable.
