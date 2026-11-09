# Aide-memoire des commandes

## Connexion depuis le poste hote (PowerShell)

```powershell
ssh infra@192.168.50.30   # OPS01
ssh infra@192.168.50.20   # LINUX01
```

## Ansible (sur OPS01, a la racine du depot)

```bash
ansible all --list-hosts
ansible linux -m ansible.builtin.ping
ansible windows -m ansible.windows.win_ping
ansible-playbook playbooks/site.yml --check --diff     # simulation
ansible-playbook playbooks/site.yml                    # deploiement complet
ansible-playbook playbooks/verification.yml            # controles
ansible-vault edit inventory/group_vars/all/vault.yml  # secrets
```

## Diagnostic Linux

```bash
systemctl status nginx prometheus grafana-server node_exporter
journalctl -u nginx --since "1 hour ago"
ss -tlnp
lsblk && df -h
sudo ufw status verbose
```

## Diagnostic Windows (PowerShell)

```powershell
Get-ADDomain
Get-ADUser -Filter * | Select-Object Name,Enabled
Get-DnsServerResourceRecord -ZoneName infraready.test
Get-Service windows_exporter, WinRM, DNS, NTDS
```

## Supervision

- Prometheus : http://prometheus.infraready.test:9090 (Status > Targets)
- Grafana : http://grafana.infraready.test:3000
