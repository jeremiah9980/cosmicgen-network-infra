# CosmicGen PoC Runbook (Handoff)

## 1. Day-2 Operations

### 1.1 Check switch health
```routeros
/system resource print
/interface bridge port print
/interface bridge vlan print
/ip address print
/ip route print
```

### 1.2 Check DHCP
```routeros
/ip dhcp-server print
/ip dhcp-server lease print
/ip dhcp-server network print
```

### 1.3 Check VPN (L2TP/IPsec)
```routeros
/interface l2tp-server server print
/ppp profile print detail where name="vnp-profile"
/ppp secret print
/ip ipsec active-peers print
/ip ipsec installed-sa print
/log print where topics~"ipsec|l2tp|ppp"
```

## 2. Common Tasks

### 2.1 Add a new VPN user
```routeros
/ppp secret add name="USERNAME" service=l2tp password="STRONG_PASSWORD" profile=vnp-profile comment="CosmicGen - USERNAME"
```

### 2.2 Remove a VPN user
```routeros
/ppp secret print
/ppp secret remove [find name="USERNAME"]
```

### 2.3 Reset a VPN user password
```routeros
/ppp secret set [find name="USERNAME"] password="NEW_STRONG_PASSWORD"
```

### 2.4 List connected hosts (ARP)
```routeros
/ip arp print
/ip arp print where interface=vlan10
/ip arp print where interface=vlan20
/ip arp print where interface=vlan50
```

### 2.5 Show “who is using DHCP” (leases)
```routeros
/ip dhcp-server lease print detail
```

## 3. Troubleshooting

### 3.1 VPN connects but can’t reach VLANs
- Confirm routes exist on MikroTik for VLANs (connected routes via SVIs)
- Confirm **forward chain** permits traffic between VPN pool and VLAN interfaces
- Ensure NAT is correct (often: masquerade VPN pool out the uplink/bridge)
- Validate MSS/MTU (L2TP commonly needs 1450-ish MTU)

### 3.2 IPsec phase1 errors (“wrong password”)
- PSK mismatch between client and MikroTik
- Client is not using the correct VPN type (must be **L2TP/IPsec with PSK**)
- Multiple devices behind NAT re-using ports; try reconnecting on a clean network

### 3.3 Can ping but cannot open web UI (Proxmox/IPMI)
- Ping proves L3; web failure usually means:
  - service not listening
  - firewall block (server-side or MikroTik forward chain)
  - wrong port (Proxmox: 8006; IPMI: usually 80/443 depending on vendor)
- From a client, test:
  - `Test-NetConnection <ip> -Port 8006`
  - `Test-NetConnection <ip> -Port 443`

### 3.4 Bruteforce login attempts
- Keep Telnet disabled.
- Restrict WinBox/SSH management to trusted address ranges.
- Maintain an address-list + drop rules for offenders.

## 4. Change Control

Before major changes:
1. Export current config:
   ```routeros
   /export file=prechange
   ```
2. Download backup:
   ```routeros
   /system backup save name=prechange
   ```
3. Apply changes in small increments.

