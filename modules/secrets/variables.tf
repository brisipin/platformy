variable "secret_name" {
  type        = string
  description = "Name of the secret in AWS Secrets Manager."
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the secret."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the secret."
}

variable "recovery_window_in_days" {
  type        = number
  default     = 7
  description = "Number of days that Secrets Manager waits before it can delete the secret (0 = immediate, 7-30 = recovery window)."
}

variable "secret_string" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Optional initial secret value. If set, creates the first version. Otherwise set the value later in AWS Console/CLI."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "ARN or ID of the KMS key to encrypt the secret. If not set, uses the default AWS key."
}
