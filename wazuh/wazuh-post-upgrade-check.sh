#!/usr/bin/env bash
#
# wazuh-post-upgrade-check.sh
#
# Contexte :
#   Après une migration d'OS (ex : Ubuntu 18.04 -> 22.04) sur un serveur
#   hébergeant Wazuh Manager, il faut confirmer que le service a survécu à
#   la mise à jour sans réinstallation et que le système est stable.
#
# Ce que fait le script :
#   - Affiche la version de l'OS
#   - Vérifie la route par défaut
#   - Liste les unités systemd en échec
#   - Vérifie le statut du service wazuh-manager
#   - Affiche la version de Wazuh via wazuh-control
#
# Usage :
#   sudo ./wazuh-post-upgrade-check.sh

set -uo pipefail

echo "== Version OS =="
lsb_release -a 2>/dev/null || cat /etc/os-release
echo

echo "== Route par défaut =="
ip route show default
echo

echo "== Unités systemd en échec =="
FAILED=$(systemctl list-units --state=failed --no-legend)
if [[ -z "$FAILED" ]]; then
    echo "Aucune unité en échec. OK."
else
    echo "$FAILED"
fi
echo

echo "== Statut du service wazuh-manager =="
if systemctl is-active --quiet wazuh-manager; then
    echo "wazuh-manager : actif (running)"
else
    echo "ATTENTION : wazuh-manager n'est pas actif !"
    systemctl status wazuh-manager --no-pager || true
fi
echo

echo "== Version Wazuh =="
if [[ -x /var/ossec/bin/wazuh-control ]]; then
    sudo /var/ossec/bin/wazuh-control info
else
    echo "Binaire wazuh-control introuvable à l'emplacement attendu (/var/ossec/bin/)."
fi
echo

echo "== Résumé =="
echo "Pensez à faire un snapshot de la VM une fois le système confirmé stable."
