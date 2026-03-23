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

variable "root_volume_size_gb" {
  type        = number
  default     = 30
  description = "Root gp3 volume size (GiB). Must be >= AMI snapshot minimum (AL2023 ARM often requires 30)."
}

variable "associate_elastic_ip" {
  type        = bool
  default     = true
  description = "Allocate an Elastic IP so the API URL stays stable across instance replacement."
}

variable "allowed_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed to reach app_port on the instance (tighten for your IP or VPN)."
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

variable "create_cost_budget" {
  type        = bool
  default     = true
  description = "Create an AWS Budget for monthly cost alerts (requires budget_alert_emails)."
}

variable "budget_monthly_usd" {
  type        = number
  default     = 50
  description = "Monthly cost budget in USD (alerts at 80% actual, 100% actual, 100% forecasted)."
}

variable "budget_alert_emails" {
  type        = list(string)
  default     = []
  description = "Emails for AWS Budget notifications (confirm subscriptions in inbox). Empty = no budget created."
}

variable "budget_cost_tag_key" {
  type        = string
  default     = "App"
  description = "Cost allocation tag key used to scope the budget to this stack. Activate this tag under Billing > Cost allocation tags."
}

variable "budget_cost_tag_value" {
  type        = string
  default     = ""
  description = "Tag value for the budget filter. If empty, uses tags[budget_cost_tag_key] or name_prefix."
}

variable "budget_time_period_start" {
  type        = string
  default     = "2025-01-01_00:00"
  description = "Budget period start (YYYY-MM-DD_HH:MM, UTC). Must be first day of a month."
}
