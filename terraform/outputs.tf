output "info" {
  value = {
    proxmox_endpoint = var.proxmox_endpoint
    proxmox_node     = var.proxmox_node
    proxmox_bridge   = var.proxmox_bridge
  }
}
