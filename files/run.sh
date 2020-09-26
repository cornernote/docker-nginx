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

# Generate certificates
if [ ! -n "$DH_SIZE" ] ; then
    DH_SIZE=2048
fi
if [ ! -f /etc/dhparam/dhparam.pem ]; then
    log "dhparam file /etc/dhparam/dhparam.pem does not exist"
    openssl dhparam -out /etc/dhparam/dhparam.pem $DH_SIZE || die "Could not generate dhparam file"
fi

# Generate nginx config from template
envsubst '$ERROR_LOG_LEVEL $SERVER_NAME $FASTCGI_PASS_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Toggle SSL
if [ "$USE_SSL" = true ] ; then
    log "SSL is enabled, uncommenting nginx.conf"
    sed -i -r 's/#?;#//g' /etc/nginx/nginx.conf
else
    log "SSL is disabled, commenting nginx.conf"
    sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/nginx.conf
fi

# Run nginx
nginx # -g 'daemon off;'

# Check if config or certificates were changed
while inotifywait -q -r --exclude '\.git/' -e modify,create,delete,move,move_self /etc/nginx /etc/letsencrypt; do
  log "Configuration changes detected. Will send reload signal to nginx in 60 seconds..."
  sleep 60
  nginx -s reload && log "Reload signal send"
done