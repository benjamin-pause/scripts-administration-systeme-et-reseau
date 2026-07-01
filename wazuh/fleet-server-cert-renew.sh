#!/usr/bin/env bash
#
# fleet-server-cert-renew.sh
#
# Contexte :
#   Le Fleet Server (Elastic Agent) utilise un certificat auto-signé pour
#   exposer son API en HTTPS. Ce certificat expire (généré avec -days 365)
#   et doit être régénéré puis rechargé par le conteneur Docker sans casser
#   les agents déjà enrollés.
#
# Ce que fait le script :
#   1. Sauvegarde l'ancien certificat/clé (au cas où)
#   2. Génère un nouveau certificat auto-signé avec le bon Subject
#      Alternative Name (DNS + IPs)
#   3. Applique les permissions correctes
#   4. Redémarre le conteneur fleet-server
#
# Usage :
#   ./fleet-server-cert-renew.sh <domaine> <ip_serveur> [chemin_certs]
#   Exemple :
#   ./fleet-server-cert-renew.sh siem-01.rlcom.re 10.77.112.134 /root/elasticsearch/certs

set -euo pipefail

DOMAIN="${1:-}"
SERVER_IP="${2:-}"
CERT_DIR="${3:-/root/elasticsearch/certs}"

if [[ -z "$DOMAIN" || -z "$SERVER_IP" ]]; then
    echo "Usage : $0 <domaine> <ip_serveur> [chemin_certs]"
    echo "Exemple : $0 siem-01.rlcom.re 10.77.112.134 /root/elasticsearch/certs"
    exit 1
fi

KEY_FILE="$CERT_DIR/fleet-server.key"
CRT_FILE="$CERT_DIR/fleet-server.crt"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$CERT_DIR"

if [[ -f "$KEY_FILE" || -f "$CRT_FILE" ]]; then
    echo "== Sauvegarde des anciens certificats =="
    [[ -f "$KEY_FILE" ]] && cp "$KEY_FILE" "$KEY_FILE.bak.$TIMESTAMP"
    [[ -f "$CRT_FILE" ]] && cp "$CRT_FILE" "$CRT_FILE.bak.$TIMESTAMP"
    echo "Sauvegarde effectuée avec le suffixe .bak.$TIMESTAMP"
fi

echo "== Génération du nouveau certificat =="
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CRT_FILE" \
    -subj "/CN=$DOMAIN" \
    -addext "subjectAltName=DNS:$DOMAIN,IP:$SERVER_IP,IP:127.0.0.1"

chmod 644 "$KEY_FILE" "$CRT_FILE"

echo
echo "== Vérification du certificat généré =="
openssl x509 -in "$CRT_FILE" -text -noout | grep -A2 "Subject Alternative"

echo
read -rp "Redémarrer le conteneur Docker 'fleet-server' maintenant ? [o/N] " CONFIRM
if [[ "$CONFIRM" == "o" || "$CONFIRM" == "O" ]]; then
    docker restart fleet-server
    echo "Conteneur fleet-server redémarré."
    echo "Pensez à vérifier : docker exec fleet-server elastic-agent status"
else
    echo "N'oubliez pas de redémarrer manuellement : docker restart fleet-server"
fi
