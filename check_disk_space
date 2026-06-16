#!/bin/bash
# check_disk_space.sh
# Vérifie l'espace disque utilisé sur chaque partition et alerte si un seuil est dépassé
# Usage : ./check_disk_space.sh [seuil_en_pourcentage]

THRESHOLD="${1:-80}"

echo "=== Vérification de l'espace disque (seuil : ${THRESHOLD}%) ==="

df -h --output=target,pcent | tail -n +2 | while read -r line; do
  MOUNT=$(echo "$line" | awk '{print $1}')
  USAGE=$(echo "$line" | awk '{print $2}' | tr -d '%')

  if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "ALERTE : $MOUNT est utilisé à ${USAGE}% (seuil : ${THRESHOLD}%)"
  else
    echo "OK : $MOUNT utilisé à ${USAGE}%"
  fi
done
