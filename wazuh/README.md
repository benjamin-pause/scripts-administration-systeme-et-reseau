# Wazuh

Scripts liés à l'exploitation d'un serveur Wazuh (Manager, Indexer,
Dashboard, Filebeat) et à la gestion du Fleet Server / des agents Elastic
déployés en parallèle pour comparaison SIEM.

## Scripts

### `wazuh-post-upgrade-check.sh`
Regroupe les vérifications à effectuer après une migration OS (ex: Ubuntu
18.04 → 22.04) pour s'assurer que Wazuh Manager a survécu à la mise à jour
sans réinstallation : statut du service, version, unités systemd en échec.

```bash
sudo ./wazuh-post-upgrade-check.sh
```

### `fleet-server-cert-renew.sh`
Régénère le certificat auto-signé utilisé par le Fleet Server (Elastic
Agent) et redémarre le conteneur Docker correspondant. Évite de refaire la
commande `openssl req` à la main à chaque expiration.

```bash
./fleet-server-cert-renew.sh siem-01.rlcom.re 10.77.112.134
```

### `fleet-agent-enroll.sh`
Automatise l'enrollment d'un agent Elastic vers un Fleet Server en HTTPS
avec certificat auto-signé, en respectant les règles qui ont posé problème
en pratique (toujours `--insecure` + `--force`, jamais
`--fleet-server-insecure-http` si on veut rester en HTTPS).

```bash
sudo ./fleet-agent-enroll.sh https://10.77.112.134:10012 <ENROLLMENT_TOKEN>
```
