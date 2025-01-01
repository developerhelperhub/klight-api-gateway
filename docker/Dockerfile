FROM developerhelperhub/openresty-lua1.5

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY myapp/ /usr/local/openresty/nginx/myapp
COPY config.yaml /usr/local/openresty/nginx/config.yaml
COPY config-security.yaml /usr/local/openresty/nginx/config-security.yaml

EXPOSE 8080

ENTRYPOINT ["openresty", "-g", "daemon off;"]
#ENTRYPOINT [ "/bin/sh" ]