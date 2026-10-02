output "project_ref" {
  value       = module.supabase.project_ref
  description = "Supabase project reference ID."
}

output "pooler_host" {
  value       = local.pooler_host
  description = "Supabase pooler hostname (IPv4)."
}

output "database_url_secret_name" {
  value       = aws_secretsmanager_secret.pooler_url.name
  description = "Secrets Manager secret holding AFFiNE's DATABASE_URL (session pooler)."
}
