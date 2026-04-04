resource "random_password" "api_key" {
  length  = 48
  special = false
}

resource "aws_secretsmanager_secret" "api_key" {
  name                    = "${var.name_prefix}/api-key"
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = random_password.api_key.result
}

resource "tls_private_key" "ec2_ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "ec2_ssh" {
  key_name   = "${var.name_prefix}-ec2-ssh"
  public_key = tls_private_key.ec2_ssh.public_key_openssh
  tags       = var.tags
}

resource "aws_secretsmanager_secret" "ec2_ssh_key" {
  name                    = "${var.name_prefix}/ec2-ssh-private-key"
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "ec2_ssh_key" {
  secret_id     = aws_secretsmanager_secret.ec2_ssh_key.id
  secret_string = tls_private_key.ec2_ssh.private_key_openssh
}

resource "random_password" "jwt_secret_key" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt_secret_key" {
  name                    = "${var.name_prefix}/jwt-secret-key"
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "jwt_secret_key" {
  secret_id     = aws_secretsmanager_secret.jwt_secret_key.id
  secret_string = random_password.jwt_secret_key.result
}
