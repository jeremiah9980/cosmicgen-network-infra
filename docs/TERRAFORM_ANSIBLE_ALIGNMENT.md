# Terraform / Ansible Alignment

## Goal
Keep the lab **repeatable** without mixing responsibilities.

## Terraform (desired responsibilities)
Terraform is best when it manages “declarative infrastructure objects”, such as:

- Proxmox resources:
  - VMs / templates
  - VM networking (bridges, tags, VLAN-aware NICs)
  - storage assignments
- DNS records (if using an API-based DNS provider)
- Static inventory artifacts (outputs that feed Ansible)

### Terraform should NOT
- run ad-hoc imperative commands on hosts (unless tightly controlled provisioners)
- manage ongoing package drift or OS state

## Ansible (desired responsibilities)
Ansible is best for “configuration management” and host-level state:

- baseline hardening (SSH config, users, sudoers, firewall)
- package install + updates
- Proxmox node configuration tasks (post-install tuning)
- app deployment inside VMs
- validating services (Proxmox UI, IPMI reachability, monitoring agents)

## Interface between them
- Terraform outputs the VM IPs / names.
- Ansible inventory consumes those outputs (dynamic inventory, or generated `hosts.ini`).

## Recommended workflow
1. Terraform:
   - create/update the Proxmox VMs
2. Ansible:
   - configure the OS and deploy workloads
3. Document changes:
   - update `docs/` and the diagram if network layout changes

