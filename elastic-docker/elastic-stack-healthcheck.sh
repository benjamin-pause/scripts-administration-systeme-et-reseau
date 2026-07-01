#!/usr/bin/env bash
#
# elastic-stack-healthcheck.sh
#
# Contexte :
#   Diagnostiquer une stack Elastic (Elasticsearch, Kibana, Fleet Server)
#   déployée sous Docker Compose implique de vérifier plusieurs conteneurs
#   et plusieurs endpoints API à chaque fois. Ce script centralise ces
#   vérifications, utile après un redémarrage ou en cas de doute sur l'état
#   du Fleet Server (HTTP vs HTTPS notamment).
#
# Ce que fait le script :
#   - Statut des conteneurs Docker (elasticsearch, kibana, fleet-server, logstash)
#   - Dernières lignes de logs de chaque conteneur
#   - Test des endpoints /api/status ou équivalent
#
# Usage :
#   ./elastic-stack-healthcheck.sh [elastic_host] [es_port] [kibana_port] [fleet_port]
#   Exemple :
#   ./elastic-stack-healthcheck.sh localhost 10010 10011 10012

set -uo pipefail

HOST="${1:-localhost}"
ES_PORT="${2:-10010}"
KIBANA_PORT="${3:-10011}"
FLEET_PORT="${4:-10012}"

CONTAINERS=(elasticsearch kibana fleet-server logstash)

echo "== Statut des conteneurs Docker =="
for c in "${CONTAINERS[@]}"; do
    if docker inspect "$c" >/dev/null 2>&1; then
        STATUS=$(docker inspect -f '{{.State.Status}}' "$c")
        echo "$c : $STATUS"
    else
        echo "$c : conteneur introuvable"
    fi
done
echo

echo "== Dernières lignes de logs =="
for c in "${CONTAINERS[@]}"; do
    if docker inspect "$c" >/dev/null 2>&1; then
        echo "--- $c ---"
        docker logs "$c" --tail 5 2>&1
        echo
    fi
done

echo "== Test des endpoints API =="

echo -n "Elasticsearch (http://$HOST:$ES_PORT) : "
if curl -s -o /dev/null -w "%{http_code}" "http://$HOST:$ES_PORT" | grep -qE "200|401"; then
    echo "répond."
else
    echo "NE RÉPOND PAS."
fi

echo -n "Kibana (http://$HOST:$KIBANA_PORT) : "
if curl -s -o /dev/null -w "%{http_code}" "http://$HOST:$KIBANA_PORT" | grep -qE "200|302"; then
    echo "répond."
else
    echo "NE RÉPOND PAS."
fi

echo -n "Fleet Server (https://$HOST:$FLEET_PORT/api/status) : "
FLEET_STATUS=$(curl -k -s "https://$HOST:$FLEET_PORT/api/status" 2>/dev/null | jq -r '.status // empty' 2>/dev/null)
if [[ "$FLEET_STATUS" == "HEALTHY" ]]; then
    echo "HEALTHY."
elif [[ -n "$FLEET_STATUS" ]]; then
    echo "répond mais statut = $FLEET_STATUS"
else
    echo "NE RÉPOND PAS en HTTPS. Test en HTTP..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$HOST:$FLEET_PORT/api/status")
    echo "  -> HTTP : code $HTTP_CODE (si 200, le Fleet Server tourne encore en HTTP, pas en HTTPS)"
fi

echo
echo "== Terminé =="
