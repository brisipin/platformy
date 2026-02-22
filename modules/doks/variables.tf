variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster."
}

variable "region" {
  type        = string
  description = "DigitalOcean region slug (e.g. nyc1, sfo3)."
}

variable "node_pool_size" {
  type        = string
  default     = "s-1vcpu-2gb"
  description = "Droplet size slug for the node pool (e.g. s-1vcpu-2gb). Smallest typical DOKS node ~$12/mo."
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of nodes in the default node pool."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Tags to apply to the cluster and nodes."
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Kubernetes version slug. If null, provider default (latest) is used."
}

variable "auto_upgrade" {
  type        = bool
  default     = true
  description = "Enable automatic patch version upgrades for the cluster."
}
