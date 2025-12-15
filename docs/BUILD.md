# CosmicGen PoC Build Document

## 1. Objective

Stand up a small “micro-cloud” proof-of-concept lab that provides:

- Segmented VLAN-based switching for lab traffic
- Upstream internet via an Eero gateway
- Remote administration via VPN (L2TP/IPsec)
- 3-node Proxmox cluster on Supermicro hosts
- IPMI out-of-band access for each host

## 2. High-Level Architecture

- **Gateway:** Eero (NAT + DHCP for the Wi‑Fi/LAN)
- **Switch:** MikroTik CRS326-24G-2S+ (RouterOS 6.49.19)
- **Compute:** 3x Supermicro servers
  - Proxmox installed on each host
  - IPMI enabled on each host (BMC web UI + remote KVM)

See the network diagram in `diagrams/`.

## 3. Addressing and VLAN Plan (example)

> Update these ranges to match your final “gold config”.

| VLAN | Purpose | Subnet | Gateway |
|---:|---|---|---|
| 10 | LAN / Workstations | 192.168.10.0/24 | 192.168.10.1 (MikroTik SVI) |
| 20 | Servers / Proxmox | 192.168.20.0/24 | 192.168.20.1 |
| 30 | Management | 192.168.30.0/24 | 192.168.30.1 |
| 40 | IoT / Misc | 192.168.40.0/24 | 192.168.40.1 |
| 50 | Uplink / “Eero side” | 192.168.0.0/16 | 192.168.0.1 (Eero) |

## 4. MikroTik Build Summary

### 4.1 Switch provisioning
- Installed/verified RouterOS version: **6.49.19**
- Enabled VLAN filtering on the bridge
- Created VLAN interfaces (SVIs) on the bridge for inter-VLAN routing
- Mapped access ports to VLANs (PVID per port) and added bridge VLAN entries

### 4.2 DHCP
- Enabled DHCP servers for internal VLANs (10/20/30/40)
- Uplink VLAN (50) is aligned with the Eero gateway network

### 4.3 Remote VPN (L2TP/IPsec)
- Enabled L2TP server with IPsec (pre-shared key)
- Created PPP profile for VPN clients
- Added PPP secrets (users) for remote access
- Opened firewall ports needed for L2TP/IPsec
- Added NAT rules as required so VPN clients can reach internal VLANs and/or internet

### 4.4 Security hardening (minimum)
- Disabled Telnet
- Restricted management services (WinBox/SSH) to trusted address ranges
- Added basic blacklist handling for obvious brute force attempts

Artifacts:
- Raw exports / work-in-progress config: see `mikrotik/`
- “Gold config” script: `mikrotik/gold-config.rsc`

## 5. Supermicro + Proxmox Build Summary

### 5.1 IPMI
- Verified IPMI/BMC network connectivity
- Confirmed browser-based IPMI and/or KVM access

### 5.2 Proxmox installation
- Installed Proxmox on each host (UEFI/BIOS as applicable)
- Verified web UI reachable on port **8006**
- Confirmed node-to-node reachability and basic cluster readiness

## 6. Validation Checklist

### Network
- [ ] Client on VLAN10 receives DHCP
- [ ] VLAN10 client can ping VLAN20 host
- [ ] VLAN10 client can reach the internet
- [ ] Proxmox UI reachable from LAN/Wi‑Fi network

### VPN
- [ ] VPN connects successfully from external network
- [ ] VPN client receives address from VPN pool
- [ ] VPN client can reach Proxmox UI (8006)
- [ ] VPN client can reach IPMI web UI

### Observability
- [ ] MikroTik logs show successful IPsec SA establishment
- [ ] VPN users authenticate without repeated phase1 parsing errors

## 7. Known Gotchas

- L2TP/IPsec behind NAT requires NAT‑T (UDP 4500) and Windows registry setting:
  `AssumeUDPEncapsulationContextOnSendRule=2`
- If you see “no matching MAC found” for SSH from modern clients, enable newer MACs/ciphers in RouterOS SSH settings (or upgrade RouterOS).
- On CRS, most ports are “slave” to the bridge; NAT/out-interface rules should reference the **bridge** (or a routed VLAN interface), not the physical port.

