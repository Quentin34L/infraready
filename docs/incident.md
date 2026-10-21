# Rapport d'incident

> Modele pre-rempli pour le scenario `disque_plein`. Remplace les sorties par CELLES DE TON LABO
> (copie-colle du terminal ou captures) avant la remise.

| Champ        | Valeur |
|--------------|--------|
| Date / heure | AAAA-MM-JJ HH:MM |
| Machine      | LINUX01 |
| Gravite      | Avertissement (service non interrompu) |
| Detection    | Alerte Prometheus `DisqueLinuxPresquePlein` + panneau Grafana "Stockage" en rouge |
| Provoque par | `ansible-playbook playbooks/incident.yml -e incident_scenario=disque_plein` (exercice controle) |

## 1. Symptome observe

Le panneau "Stockage utilise par volume" passe au-dessus de 80 % pour `linux01 /srv/data`.
Apres 2 minutes, l'alerte `DisqueLinuxPresquePlein` passe a l'etat *firing* dans Prometheus (onglet Alerts).

## 2. Tests et journaux consultes

```bash
df -h /srv/data                       # occupation du volume
sudo du -xh --max-depth=1 /srv/data | sort -h   # quel dossier occupe la place
sudo find /srv/data -xdev -size +100M -exec ls -lh {} \;   # gros fichiers
sudo lvs; sudo vgs                    # place restante dans le groupe de volumes
journalctl -p warning --since "1 hour ago"
```

Sortie a coller ici.

## 3. Cause identifiee

Un fichier de 3,5 Go `incident_remplissage.bin` occupe le volume de donnees de 4 Go.

## 4. Correction appliquee

```bash
sudo rm /srv/data/incident_remplissage.bin
```

Alternative si les donnees etaient legitimes : agrandir le volume avec la place libre du VG
(`sudo lvextend -r -L +0.9G /dev/vg_data/lv_data`) puis reporter la nouvelle taille dans
`storage_lv_size` pour que le playbook reste coherent.

## 5. Verification du retour a la normale

```bash
df -h /srv/data
ansible-playbook playbooks/verification.yml
```

L'alerte repasse a l'etat *inactive* dans Prometheus et le panneau Grafana redevient vert.

## Enseignements

- L'alerte a seuil a permis de detecter le probleme avant la saturation.
- Prevention : surveiller la tendance, definir qui alimente `/srv/data`, prevoir la marge LVM.

---

## Autres scenarios disponibles

| Scenario | Symptome | Diagnostic | Correction |
|----------|----------|------------|------------|
| `nginx_arret` | site injoignable (`curl` : connexion refusee) | `systemctl status nginx`, `journalctl -u nginx` | `sudo systemctl start nginx` ou relancer `playbooks/linux.yml` |
| `dns_incorrect` | `ping win-dc01` echoue depuis LINUX01, verification KO | `getent hosts win-dc01.infraready.test`, `resolvectl query`, `cat /etc/hosts` | supprimer la ligne `# INCIDENT-INFRAREADY` de `/etc/hosts` |
| `exporter_windows_arret` | WIN-DC01 en DOWN dans Grafana, alerte `HoteInjoignable` | page Targets de Prometheus, `Get-Service windows_exporter` | `Start-Service windows_exporter` ou relancer `playbooks/windows.yml` |
