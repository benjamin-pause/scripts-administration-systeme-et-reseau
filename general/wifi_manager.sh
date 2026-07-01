#!/bin/bash
# wifi_manager.sh
# Liste les réseaux Wi-Fi disponibles et permet de s'y connecter via nmcli
# Usage : ./wifi_manager.sh

if ! command -v nmcli &> /dev/null; then
  echo "nmcli n'est pas installé. Installez NetworkManager pour utiliser ce script."
  exit 1
fi

echo "=== Réseaux Wi-Fi disponibles ==="
nmcli device wifi rescan
nmcli device wifi list

read -p "Nom du réseau (SSID) auquel vous connecter : " SSID
read -s -p "Mot de passe : " WIFI_PASSWORD
echo ""

nmcli device wifi connect "$SSID" password "$WIFI_PASSWORD"

if [ $? -eq 0 ]; then
  echo "Connexion réussie à $SSID."
else
  echo "Échec de la connexion à $SSID."
  exit 1
fi
