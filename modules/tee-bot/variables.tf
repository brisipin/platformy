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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags for AWS resources."
}

variable "github_actions_ecr_push_repositories" {
  type        = list(string)
  default     = []
  description = "GitHub repos allowed to assume the ECR push role (e.g. [\"myorg/my-backend\"]). Empty = no push role."
}

variable "create_github_oidc_provider" {
  type        = bool
  default     = false
  description = "Create account-level GitHub OIDC provider. Set true only if it does not exist yet (one per AWS account)."
}

variable "github_oidc_provider_arn" {
  type        = string
  default     = ""
  description = "Existing IAM OIDC provider ARN for https://token.actions.githubusercontent.com. Overrides lookup/create when set."
}
