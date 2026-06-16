#!/bin/bash
# create_user.sh
# Crée un nouvel utilisateur Linux avec dossier personnel et shell bash
# Usage : sudo ./create_user.sh nom_utilisateur

USERNAME="$1"

if [ -z "$USERNAME" ]; then
  echo "Usage : $0 <nom_utilisateur>"
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en root (sudo)."
  exit 1
fi

if id "$USERNAME" &>/dev/null; then
  echo "L'utilisateur '$USERNAME' existe déjà."
  exit 1
fi

useradd -m -s /bin/bash "$USERNAME"
passwd "$USERNAME"

echo "Utilisateur '$USERNAME' créé avec succès."
echo "Dossier personnel : /home/$USERNAME"
