#!/bin/bash

# This script is run within the nginx containers on start

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

# Generate nginx config from template
if [ ! -n "$SERVER_NAME" ] ; then
    export SERVER_NAME="app"
fi
if [ -f /etc/nginx/nginx.conf.template ]; then
    if [ ! -n "$NGINX_ERROR_LOG_LEVEL" ] ; then
        export NGINX_ERROR_LOG_LEVEL="warn"
    fi
    if [ ! -n "$NGINX_BASE_PATH" ] ; then
        export NGINX_BASE_PATH="/app"
    fi
    if [ ! -n "$FASTCGI_PASS_HOST" ] ; then
        export FASTCGI_PASS_HOST="127.0.0.1:9000"
    fi
    envsubst '$NGINX_ERROR_LOG_LEVEL $NGINX_BASE_PATH $SERVER_NAME $FASTCGI_PASS_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
fi

# Toggle HTTP
if [ -z "$USE_HTTP" ] ; then
    USE_HTTP=1
fi
if [ "$USE_HTTP" = 1 ] ; then
    log "HTTP is enabled - removing #http;# comments from /etc/nginx/nginx.conf"
    sed -i -r 's/#http;#//g' /etc/nginx/nginx.conf
fi

# Toggle HTTPS
if [ "$USE_HTTPS" = 1 ] ; then
    # Generate dhparam
    if [ ! -n "$DH_SIZE" ] ; then
        DH_SIZE=2048
    fi
    if [ ! -f /etc/dhparam/dhparam.pem ]; then
        log "dhparam file /etc/dhparam/dhparam.pem does not exist"
        openssl dhparam -out /etc/dhparam/dhparam.pem $DH_SIZE || die "Could not generate dhparam file"
    fi
    log "HTTPS is enabled - removing #https;# comments from /etc/nginx/nginx.conf"
    sed -i -r 's/#https;#//g' /etc/nginx/nginx.conf
fi

# Run nginx
log "Starting nginx"
nginx # -g 'daemon off;'

# Check if config or certificates were changed
while inotifywait -q -r --exclude '\.git/' -e modify,create,delete,move,move_self /etc/nginx /etc/letsencrypt; do
  log "Nginx changes detected. Will send reload signal to nginx in 10 seconds..."
  sleep 10
  nginx -s reload && \
  log "Reload signal send"
done
