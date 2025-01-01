
check app running on port  8081
```shell
lsof -i :8081

COMMAND   PID    USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
nginx   90495 binoykr    6u  IPv4 0x718b25731f7195b9      0t0  TCP *:http-alt (LISTEN)
nginx   90496 binoykr    6u  IPv4 0x718b25731f7195b9      0t0  TCP *:http-alt (LISTEN)
```

check app running on port  443
```shell
netstat -tuln | grep 443
```

install tenlet
```shell
apk update
apk add busybox-extras
busybox-extras telnet 172.20.0.4 8080
```