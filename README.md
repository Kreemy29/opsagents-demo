# opsagents-demo

Demo repository for OpsAgents. GitHub Actions runs OpenTofu (`init`, `validate`, `graph`) on
`infra/` for every push. The second commit introduces a dependency cycle between the IAM role,
its policy and the EKS cluster, so the deploy check fails and OpsAgents investigates.
