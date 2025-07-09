#!/usr/bin/env bash
set -euo pipefail

# Couleurs pour lisibilité
RED=$(tput setaf 1) ; GREEN=$(tput setaf 2) ; NC=$(tput sgr0)

# 1. Lancer seulement en root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}[ERREUR] Exécuter en root${NC}"
  exit 1
fi

# 2. Vérifier la présence de Proxmox
if ! pveversion >/dev/null 2>&1 ; then
  echo -e "${RED}[ERREUR] Proxmox VE non détecté${NC}"
  exit 1
fi

# 3. Test de connectivité
ping -c1 download.proxmox.com >/dev/null || {
  echo -e "${RED}[ERREUR] Pas d’accès Internet${NC}"
  exit 1
}

echo -e "${GREEN}[OK] Pré-requis validés${NC}"
