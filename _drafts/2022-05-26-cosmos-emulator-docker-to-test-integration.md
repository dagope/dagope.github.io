
# link de interes
https://www.aaron-powell.com/posts/2021-05-27-local-dev-with-cosmosdb-and-devcontainers/
https://github.com/Azure/azure-cosmos-db-emulator-docker
https://docs.microsoft.com/en-us/azure/cosmos-db/linux-emulator?tabs=sql-api%2Cssl-netstd21
https://github.com/dotnet/Docker.DotNet
https://superuser.com/questions/1506440/import-certificates-using-command-line-on-windows

# Proceso

```
sudo apt-get install net-tools
ipaddr="`ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1`"
docker pull mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator

```
```sh
docker run \
    --publish 8081:8081 \
    --publish 10251-10254:10251-10254 \
    --memory 3g --cpus=2.0 \
    --name=cosmos-linux-emulator \
    --env AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10 \
    --env AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true \
    --env AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=$ipaddr \
    --interactive \
    --tty \
    mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator
```
Open:
```
https://localhost:8081/_explorer/index.html
```
docker run --publish 8081:8081 --publish 10251-10254:10251-10254 --memory 3g --cpus=2.0 --name=cosmos-linux-emulator --env AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10 --env AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true --env AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=172.26.240.1   --env NODE_TLS_REJECT_UNAUTHORIZED=0 --interactive --tty mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator
    
curl -k https://$ipaddr:8081/_explorer/emulator.pem > ~/emulatorcert.crt
sudo cp ~/emulatorcert.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates


### Para instalar en el equipo windows
- Navegar a `https://localhost:8081/_explorer/emulator.pem` y guardar el texto en fichero localhost.crt
- Instalar el certificado en el almacen "Entidades de certificación raíz de confianza".



### Prepare run cosmosDb container in localhost

```bash
#!/bin/bash

$SUDO apt-get install net-tools
ipaddr="`ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1`"
echo $ipaddr
echo "started cosmos emulator"

docker run --publish 8081:8081 --publish 10251-10254:10251-10254 --memory 3g --cpus=2.0 --name=cosmos-linux-emulator --env AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10     --env AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true --env AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=$ipaddr  --interactive --tty  --detach  mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator

echo "waiting for CosmosDb emulator to start"
until [[ $(curl -k -s -f -o /dev/null -w '%{http_code}' https://$ipaddr:8081/_explorer/emulator.pem) =~ "200"  ]] ;do    
    printf '.'
    sleep 5
    curl -k -s -f -o /dev/null -w '%{http_code}' https://$ipaddr:8081/_explorer/emulator.pem
done

echo "CosmosDb emulator started"


$SUDO curl -k https://$ipaddr:8081/_explorer/emulator.pem > ~/emulatorcert.crt
$SUDO cp ~/emulatorcert.crt /usr/local/share/ca-certificates/
$SUDO update-ca-certificates

echo "done"

#sudo 
# docker pull mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator
# docker run --publish 8081:8081 --publish 10251-10254:10251-10254 --memory 3g --cpus=2.0 --name=cosmos-linux-emulator --env AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10     --env AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true --env AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=$ipaddr  --interactive --tty  mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator

```


