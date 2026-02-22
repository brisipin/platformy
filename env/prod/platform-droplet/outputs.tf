output "droplet_id" {
  value       = module.platform_droplet.id
  description = "ID of the platform Droplet."
}

output "droplet_name" {
  value       = module.platform_droplet.name
  description = "Name of the Droplet."
}

output "ipv4_address" {
  value       = module.platform_droplet.ipv4_address
  description = "Public IPv4 address."
}

output "ipv4_address_private" {
  value       = module.platform_droplet.ipv4_address_private
  description = "Private IPv4 address."
}
