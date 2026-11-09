# Installation d'Ubuntu Server 24.04 (LINUX01 et OPS01)

Image : `ubuntu-24.04-live-server-amd64.iso`. Meme procedure pour les deux VM,
seuls le nom du serveur et les ressources changent (voir [architecture](architecture.md)).

## Creation de la VM dans VMware Workstation

1. Fichier > Nouvelle machine virtuelle > Typique, ISO Ubuntu Server.
2. Ressources : 2 vCPU, 2 Go (LINUX01) ou 4 Go (OPS01) de RAM.
3. Carte reseau : **NAT (VMnet8)**.
4. LINUX01 uniquement : ajouter un second disque SCSI de 5 Go (stockage LVM `/srv/data`).

## Ecrans de l'installeur

| Ecran            | Choix                                                        |
|------------------|--------------------------------------------------------------|
| Langue / clavier | Francais, disposition `French` (variante simple, pas legacy) |
| Type             | Ubuntu Server (pas la version minimisee)                     |
| Reseau           | DHCP (l'IP fixe est posee apres, voir [ip-fixes](ip-fixes.md)) |
| Proxy / miroir   | par defaut                                                   |
| Stockage         | disque entier avec LVM                                       |
| Profil           | nom `infra`, serveur `linux01` ou `ops01`, utilisateur `infra` |
| Ubuntu Pro       | ignorer                                                      |
| SSH              | **cocher "Installer le serveur OpenSSH"** (indispensable a Ansible) |
| Snaps            | aucun (Prometheus et Grafana sont installes par Ansible)     |

A la fin : "Redemarrer maintenant", puis Entree au message `Please remove the installation medium`.
Deconnecter ensuite le lecteur CD/DVD dans les parametres de la VM.

## Apres l'installation

```bash
hostnamectl --static          # doit afficher linux01 ou ops01
ip -br a                      # adresse DHCP en 192.168.50.x
systemctl is-active ssh       # active
# Etendre / sur tout le groupe de volumes (l'installeur ne prend que 10 Go par defaut)
sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
df -h /
```
