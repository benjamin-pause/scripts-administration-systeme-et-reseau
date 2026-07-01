#!/usr/bin/env bash
#
# fleet-agent-enroll.sh
#
# Contexte :
#   L'enrollment d'un Elastic Agent vers un Fleet Server en HTTPS avec
#   certificat auto-signé échoue souvent si on oublie un flag :
#   Kibana refuse toute URL "http://" pour les Fleet Server hosts, et il ne
#   faut jamais utiliser --fleet-server-insecure-http si on veut rester en
#   HTTPS. Ce script encapsule la commande correcte pour éviter l'erreur.
#
# Ce que fait le script :
#   1. Teste la connectivité HTTPS vers le Fleet Server (curl -k)
#   2. Lance l'enrollment de l'agent avec les bons flags
#   3. Vérifie le statut final de l'agent
#
# Usage :
#   sudo ./fleet-agent-enroll.sh <url_fleet_server> <enrollment_token> [chemin_agent]
#   Exemple :
#   sudo ./fleet-agent-enroll.sh https://10.77.112.134:10012 MndTcXlw... /Library/Elastic/Agent

set -euo pipefail

FLEET_URL="${1:-}"
ENROLL_TOKEN="${2:-}"
AGENT_PATH="${3:-/opt/Elastic/Agent}"

if [[ -z "$FLEET_URL" || -z "$ENROLL_TOKEN" ]]; then
    echo "Usage : $0 <url_fleet_server> <enrollment_token> [chemin_agent]"
    echo "Exemple : $0 https://10.77.112.134:10012 <TOKEN> /Library/Elastic/Agent"
    exit 1
fi

STATUS_URL="${FLEET_URL}/api/status"

echo "== Test de connectivité vers $STATUS_URL =="
if curl -k -sf "$STATUS_URL" >/dev/null; then
    echo "OK : Fleet Server joignable."
else
    echo "ERREUR : impossible de joindre $STATUS_URL"
    echo "Vérifier le firewall / que le port est bien exposé publiquement si besoin."
    exit 1
fi

AGENT_BIN="$AGENT_PATH/elastic-agent"
if [[ ! -x "$AGENT_BIN" ]]; then
    echo "ERREUR : binaire elastic-agent introuvable dans $AGENT_PATH"
    echo "Adapter le 3e argument au bon chemin d'installation."
    exit 1
fi

echo
echo "== Enrollment de l'agent =="
sudo "$AGENT_BIN" enroll \
    --url="$FLEET_URL" \
    --enrollment-token="$ENROLL_TOKEN" \
    --insecure \
    --force

echo
echo "== Statut de l'agent après enrollment =="
sudo "$AGENT_BIN" status

echo
echo "Rappel : en cas de changement d'URL Fleet, toujours ré-enroller avec"
echo "--force plutôt que d'éditer fleet.enc à la main."
