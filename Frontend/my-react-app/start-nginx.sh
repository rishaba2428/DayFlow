#!/bin/sh
set -e

CONF=/etc/nginx/conf.d/default.conf
cp /etc/nginx/nginx.default.conf "$CONF"

HOST="${BACKEND_HOST:-}"
HOST="${HOST#http://}"
HOST="${HOST#https://}"

if [ -n "$HOST" ] && ! echo "$HOST" | grep -q '[\${]' && ! echo "$HOST" | grep -q ':$'; then
  sed -i "s|BACKEND_PLACEHOLDER|${HOST}|g" "$CONF"
  echo "API proxy -> ${HOST}"
else
  # Remove API proxy block so bad upstream cannot break boot
  sed -i '/location \/api\//,/^    }/d' "$CONF"
  echo "WARN: no valid BACKEND_HOST â€” UI only"
fi

nginx -t
exec nginx -g 'daemon off;'
