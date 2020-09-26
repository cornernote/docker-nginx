## Building Images

Build image:

```
docker-compose build
```

Tag image:

```
docker tag 8adb3c16bb5b cornernote/nginx:1.19
```

Push to hub.docker.com:

```
docker login
docker push cornernote/nginx:1.19
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
    image: cornernote/nginx:1.19
    volumes:
      - ./nginx.conf.template:/nginx.conf.template
      - ./web:/app/web
    environment:
      - USE_SSL=0
      - DH_SIZE=2048
      - ERROR_LOG_LEVEL=warn
      - SERVER_NAME=example.com
      - FASTCGI_PASS_HOST=127.0.0.1:9000
    ports:
      - 80:80
      - 443:443
```
