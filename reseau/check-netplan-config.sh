#!/usr/bin/env bash
#
# check-netplan-config.sh
#
# Contexte :
#   Après avoir corrigé une route par défaut manuellement, il faut la rendre
#   permanente dans Netplan. Appliquer une config incomplète (sans gateway
#   ou sans DNS) sur un serveur distant en SSH peut couper l'accès. Ce script
#   fait une vérification "à sec" avant d'appliquer quoi que ce soit.
#
# Ce que fait le script :
#   1. Vérifie la syntaxe YAML basique du fichier
#   2. Vérifie la présence d'une passerelle (gateway4 ou route table "default")
#   3. Vérifie la présence de serveurs DNS (nameservers)
#   4. Propose d'exécuter "netplan try" (rollback auto si la config casse le réseau)
#
# Usage :
#   ./check-netplan-config.sh /etc/netplan/00-installer-config.yaml

set -euo pipefail

FILE="${1:-}"

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Usage : $0 /chemin/vers/le/fichier.yaml"
    exit 1
fi

echo "== Vérification de $FILE =="
echo

ERRORS=0

echo "-- Vérification syntaxe YAML --"
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import yaml,sys; yaml.safe_load(open('$FILE'))" 2>/tmp/yaml_err; then
        echo "OK : YAML valide."
    else
        echo "ERREUR : YAML invalide."
        cat /tmp/yaml_err
        ERRORS=$((ERRORS+1))
    fi
else
    echo "python3/pyyaml non disponible, vérification syntaxique ignorée."
fi
echo

echo "-- Vérification passerelle --"
if grep -qE "gateway4:|via:" "$FILE"; then
    echo "OK : une passerelle est définie."
else
    echo "ATTENTION : aucune passerelle (gateway4 ou route 'via') trouvée."
    echo "Sans passerelle, le serveur risque de perdre l'accès Internet/SSH distant."
    ERRORS=$((ERRORS+1))
fi
echo

echo "-- Vérification DNS --"
if grep -q "nameservers:" "$FILE"; then
    echo "OK : une section nameservers est présente."
else
    echo "ATTENTION : aucune section nameservers trouvée."
    ERRORS=$((ERRORS+1))
fi
echo

if [[ $ERRORS -gt 0 ]]; then
    echo "== Résultat : $ERRORS problème(s) détecté(s). NE PAS appliquer tel quel. =="
    exit 1
fi

echo "== Résultat : configuration cohérente. =="
echo
read -rp "Lancer 'netplan try' (rollback automatique après 120s sans confirmation) ? [o/N] " CONFIRM
if [[ "$CONFIRM" == "o" || "$CONFIRM" == "O" ]]; then
    sudo netplan try
else
    echo "Pour appliquer manuellement : sudo netplan apply"
fi
