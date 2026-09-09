#!/bin/sh
set -e

export PORT="${PORT:-80}"
export BACKEND_HOST="${BACKEND_HOST:-backend:8080}"

envsubst '${PORT} ${BACKEND_HOST}' \
  < /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
