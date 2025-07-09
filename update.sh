#!/usr/bin/env bash
set -euo pipefail
LOG=/var/log/proxmox-update.log
exec &> >(tee -a "$LOG")

source ./preflight.sh   # quitte si pré-requis KO

echo "==== $(date '+%F %T') Début de mise à jour ===="

# 1. Désactiver les dépôts Enterprise s’ils existent
sed -i 's|^deb https://enterprise.proxmox.com|#&|' \
  /etc/apt/sources.list.d/pve-enterprise.list 2>/dev/null || true
sed -i 's|^deb https://enterprise.proxmox.com|#&|' \
  /etc/apt/sources.list.d/ceph.list 2>/dev/null || true

# 2. Activer le dépôt no-subscription si absent
NS_FILE=/etc/apt/sources.list.d/pve-install-repo.list
if ! grep -q 'pve-no-subscription' "$NS_FILE" 2>/dev/null; then
  echo "deb http://download.proxmox.com/debian/pve $(lsb_release -sc) pve-no-subscription" \
    > "$NS_FILE"
fi

# 3. Mettre à jour les paquets
apt update
apt full-upgrade -y

# 4. Nettoyage
apt autoremove --purge -y
apt clean

echo "==== Fin $(date '+%F %T') ===="
