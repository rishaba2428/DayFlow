#!/bin/sh
set -e

PORT="${PORT:-8080}"
HOST="${BACKEND_HOST:-}"
HOST="${HOST#http://}"
HOST="${HOST#https://}"

# Invalid / unresolved Railway placeholders â†’ static only
use_proxy=1
case "$HOST" in
  ""|*"$"*|*"{"*|*}"|*":")
    use_proxy=0
    ;;
esac

if [ "$use_proxy" -eq 1 ]; then
  export PORT HOST
  envsubst '${PORT} ${HOST}' \
    < /etc/nginx/dayflow.conf.template \
    > /etc/nginx/conf.d/default.conf
  echo "nginx proxy -> ${HOST}"
else
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
  echo "WARN: BACKEND_HOST invalid ('${HOST}') â€” static only"
fi

# Remove any auto-generated broken configs from nginx image
rm -f /etc/nginx/conf.d/default.conf.bak 2>/dev/null || true

nginx -t
exec nginx -g 'daemon off;'
