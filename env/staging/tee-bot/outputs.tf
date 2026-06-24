output "kubeconfig_raw" {
  value     = module.tee_bot.kubeconfig_raw
  sensitive = true
}

output "ecr_repository_url" {
  value = module.tee_bot.ecr_repository_url
}

output "ecr_push_role_arn" {
  value = module.tee_bot.ecr_push_role_arn
}
