#!/bin/bash
# backup_folder.sh
# Sauvegarde un dossier sous forme d'archive compressée horodatée
# Usage : ./backup_folder.sh /chemin/dossier /chemin/destination

SOURCE_DIR="$1"
DEST_DIR="$2"

if [ -z "$SOURCE_DIR" ] || [ -z "$DEST_DIR" ]; then
  echo "Usage : $0 <dossier_source> <dossier_destination>"
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Erreur : le dossier source '$SOURCE_DIR' n'existe pas."
  exit 1
fi

mkdir -p "$DEST_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="backup_$(basename "$SOURCE_DIR")_$TIMESTAMP.tar.gz"

tar -czf "$DEST_DIR/$ARCHIVE_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

if [ $? -eq 0 ]; then
  echo "Sauvegarde réussie : $DEST_DIR/$ARCHIVE_NAME"
else
  echo "Erreur lors de la sauvegarde."
  exit 1
fi
