Build the image 
```shell
docker build -f docker/Dockerfile -t kublight/api-gateway .
```

Create the network for api gateway service
```shell
docker network ls
docker network create api-gateway-network
```

Run docker compose
```shell
docker-compose up -d
```

Test Application
```shell
docker run -d -it --name klight-api-gateway -p 8081:8081 -v ${HOME}:/root/ -v ${PWD}:/app -w /app kublight/api-gateway
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

docker exec -it klight-api-gateway-service ping klight-keycloak-service

nslookup klight-keycloak-service

busybox-extras telnet 172.20.0.4 8080

curl http://klight-keycloak-service:8080/realms/klight-api-gateway/.well-known/openid-configuration
```

Note: Internal keycloak service connection through 8080 port and accessing through 8080 in browser 

Accessing admin http://klight-keycloak-service:8080 we have to configure in the `/etc/hosts`
```shell
127.0.0.1       klight-keycloak-service
```

NoteL 
* https://medium.com/@fingervinicius/easy-running-keycloak-with-docker-compose-b0d7a4ee2358
* https://www.keycloak.org/server/all-config