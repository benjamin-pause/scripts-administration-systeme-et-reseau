#!/usr/bin/env bash
#
# zabbix-upgrade.sh
#
# Contexte :
#   Mise à jour mineure d'un serveur Zabbix (ex : 7.4.1 -> 7.4.11) sur
#   Debian/Ubuntu avec Apache et MySQL. Nécessite de mettre à jour le paquet
#   zabbix-release avant de pouvoir upgrader les composants.
#
# Ce que fait le script :
#   1. Affiche la version actuelle
#   2. Met à jour apt et le paquet zabbix-release
#   3. Met à jour tous les composants Zabbix
#   4. Redémarre les services (zabbix-server, zabbix-agent, apache2)
#   5. Confirme la nouvelle version et le statut du service
#
# Usage :
#   sudo ./zabbix-upgrade.sh

set -euo pipefail

echo "== Version actuelle =="
zabbix_server -V | head -1
echo

echo "== Mise à jour des dépôts et du paquet zabbix-release =="
sudo apt update
sudo apt install --only-upgrade -y zabbix-release
sudo apt update

echo
echo "== Mise à jour des composants Zabbix =="
sudo apt install --only-upgrade -y \
    zabbix-agent \
    zabbix-apache-conf \
    zabbix-frontend-php \
    zabbix-server-mysql \
    zabbix-get \
    zabbix-sql-scripts

echo
echo "== Redémarrage des services =="
sudo systemctl restart zabbix-server zabbix-agent apache2

echo
echo "== Vérification post-mise à jour =="
zabbix_server -V | head -1

if systemctl is-active --quiet zabbix-server; then
    echo "zabbix-server : actif (running). OK."
else
    echo "ATTENTION : zabbix-server n'est pas actif !"
    systemctl status zabbix-server --no-pager || true
    exit 1
fi
