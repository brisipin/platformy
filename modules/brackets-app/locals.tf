locals {
  instance_subnet_id = sort(data.aws_subnets.default.ids)[0]

  github_oidc_provider_arn_resolved = length(var.github_actions_ecr_push_repositories) == 0 ? "" : (
    var.github_oidc_provider_arn != "" ? var.github_oidc_provider_arn : (
      var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
    )
  )
  github_oidc_subject_patterns = [for r in var.github_actions_ecr_push_repositories : "repo:${r}:*"]
}
