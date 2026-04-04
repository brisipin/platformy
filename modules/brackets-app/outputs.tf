output "api_base_url" {
  value       = "http://${length(aws_eip.app) > 0 ? aws_eip.app[0].public_ip : aws_instance.app.public_ip}:${var.app_port}"
  description = "Base URL for the frontend. HTTP only; add TLS on the instance or in front (e.g. Cloudflare) if needed."
}

output "api_public_ip" {
  value       = length(aws_eip.app) > 0 ? aws_eip.app[0].public_ip : aws_instance.app.public_ip
  description = "Public IPv4 for the API (Elastic IP when associate_elastic_ip is true)."
}

output "api_key" {
  value       = random_password.api_key.result
  sensitive   = true
  description = "Bearer-style secret; configure FastAPI to require this value (e.g. X-API-Key). Store in frontend build secrets, not in S3 objects."
}

output "api_key_secret_arn" {
  value       = aws_secretsmanager_secret.api_key.arn
  description = "Secrets Manager ARN (optional: read from CI instead of OpenTofu output)."
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "docker build && docker push target after aws ecr get-login-password."
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.app.arn
  description = "ECR repository ARN (for cross-checking IAM policies)."
}

output "ecr_push_role_arn" {
  value       = length(aws_iam_role.github_ecr_push) > 0 ? aws_iam_role.github_ecr_push[0].arn : null
  description = "Assume this role from GitHub Actions (oidc) to push images. Null if github_actions_ecr_push_repositories is empty."
}

output "ecr_push_role_name" {
  value       = length(aws_iam_role.github_ecr_push) > 0 ? aws_iam_role.github_ecr_push[0].name : null
  description = "IAM role name for ECR push."
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID (ECR registry host is <account>.dkr.ecr.<region>.amazonaws.com)."
}

output "aws_region" {
  value       = data.aws_region.current.name
  description = "Region where ECR and the role live."
}

output "github_oidc_provider_arn" {
  value       = length(var.github_actions_ecr_push_repositories) > 0 && local.github_oidc_provider_arn_resolved != "" ? local.github_oidc_provider_arn_resolved : null
  description = "OIDC provider ARN used in the push role trust policy."
}

output "instance_id" {
  value       = aws_instance.app.id
  description = "EC2 instance id (SQLite data on instance disk until you add backups)."
}

output "cost_budget_id" {
  value       = length(aws_budgets_budget.app) > 0 ? aws_budgets_budget.app[0].id : null
  description = "AWS Budget id when cost budget is created."
}

output "api_cdn_url" {
  value       = "https://${aws_cloudfront_distribution.api.domain_name}"
  description = "HTTPS URL for the API via CloudFront. Set as VITE_API_BASE_URL GitHub Actions secret."
}

output "frontend_bucket_name" {
  value       = length(aws_s3_bucket.frontend) > 0 ? aws_s3_bucket.frontend[0].bucket : null
  description = "S3 bucket name for the static frontend. Set as S3_BUCKET GitHub Actions secret."
}

output "cloudfront_distribution_id" {
  value       = length(aws_cloudfront_distribution.frontend) > 0 ? aws_cloudfront_distribution.frontend[0].id : null
  description = "CloudFront distribution ID. Set as CLOUDFRONT_DISTRIBUTION_ID GitHub Actions secret."
}

output "cloudfront_domain_name" {
  value       = length(aws_cloudfront_distribution.frontend) > 0 ? aws_cloudfront_distribution.frontend[0].domain_name : null
  description = "CloudFront domain (e.g. d1234.cloudfront.net). Access the frontend here until you add a custom domain."
}

output "ec2_ssh_private_key" {
  value       = tls_private_key.ec2_ssh.private_key_openssh
  sensitive   = true
  description = "ED25519 private key for SSH access to the EC2 instance. Set as EC2_SSH_KEY GitHub Actions secret."
}

output "jwt_secret_key" {
  value       = random_password.jwt_secret_key.result
  sensitive   = true
  description = "JWT signing secret. Set as JWT_SECRET_KEY GitHub Actions secret."
}

output "cors_allowed_origins" {
  value       = length(aws_cloudfront_distribution.frontend) > 0 ? "https://${aws_cloudfront_distribution.frontend[0].domain_name}" : null
  description = "CORS origin to allow (CloudFront URL). Set as CORS_ALLOWED_ORIGINS GitHub Actions secret."
}
