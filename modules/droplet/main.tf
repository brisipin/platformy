resource "digitalocean_droplet" "this" {
  name   = var.name
  region = var.region
  size   = var.size
  image  = var.image
  tags   = var.tags

  backups = var.backups
  ipv6    = var.ipv6
}
