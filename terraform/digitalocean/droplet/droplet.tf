resource "digitalocean_droplet" "minecraft" {
  count = var.replicas
  image  = "ubuntu-20-04-x64"
  name   = "github-"
  region = var.region
  size   = var.node_type
  user_data = templatefile("${path.module}/../cloud-init.tpl", {
    ssh_key = var.public_key
  })
}
