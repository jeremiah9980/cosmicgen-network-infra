# CosmicGen Network Infrastructure (POC)

This repository documents the design, deployment, and operational model of the
CosmicGen Proof-of-Concept (POC) network and virtualization environment.

The environment provides:
- Segmented VLAN architecture
- Secure remote VPN access (L2TP/IPsec)
- Proxmox-based virtualization hosts
- IPMI-based out-of-band management
- Integration with an Eero gateway as upstream edge device

This repo serves as:
- Architecture documentation
- Operational runbook
- Infrastructure-as-Code (IaC) alignment reference
- Resume / portfolio artifact

---

## 📐 High-Level Architecture

- **Upstream Gateway:** Eero (192.168.0.1/16)
- **Core Network Device:** MikroTik CRS326-24G-2S+
- **Virtualization Platform:** Proxmox VE (3-node cluster)
- **Remote Access:** L2TP/IPsec VPN
- **Management:** IPMI + Proxmox Web UI

---

## 🧱 VLAN & IP Schema

| VLAN | Purpose        | Subnet              | Gateway IP        |
|-----:|---------------|---------------------|-------------------|
| 10   | User LAN       | 192.168.10.0/24     | 192.168.10.1     |
| 20   | Servers        | 192.168.20.0/24     | 192.168.20.1     |
| 30   | Management     | 192.168.30.0/24     | 192.168.30.1     |
| 40   | IoT / Devices  | 192.168.40.0/24     | 192.168.40.1     |
| 50   | Transit / WAN  | 192.168.0.0/16      | 192.168.0.254    |
| VPN  | Remote Access  | 192.168.250.0/24    | 192.168.250.1    |

---

## 🔐 VPN Architecture

- **Protocol:** L2TP over IPsec
- **Authentication:** MS-CHAPv2 + PSK
- **IP Pool:** 192.168.250.0/24
- **DNS:** 192.168.0.1 (Eero)
- **Access Scope:** Full routed access to internal VLANs

### Required Ports (Forwarded on Eero)
| Port | Protocol | Purpose |
|-----:|---------|---------|
| 500  | UDP     | IPsec IKE |
| 4500 | UDP     | IPsec NAT-T |
| 1701 | UDP     | L2TP |

---

## 🖥️ Proxmox Hosts

- 3× Supermicro servers
- Dedicated IPMI interfaces per host
- Proxmox VE installed on each node
- Web access via `https://<host-ip>:8006`

---

## 🔄 NAT & Routing

- Source NAT (masquerade) for all internal VLANs → VLAN50 (Eero)
- Default route via 192.168.0.1
- VPN clients NATed into VLAN50 for upstream internet access

---

## 🛡️ Security Hardening

- Telnet disabled
- WinBox and SSH restricted by subnet
- Brute-force IP blacklisting
- Explicit firewall rules for VPN, Proxmox, and management access

---

## 📂 Repository Structure

```text
.
├── docs/
│   ├── Network-Diagram.png
│   ├── Build-Document.md
│   ├── Runbook.md
│   └── VPN-Setup-Windows.md
├── terraform/
│   ├── proxmox/
│   └── network/
├── ansible/
│   ├── proxmox/
│   └── baseline/
└── scripts/
    └── Install-CosmicGen-VPN.ps1
