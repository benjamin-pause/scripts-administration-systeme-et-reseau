# Setup-sudo-access-SH#!/bin/bash
# setup_sudo_access.sh
# Installe le paquet sudo si nécessaire et ajoute un utilisateur au groupe sudo
# Usage : sudo ./setup_sudo_access.sh nom_utilisateur

USERNAME="$1"

if [ -z "$USERNAME" ]; then
  echo "Usage : $0 <nom_utilisateur>"
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en root."
  exit 1
fi

if ! id "$USERNAME" &>/dev/null; then
  echo "Erreur : l'utilisateur '$USERNAME' n'existe pas."
  exit 1
fi

echo "[1/2] Vérification de l'installation de sudo..."
if ! command -v sudo &> /dev/null; then
  echo "sudo n'est pas installé, installation en cours..."
  apt update -y
  apt install -y sudo
else
  echo "sudo est déjà installé."
fi

echo "[2/2] Ajout de '$USERNAME' au groupe sudo..."
usermod -aG sudo "$USERNAME"

echo "Terminé. '$USERNAME' peut désormais utiliser sudo (déconnexion/reconnexion nécessaire pour que ça prenne effet)."
