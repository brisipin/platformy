output "cluster_id" {
  value       = digitalocean_kubernetes_cluster.this.id
  description = "ID of the Kubernetes cluster."
}

output "cluster_endpoint" {
  value       = digitalocean_kubernetes_cluster.this.endpoint
  description = "API endpoint for the cluster."
}

output "kube_config" {
  value       = digitalocean_kubernetes_cluster.this.kube_config
  sensitive   = true
  description = "Kubernetes config (kubeconfig) for the cluster."
}

output "cluster_name" {
  value       = digitalocean_kubernetes_cluster.this.name
  description = "Name of the cluster."
}
