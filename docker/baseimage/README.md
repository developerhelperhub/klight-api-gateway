Check the current version of Alpine you're using:
```shell
cat /etc/alpine-release
```

Update the /etc/apk/repositories file with URLs for a supported version, for example, v3.18. You can use a text editor like vi or nano:
```shell
vi /etc/apk/repositories
```shell

Replace any outdated URLs (like v3.15) with URLs for the latest supported version. For example:
```shell
https://dl-cdn.alpinelinux.org/alpine/v3.18/main
https://dl-cdn.alpinelinux.org/alpine/v3.18/community
```

This installs OpenResty typically into /usr/local/openresty.
```shell
/usr/local/openresty
```

Build the image 
```shell
docker build -t developerhelperhub/openresty-lua1.5 .
```

Test run the application inside container

```shell
docker run -it --name klight-api-gateway -p 8080:8080 --entrypoint /bin/sh -v ${HOME}:/root/ -v ${PWD}:/app -w /app developerhelperhub/openresty-lua1.5

or 



cp nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
cp -r src/ /usr/local/openresty/nginx/myapp

openresty -g daemon\ off\;
```


