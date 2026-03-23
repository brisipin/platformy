output "api_base_url" {
  value       = module.brackets_app.api_base_url
  description = "Configure frontend to call this base URL."
}

output "api_key" {
  value       = module.brackets_app.api_key
  sensitive   = true
  description = "Pass to frontend as build-time secret (e.g. GitHub Actions env), not committed."
}

output "ecr_repository_url" {
  value = module.brackets_app.ecr_repository_url
}

output "ecr_push_role_arn" {
  value = module.brackets_app.ecr_push_role_arn
}

output "aws_account_id" {
  value = module.brackets_app.aws_account_id
}

output "aws_region" {
  value = module.brackets_app.aws_region
}
