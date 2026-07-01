# Réseau

Scripts liés au diagnostic et à la correction de problèmes réseau sur des
serveurs Linux (Ubuntu/Debian avec Netplan), issus d'une migration Ubuntu
18.04 → 22.04 en environnement Wazuh où le serveur avait perdu sa passerelle
par défaut après un changement de configuration réseau.

## Scripts

### `fix-default-gateway.sh`
Diagnostique la table de routage, identifie la vraie passerelle via le cache
ARP si la route par défaut est absente ou incorrecte, et propose de la
corriger. Usage typique : un serveur qui n'arrive plus à résoudre de noms de
domaine (`Temporary failure resolving ...`) alors que l'interface est up.

```bash
sudo ./fix-default-gateway.sh
```

### `check-netplan-config.sh`
Vérifie qu'un fichier de configuration Netplan contient bien une passerelle
(`gateway4` ou route par défaut) et des serveurs DNS avant de l'appliquer.
Évite de se couper l'accès SSH en appliquant une config incomplète.

```bash
./check-netplan-config.sh /etc/netplan/00-installer-config.yaml
```

### `pre-upgrade-checklist.sh`
Liste de vérifications à exécuter avant un `do-release-upgrade` à distance
(via SSH) : route par défaut présente, DNS fonctionnel, espace disque
suffisant, aucun service en échec. Pensé pour éviter de se retrouver bloqué
en plein upgrade sur un serveur distant.

```bash
./pre-upgrade-checklist.sh
```
