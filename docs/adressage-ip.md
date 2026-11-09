# Plan d'adressage

Reseau : `192.168.50.0/24` sur VMnet8 (NAT VMware). Verifier qu'il n'entre pas en conflit avec le
reseau de l'etablissement (`ipconfig` sur l'hote) avant de l'appliquer.

| Adresse        | Machine              | Configuration            |
|----------------|----------------------|--------------------------|
| 192.168.50.1   | Poste hote (VMnet8)  | automatique VMware       |
| 192.168.50.2   | Passerelle NAT VMware | automatique VMware       |
| 192.168.50.10  | WIN-DC01             | fixe                     |
| 192.168.50.20  | LINUX01              | fixe (netplan)           |
| 192.168.50.30  | OPS01                | fixe (netplan)           |
| 192.168.50.128-254 | DHCP VMware      | non utilise par le labo  |

| Parametre        | Valeur                                   |
|------------------|------------------------------------------|
| Masque           | 255.255.255.0 (/24)                      |
| Passerelle       | 192.168.50.2 (acces Internet pour apt et Windows Update) |
| DNS des serveurs | 192.168.50.10 (WIN-DC01)                 |
| Redirecteur DNS du DC | 192.168.50.2                        |
| Domaine          | infraready.test (NetBIOS INFRAREADY)     |

## Enregistrements DNS (zone infraready.test)

| Nom        | Type  | Valeur                     | Cree par            |
|------------|-------|----------------------------|---------------------|
| win-dc01   | A     | 192.168.50.10              | inscription automatique du DC |
| linux01    | A     | 192.168.50.20              | Ansible             |
| ops01      | A     | 192.168.50.30              | Ansible             |
| web        | CNAME | linux01.infraready.test    | Ansible             |
| grafana    | CNAME | ops01.infraready.test      | Ansible             |
| prometheus | CNAME | ops01.infraready.test      | Ansible             |

Zone inverse `50.168.192.in-addr.arpa` : PTR 10, 20 et 30 (Ansible).

## Flux reseau autorises

| Source  | Destination | Port   | Usage                    |
|---------|-------------|--------|--------------------------|
| OPS01   | WIN-DC01    | 5985/tcp | WinRM (Ansible)        |
| OPS01   | WIN-DC01    | 9182/tcp | windows_exporter       |
| OPS01   | LINUX01     | 9100/tcp | node_exporter          |
| labo    | LINUX01, OPS01 | 22/tcp | SSH                   |
| labo    | LINUX01     | 80/tcp | site web                 |
| labo    | OPS01       | 3000/tcp, 9090/tcp | Grafana, Prometheus |
| labo    | WIN-DC01    | 53, 88, 389, 445... | services AD et DNS (regles Windows du role AD DS) |
| labo    | WIN-DC01    | ICMPv4 echo | ping                |

## Configuration VMware constatee

Releve de l'editeur de reseau virtuel du poste hote (capture `docs/captures/03-reseau-vmnet8.jpg`) :

| Reseau | Type          | DHCP   | Sous-reseau     | Usage                         |
|--------|---------------|--------|-----------------|-------------------------------|
| VMnet1 | Hote uniquement | actif | 192.168.94.0/24 | non utilise par le labo       |
| VMnet8 | NAT           | actif  | 192.168.50.0/24 | reseau du labo (3 VM)         |

A l'installation, OPS01 a recu `192.168.50.130/24` en DHCP : l'adresse fixe `.30` est posee
ensuite (voir [ip-fixes](ip-fixes.md)).
