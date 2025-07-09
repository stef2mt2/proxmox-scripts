#!/usr/bin/env bash
# ==============================================================================
# Script de mise à jour Proxmox VE
# ==============================================================================
# Auteur    : Votre nom
# Date      : $(date '+%Y-%m-%d')
# Version   : 1.0
# Description : Script automatisé pour mettre à jour Proxmox VE
# ==============================================================================

set -euo pipefail

# Configuration des variables
LOG_FILE="/var/log/proxmox-update.log"
BACKUP_DIR="/var/backups/proxmox-update"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Couleurs pour l'affichage
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0) # No Color

# Fonction de journalisation
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Fonction d'affichage avec couleur
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")  echo -e "${BLUE}[INFO]${NC} $message" ;;
        "OK")    echo -e "${GREEN}[OK]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
    log "$status: $message"
}

# Vérification des privilèges root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "ERROR" "Ce script doit être exécuté en tant que root"
        exit 1
    fi
}

# Vérification de la présence de Proxmox
check_proxmox() {
    if ! command -v pveversion &> /dev/null; then
        print_status "ERROR" "Proxmox VE n'est pas installé sur ce système"
        exit 1
    fi

    local pve_version=$(pveversion --verbose | head -1)
    print_status "INFO" "Version Proxmox détectée : $pve_version"
}

# Création du répertoire de sauvegarde
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_status "OK" "Répertoire de sauvegarde créé : $BACKUP_DIR"
    fi
}

# Sauvegarde des configurations importantes
backup_configs() {
    print_status "INFO" "Sauvegarde des configurations..."

    local backup_file="$BACKUP_DIR/proxmox-configs-$(date +%Y%m%d_%H%M%S).tar.gz"

    tar -czf "$backup_file"         /etc/pve/         /etc/network/interfaces         /etc/apt/sources.list.d/         2>/dev/null || true

    print_status "OK" "Sauvegarde créée : $backup_file"
}

# Configuration des dépôts no-subscription
configure_repositories() {
    print_status "INFO" "Configuration des dépôts no-subscription..."

    # Désactiver les dépôts Enterprise
    if [[ -f /etc/apt/sources.list.d/pve-enterprise.list ]]; then
        sed -i 's/^deb/# deb/' /etc/apt/sources.list.d/pve-enterprise.list
        print_status "OK" "Dépôt pve-enterprise désactivé"
    fi

    if [[ -f /etc/apt/sources.list.d/ceph.list ]]; then
        sed -i 's/^deb https://enterprise.proxmox.com/# deb https://enterprise.proxmox.com/' /etc/apt/sources.list.d/ceph.list
        print_status "OK" "Dépôt ceph enterprise désactivé"
    fi

    # Ajouter le dépôt no-subscription
    local pve_repo_file="/etc/apt/sources.list.d/pve-no-subscription.list"
    local debian_version=$(lsb_release -sc)

    if ! grep -q "pve-no-subscription" "$pve_repo_file" 2>/dev/null; then
        echo "deb http://download.proxmox.com/debian/pve $debian_version pve-no-subscription" > "$pve_repo_file"
        print_status "OK" "Dépôt pve-no-subscription ajouté"
    fi
}

# Mise à jour du système
update_system() {
    print_status "INFO" "Mise à jour du système..."

    # Mise à jour des listes de paquets
    if apt update; then
        print_status "OK" "Listes de paquets mises à jour"
    else
        print_status "ERROR" "Échec de la mise à jour des listes de paquets"
        exit 1
    fi

    # Mise à jour complète
    if apt full-upgrade -y; then
        print_status "OK" "Mise à jour du système terminée"
    else
        print_status "ERROR" "Échec de la mise à jour du système"
        exit 1
    fi

    # Nettoyage
    apt autoremove --purge -y
    apt autoclean
    print_status "OK" "Nettoyage terminé"
}

# Vérification post-mise à jour
post_update_check() {
    print_status "INFO" "Vérification post-mise à jour..."

    # Vérifier les services Proxmox
    local services=("pvestatd" "pvedaemon" "pveproxy" "pve-cluster")

    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            print_status "OK" "Service $service : actif"
        else
            print_status "WARN" "Service $service : inactif"
        fi
    done

    # Afficher la nouvelle version
    local new_version=$(pveversion --verbose | head -1)
    print_status "INFO" "Version après mise à jour : $new_version"
}

# Fonction principale
main() {
    print_status "INFO" "=== Début de la mise à jour Proxmox VE ==="

    check_root
    check_proxmox
    create_backup_dir
    backup_configs
    configure_repositories
    update_system
    post_update_check

    print_status "OK" "=== Mise à jour terminée avec succès ==="
    print_status "INFO" "Log complet disponible : $LOG_FILE"

    # Suggestion de redémarrage si nécessaire
    if [[ -f /var/run/reboot-required ]]; then
        print_status "WARN" "Un redémarrage est recommandé pour finaliser la mise à jour"
        print_status "INFO" "Commande : reboot"
    fi
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
