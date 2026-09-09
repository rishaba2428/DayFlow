#!/bin/sh
set -e

PORT="${PORT:-8080}"
HOST="${BACKEND_HOST:-}"
HOST="${HOST#http://}"
HOST="${HOST#https://}"

use_proxy=1
if [ -z "$HOST" ]; then
  use_proxy=0
fi
# Unresolved Railway placeholders or trailing colon only
if echo "$HOST" | grep -q '[\${]'; then
  use_proxy=0
fi
if echo "$HOST" | grep -q ':$'; then
  use_proxy=0
fi

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

nginx -t
exec nginx -g 'daemon off;'
