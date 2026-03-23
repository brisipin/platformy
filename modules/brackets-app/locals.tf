locals {
  azs_sorted = sort(distinct([for s in data.aws_subnet.default : s.availability_zone]))
  alb_subnet_ids = [
    for az in slice(local.azs_sorted, 0, min(2, length(local.azs_sorted))) :
    sort([for s in data.aws_subnet.default : s.id if s.availability_zone == az])[0]
  ]
  instance_subnet_id = local.alb_subnet_ids[0]
  lb_name            = substr(replace("${var.name_prefix}-alb", "_", "-"), 0, 32)
  tg_name            = substr(replace("${var.name_prefix}-tg", "_", "-"), 0, 32)

  github_oidc_provider_arn_resolved = length(var.github_actions_ecr_push_repositories) == 0 ? "" : (
    var.github_oidc_provider_arn != "" ? var.github_oidc_provider_arn : (
      var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
    )
  )
  github_oidc_subject_patterns = [for r in var.github_actions_ecr_push_repositories : "repo:${r}:*"]
}
