output "secret_arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "ARN of the secret. Use this in other roots/modules with data.aws_secretsmanager_secret_version."
}

output "secret_name" {
  value       = aws_secretsmanager_secret.this.name
  description = "Name of the secret."
}

output "secret_id" {
  value       = aws_secretsmanager_secret.this.id
  description = "ID of the secret (same as ARN for Secrets Manager)."
}
