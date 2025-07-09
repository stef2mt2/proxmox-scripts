# proxmox-scripts
scripts de maj proxmox
# 🔧 Scripts de Mise à Jour Proxmox VE

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/votre-nom/proxmox-scripts/releases)

## 📋 Description

Collection de scripts automatisés pour la maintenance et mise à jour de Proxmox Virtual Environment (VE). Ces scripts résolvent les problèmes courants comme les erreurs "401 Unauthorized" lors des mises à jour et automatisent les tâches de maintenance.

## ✨ Fonctionnalités

- ✅ **Configuration automatique** des dépôts no-subscription
- ✅ **Désactivation** des dépôts Enterprise (résout les erreurs 401)
- ✅ **Sauvegarde** automatique des configurations
- ✅ **Mise à jour** complète du système
- ✅ **Vérifications** post-mise à jour
- ✅ **Journalisation** détaillée
- ✅ **Mode interactif** et automatique

## 🚀 Installation Rapide

```bash
# Télécharger le script principal
wget https://raw.githubusercontent.com/votre-nom/proxmox-scripts/main/scripts/proxmox-update.sh

# Rendre le script exécutable
chmod +x proxmox-update.sh

# Exécuter la mise à jour
sudo ./proxmox-update.sh
```

## 📁 Structure du Projet

```
proxmox-scripts/
├── README.md                 # Ce fichier
├── LICENSE                   # Licence MIT
├── scripts/
│   ├── proxmox-update.sh    # Script principal de mise à jour
│   ├── preflight-check.sh   # Vérifications préalables
│   └── maintenance.sh       # Scripts de maintenance
├── docs/
│   ├── installation.md      # Guide d'installation détaillé
│   └── troubleshooting.md   # Guide de dépannage
├── examples/
│   └── cron-example.txt     # Exemple de tâche cron
└── tests/
    └── test-update.sh       # Tests unitaires
```

## 🔧 Utilisation

### 1. Utilisation Basique

```bash
# Mise à jour interactive
sudo ./proxmox-update.sh

# Mise à jour automatique (sans interaction)
sudo ./proxmox-update.sh --auto
```

### 2. Vérifications Préalables

```bash
# Vérifier l'environnement avant mise à jour
sudo ./scripts/preflight-check.sh
```

### 3. Automatisation avec Cron

```bash
# Éditer le crontab
sudo crontab -e

# Ajouter une tâche hebdomadaire (dimanche à 2h)
0 2 * * 0 /path/to/proxmox-update.sh --auto >> /var/log/proxmox-cron.log 2>&1
```

## 🛡️ Problèmes Résolus

### Erreur 401 Unauthorized

**Avant :**
```
Err:9 https://enterprise.proxmox.com/debian/ceph-quincy bookworm InRelease
401 Unauthorized [IP: 51.91.38.34 443]
```

**Après :**
```
✅ Dépôts no-subscription configurés
✅ Mise à jour terminée avec succès
```

### Configuration Manuelle vs Automatique

| Tâche | Manuel | Avec Script |
|-------|---------|-------------|
| Désactiver dépôts Enterprise | ⏱️ 5 min | ✅ Automatique |
| Configurer no-subscription | ⏱️ 3 min | ✅ Automatique |
| Sauvegarde configs | ⏱️ 10 min | ✅ Automatique |
| Mise à jour système | ⏱️ 15 min | ✅ Automatique |
| Vérifications post-update | ⏱️ 5 min | ✅ Automatique |

## 📖 Documentation

- [📥 Guide d'Installation](docs/installation.md)
- [🔧 Guide d'Utilisation](docs/usage.md)
- [🚨 Dépannage](docs/troubleshooting.md)
- [📝 Changelog](CHANGELOG.md)

## 🔍 Exemples d'Utilisation

### Environnement de Test

```bash
# Vérifier sans appliquer les changements
sudo ./proxmox-update.sh --dry-run
```

### Environnement de Production

```bash
# Mise à jour avec notifications
sudo ./proxmox-update.sh --auto --notify-email admin@example.com
```

### Avec Intégration Monitoring

```bash
# Mise à jour avec webhook Discord/Slack
sudo ./proxmox-update.sh --auto --webhook-url https://discord.com/api/webhooks/...
```

## 🚨 Prérequis

- **OS** : Debian 11 (Bullseye) ou Debian 12 (Bookworm)
- **Proxmox** : Version 7.x ou 8.x
- **Privilèges** : Root ou sudo
- **Connexion** : Accès Internet requis
- **Espace** : 500 MB libres minimum

## ⚠️ Avertissements

- 🔒 **Toujours** tester en environnement de développement d'abord
- 💾 **Créer** une sauvegarde complète avant la première utilisation
- 📋 **Vérifier** les logs après chaque exécution
- 🔄 **Redémarrer** si recommandé par le script

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. **Fork** le projet
2. **Créer** une branche pour votre fonctionnalité
3. **Commiter** vos changements
4. **Pousser** vers la branche
5. **Ouvrir** une Pull Request

### Développement Local

```bash
# Cloner le projet
git clone https://github.com/votre-nom/proxmox-scripts.git
cd proxmox-scripts

# Installer les dépendances de développement
sudo apt install shellcheck bats

# Exécuter les tests
./tests/run-tests.sh
```

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🆘 Support

- 🐛 **Issues** : [GitHub Issues](https://github.com/votre-nom/proxmox-scripts/issues)
- 💬 **Discussions** : [GitHub Discussions](https://github.com/votre-nom/proxmox-scripts/discussions)
- 📧 **Email** : support@votredomaine.com

## 📊 Statistiques

- ⭐ **GitHub Stars** : ![GitHub Repo stars](https://img.shields.io/github/stars/votre-nom/proxmox-scripts?style=social)
- 🍴 **Forks** : ![GitHub forks](https://img.shields.io/github/forks/votre-nom/proxmox-scripts?style=social)
- 📥 **Downloads** : ![GitHub all releases](https://img.shields.io/github/downloads/votre-nom/proxmox-scripts/total)

## 🎯 Roadmap

- [ ] Support Proxmox 9.x
- [ ] Interface web de gestion
- [ ] Support clusters multi-nœuds
- [ ] Intégration Ansible
- [ ] Support conteneurs LXC
- [ ] Métriques Prometheus

---

⭐ **Ce projet vous aide ?** N'hésitez pas à lui donner une étoile !

📢 **Restez informé** des mises à jour en "watchant" le dépôt
