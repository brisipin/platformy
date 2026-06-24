variable "cloudspace_name" {
  type        = string
  default     = "tee-bot-dev"
  description = "Name of the Rackspace Spot cloudspace."
}

variable "region" {
  type        = string
  default     = "us-central-dfw-2"
  description = "Rackspace Spot region for the cloudspace."
}

variable "core_server_class" {
  type        = string
  default     = "gp.vs2.medium-dfw2"
  description = "Server class for the core nodepool."
}

variable "core_bid_price" {
  type        = number
  default     = 0.02
  description = "Bid price for the core nodepool. Temporary: core runs on spot for now, switch back to on-demand later."
}

variable "core_desired_nodes" {
  type        = number
  default     = 1
  description = "Desired node count for the core nodepool."
}

variable "workers_server_class" {
  type        = string
  default     = "gp.vs2.medium-dfw2"
  description = "Server class for the spot workers nodepool."
}

variable "workers_bid_price" {
  type        = number
  default     = 0.02
  description = "Bid price for the spot workers nodepool. Tune to your comfort."
}

variable "workers_desired_nodes" {
  type        = number
  default     = 2
  description = "Desired node count for the spot workers nodepool."
}
