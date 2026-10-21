#!/usr/bin/env bash
# Prepare OPS01 comme controleur Ansible.
# A lancer depuis la racine du depot, avec le compte "infra" (pas root) :
#   bash scripts/linux/bootstrap_ops01.sh
set -euo pipefail

if [[ ! -f requirements.yml ]]; then
  echo "Lance ce script depuis la racine du depot infraready." >&2
  exit 1
fi

echo "[1/5] Paquets systeme"
sudo apt-get update -q
sudo apt-get install -y -q git pipx python3-venv shellcheck

echo "[2/5] Ansible et outils de validation (pipx, dans ~/.local/bin)"
pipx ensurepath >/dev/null
export PATH="$HOME/.local/bin:$PATH"
pipx install --include-deps ansible || pipx upgrade --include-injected ansible
pipx inject ansible pywinrm
pipx install ansible-lint || true
pipx install yamllint || true

echo "[3/5] Collections Ansible du projet"
ansible-galaxy collection install -r requirements.yml

echo "[4/5] Cle SSH du compte infra"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -N "" -C "ansible@ops01" -f "$HOME/.ssh/id_ed25519"
fi

echo "[5/5] Versions installees"
ansible --version | head -n 1
ansible-lint --version | head -n 1

cat <<'EOF'

Etapes suivantes :
  1. ssh-copy-id infra@192.168.50.20        (copie la cle vers LINUX01)
  2. ssh-copy-id infra@localhost            (OPS01 se gere lui-meme)
  3. cp inventory/group_vars/all/vault.yml.example inventory/group_vars/all/vault.yml
     puis remplir les valeurs et : ansible-vault encrypt inventory/group_vars/all/vault.yml
  4. Ouvre un nouveau terminal (PATH mis a jour), puis :
     ansible linux -m ansible.builtin.ping --ask-vault-pass
EOF
