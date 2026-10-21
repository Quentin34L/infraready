# Securite et gestion des acces

## Secrets

- Aucun mot de passe dans Git en clair : ils sont dans `inventory/group_vars/all/vault.yml`,
  chiffre avec Ansible Vault (AES256). Le modele `vault.yml.example` ne contient que des valeurs factices.
- Le mot de passe du vault est hors du depot (`~/.vault_pass_infraready`, droits 600).
- La CI execute `scripts/check_secrets.py` : elle echoue si un fichier vault est en clair,
  si une cle privee ou un fichier de mot de passe est commite, ou si une cle `password` a une valeur litterale.
- Les modules qui manipulent un mot de passe le masquent dans la sortie (`no_log` ou option protegee).

## Moindre privilege

| Compte / groupe        | Droits accordes                                  | Justification |
|------------------------|--------------------------------------------------|---------------|
| `infra` (Linux)        | sudo avec mot de passe                           | compte d'administration utilise par Ansible |
| `webadmin` (Linux)     | ecriture sur `/srv/www/infraready` et `/srv/data` ; sudo limite a `systemctl reload/restart/status nginx` et `nginx -t` | gerer le site sans etre root |
| `auditeurs` + `adm` (Linux) | lecture des journaux, aucune ecriture       | audit sans modification |
| `GRP-Admins-Infra` (AD) | aucun droit d'administration du domaine par defaut | a deleguer au besoin, pas de membre de Domain Admins |
| `GRP-Utilisateurs` (AD) | Modification sur `C:\Partages\Commun` (NTFS + partage) | travail collaboratif |
| `GRP-Support` (AD)     | Lecture sur `C:\Partages\Commun`                  | consultation |

## Surface reseau

- UFW sur les serveurs Ubuntu : entrant refuse par defaut, ouverture par port et par source (voir `docs/adressage-ip.md`).
- node_exporter (9100) et windows_exporter (9182) ne sont joignables que depuis OPS01.
- WinRM n'est joignable que depuis OPS01 ; authentification NTLM avec chiffrement des messages,
  Basic et trafic non chiffre refuses.
- SSH : connexion root interdite, 3 tentatives maximum ; authentification par mot de passe a desactiver
  (`common_ssh_disable_password_auth: true`) une fois les cles en place.

## Regles d'intervention

- Travail uniquement sur les 3 VM du projet, aucun scan ni modification de systemes externes.
- Snapshot VMware avant chaque changement important (promotion AD, disque, maintenance).
- Verification de la cible avant partitionnement : le role `storage` refuse un disque partitionne ou utilise.
- Playbooks testes avec `--check` et `--limit` avant d'etre joues sur toutes les machines.

## Ameliorations possibles

- WinRM en HTTPS (5986) avec certificat, ou authentification Kerberos.
- Cles SSH seules, sans mot de passe.
- Centralisation des journaux (Loki + Grafana Alloy).
