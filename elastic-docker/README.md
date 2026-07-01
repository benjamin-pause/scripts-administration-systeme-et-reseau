# Elastic Stack sous Docker

Scripts liés au déploiement et à la supervision d'une stack Elastic
(Elasticsearch, Kibana, Fleet Server, Logstash) déployée via Docker Compose,
dans le cadre d'un projet de comparaison avec OpenSearch.

## Scripts

### `elastic-stack-healthcheck.sh`
Vérifie en une seule commande l'état de tous les composants de la stack :
statut des conteneurs Docker, dernières lignes de logs, et réponse de
l'API `/api/status` pour Elasticsearch, Kibana et Fleet Server.

```bash
./elastic-stack-healthcheck.sh
```

### `docker-compose-deploy.sh`
Déploie la stack avec `docker compose up -d` après avoir vérifié les
prérequis (certificats présents, fichier `.env` rempli) pour éviter un
démarrage avec une configuration incomplète.

```bash
./docker-compose-deploy.sh /root/elasticsearch
```
