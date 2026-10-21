# Preuves de fonctionnement

`bash scripts/linux/collect_preuves.sh` enregistre les sorties texte dans `preuves/<date>/`.
Les captures d'ecran sont a ranger dans `docs/captures/`.

| # | Preuve | Comment l'obtenir | Fait |
|---|--------|-------------------|------|
| 1 | VM demarrees | capture VMware avec les 3 VM allumees | [ ] |
| 2 | IP et noms | `ip -br a` + `hostnamectl` (Linux), `ipconfig /all` (Windows) | [ ] |
| 3 | Connectivite | `ping` entre les 3 machines | [ ] |
| 4 | DNS | `nslookup linux01.infraready.test 192.168.50.10`, `getent hosts`, zone inverse | [ ] |
| 5 | Domaine AD | capture "Utilisateurs et ordinateurs Active Directory" (OU, groupes, comptes) | [ ] |
| 6 | Journaux Windows | Observateur d'evenements : journal "Directory Service" et "System" | [ ] |
| 7 | Service web | `curl -i http://web.infraready.test` | [ ] |
| 8 | Permissions Linux | `ls -ld /srv/www/infraready /srv/data`, `sudo -l -U lmartin` | [ ] |
| 9 | Stockage | `lsblk`, `df -h /srv/data`, `grep srv/data /etc/fstab` | [ ] |
| 10 | Ansible | sortie de `linux.yml` et `windows.yml` | [ ] |
| 11 | Idempotence | second passage avec `changed=0` | [ ] |
| 12 | Maintenance | sortie de `maintenance.yml` | [ ] |
| 13 | Prometheus | page Status > Targets toutes UP | [ ] |
| 14 | Grafana | tableau de bord "InfraReady - Etat des serveurs" | [ ] |
| 15 | Alerte | alerte *firing* dans Prometheus pendant l'incident | [ ] |
| 16 | GitHub Actions | onglet Actions avec un workflow vert | [ ] |
| 17 | Incident | sorties du rapport `docs/incident.md` | [ ] |
