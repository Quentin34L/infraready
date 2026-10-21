#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Prepare WIN-DC01 pour etre pilote par Ansible depuis OPS01.
.DESCRIPTION
    A lancer UNE fois, en PowerShell administrateur, sur WIN-DC01 avant le premier playbook.
    - active WinRM (HTTP 5985, authentification Negotiate/NTLM, Basic et non chiffre refuses)
    - limite WinRM a l'adresse d'OPS01 dans le pare-feu
    - autorise le ping depuis le reseau du labo
.EXAMPLE
    Set-ExecutionPolicy -Scope Process Bypass -Force
    .\Enable-WinRM.ps1 -ControllerIP 192.168.50.30 -LabNetwork 192.168.50.0/24
#>
param(
    [string]$ControllerIP = '192.168.50.30',
    [string]$LabNetwork = '192.168.50.0/24'
)
$ErrorActionPreference = 'Stop'

Write-Host '[1/5] Profil reseau en Prive (tant que la machine n est pas dans le domaine)'
Get-NetConnectionProfile |
    Where-Object NetworkCategory -eq 'Public' |
    Set-NetConnectionProfile -NetworkCategory Private

Write-Host '[2/5] Activation de WinRM'
Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null
Set-Service -Name WinRM -StartupType Automatic
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $false
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false

Write-Host '[3/5] Pare-feu : WinRM uniquement depuis OPS01'
Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' -ErrorAction SilentlyContinue | Disable-NetFirewallRule
$winrmRule = 'InfraReady - WinRM depuis OPS01'
if (-not (Get-NetFirewallRule -DisplayName $winrmRule -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $winrmRule -Direction Inbound -Protocol TCP -LocalPort 5985 `
        -RemoteAddress $ControllerIP -Action Allow -Profile Any | Out-Null
}

Write-Host '[4/5] Pare-feu : ping depuis le reseau du labo'
$icmpRule = 'InfraReady - ICMPv4 depuis le labo'
if (-not (Get-NetFirewallRule -DisplayName $icmpRule -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $icmpRule -Direction Inbound -Protocol ICMPv4 -IcmpType 8 `
        -RemoteAddress $LabNetwork -Action Allow -Profile Any | Out-Null
}

Write-Host '[5/5] Verification'
Get-Service WinRM | Format-Table Name, Status, StartType -AutoSize
winrm enumerate winrm/config/Listener
Get-NetFirewallRule -DisplayName $winrmRule | Get-NetFirewallAddressFilter |
    Format-Table @{ n = 'Regle'; e = { $winrmRule } }, RemoteAddress -AutoSize
Write-Host "Termine. Depuis OPS01 : ansible windows -m ansible.windows.win_ping"
