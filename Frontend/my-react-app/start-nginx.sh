#!/bin/sh
set -e

PORT="${PORT:-8080}"
HOST="${BACKEND_HOST:-}"

# Strip scheme if someone pasted a full URL
HOST="${HOST#http://}"
HOST="${HOST#https://}"

# If Railway var didn't resolve (still has $ or {) or empty — serve UI without API proxy
case "$HOST" in
  ""|*"$"*|*"{"*|*}*|*":")
    echo "WARN: BACKEND_HOST missing/invalid ('$HOST') — serving frontend only"
    cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen ${PORT};
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF
    ;;
  *)
    export PORT HOST
    envsubst '${PORT} ${HOST}' \
      < /etc/nginx/templates/default.conf.template \
      > /etc/nginx/conf.d/default.conf
    ;;
esac

echo "Starting nginx on port ${PORT}, backend=${HOST:-none}"
nginx -t
exec nginx -g 'daemon off;'
