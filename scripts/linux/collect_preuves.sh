#!/usr/bin/env bash
# Rassemble les preuves de fonctionnement dans preuves/<date>/ (a lancer sur OPS01,
# depuis la racine du depot, avec ANSIBLE_VAULT_PASSWORD_FILE defini ou --ask-vault-pass).
set -uo pipefail

dossier="preuves/$(date +%Y-%m-%d_%H%M)"
mkdir -p "$dossier"
echo "Preuves enregistrees dans $dossier"

run() {
  local fichier="$1"; shift
  echo "== $*" | tee "$dossier/$fichier"
  "$@" >>"$dossier/$fichier" 2>&1
  echo "   code retour : $?" | tee -a "$dossier/$fichier"
}

run 01_ping_linux.txt ansible linux -m ansible.builtin.ping
run 02_ping_windows.txt ansible windows -m ansible.windows.win_ping
run 03_dns.txt bash -c "for n in win-dc01 linux01 ops01 grafana; do getent hosts \$n.infraready.test || echo \"\$n : ECHEC\"; done"
run 04_web.txt curl -sS -i http://linux01.infraready.test/health
run 05_prometheus_cibles.txt bash -c "curl -sS http://localhost:9090/api/v1/targets | python3 -m json.tool"
run 06_prometheus_alertes.txt bash -c "curl -sS http://localhost:9090/api/v1/alerts | python3 -m json.tool"
run 07_grafana_sante.txt curl -sS http://localhost:3000/api/health
run 08_verification.txt ansible-playbook playbooks/verification.yml
run 09_idempotence_linux.txt ansible-playbook playbooks/linux.yml
run 10_idempotence_windows.txt ansible-playbook playbooks/windows.yml

echo
echo "Controle d'idempotence (le second passage doit afficher changed=0) :"
grep -h "changed=" "$dossier"/09_*.txt "$dossier"/10_*.txt || true
