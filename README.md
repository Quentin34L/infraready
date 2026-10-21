# InfraReady

![Validation](../../actions/workflows/validation.yml/badge.svg)

Laboratoire d'administration systemes Linux/Windows : 3 VM configurees par Ansible,
supervisees par Prometheus et Grafana, validees par GitHub Actions.

| Machine  | Systeme                 | IP            | Role                                   |
|----------|-------------------------|---------------|----------------------------------------|
| WIN-DC01 | Windows Server 2025     | 192.168.50.10 | AD DS + DNS `infraready.test`          |
| LINUX01  | Ubuntu Server 24.04 LTS | 192.168.50.20 | nginx, comptes, disque LVM `/srv/data` |
| OPS01    | Ubuntu Server 24.04 LTS | 192.168.50.30 | Ansible, Git, Prometheus, Grafana      |

Details : [architecture](docs/architecture.md) · [adressage IP](docs/adressage-ip.md) ·
[securite](docs/securite.md) · [maintenance](docs/maintenance.md) · [incident](docs/incident.md) ·
[preuves](docs/preuves.md)

## Prerequis

- Les 3 VM installees, IP fixes posees, `scripts/windows/Enable-WinRM.ps1` execute sur WIN-DC01.
- Sur OPS01, depuis la racine du depot : `bash scripts/linux/bootstrap_ops01.sh`
  (installe Ansible via pipx, pywinrm, les collections de `requirements.yml`, une cle SSH).
- Le fichier de secrets cree et chiffre :

```bash
cp inventory/group_vars/all/vault.yml.example inventory/group_vars/all/vault.yml
nano inventory/group_vars/all/vault.yml          # remplacer les A_REMPLACER
ansible-vault encrypt inventory/group_vars/all/vault.yml
# Mot de passe vault hors du depot, pour ne pas le retaper :
echo 'mon-mot-de-passe-vault' > ~/.vault_pass_infraready && chmod 600 ~/.vault_pass_infraready
echo 'export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass_infraready' >> ~/.bashrc && source ~/.bashrc
```

## Utilisation

```bash
ansible linux -m ansible.builtin.ping                 # test SSH
ansible windows -m ansible.windows.win_ping           # test WinRM

ansible-playbook playbooks/windows.yml                # domaine, OU, groupes, comptes, DNS, partage, exporter
ansible-playbook playbooks/linux.yml                  # socle, comptes, nginx, stockage LVM, node_exporter
ansible-playbook playbooks/monitoring.yml             # Prometheus + Grafana
ansible-playbook playbooks/verification.yml           # controles en lecture seule
ansible-playbook playbooks/site.yml                   # tout, dans l'ordre

ansible-playbook playbooks/maintenance.yml --check    # simulation de maintenance
ansible-playbook playbooks/maintenance.yml -e maintenance_reboot=true

ansible-playbook playbooks/incident.yml -e incident_scenario=nginx_arret
bash scripts/linux/collect_preuves.sh                 # preuves dans preuves/<date>/
```

Idempotence : relancer `linux.yml` ou `windows.yml` doit afficher `changed=0` au second passage.

Interfaces : Grafana `http://grafana.infraready.test:3000` (admin / mot de passe du vault),
Prometheus `http://prometheus.infraready.test:9090`.

## Structure

```
inventory/        hotes, variables, secrets chiffres (vault.yml)
playbooks/        linux, windows, monitoring, maintenance, verification, incident, site
roles/            common, linux_accounts, webserver, storage, windows_dc, prometheus, grafana
monitoring/       prometheus.yml, regles d'alerte, tableau de bord Grafana
scripts/          bootstrap OPS01, activation WinRM, collecte de preuves, controle des secrets
docs/             dossier technique au format Markdown
.github/workflows validation automatique a chaque push et pull request
```

## Validation automatique (GitHub Actions)

A chaque push et pull request : controle des secrets, yamllint, syntaxe des playbooks,
ansible-lint (profil production), promtool, JSON des dashboards, shellcheck.
Le runner GitHub n'a pas acces au reseau VMware prive : la CI valide le depot, elle ne deploie pas.

## Limites connues

A completer honnetement avant la remise (fonctionnalites non terminees, raisons, actions pour finir).
