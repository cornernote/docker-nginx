# Building Images

Build images:

```
docker-compose build
```

List images:

```
docker images
```

Tag image:

```
docker tag XXX cornernote/nginx:1.13-ssl
```

Push to hub.docker.com:

```
docker login
docker push cornernote/nginx:1.13-ssl
```
