# Pose des IP fixes

Plan complet : [adressage IP](adressage-ip.md). Passerelle et DNS de secours : `192.168.50.2`
(NAT VMware). Une fois le domaine cree, le DNS des serveurs Linux devient `192.168.50.10`.

## Ubuntu (netplan) - LINUX01 et OPS01

Verifier le nom de l'interface avec `ip -br a` (ici `ens33`), puis :

```bash
sudo tee /etc/netplan/50-infraready.yaml > /dev/null <<'NETPLAN'
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses: [192.168.50.20/24]   # 192.168.50.30/24 sur OPS01
      routes:
        - to: default
          via: 192.168.50.2
      nameservers:
        addresses: [192.168.50.10, 192.168.50.2]
        search: [infraready.test]
NETPLAN
sudo chmod 600 /etc/netplan/50-infraready.yaml
sudo rm -f /etc/netplan/50-cloud-init.yaml
sudo netplan apply
ip -br a && ip route
```

## Windows - WIN-DC01

Voir [installation Windows](installation-windows.md) (`New-NetIPAddress`).

## Controle croise

```bash
ping -c2 192.168.50.10 && ping -c2 192.168.50.20 && ping -c2 192.168.50.30
```
