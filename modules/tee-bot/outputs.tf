output "kubeconfig_raw" {
  value     = data.spot_kubeconfig.tee_bot.raw
  sensitive = true
}

output "cloudspace_name" {
  value = spot_cloudspace.tee_bot.name
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.teebot.repository_url
  description = "docker build && docker push target after aws ecr get-login-password."
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.teebot.arn
}

output "ecr_push_role_arn" {
  value       = length(aws_iam_role.github_ecr_push) > 0 ? aws_iam_role.github_ecr_push[0].arn : null
  description = "Assume this role from GitHub Actions (oidc) to push images. Null if github_actions_ecr_push_repositories is empty."
}
