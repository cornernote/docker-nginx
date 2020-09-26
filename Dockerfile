FROM nginx:1.19

# Setup for letsencrypt
RUN apt-get update && \
	apt-get install -y \
	    inotify-tools \
	    openssl \
	    certbot \
	    --no-install-recommends && \
	apt-get -y autoremove && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
VOLUME /etc/dhparam
VOLUME /etc/letsencrypt
VOLUME /var/letsencrypt

# Cleanup nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copy configuration files
COPY files/ /

# Use application path
WORKDIR /app

# Run
ENTRYPOINT ["/run.sh"]
