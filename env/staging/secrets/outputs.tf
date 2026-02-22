output "do_token_secret_arn" {
  value       = module.do_token.secret_arn
  description = "ARN of the DigitalOcean API token secret. Pass this to DOKS and other roots as do_token_secret_arn."
}
