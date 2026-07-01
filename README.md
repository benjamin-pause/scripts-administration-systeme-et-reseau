# scripts-administration-systeme-et-reseau

Petite collection de scripts Bash couvrant des tâches courantes
d'administration système et réseau sous Linux, réalisée dans le cadre d'un
BTS SIO option SISR. Une partie des scripts a été développée pendant mon
stage chez RLCom (La Réunion), pour répondre à des problèmes réels
rencontrés en intervention (migration de serveurs, supervision Wazuh/Zabbix,
déploiement Elastic Stack sous Docker).

## Organisation

| Dossier | Contenu |
|---|---|
| [`general/`](./general) | Scripts génériques d'administration Linux (mises à jour, sauvegardes, utilisateurs, monitoring) |
| [`reseau/`](./reseau) | Diagnostic et correction réseau (routage, Netplan, pré-checks de migration) |
| [`wazuh/`](./wazuh) | Vérification post-migration Wazuh, gestion des certificats Fleet Server, enrollment d'agents |
| [`zabbix/`](./zabbix) | Mise à jour de version, création d'hôtes en masse via l'API |
| [`elastic-docker/`](./elastic-docker) | Healthcheck et déploiement d'une stack Elastic sous Docker Compose |

Chaque dossier a son propre `README.md` avec le détail des scripts qu'il contient.

## Rendre les scripts exécutables

Après clonage du dépôt :

```bash
chmod +x general/*.sh reseau/*.sh wazuh/*.sh zabbix/*.sh elastic-docker/*.sh
```

## Compétences mobilisées

- Scripting Bash (variables, conditions, boucles, gestion d'erreurs)
- Administration système Linux (paquets, utilisateurs, espace disque, systemd)
- Configuration et diagnostic réseau (routage, DNS, Netplan, Wi-Fi)
- Supervision et SIEM (Wazuh, Zabbix, Elastic Stack)
- Conteneurisation (Docker, Docker Compose)
- Utilisation d'API REST (Zabbix API, Elasticsearch/Fleet API)
- Journalisation et bonnes pratiques (logs, gestion d'erreurs, vérifications avant action)

## Avertissement

Les identifiants, tokens et mots de passe visibles dans les exemples de
commande (`VOTRE_MOT_DE_PASSE`, `VOTRE_TOKEN_ICI`, etc.) sont des
placeholders. Aucun secret réel n'est présent dans ce dépôt.

## Auteur

Benjamin PAUSE — BTS SIO option SISR, Lycée Pierre Poivre (Le Tampon)
Stage réalisé chez RLCom, La Réunion.
