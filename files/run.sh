#!/bin/bash

# functions
function die {
    echo >&2 "$@"
    exit 1
}
log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

# Fail on any error
set -o errexit

# Example of using environment variable in configuration at runtime
if [ ! -n "$NGINX_ERROR_LOG_LEVEL" ] ; then
    NGINX_ERROR_LOG_LEVEL="warn"
fi
sed -i "s|\${NGINX_ERROR_LOG_LEVEL}|${NGINX_ERROR_LOG_LEVEL}|" /etc/nginx/nginx.conf

if [ ! -n "$SERVER_NAME" ] ; then
    SERVER_NAME="app"
fi
sed -i "s|\${SERVER_NAME}|${SERVER_NAME}|" /etc/nginx/nginx.conf

if [ ! -n "$FASTCGI_PASS_HOST" ] ; then
    FASTCGI_PASS_HOST="php"
fi
sed -i "s|\${FASTCGI_PASS_HOST}|${FASTCGI_PASS_HOST}|" /etc/nginx/nginx.conf

# Generate certificates
if [ ! -f /etc/nginx/dhparam/dhparam.pem ]; then
    echo "dhparam file /etc/nginx/dhparam/dhparam.pem does not exist. Generating one with 4086 bit. This will take a while..."
    openssl dhparam -out /etc/nginx/dhparam/dhparam.pem 4096 || die "Could not generate dhparam file"
    echo "Finished. Starting nginx now..."
fi

# Run nginx
#nginx -g 'daemon off;'
nginx

# Check if config or certificates were changed
while inotifywait -q -r --exclude '\.git/' -e modify,create,delete,move,move_self /etc/nginx /etc/letsencrypt; do
  log "Configuration changes detected. Will send reload signal to nginx in 60 seconds..."
  sleep 60
  nginx -s reload && log "Reload signal send"
done