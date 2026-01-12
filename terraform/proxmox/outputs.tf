output "vm_names" {
  value = [for v in proxmox_vm_qemu.vm : v.name]
}

output "vm_ids" {
  value = [for v in proxmox_vm_qemu.vm : v.vmid]
}
