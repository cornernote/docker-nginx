# Nginx Configuration

The file `/etc/nginx/nginx.conf` is generated from `/etc/nginx/nginx.conf.template`.

You can overwrite it as follows:

```yaml
version: '3'
services:
  php:
    image: cornernote/nginx
    volumes:
      - ./build/nginx.conf.template:/etc/nginx/nginx.conf.template
    ports:
      - 80:80 
```

During start-up the following variables will be replaced by environment variables in `nginx.conf.template`:

* `${SERVER_NAME}`
* `${NGINX_BASE_PATH}`
* `${FASTCGI_PASS_HOST}`
* If you have set `USE_HTTP=1` then the string `#http;#` will be removed.
* If you have set `USE_HTTPS=1` then the string `#https;#` will be removed.

To copy the initial configuration, start the container without a volume for `/etc/nginx/nginx.conf.template`, then run:

```shell script
docker cp root_nginx_1:/etc/nginx/nginx.conf.template build/nginx.conf.template
```