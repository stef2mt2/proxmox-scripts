#!/usr/bin/env bash
# ==============================================================================
# Script d'Installation Automatique - Scripts Proxmox
# ==============================================================================
# Description : Télécharge et installe automatiquement les scripts Proxmox
# Utilisation : curl -sSL https://raw.githubusercontent.com/votre-nom/proxmox-scripts/main/install.sh | bash
# ==============================================================================

set -euo pipefail

# Configuration
REPO_URL="hhttps://raw.githubusercontent.com/stef2mt2/proxmox-scripts/refs/heads/scripts/proxmox-update.sh"
INSTALL_DIR="/usr/local/sbin/proxmox-scripts"
LOG_FILE="/var/log/proxmox-scripts-install.log"

# Couleurs pour l'affichage
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)

# Fonction d'affichage
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")  echo -e "${BLUE}[INFO]${NC} $message" ;;
        "OK")    echo -e "${GREEN}[OK]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $status: $message" >> "$LOG_FILE"
}

# Vérification des privilèges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "ERROR" "Ce script doit être exécuté en tant que root"
        exit 1
    fi
}

# Vérification de la connexion Internet
check_internet() {
    if ! ping -c 1 github.com &>/dev/null; then
        print_status "ERROR" "Connexion Internet requise"
        exit 1
    fi
    print_status "OK" "Connexion Internet vérifiée"
}

# Vérification de Proxmox
check_proxmox() {
    if ! command -v pveversion &>/dev/null; then
        print_status "ERROR" "Proxmox VE n'est pas installé"
        exit 1
    fi
    print_status "OK" "Proxmox VE détecté"
}

# Création du répertoire d'installation
create_install_dir() {
    if [[ -d "$INSTALL_DIR" ]]; then
        print_status "WARN" "Répertoire d'installation existe déjà"
        read -p "Voulez-vous continuer ? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "INFO" "Installation annulée"
            exit 0
        fi
        rm -rf "$INSTALL_DIR"
    fi

    mkdir -p "$INSTALL_DIR/scripts"
    mkdir -p "$INSTALL_DIR/docs"
    mkdir -p "$INSTALL_DIR/examples"
    print_status "OK" "Répertoire d'installation créé : $INSTALL_DIR"
}

# Téléchargement des scripts
download_scripts() {
    print_status "INFO" "Téléchargement des scripts..."

    local scripts=(
        "scripts/proxmox-update.sh"
        "scripts/preflight-check.sh"
        "scripts/maintenance.sh"
    )

    for script in "${scripts[@]}"; do
        local url="$REPO_URL/$script"
        local dest="$INSTALL_DIR/$script"

        if wget -q -O "$dest" "$url"; then
            chmod +x "$dest"
            print_status "OK" "Téléchargé : $script"
        else
            print_status "ERROR" "Échec du téléchargement : $script"
        fi
    done
}

# Téléchargement de la documentation
download_docs() {
    print_status "INFO" "Téléchargement de la documentation..."

    local docs=(
        "docs/installation.md"
        "docs/usage.md"
        "examples/cron-example.txt"
    )

    for doc in "${docs[@]}"; do
        local url="$REPO_URL/$doc"
        local dest="$INSTALL_DIR/$doc"

        if wget -q -O "$dest" "$url"; then
            print_status "OK" "Téléchargé : $doc"
        else
            print_status "WARN" "Échec du téléchargement : $doc (optionnel)"
        fi
    done
}

# Création des liens symboliques
create_symlinks() {
    print_status "INFO" "Création des liens symboliques..."

    local main_script="$INSTALL_DIR/scripts/proxmox-update.sh"
    local symlink="/usr/local/bin/proxmox-update"

    if [[ -f "$main_script" ]]; then
        ln -sf "$main_script" "$symlink"
        print_status "OK" "Lien symbolique créé : $symlink"
    fi
}

# Configuration du système
setup_system() {
    print_status "INFO" "Configuration du système..."

    # Créer le répertoire de logs
    mkdir -p /var/log/proxmox-scripts

    # Créer le répertoire de sauvegarde
    mkdir -p /var/backups/proxmox-scripts

    print_status "OK" "Configuration système terminée"
}

# Test d'installation
test_installation() {
    print_status "INFO" "Test de l'installation..."

    if [[ -x "$INSTALL_DIR/scripts/proxmox-update.sh" ]]; then
        print_status "OK" "Script principal installé et exécutable"
    else
        print_status "ERROR" "Script principal non installé correctement"
        exit 1
    fi

    if command -v proxmox-update &>/dev/null; then
        print_status "OK" "Commande proxmox-update disponible"
    else
        print_status "WARN" "Commande proxmox-update non disponible (chemin PATH)"
    fi
}

# Affichage des informations finales
show_final_info() {
    print_status "OK" "Installation terminée avec succès !"

    cat << EOF

=== INFORMATIONS D'INSTALLATION ===

📁 Répertoire d'installation : $INSTALL_DIR
📋 Log d'installation : $LOG_FILE

=== UTILISATION ===

# Mise à jour interactive
sudo $INSTALL_DIR/scripts/proxmox-update.sh

# Mise à jour automatique
sudo $INSTALL_DIR/scripts/proxmox-update.sh --auto

# Ou avec le lien symbolique
sudo proxmox-update

=== DOCUMENTATION ===

# Consulter la documentation
cat $INSTALL_DIR/docs/installation.md
cat $INSTALL_DIR/docs/usage.md

# Exemple de cron
cat $INSTALL_DIR/examples/cron-example.txt

=== DÉSINSTALLATION ===

# Pour désinstaller
sudo rm -rf $INSTALL_DIR
sudo rm -f /usr/local/bin/proxmox-update

EOF
}

# Fonction principale
main() {
    print_status "INFO" "=== Installation des Scripts Proxmox ==="

    check_root
    check_internet
    check_proxmox
    create_install_dir
    download_scripts
    download_docs
    create_symlinks
    setup_system
    test_installation
    show_final_info

    print_status "OK" "Installation terminée !"
}

# Gestion des signaux
trap 'print_status "ERROR" "Installation interrompue"; exit 1' INT TERM

# Exécution
main "$@"
