# Zabbix

Scripts liés à l'exploitation d'un serveur Zabbix : mise à jour de version
et création d'hôtes en masse via l'API (plutôt qu'à la main dans
l'interface web, utile quand on doit créer des dizaines d'hôtes pour
plusieurs groupes réseau).

## Scripts

### `zabbix-upgrade.sh`
Automatise la séquence de mise à jour mineure de Zabbix (apt update, upgrade
du paquet zabbix-release, mise à jour des composants, redémarrage des
services) avec vérification de la version avant/après.

```bash
sudo ./zabbix-upgrade.sh
```

### `zabbix-host-bulk-create.sh`
Crée plusieurs hôtes Zabbix d'un coup à partir d'un fichier CSV
(nom, IP, groupe, template) via l'API JSON-RPC de Zabbix. Évite la saisie
manuelle répétitive dans l'interface web pour un grand nombre d'hôtes.

```bash
./zabbix-host-bulk-create.sh hosts.csv
```

Format attendu du CSV (`hosts.csv`) :
```
nom,ip,groupe,template
pf39,10.88.88.39,Infra Firewall C+B,Template ICMP Ping
zen6,10.88.88.106,Infra Proxmox C+B,Proxmox Check
```
