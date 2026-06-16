#!/bin/bash
# ping_monitor.sh
# Vérifie la connectivité réseau vers une liste d'hôtes et enregistre le résultat
# Usage : ./ping_monitor.sh

HOSTS=("8.8.8.8" "1.1.1.1" "google.com")
LOG_FILE="ping_monitor.log"

echo "=== Test de connectivité - $(date) ===" | tee -a "$LOG_FILE"

for HOST in "${HOSTS[@]}"; do
  if ping -c 2 -W 2 "$HOST" &> /dev/null; then
    echo "OK : $HOST est accessible" | tee -a "$LOG_FILE"
  else
    echo "ECHEC : $HOST est inaccessible" | tee -a "$LOG_FILE"
  fi
done
