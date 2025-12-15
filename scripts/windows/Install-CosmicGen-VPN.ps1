<# 
Install-CosmicGen-VPN.ps1
Creates an L2TP/IPsec (PSK) VPN connection on Windows and applies the NAT-T registry fix.

Run as Administrator.
#>

param(
  [Parameter(Mandatory=$true)]
  [string]$ServerAddress,

  [Parameter(Mandatory=$true)]
  [string]$PresharedKey,

  [Parameter(Mandatory=$true)]
  [string]$ConnectionName,

  [string]$DnsSuffix = "",
  [switch]$AllUsers
)

function Assert-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p  = New-Object Security.Principal.WindowsPrincipal($id)
  if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "ERROR: Access is denied. Re-run PowerShell as Administrator."
    exit 1
  }
}

Assert-Admin

Write-Host "Installing CosmicGen VPN '$ConnectionName' to $ServerAddress ..."

# NAT-T registry fix for L2TP/IPsec behind NAT (required for many home/CGNAT scenarios)
Write-Host "Applying NAT-T registry fix (AssumeUDPEncapsulationContextOnSendRule=2)..."
reg add HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent `
  /v AssumeUDPEncapsulationContextOnSendRule `
  /t REG_DWORD /d 2 /f | Out-Null

# Remove existing connection if present (idempotent)
$existing = Get-VpnConnection -Name $ConnectionName -ErrorAction SilentlyContinue
if ($existing) {
  Write-Host "Existing VPN '$ConnectionName' found; removing so we can recreate cleanly..."
  Remove-VpnConnection -Name $ConnectionName -Force -ErrorAction SilentlyContinue | Out-Null
}

# Create VPN connection
$addParams = @{
  Name              = $ConnectionName
  ServerAddress     = $ServerAddress
  TunnelType        = "L2tp"
  L2tpPsk           = $PresharedKey
  AuthenticationMethod = @("MSChapv2")
  EncryptionLevel   = "Required"
  SplitTunneling    = $false
  RememberCredential = $true
  Force             = $true
}

if ($AllUsers) {
  $addParams["AllUserConnection"] = $true
}

Add-VpnConnection @addParams | Out-Null

# Optional DNS suffix (some orgs prefer this; safe to ignore if not used)
if ($DnsSuffix -and $DnsSuffix.Trim().Length -gt 0) {
  Write-Host "Setting DNS suffix to '$DnsSuffix'..."
  Set-VpnConnection -Name $ConnectionName -DnsSuffix $DnsSuffix -PassThru | Out-Null
}

Write-Host "VPN created."
Write-Host "IMPORTANT: A reboot is sometimes required after the registry change."
Write-Host "Connect via: Settings -> Network & Internet -> VPN -> $ConnectionName"
