#!/usr/bin/env bash
#
# zabbix-host-bulk-create.sh
#
# Contexte :
#   Créer des dizaines d'hôtes Zabbix à la main dans l'interface web (un par
#   un, en configurant groupe + template + IP à chaque fois) est long et
#   source d'erreurs. Ce script lit un CSV et crée les hôtes via l'API
#   JSON-RPC de Zabbix.
#
# Prérequis :
#   - curl et jq installés
#   - Un utilisateur API Zabbix avec les droits de création d'hôtes
#   - Variables d'environnement ZABBIX_URL, ZABBIX_USER, ZABBIX_PASSWORD
#     (à définir avant d'exécuter le script, ne jamais les coder en dur)
#
# Format du CSV attendu (avec en-tête) :
#   nom,ip,groupe,template
#   pf39,10.88.88.39,Infra Firewall C+B,Template ICMP Ping
#
# Usage :
#   export ZABBIX_URL="http://zabbix.example.com/api_jsonrpc.php"
#   export ZABBIX_USER="admin"
#   export ZABBIX_PASSWORD="motdepasse"
#   ./zabbix-host-bulk-create.sh hosts.csv

set -euo pipefail

CSV_FILE="${1:-}"

if [[ -z "$CSV_FILE" || ! -f "$CSV_FILE" ]]; then
    echo "Usage : $0 fichier.csv"
    exit 1
fi

: "${ZABBIX_URL:?Variable ZABBIX_URL non définie}"
: "${ZABBIX_USER:?Variable ZABBIX_USER non définie}"
: "${ZABBIX_PASSWORD:?Variable ZABBIX_PASSWORD non définie}"

if ! command -v jq >/dev/null 2>&1; then
    echo "ERREUR : jq est requis (sudo apt install jq)."
    exit 1
fi

echo "== Authentification à l'API Zabbix =="
AUTH_TOKEN=$(curl -s -X POST "$ZABBIX_URL" \
    -H 'Content-Type: application/json-rpc' \
    -d @- <<EOF | jq -r '.result'
{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "username": "$ZABBIX_USER",
        "password": "$ZABBIX_PASSWORD"
    },
    "id": 1
}
EOF
)

if [[ -z "$AUTH_TOKEN" || "$AUTH_TOKEN" == "null" ]]; then
    echo "ERREUR : échec de l'authentification à l'API Zabbix."
    exit 1
fi
echo "Authentifié."
echo

get_group_id() {
    local group_name="$1"
    curl -s -X POST "$ZABBIX_URL" \
        -H 'Content-Type: application/json-rpc' \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"filter\":{\"name\":[\"$group_name\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":2}" \
        | jq -r '.result[0].groupid // empty'
}

get_template_id() {
    local template_name="$1"
    curl -s -X POST "$ZABBIX_URL" \
        -H 'Content-Type: application/json-rpc' \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"filter\":{\"host\":[\"$template_name\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":3}" \
        | jq -r '.result[0].templateid // empty'
}

CREATED=0
SKIPPED=0

tail -n +2 "$CSV_FILE" | while IFS=',' read -r NAME IP GROUP TEMPLATE; do
    [[ -z "$NAME" ]] && continue

    GROUP_ID=$(get_group_id "$GROUP")
    TEMPLATE_ID=$(get_template_id "$TEMPLATE")

    if [[ -z "$GROUP_ID" ]]; then
        echo "[SKIP] $NAME : groupe '$GROUP' introuvable."
        continue
    fi
    if [[ -z "$TEMPLATE_ID" ]]; then
        echo "[SKIP] $NAME : template '$TEMPLATE' introuvable."
        continue
    fi

    RESULT=$(curl -s -X POST "$ZABBIX_URL" \
        -H 'Content-Type: application/json-rpc' \
        -d @- <<EOF
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "$NAME",
        "interfaces": [{
            "type": 1,
            "main": 1,
            "useip": 1,
            "ip": "$IP",
            "dns": "",
            "port": "10050"
        }],
        "groups": [{"groupid": "$GROUP_ID"}],
        "templates": [{"templateid": "$TEMPLATE_ID"}]
    },
    "auth": "$AUTH_TOKEN",
    "id": 4
}
EOF
    )

    if echo "$RESULT" | jq -e '.result.hostids' >/dev/null 2>&1; then
        echo "[OK]   $NAME ($IP) créé."
    else
        echo "[FAIL] $NAME : $(echo "$RESULT" | jq -c '.error // .')"
    fi
done

echo
echo "== Terminé. Vérifier dans Zabbix -> Data collection -> Hosts =="
