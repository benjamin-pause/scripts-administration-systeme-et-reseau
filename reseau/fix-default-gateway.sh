#!/usr/bin/env bash
#
# fix-default-gateway.sh
#
# Contexte :
#   Rencontré lors d'une migration Ubuntu 18.04 -> 22.04 sur un serveur Wazuh
#   en production (accès distant via SSH). La route par défaut était absente
#   ou pointait sur l'IP du serveur lui-même, provoquant des erreurs du type
#   "Temporary failure resolving 'archive.ubuntu.com'" alors que
#   l'interface réseau était fonctionnelle.
#
# Ce que fait le script :
#   1. Affiche la route par défaut actuelle (si elle existe)
#   2. Identifie la passerelle probable via le cache ARP (arp -a)
#   3. Propose de remplacer la route par défaut par la bonne passerelle
#   4. Effectue un test de connectivité (DNS) après correction
#
# Usage :
#   sudo ./fix-default-gateway.sh [interface]
#   Exemple : sudo ./fix-default-gateway.sh ens18
#
# Remarque :
#   Ce script corrige la route de manière temporaire (jusqu'au reboot).
#   Pour une correction permanente, éditer le fichier Netplan correspondant
#   (voir check-netplan-config.sh dans ce même dossier).

set -euo pipefail

IFACE="${1:-}"

if [[ -z "$IFACE" ]]; then
    IFACE=$(ip route show | awk '/default/ {print $5; exit}')
    if [[ -z "$IFACE" ]]; then
        IFACE=$(ip -o link show | awk -F': ' '$2 != "lo" {print $2; exit}')
    fi
fi

echo "== Interface ciblée : $IFACE =="
echo

echo "== Route par défaut actuelle =="
ip route show default || echo "Aucune route par défaut trouvée."
echo

echo "== Passerelles candidates détectées via ARP =="
CANDIDATE_GW=$(arp -a 2>/dev/null | awk -v ifc="$IFACE" '$0 ~ ifc {print $2}' | tr -d '()' | head -n1)

if [[ -z "$CANDIDATE_GW" ]]; then
    echo "Aucune entrée ARP claire trouvée pour $IFACE."
    echo "Table ARP complète pour information :"
    arp -a || true
    read -rp "Entrez manuellement l'adresse IP de la passerelle : " CANDIDATE_GW
else
    echo "Passerelle probable détectée : $CANDIDATE_GW"
fi

echo
read -rp "Appliquer la route par défaut via $CANDIDATE_GW sur $IFACE ? [o/N] " CONFIRM
if [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]]; then
    echo "Annulé. Aucune modification effectuée."
    exit 0
fi

echo "== Application de la nouvelle route =="
sudo ip route del default 2>/dev/null || true
sudo ip route add default via "$CANDIDATE_GW" dev "$IFACE"

echo
echo "== Nouvelle route par défaut =="
ip route show default

echo
echo "== Test de résolution DNS =="
if getent hosts archive.ubuntu.com >/dev/null 2>&1; then
    echo "OK : résolution DNS fonctionnelle."
else
    echo "ATTENTION : la résolution DNS échoue toujours."
    echo "Vérifier /etc/resolv.conf ou la configuration Netplan (DNS)."
fi

echo
echo "Rappel : cette correction n'est PAS persistante après reboot."
echo "Pour la rendre permanente, mettre à jour le fichier Netplan avec :"
echo "  gateway4: $CANDIDATE_GW"
echo "puis exécuter : sudo netplan apply"
