# Installation de Windows Server 2025 (WIN-DC01)

## Creation de la VM

- 2 vCPU, 4 Go de RAM, disque 50 Go, carte reseau **NAT (VMnet8)**.
- Edition : Windows Server 2025 Standard **(experience de bureau)**.

## Preparation avant Ansible

Dans PowerShell en administrateur :

```powershell
# Nom de la machine
Rename-Computer -NewName WIN-DC01 -Restart

# IP fixe (adapter le nom de l'interface : Get-NetAdapter)
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.50.10 -PrefixLength 24 -DefaultGateway 192.168.50.2
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 127.0.0.1,192.168.50.2

# Activer WinRM pour Ansible (script du depot)
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\windows\Enable-WinRM.ps1
```

Le role AD DS, le domaine `infraready.test`, les OU, groupes, comptes, DNS et le partage
sont ensuite crees par `ansible-playbook playbooks/windows.yml` depuis OPS01.

## Verifications

```powershell
hostname
Get-NetIPAddress -AddressFamily IPv4 | Format-Table InterfaceAlias,IPAddress
Get-Service WinRM
Test-NetConnection 192.168.50.30 -Port 22
```
