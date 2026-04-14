variable "name_prefix" {
  type        = string
  description = "Prefix for AWS resource names (e.g. brackets-staging)."
}

variable "organization_id" {
  type        = string
  description = "Supabase organization ID. Find at supabase.com/dashboard/org/<slug>/settings."
}

variable "project_name" {
  type        = string
  description = "Supabase project display name."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Supabase project region. Must be a valid Supabase region slug (e.g. us-east-1, eu-west-1)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags applied to AWS resources."
}
