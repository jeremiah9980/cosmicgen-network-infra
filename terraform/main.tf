terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.85.0"
    }
  }
}

provider "proxmox" {
  # Example:
  # endpoint = "https://proxmox.example.local:8006/api2/json"
  # username = "root@pam"
  # password = var.proxmox_password
  # insecure = true
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
}

# --- Example VM placeholder (fill in once templates/storage/network are defined) ---
# resource "proxmox_virtual_environment_vm" "example" {
#   name      = "example-vm01"
#   node_name = var.proxmox_node
#
#   cpu {
#     cores = 2
#   }
#
#   memory {
#     dedicated = 4096
#   }
#
#   network_device {
#     bridge = var.proxmox_bridge
#     vlan_id = 20
#   }
# }
