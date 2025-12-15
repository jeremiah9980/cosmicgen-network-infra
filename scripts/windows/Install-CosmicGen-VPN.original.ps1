# ================================
# CosmicGen L2TP/IPsec VPN Installer
# ================================

$VpnName      = "CosmicGen-POC"
$Server       = "47.163.25.30"   # Your public IP or DDNS
$PresharedKey = "Kass217799+"    # IPsec PSK
$DnsSuffix    = "cosmicgen.local"

Write-Host "Installing CosmicGen VPN..." -ForegroundColor Cyan

# --- Enable NAT-T for L2TP/IPsec ---
Write-Host "Applying NAT-T registry fix..." -ForegroundColor Yellow
reg add HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent `
    /v AssumeUDPEncapsulationContextOnSendRule `
    /t REG_DWORD /d 2 /f

# --- Remove existing VPN if present ---
if (Get-VpnConnection -Name $VpnName -ErrorAction SilentlyContinue) {
    Write-Host "Existing VPN found. Removing..." -ForegroundColor Yellow
    Remove-VpnConnection -Name $VpnName -Force
}

# --- Create VPN ---
Write-Host "Creating VPN connection..." -ForegroundColor Green
Add-VpnConnection `
    -Name $VpnName `
    -ServerAddress $Server `
    -TunnelType L2tp `
    -L2tpPsk $PresharedKey `
    -AuthenticationMethod MSChapv2 `
    -EncryptionLevel Required `
    -SplitTunneling $false `
    -AllUserConnection `
    -RememberCredential `
    -Force

# --- Optional: Disable IPv6 on VPN ---
Set-VpnConnection `
    -Name $VpnName `
    -AllUserConnection `
    -DisableClassBasedDefaultRoute $false

# --- Restart required services ---
Write-Host "Restarting VPN services..." -ForegroundColor Yellow
Restart-Service RasMan -Force
Restart-Service PolicyAgent -Force

Write-Host ""
Write-Host "✅ CosmicGen VPN installed successfully!" -ForegroundColor Green
Write-Host "➡️ VPN Name: $VpnName"
Write-Host "➡️ Server: $Server"
Write-Host ""
Write-Host "User must now connect and enter their VPN username/password."
