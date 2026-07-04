#!/bin/bash
# DNS/deploy/generate-config.sh — génère la config d'un site pour un
# déploiement réel (serveur dédié, pas le banc de test mono-hôte).
#
# L'image coredns/coredns est distroless (pas de shell), donc le templating
# `${ETCD_URL}`/`${DOMAIN}` ne peut pas se faire à l'intérieur du conteneur
# (pas d'envsubst possible au démarrage, cf. Corefile.tpl) : il se fait ici,
# côté hôte de déploiement, AVANT de lancer `docker compose`.
#
# Usage:
#   ./generate-config.sh --site grenoble --etcd-url http://10.10.1.5:2379 [--domain securepulse.fr]
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SITE=""
ETCD_URL=""
DOMAIN="securepulse.fr"

while [ $# -gt 0 ]; do
    case "$1" in
        --site) SITE="$2"; shift 2 ;;
        --etcd-url) ETCD_URL="$2"; shift 2 ;;
        --domain) DOMAIN="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

[ -n "$SITE" ] || { echo "--site is required" >&2; exit 1; }
[ -n "$ETCD_URL" ] || { echo "--etcd-url is required (etcd endpoint reachable from this DC, e.g. http://10.10.1.5:2379)" >&2; exit 1; }

OUT_DIR="sites/${SITE}"
mkdir -p "$OUT_DIR"

DOMAIN="$DOMAIN" ETCD_URL="$ETCD_URL" envsubst '${DOMAIN} ${ETCD_URL}' < ../Corefile.tpl > "${OUT_DIR}/Corefile"

cat > "${OUT_DIR}/.env" <<EOF
SITE=${SITE}
DOMAIN=${DOMAIN}
ETCD_URL=${ETCD_URL}
EOF

echo "[generate-config] écrit ${OUT_DIR}/Corefile et ${OUT_DIR}/.env"
echo "[generate-config] déploiement : ./deploy.sh ${SITE}"
