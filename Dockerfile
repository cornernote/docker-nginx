FROM nginx:1.13

# Cleanup nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copy configuration files
COPY files/ /

# Use application path
WORKDIR /app

# Run
ENTRYPOINT ["/run.sh"]