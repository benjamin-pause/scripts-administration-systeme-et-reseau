#!/usr/bin/env bash
#
# docker-compose-deploy.sh
#
# Contexte :
#   Déployer la stack Elastic sous Docker Compose échoue souvent si un
#   prérequis a été oublié : certificats absents, fichier .env vide ou avec
#   des placeholders non remplis. Ce script vérifie ces prérequis avant de
#   lancer "docker compose up -d" pour éviter des conteneurs qui crashloop.
#
# Ce que fait le script :
#   1. Vérifie la présence de docker-compose.yml et .env
#   2. Vérifie que les certificats Fleet Server existent
#   3. Vérifie qu'aucune variable du .env n'est restée à sa valeur par défaut
#   4. Lance le déploiement et affiche le statut des conteneurs
#
# Usage :
#   ./docker-compose-deploy.sh /root/elasticsearch

set -euo pipefail

STACK_DIR="${1:-.}"

if [[ ! -f "$STACK_DIR/docker-compose.yml" ]]; then
    echo "ERREUR : docker-compose.yml introuvable dans $STACK_DIR"
    exit 1
fi

if [[ ! -f "$STACK_DIR/.env" ]]; then
    echo "ERREUR : fichier .env introuvable dans $STACK_DIR"
    exit 1
fi

echo "== Vérification des certificats Fleet Server =="
CERT_DIR="$STACK_DIR/certs"
if [[ -f "$CERT_DIR/fleet-server.crt" && -f "$CERT_DIR/fleet-server.key" ]]; then
    echo "OK : certificats présents."
    EXPIRY=$(openssl x509 -enddate -noout -in "$CERT_DIR/fleet-server.crt" | cut -d= -f2)
    echo "Expiration du certificat : $EXPIRY"
else
    echo "ATTENTION : certificats Fleet Server manquants dans $CERT_DIR"
    echo "Le Fleet Server ne démarrera pas correctement en HTTPS."
    read -rp "Continuer quand même ? [o/N] " CONFIRM
    [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]] && exit 1
fi
echo

echo "== Vérification du fichier .env =="
if grep -qE "changeme|VOTRE_MOT_DE_PASSE|CHANGE_ME" "$STACK_DIR/.env"; then
    echo "ATTENTION : le fichier .env contient encore des valeurs par défaut."
    grep -E "changeme|VOTRE_MOT_DE_PASSE|CHANGE_ME" "$STACK_DIR/.env"
    read -rp "Continuer quand même avec ces valeurs par défaut ? [o/N] " CONFIRM
    [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]] && exit 1
else
    echo "OK : aucune valeur par défaut détectée."
fi
echo

echo "== Déploiement de la stack =="
(cd "$STACK_DIR" && docker compose up -d)

echo
echo "== Statut des conteneurs =="
(cd "$STACK_DIR" && docker compose ps)

echo
echo "Pensez à lancer elastic-stack-healthcheck.sh pour vérifier les endpoints."
