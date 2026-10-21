#!/usr/bin/env python3
"""Controle CI : aucun secret en clair dans le depot.

- tout fichier vault*.yml (hors .example) doit etre chiffre par ansible-vault ;
- aucun fichier de mot de passe vault ni cle privee ne doit etre commite ;
- toute cle "password/secret/token" doit valoir une expression Jinja ({{ ... }})
  ou une valeur technique connue (on_create, always...).
"""
import re
import sys
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
IGNORES = {".git", "collections", "__pycache__", ".cache"}
EXTENSIONS = {".yml", ".yaml", ".j2", ".cfg", ".ini", ".ps1", ".sh"}
CLE_SENSIBLE = re.compile(
    r"^\s*-?\s*([\w.\-]*(password|passwd|secret|token)[\w.\-]*)\s*[:=]\s*(.*)$",
    re.IGNORECASE,
)
VALEURS_AUTORISEES = {
    "", "on_create", "always", "when_changed", "true", "false", "null", "~", "|", ">-", ">",
}
PLACEHOLDER = re.compile(r"^A_REMPLACER")
FICHIERS_INTERDITS = re.compile(r"^(\.vault_pass.*|.*\.pem|id_rsa|id_ed25519)$")
CLE_PRIVEE = re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")


def fichiers():
    for chemin in RACINE.rglob("*"):
        if chemin.is_file() and not IGNORES.intersection(chemin.relative_to(RACINE).parts):
            yield chemin


def main() -> int:
    erreurs = []
    for chemin in fichiers():
        rel = chemin.relative_to(RACINE)
        if FICHIERS_INTERDITS.match(chemin.name):
            erreurs.append(f"{rel} : fichier sensible qui ne doit pas etre commite")
            continue
        try:
            texte = chemin.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        if CLE_PRIVEE.search(texte):
            erreurs.append(f"{rel} : contient une cle privee")
        if chemin.name.startswith("vault") and chemin.suffix in {".yml", ".yaml"}:
            if not texte.startswith("$ANSIBLE_VAULT;"):
                erreurs.append(f"{rel} : fichier vault NON chiffre (ansible-vault encrypt {rel})")
            continue
        if chemin.suffix not in EXTENSIONS or chemin.name == Path(__file__).name:
            continue
        for numero, ligne in enumerate(texte.splitlines(), start=1):
            correspondance = CLE_SENSIBLE.match(ligne)
            if not correspondance:
                continue
            valeur = correspondance.group(3).split(" #")[0].strip().strip("\"'")
            if (
                valeur.startswith("{{")
                or valeur.startswith("$")
                or valeur.lower() in VALEURS_AUTORISEES
                or PLACEHOLDER.match(valeur)
            ):
                continue
            erreurs.append(f"{rel}:{numero} : valeur en clair pour '{correspondance.group(1)}'")

    if erreurs:
        print("Secrets potentiels detectes :")
        for e in erreurs:
            print(f"  - {e}")
        return 1
    print("OK : aucun secret en clair detecte")
    return 0


if __name__ == "__main__":
    sys.exit(main())
