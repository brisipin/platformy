output "project_ref" {
  value       = supabase_project.main.id
  description = "Supabase project reference ID (used in connection strings and dashboard URLs)."
}

output "database_host" {
  value       = local.database_host
  description = "Supabase database hostname."
}

output "database_url" {
  value       = local.database_url
  sensitive   = true
  description = "Full PostgreSQL connection URL (postgresql://postgres:...@.../postgres). Set as DATABASE_URL."
}

output "database_url_secret_arn" {
  value       = aws_secretsmanager_secret.database_url.arn
  description = "AWS Secrets Manager ARN for the database URL. Grant EC2/Lambda GetSecretValue on this ARN."
}

output "database_url_secret_name" {
  value       = aws_secretsmanager_secret.database_url.name
  description = "AWS Secrets Manager secret name for the database URL."
}
