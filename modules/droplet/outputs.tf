output "id" {
  value       = digitalocean_droplet.this.id
  description = "ID of the Droplet."
}

output "name" {
  value       = digitalocean_droplet.this.name
  description = "Name of the Droplet."
}

output "ipv4_address" {
  value       = digitalocean_droplet.this.ipv4_address
  description = "Public IPv4 address."
}

output "ipv4_address_private" {
  value       = digitalocean_droplet.this.ipv4_address_private
  description = "Private IPv4 address."
}

output "urn" {
  value       = digitalocean_droplet.this.urn
  description = "URN of the Droplet."
}
