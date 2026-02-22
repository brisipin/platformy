variable "name" {
  type        = string
  description = "Name of the Droplet."
}

variable "region" {
  type        = string
  description = "DigitalOcean region slug (e.g. nyc1, sfo3)."
}

variable "size" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "Droplet size slug. s-1vcpu-1gb = 1 vCPU, 1 GB RAM, 25 GB disk ≈ $6/mo."
}

variable "image" {
  type        = string
  default     = "ubuntu-22-04-x64"
  description = "Image slug (e.g. ubuntu-22-04-x64)."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Tags to apply to the Droplet."
}

variable "backups" {
  type        = bool
  default     = false
  description = "Enable automated backups (adds cost)."
}

variable "ipv6" {
  type        = bool
  default     = false
  description = "Enable IPv6."
}
