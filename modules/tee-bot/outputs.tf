output "kubeconfig_raw" {
  value     = data.spot_kubeconfig.tee_bot.raw
  sensitive = true
}

output "cloudspace_name" {
  value = spot_cloudspace.tee_bot.name
}
