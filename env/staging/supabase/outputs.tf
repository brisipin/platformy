output "project_ref" {
  value       = module.supabase.project_ref
  description = "Supabase project reference ID."
}

output "database_host" {
  value       = module.supabase.database_host
  description = "Supabase database hostname."
}

output "database_url_secret_arn" {
  value       = module.supabase.database_url_secret_arn
  description = "Secrets Manager ARN for DATABASE_URL. Referenced by the brackets-app root via remote state."
}

output "database_url_secret_name" {
  value       = module.supabase.database_url_secret_name
  description = "Secrets Manager secret name for DATABASE_URL."
}
