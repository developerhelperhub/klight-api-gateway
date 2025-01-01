Build the image 
```shell
docker build -f docker/Dockerfile -t klight/api-gateway .
```

Run docker compose
```shell
docker-compose up -d
```

Test Application
```shell
#docker run -d -it --name klight-api-gateway -p 8080:8080 -v ${HOME}:/root/ -v ${PWD}:/app -w /app klight/api-gateway
#or following command to login into container if already running the container

docker exec -it klight-api-gateway-service /bin/sh

openresty -g "daemon off;"
```

Check the DNS resolver by looking at /etc/resolv.conf: Inside the container, run:
```shell
cat /etc/resolv.conf
```
You should see something like:
```shell
nameserver 127.0.0.11
```
This indicates that Docker’s internal DNS server is being used.


Test connection of Keycloack endpoint
```shell
curl http://klight-keycloak-service:8084/realms/klight-api-gateway/.well-known/openid-configuration

nslookup klight-keycloak-service
```