#!/bin/bash
# DNS/deploy/deploy.sh <SITE> — lance CoreDNS pour ce site sur ce serveur.
# Suppose que generate-config.sh a déjà été exécuté pour ce SITE (ou que
# add_new_dc.sh à la racine du projet l'a fait pour vous).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SITE="${1:?usage: ./deploy.sh <site>}"
[ -f "sites/${SITE}/.env" ] || { echo "sites/${SITE}/.env introuvable — lancez d'abord generate-config.sh --site ${SITE} ..." >&2; exit 1; }

docker compose -f docker-compose.prod.yml --env-file "sites/${SITE}/.env" up -d --build
echo "[deploy] dns-${SITE} démarré."
