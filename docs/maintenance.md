# Procedure de maintenance

## Avant toute maintenance

1. Prevenir les utilisateurs et choisir un creneau.
2. Prendre un snapshot VMware de chaque VM concernee (nom : `avant-maj-AAAAMMJJ`).
3. Verifier l'etat de depart : `ansible-playbook playbooks/verification.yml` (tout doit etre vert).
4. Verifier l'espace disque (le playbook bloque en dessous de 15 % libres sur `/`).
5. Simuler : `ansible-playbook playbooks/maintenance.yml --check`.

## Mises a jour Linux (automatisees)

```bash
ansible-playbook playbooks/maintenance.yml --limit linux01                       # un serveur d'abord
ansible-playbook playbooks/maintenance.yml --limit linux -e maintenance_reboot=true
```

Le playbook traite un serveur a la fois (`serial: 1`), liste les paquets, applique `apt upgrade`
(sans suppression de paquets), indique si un redemarrage est requis, ne redemarre que si
`maintenance_reboot=true` et jamais OPS01 (qui execute Ansible), puis verifie que nginx et
node_exporter tournent.

Les mises a jour de securite automatiques d'Ubuntu (unattended-upgrades) restent actives, sans redemarrage automatique.

## Mises a jour Windows (mecanisme natif Windows Update)

```bash
ansible-playbook playbooks/maintenance.yml --limit windows                                   # liste seulement
ansible-playbook playbooks/maintenance.yml --limit windows -e maintenance_windows_install=true -e maintenance_reboot=true
```

Categories : mises a jour de securite, critiques et cumulatives. Journal : `C:\Temp\win_updates.log`.
Methode manuelle equivalente : Parametres > Windows Update > Rechercher des mises a jour.

## Precautions avant redemarrage

- Le DC est le DNS de tout le labo : pendant son redemarrage, les noms `*.infraready.test` ne resolvent plus.
  Redemarrer le DC en dernier et hors demonstration.
- Ne jamais redemarrer OPS01 pendant un playbook.
- Apres redemarrage, attendre 2 minutes que les services AD demarrent avant de relancer Ansible.

## Apres la maintenance

1. `ansible-playbook playbooks/verification.yml`
2. Verifier le tableau de bord Grafana (tous les hotes UP, aucune alerte).
3. Supprimer le snapshot apres quelques jours sans probleme ; sinon, revenir au snapshot.

## Controles reguliers

| Controle            | Outil                                     | Seuil         |
|---------------------|-------------------------------------------|---------------|
| Espace disque       | Grafana + alerte `DisqueLinuxPresquePlein` / `DisqueWindowsPresquePlein` | 80 % |
| Disponibilite       | alerte `HoteInjoignable`                  | 1 minute      |
| Services            | `playbooks/verification.yml`              | tous actifs   |
| Journaux            | `journalctl -p err -b`, Observateur d'evenements | aucune erreur nouvelle |
