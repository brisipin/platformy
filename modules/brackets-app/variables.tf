variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (use per deployment, e.g. brackets-staging)."
}

variable "ecr_image_tag" {
  type        = string
  default     = "latest"
  description = "Image tag to run after you push to ECR."
}

variable "instance_type" {
  type        = string
  default     = "t4g.micro"
  description = "Cheapest general-purpose Graviton instance; requires ARM64 image in ECR."
}

variable "app_port" {
  type        = number
  default     = 8000
  description = "Container port FastAPI listens on."
}

variable "health_check_path" {
  type        = string
  default     = "/health"
  description = "ALB health check path; expose this in FastAPI (GET returns 200)."
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN in this region for HTTPS listener. Leave empty for HTTP-only ALB."
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Set true for production ALB."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags for resources."
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
