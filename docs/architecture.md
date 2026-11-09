# Architecture

## Schema

```mermaid
flowchart LR
  subgraph HOTE["Poste hote - VMware Workstation"]
    subgraph NAT["VMnet8 (NAT) 192.168.50.0/24 - passerelle 192.168.50.2"]
      DC["WIN-DC01 192.168.50.10<br/>AD DS + DNS infraready.test<br/>windows_exporter :9182"]
      L1["LINUX01 192.168.50.20<br/>nginx :80 - /srv/data LVM<br/>node_exporter :9100"]
      OPS["OPS01 192.168.50.30<br/>Ansible - Git<br/>Prometheus :9090 - Grafana :3000"]
    end
  end
  OPS -- "SSH 22 (Ansible)" --> L1
  OPS -- "WinRM 5985 (Ansible)" --> DC
  OPS -- "scrape 9100" --> L1
  OPS -- "scrape 9182" --> DC
  L1 -- "DNS 53" --> DC
  OPS -- "DNS 53" --> DC
  DC -- "redirecteur DNS" --> GW["Passerelle NAT 192.168.50.2"]
  OPS -. "git push" .-> GH["GitHub + Actions"]
```

## Roles des machines

| Machine  | Services                                   | Gere par                       |
|----------|--------------------------------------------|--------------------------------|
| WIN-DC01 | AD DS, DNS, partage `Commun`, windows_exporter | `playbooks/windows.yml` (role `windows_dc`) |
| LINUX01  | nginx, comptes Linux, LVM `/srv/data`, node_exporter, UFW | `playbooks/linux.yml` |
| OPS01    | Ansible, Prometheus, Grafana, node_exporter, UFW | `playbooks/linux.yml` + `playbooks/monitoring.yml` |

## Ressources des VM

| Machine  | vCPU | RAM | Disques              |
|----------|------|-----|----------------------|
| WIN-DC01 | 2    | 4 Go | 50 Go                |
| LINUX01  | 2    | 2 Go | 30 Go + 5 Go (donnees) |
| OPS01    | 2    | 4 Go | 50 Go                |

## Variante a 2 VM (poste limite en RAM)

Si le poste a 8 Go de RAM, LINUX01 et OPS01 sont fusionnes sur une seule VM Ubuntu
(192.168.50.20). Dans `inventory/hosts.yml`, mettre le meme hote dans `web` et `monitoring`,
et remplacer 192.168.50.30 par 192.168.50.20 dans `lab_controller_ip` et `monitoring/prometheus.yml`.
Limite : un incident sur ce serveur coupe aussi la supervision et l'outil d'administration.

## Etat reel des VM (releve du 08/11/2026)

| Machine  | Creee | Systeme installe | Remarque |
|----------|-------|------------------|----------|
| WIN-DC01 | oui   | Windows Server   | a preparer pour WinRM |
| LINUX01  | oui   | Ubuntu 24.04.5   | 2 vCPU, 2 Go, 30 Go + 5 Go, compte `infra` |
| OPS01    | oui   | Ubuntu 24.04.5   | 20 Go ; nom d'hote a corriger (`ops1` -> `ops01`) |
