# Resume-ready bullets (CosmicGen PoC Lab Build)

- Designed and implemented a segmented lab network on a MikroTik CRS326 (RouterOS 6.49.x) using VLAN-aware bridging, access-port PVIDs, and inter-VLAN routing for LAN/servers/management/IoT.
- Integrated an Eero gateway (192.168.0.0/16) as the upstream NAT device and aligned switch uplink/VLAN50 addressing for reliable north/south connectivity.
- Enabled secure remote administration via L2TP over IPsec (PSK), including PPP profiles/pools, firewall port allowances (UDP 500/4500/1701 + ESP), and NAT policies for VPN-to-LAN access.
- Provisioned three Supermicro hosts with out-of-band IPMI management and validated remote KVM/web access for hardware lifecycle operations.
- Installed and validated Proxmox on all nodes; confirmed web UI/API reachability and baseline cluster readiness for virtualization workloads.
- Authored Windows automation scripts to deploy L2TP/IPsec VPN profiles (including NAT-T registry configuration) and provided operational runbooks for day-2 support and troubleshooting.
- Established Infrastructure-as-Code foundations with a GitHub-ready repository structure aligning Terraform (Proxmox resource lifecycle) and Ansible (host configuration management).
