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
if [ ! -f /etc/nginx/dhparam/dhparam.pem ]; then
    echo "dhparam file /etc/nginx/dhparam/dhparam.pem does not exist. Generating one with $DH_SIZE bit. This will take a while..."
    openssl dhparam -out /etc/nginx/dhparam/dhparam.pem $DH_SIZE || die "Could not generate dhparam file"
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