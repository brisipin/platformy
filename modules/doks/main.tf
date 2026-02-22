resource "digitalocean_kubernetes_cluster" "this" {
  name    = var.cluster_name
  region  = var.region
  version = var.kubernetes_version
  tags    = var.tags

  auto_upgrade = var.auto_upgrade

  node_pool {
    name       = "default-pool"
    size       = var.node_pool_size
    node_count = var.node_count
    tags       = var.tags
  }
}
