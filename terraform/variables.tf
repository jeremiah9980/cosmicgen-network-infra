variable "proxmox_endpoint" {
  description = "Proxmox API endpoint, e.g. https://pve01:8006/api2/json"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox username, e.g. root@pam or terraform@pve"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password (store in TF_VAR_ env var or a secret manager)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Allow insecure TLS (self-signed cert) for lab use"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Default Proxmox node name"
  type        = string
  default     = "pve01"
}

variable "proxmox_bridge" {
  description = "Proxmox Linux bridge to attach VMs to"
  type        = string
  default     = "vmbr0"
}
