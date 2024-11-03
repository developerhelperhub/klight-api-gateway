### Open Mongo SH in Mongo Compass
1. Open the Mongo Compass
2. Click "MongoSH"

### Check connection
```shell
db.serverStatus().connections
```

### Close connection
```shell
db.getMongo().close()
```