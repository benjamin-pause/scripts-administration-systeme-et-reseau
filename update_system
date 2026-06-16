#!/bin/bash
# update_system.sh
# Met à jour automatiquement un système Debian/Ubuntu (apt update + upgrade)
# Usage : sudo ./update_system.sh

LOG_FILE="/var/log/update_system.log"

echo "=== Mise à jour du système - $(date) ===" | tee -a "$LOG_FILE"

if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en root (sudo)."
  exit 1
fi

echo "[1/3] Mise à jour de la liste des paquets..."
apt update -y >> "$LOG_FILE" 2>&1

echo "[2/3] Mise à niveau des paquets installés..."
apt upgrade -y >> "$LOG_FILE" 2>&1

echo "[3/3] Nettoyage des paquets obsolètes..."
apt autoremove -y >> "$LOG_FILE" 2>&1

echo "Mise à jour terminée. Log disponible dans $LOG_FILE"
