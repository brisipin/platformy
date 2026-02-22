resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
  kms_key_id              = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "this" {
  count = length(var.secret_string) > 0 ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}
