## Building Images

Build image:

```
docker-compose build
```

Tag image:

```
docker tag f89c1b3046c8 cornernote/nginx:1.21
```

Push to hub.docker.com:

```
docker login
docker push cornernote/nginx:1.21
```

## Shell into Image

```
docker-compose run --rm nginx bash
```


## Usage Example

### `docker-compose.yml`

```
version: '3'
services:

  nginx:
    image: cornernote/nginx:1.21
    volumes:
      - ./nginx.conf.template:/nginx.conf.template
      - ./web:/app/web
    environment:
      - USE_HTTP=1
      - USE_HTTPS=0
      # see https://certbot-dns-cloudflare.readthedocs.io/en/stable/
      - SSL_CLOUDFLARE_EMAIL=0123456789abcdef0123456789abcdef01234567
      - SSL_CLOUDFLARE_API_KEY=0123456789abcdef0123456789abcdef01234567
      #or token#- SSL_CLOUDFLARE_TOKEN=0123456789abcdef0123456789abcdef01234567
      - SSL_EMAIL=info@example.com
      - SSL_DOMAIN=example.com
      - DH_SIZE=2048
      - NGINX_ERROR_LOG_LEVEL=warn
      - NGINX_BASE_PATH=/app
      - SERVER_NAME=example.com
      - FASTCGI_PASS_HOST=127.0.0.1:9000
    ports:
      - 80:80
      - 443:443
```
