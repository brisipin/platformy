resource "aws_cloudwatch_log_group" "api" {
  name              = "/brackets/api"
  retention_in_days = 30

  tags = var.tags
}
