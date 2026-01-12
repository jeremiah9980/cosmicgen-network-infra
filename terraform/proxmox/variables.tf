variable "pm_api_url" {
  type        = string
  description = "Proxmox API URL"
  default     = "https://47.163.25.30:8006/api2/json"
}

variable "pm_api_token_id" {
  type        = string
  sensitive   = true
}

variable "pm_api_token_secret" {
  type        = string
  sensitive   = true
}

variable "target_node" {
  type        = string
  description = "Proxmox node name (e.g. pve01)"
}

variable "template_vmid" {
  type        = number
  description = "VMID of cloud-init template"
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_name_prefix" {
  type    = string
  default = "cosmicgen-vm"
}

variable "vm_cpu_cores" {
  type    = number
  default = 2
}

variable "vm_memory_mb" {
  type    = number
  default = 4096
}

variable "vm_disk_gb" {
  type    = number
  default = 40
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "vlan_tag" {
  type    = number
  default = 0
}

variable "ssh_public_keys" {
  type    = string
  default = ""
}

variable "ci_user" {
  type    = string
  default = "ubuntu"
}

variable "ip_config" {
  type    = string
  default = "ip=dhcp"
}
