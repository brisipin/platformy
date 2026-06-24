output "kubeconfig_raw" {
  value     = module.tee_bot.kubeconfig_raw
  sensitive = true
}
