# Depannage

Problemes rencontres pendant la mise en place du laboratoire et solutions appliquees.

| Symptome | Cause | Solution |
|----------|-------|----------|
| `Login incorrect` sur la console Ubuntu | clavier QWERTY/AZERTY ou nom d'utilisateur different de celui saisi a l'installation | taper le mot de passe dans le champ `login:` pour voir les caracteres, verifier la disposition, sinon reinitialiser le mot de passe (ci-dessous) |
| Nom d'hote `ops1` au lieu de `ops01` | faute de frappe a l'installation | `sudo hostnamectl set-hostname ops01` puis corriger `/etc/hosts` |
| `Failed unmounting cdrom.mount` en fin d'installation | ISO toujours connectee | Entree, puis decocher "Connecte" sur le CD/DVD de la VM |
| L'installeur se relance au redemarrage | la VM demarre encore sur l'ISO | deconnecter le CD/DVD, redemarrer |
| "Cette machine virtuelle semble etre actuellement utilisee" | VM ouverte dans une autre fenetre VMware | Annuler et utiliser la fenetre deja ouverte |
| `/` ne fait que 10 Go | choix par defaut de l'installeur LVM | `sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv` |
| Copier-coller impossible dans la console VMware | console texte sans VMware Tools graphiques | se connecter en SSH depuis PowerShell : `ssh infra@192.168.50.30` |

## Reinitialiser le mot de passe d'un compte Ubuntu

1. Redemarrer la VM, maintenir **Maj** (ou Echap) pour afficher GRUB.
2. Sur l'entree Ubuntu, touche `e`, ajouter `init=/bin/bash` a la fin de la ligne `linux`, puis `Ctrl+X`.
3. Dans le shell root :

```bash
mount -o remount,rw /
passwd infra
exec /sbin/init
```
