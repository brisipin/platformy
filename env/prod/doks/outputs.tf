output "cluster_id" {
  value       = module.doks.cluster_id
  description = "ID of the DOKS cluster."
}

output "cluster_endpoint" {
  value       = module.doks.cluster_endpoint
  description = "API endpoint for the cluster."
}

output "cluster_name" {
  value       = module.doks.cluster_name
  description = "Name of the cluster."
}

output "kube_config" {
  value       = module.doks.kube_config
  sensitive   = true
  description = "Kubernetes config (kubeconfig) for the cluster."
}
