#!/usr/bin/env bash
#
# pre-upgrade-checklist.sh
#
# Contexte :
#   Avant de lancer "do-release-upgrade" à distance sur un serveur en
#   production (via SSH, dans une session screen/tmux pour survivre à une
#   déconnexion), il faut s'assurer que rien ne va bloquer l'upgrade ou
#   couper l'accès distant en plein milieu.
#
# Ce que fait le script :
#   - Vérifie la présence d'une route par défaut
#   - Vérifie la résolution DNS
#   - Vérifie l'espace disque disponible sur /
#   - Vérifie qu'aucun service systemd n'est déjà en échec
#   - Vérifie qu'une session screen/tmux est active (recommandé)
#   - Affiche un résumé final GO / NO-GO
#
# Usage :
#   ./pre-upgrade-checklist.sh

set -uo pipefail

PASS=0
FAIL=0

check() {
    local label="$1"
    local status="$2"
    if [[ "$status" -eq 0 ]]; then
        echo "[ OK ] $label"
        PASS=$((PASS+1))
    else
        echo "[FAIL] $label"
        FAIL=$((FAIL+1))
    fi
}

echo "== Checklist pré-upgrade =="
echo

# 1. Route par défaut
ip route show default | grep -q default
check "Route par défaut présente" $?

# 2. Résolution DNS
getent hosts archive.ubuntu.com >/dev/null 2>&1
check "Résolution DNS fonctionnelle (archive.ubuntu.com)" $?

# 3. Espace disque sur /
DISK_FREE_PCT=$(df --output=pcent / | tail -1 | tr -dc '0-9')
if [[ "$DISK_FREE_PCT" -lt 85 ]]; then
    check "Espace disque suffisant sur / (${DISK_FREE_PCT}% utilisé)" 0
else
    check "Espace disque suffisant sur / (${DISK_FREE_PCT}% utilisé, >85%)" 1
fi

# 4. Services en échec
FAILED_UNITS=$(systemctl list-units --state=failed --no-legend | wc -l)
if [[ "$FAILED_UNITS" -eq 0 ]]; then
    check "Aucun service systemd en échec" 0
else
    check "Aucun service systemd en échec ($FAILED_UNITS en échec)" 1
    systemctl list-units --state=failed --no-legend
fi

# 5. Session screen/tmux active
if [[ -n "${STY:-}" || -n "${TMUX:-}" ]]; then
    check "Session screen/tmux active (protection contre coupure SSH)" 0
else
    check "Session screen/tmux active (AUCUNE détectée, risque en cas de coupure SSH)" 1
fi

echo
echo "== Résumé : $PASS OK / $FAIL problème(s) =="

if [[ $FAIL -eq 0 ]]; then
    echo "GO : conditions réunies pour lancer 'sudo do-release-upgrade'."
    exit 0
else
    echo "NO-GO : corriger les points ci-dessus avant de lancer l'upgrade."
    exit 1
fi
