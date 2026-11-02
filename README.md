# opsagents-demo

Demo repository for OpsAgents. Each workflow covers one part of the repository, so each
failure reaches one agent:

| Workflow | Runs when | On failure, OpsAgents starts |
|---|---|---|
| `deploy` | `infra/` changes | Dependency Resolver: OpenTofu `init`, `validate`, `graph` |
| `tests` | `service/` changes | Diagnostic / RCA: the service's pytest suite |
| (pull request) | a PR is opened | Code Reviewer, after RCA if the PR's tests failed |
