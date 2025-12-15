# CosmicGen-POC-SW1 — "Gold Config" (RouterOS 6.49.x)
# CRS326-24G-2S+
# NOTE: review and adjust IPs/ports/VLAN membership to match your physical cabling.

########################################
# BRIDGE + VLANs
########################################
/interface bridge
add name=bridge vlan-filtering=yes protocol-mode=rstp comment="CosmicGen bridge (VLAN-aware)"

/interface vlan
add interface=bridge name=vlan10 vlan-id=10 comment="VLAN10 LAN"
add interface=bridge name=vlan20 vlan-id=20 comment="VLAN20 Servers"
add interface=bridge name=vlan30 vlan-id=30 comment="VLAN30 Mgmt"
add interface=bridge name=vlan40 vlan-id=40 comment="VLAN40 IoT"
add interface=bridge name=vlan50 vlan-id=50 comment="VLAN50 Uplink (Eero)"

/interface bridge port
# Uplink to Eero (untagged VLAN50)
add bridge=bridge interface=ether1  pvid=50 comment="UPLINK -> Eero"
# Access ports VLAN10 (2-10)
:for i from=2 to=10 do={ /interface bridge port add bridge=bridge interface=("ether".$i) pvid=10 comment=("VLAN10 access ether".$i) }
# Access ports VLAN50 (11-15) for devices that must sit on Eero-side subnet
:for i from=11 to=15 do={ /interface bridge port add bridge=bridge interface=("ether".$i) pvid=50 comment=("VLAN50 access ether".$i) }

# Add remaining ports as needed:
# /interface bridge port add bridge=bridge interface=ether16 pvid=10

/interface bridge vlan
# Tagged membership includes "bridge" itself so CPU/Router sees VLANs.
add bridge=bridge vlan-ids=10 tagged=bridge untagged=ether2,ether3,ether4,ether5,ether6,ether7,ether8,ether9,ether10
add bridge=bridge vlan-ids=20 tagged=bridge
add bridge=bridge vlan-ids=30 tagged=bridge
add bridge=bridge vlan-ids=40 tagged=bridge
add bridge=bridge vlan-ids=50 tagged=bridge untagged=ether1,ether11,ether12,ether13,ether14,ether15

########################################
# IP addressing + routing
########################################
/ip address
add address=192.168.0.254/16 interface=vlan50 comment="Uplink SVI (Eero-side)"
add address=192.168.10.1/24 interface=vlan10 comment="VLAN10 GW"
add address=192.168.20.1/24 interface=vlan20 comment="VLAN20 GW"
add address=192.168.30.1/24 interface=vlan30 comment="VLAN30 GW"
add address=192.168.40.1/24 interface=vlan40 comment="VLAN40 GW"

/ip route
# Default route points to Eero gateway
add dst-address=0.0.0.0/0 gateway=192.168.0.1 distance=1 comment="Default -> Eero"

########################################
# DHCP servers (internal VLANs)
########################################
/ip pool
add name=pool_vlan10 ranges=192.168.10.50-192.168.10.200
add name=pool_vlan20 ranges=192.168.20.50-192.168.20.200
add name=pool_vlan30 ranges=192.168.30.50-192.168.30.200
add name=pool_vlan40 ranges=192.168.40.50-192.168.40.200

/ip dhcp-server
add name=dhcp_vlan10 interface=vlan10 address-pool=pool_vlan10 lease-time=8h disabled=no
add name=dhcp_vlan20 interface=vlan20 address-pool=pool_vlan20 lease-time=8h disabled=no
add name=dhcp_vlan30 interface=vlan30 address-pool=pool_vlan30 lease-time=8h disabled=no
add name=dhcp_vlan40 interface=vlan40 address-pool=pool_vlan40 lease-time=8h disabled=no

/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=192.168.0.1,1.1.1.1
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=192.168.0.1,1.1.1.1
add address=192.168.30.0/24 gateway=192.168.30.1 dns-server=192.168.0.1,1.1.1.1
add address=192.168.40.0/24 gateway=192.168.40.1 dns-server=192.168.0.1,1.1.1.1

########################################
# VPN (L2TP over IPsec)
########################################
/ip pool
add name=vpn-pool ranges=192.168.250.100-192.168.250.200

/ppp profile
add name=vnp-profile local-address=192.168.250.1 remote-address=vpn-pool dns-server=192.168.0.1 use-encryption=yes

/interface l2tp-server server
set enabled=yes default-profile=vnp-profile authentication=mschap2 use-ipsec=yes ipsec-secret="CHANGE_ME_PSK" max-mtu=1450 max-mru=1450

# Example user (add others in Runbook)
# /ppp secret add name="Jeremiah" service=l2tp password="CHANGE_ME" profile=vnp-profile comment="CosmicGen - Jeremiah"

########################################
# Firewall + NAT
########################################
/ip firewall filter
# Management (tighten to your admin IPs where possible)
add chain=input action=accept protocol=tcp dst-port=8291 src-address=192.168.0.0/16 comment="Allow WinBox from LAN"
add chain=input action=accept protocol=tcp dst-port=22   src-address=192.168.0.0/16 comment="Allow SSH from LAN"

# VPN ports
add chain=input action=accept protocol=udp dst-port=500,4500,1701 comment="Allow L2TP/IPsec (IKE/NAT-T/L2TP)"
add chain=input action=accept protocol=ipsec-esp comment="Allow IPsec ESP"

# Allow established/related
add chain=input action=accept connection-state=established,related comment="Allow established/related"

# Drop everything else to the router
add chain=input action=drop comment="Drop other input"

# Forwarding rules (example: allow VPN to reach VLANs)
add chain=forward action=accept src-address=192.168.250.0/24 comment="Allow VPN clients forward"
add chain=forward action=accept connection-state=established,related comment="Allow established/related forward"
# (Optional) You can add explicit allow rules per VLAN if you want tighter control.

# NAT internal VLANs and VPN pool out to the uplink SVI (vlan50)
/ip firewall nat
add chain=srcnat action=masquerade out-interface=vlan50 src-address=192.168.10.0/24 comment="NAT VLAN10 -> Eero"
add chain=srcnat action=masquerade out-interface=vlan50 src-address=192.168.20.0/24 comment="NAT VLAN20 -> Eero"
add chain=srcnat action=masquerade out-interface=vlan50 src-address=192.168.30.0/24 comment="NAT VLAN30 -> Eero"
add chain=srcnat action=masquerade out-interface=vlan50 src-address=192.168.40.0/24 comment="NAT VLAN40 -> Eero"
add chain=srcnat action=masquerade out-interface=vlan50 src-address=192.168.250.0/24 comment="NAT VPN -> Eero"

########################################
# Services hardening
########################################
/ip service
set telnet disabled=yes
set ftp disabled=yes
# tighten WinBox/SSH further if you have a fixed admin subnet:
set winbox address=192.168.0.0/16
set ssh address=192.168.0.0/16

