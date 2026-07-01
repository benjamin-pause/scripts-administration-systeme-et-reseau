# scripts-d-administration-systeme-et-reseau
Petite collection de scripts Bash couvrant des tâches courantes d'administration système et réseau sous Linux, réalisée dans le cadre d'un BTS SIO option SISR.
## Scripts disponibles

### `update_system.sh`
Met à jour automatiquement un système Debian/Ubuntu (`apt update`, `apt upgrade`, `apt autoremove`) et journalise le résultat dans `/var/log/update_system.log`.
```bash
sudo ./update_system.sh
```

### `backup_folder.sh`
Sauvegarde un dossier sous forme d'archive `.tar.gz` horodatée.
```bash
./backup_folder.sh /chemin/dossier /chemin/destination
```

### `check_disk_space.sh`
Vérifie l'espace disque utilisé sur chaque partition montée et alerte si un seuil (80% par défaut) est dépassé.
```bash
./check_disk_space.sh 90
```

### `wifi_manager.sh`
Liste les réseaux Wi-Fi disponibles et permet de s'y connecter via `nmcli` (nécessite NetworkManager).
```bash
./wifi_manager.sh
```

### `create_user.sh`
Crée un nouvel utilisateur Linux avec dossier personnel et shell bash.
```bash
sudo ./create_user.sh nom_utilisateur
```

### `ping_monitor.sh`
Teste la connectivité réseau vers une liste d'hôtes (modifiable dans le script) et enregistre le résultat dans un fichier de log.
```bash
./ping_monitor.sh
```

### `setup_sudo_access.sh`
Installe le paquet `sudo` si nécessaire et ajoute un utilisateur existant au groupe sudo.
```bash
sudo ./setup_sudo_access.sh nom_utilisateur
```

### `update_zabbix.sh`
Met à jour les composants Zabbix (server, frontend, agent) sur une distribution Debian/Ubuntu et redémarre les services associés. Les noms de paquets sont à adapter selon le backend de base de données et le serveur web utilisés.
```bash
sudo ./update_zabbix.sh
```

## Rendre les scripts exécutables

Après clonage du dépôt :
```bash
chmod +x *.sh
```

## Compétences mobilisées

- Scripting Bash (variables, conditions, boucles, gestion d'erreurs)
- Administration système Linux (paquets, utilisateurs, espace disque)
- Configuration réseau (Wi-Fi, tests de connectivité)
- Journalisation et bonnes pratiques de logs
