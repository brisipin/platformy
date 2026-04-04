output "api_base_url" {
  value       = module.brackets_app.api_base_url
  description = "Configure frontend to call this base URL."
}

output "api_public_ip" {
  value       = module.brackets_app.api_public_ip
  description = "EC2 public IP. Set as EC2_HOST GitHub Actions secret."
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

output "cost_budget_id" {
  value = module.brackets_app.cost_budget_id
}

output "frontend_bucket_name" {
  value       = module.brackets_app.frontend_bucket_name
  description = "Set as S3_BUCKET GitHub Actions secret."
}

output "cloudfront_distribution_id" {
  value       = module.brackets_app.cloudfront_distribution_id
  description = "Set as CLOUDFRONT_DISTRIBUTION_ID GitHub Actions secret."
}

output "cloudfront_domain_name" {
  value       = module.brackets_app.cloudfront_domain_name
  description = "Frontend URL (until you add a custom domain)."
}
