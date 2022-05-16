# SSL Installation

## Using `certbot`

Create a `cornernote/docker-nginx` application definition:

`cat > docker-compose.yml` (paste from below, then `CTRL+D`)

```yaml
version: '3'
services:
  nginx:
    image: cornernote/nginx
    ports:
      - 80:80
      - 443:443
    environment:
      - SERVER_NAME=example.com
      - USE_HTTP=1
      - USE_HTTPS=0
```

Start the container
    
```shell script
docker-compose up -d
```

Request the certificate by running `certbot` inside the container.

```shell script
docker-compose exec nginx certbot certonly \
    --noninteractive \
    --agree-tos \
    --email info@example.com \
    --webroot --webroot-path /var/letsencrypt \
    -d example.com
```

Update your environment variables to `USE_HTTP=0` and `USE_HTTPS=1`, then restart the container
    
```shell script
docker-compose up -d
```

## Manual Installation

You can easily map your existing SSL certificate into the container.

Create a `cornernote/docker-nginx` application definition:

`cat > docker-compose.yml` (paste from below, then `CTRL+D`)

```yaml
version: '3'
services:
  nginx:
    image: cornernote/nginx
    ports:
      - 80:80
      - 443:443
    environment:
      - SERVER_NAME=example.com
      - USE_HTTP=0
      - USE_HTTPS=1
    volumes:
      - ./build/ssl/key.pem:/etc/letsencrypt/live/example.com/privkey.pem
      - ./build/ssl/cert.pem:/etc/letsencrypt/live/example.com/fullchain.pem
      - ./build/ssl/cert.pem:/etc/letsencrypt/live/example.com/chain.pem
```

Create a self-signed SSL certificate 

```shell script
mkdir -p build/ssl && openssl req -x509 -newkey rsa:4096 -keyout build/ssl/key.pem -out build/ssl/cert.pem -days 365
```

Start the container
    
```shell script
docker-compose up -d
```

