---
published: false
layout: post
title: Comandos docker más usados
author: David Gonzalo
comments: true
categories: [Docker, Commands]
disqus_page_identifier: 20181209
codeStyle: enlighterjs
---



#### Descargar imagen de un tag determinado
```bash
docker pull <image-name>:<tag>
```
#### Listar imagenes descargadas
```bash
docker images
```
#### Borrar imagen 
```bash
docker rmi <image-id>
```
#### Borrar todas las imagenes
```bash
docker rmi $(docker images -q)
```
---------------------
## Contenedores
#### Crear un contenedor con nombre
```bash
docker run --name micontainer <image-name>
```
#### Parar todos los contenedores
```bash
docker stop $(docker ps -a -q)
```
#### Borrar todos los contenedores
```bash
docker rm $(docker ps -a -q)
```
#### Ejecutar y borrar automaticamente al finalizar el contenedor
```bash
docker run --rm alpine
```
#### Arrancar y atachar al contenedor 
```bash
docker start -i <container-id>
```
#### Ver tamaño de los contenedores
```bash
docker ps -s -a
```
#### Abrir sesión interactiva sobre un contenedor
```bash
docker exec -it <id-contenedor> /bin/bash
```
#### Crear contenedor e iniciar sesion interactiva
```bash
docker run -it <image-name> /bin/bash
```
o
```bash
docker run -it --entrypoint /bin/bash <image-name>
```
#### Crear contenedor en segundo plano
```bash
docker run -d <image-name>
```
#### Crear contenedor y mapear puerto
```bash
docker run -d -p <host-port>:<host-image> <image-name>
```
#### Crear establecer valor de variable de entorno
```bash
docker run -e "variable1=valor1" -e "variable1=valor1" <image-name>
```

## Inspeccionar objetos
#### Inspeccionar un objeto (contaier o imagen)
```bash
docker inspect <container-id/image-id>
```
#### Ver los volúmenes montados de un contenedor:
```bash
docker inspect --format "{{json .Mounts}}" <container-id>
```
#### Ver la ip de un contendor
docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" <container-id>

--------
## Volumen
#### Crear volumen
Usar minúsculas en el nombre del volumen para evitar algun error.
```bash
docker volume create <volumeName>
```
#### Listar volumenes
```bash
docker volume ls
```
#### Eliminar volumenes no usados en ningún contenedor
```bash
docker volume prune
```
#### Asociar volumen al contenedor
```bash
docker run -v <volumeName>:/<pathContainer> <imageName>
```

----
Docker Builds:
#### Crear imagen de un contenedor
```bash
docker build . -t <imageName>:<tag>
```
----
Docker Machine
#### Crear una máquina virtual
```bash
docker-machine create --driver hyperv test-campus
```
docker-machine create --driver hyperv --hyperv-virtual-switch external-switch test-campus

#### Ver variables de entorno de la maquina virtual
```bash
docker-machine env machineName
```
#### Usar una máquina existente con Docker Magine
```bash
docker-machine create --driver generic --generic-ip-address=a.b.c.d --generic-ssh-key=~/.ssh/id_rsa
```

----
Docker Logs y Depuración:
#### Ver log de un contenedor (la salida stdout y stderr)
```bash
docker logs <containerId>
```
#### Para copiar un fichero /logs/log.txt desde un contenedor al host
```bash
docker cp <ContainerId>:logs/log.txt .
```
#### Para copiar un fichero /logs/log.txt desde un host al contenedor
```bash
docker cp foo.txt <id-contenedor>:/app/foo.txt
```
#### Crear imagen a partir de otro contenedor
```bash
docker commit <ContainerIdOrigin> <ImageName>
```

-----
## Compilar aplicaciones NetCore
Ejemplo de compilación de una aplicacion NetCore haciendo uso de la imagen base dotnet (sin dockerFile)
```bash
docker run -v /C/src:/src -v /C/out:/src/out microsoft/dotnet:2.0.3-sdk-jessie bash -c "cd /src && dotnet publish -o out"
```

# Contenedores Cloud en Azure
## Descargar Azure-Cli.
Descargar Azure-Cli. No hace falta instalar y ver aqui el ultimo tag --> https://hub.docker.com/r/microsoft/azure-cli/tags/
```bash
docker pull microsoft/azure-cli:<tag>
```
## Login de nuestra cuenta Azure.
```bash
az login
```
## Listar suscripciones de Azure
```bash
az account list
```
## Cambiar suscripcion activa
```bash
az account set --subscription <id>
```
## Ver suscripcion activa
```bash
az account show
```
## Desplegar en una WebApp usando la CLI
```bash
az group create --name testRg --location "West Europe"
az appservice plan create --name testSp --resource-group testRg --sku S1 --is-linux
az webapp create --resource-group testRg --plan testSp --name testDockerCampusMvp --deployment-container-image-name dockercampusmvp/go-hello-world:latest
```
Configurando variables de entorno
```bash
az webapp config appsettings set --resource-group myResourceGroup --testRg testDockerCampusMvp --settings variable=valor
```

# Kubernetes
## Arrancar/instalar minikube 1ª vez
```bash
minikube start --kubernetes-version v1.9.0 --vm-driver hyperv --hyperv-virtual-switch <nombre_virtual_switch_con_conexion>
```
## Parar minikube (si no lo usamos lo paramos y que no ocupe memoria RAM)
```bash
minikube ssh
sudo poweroff
```
## Arrancar otra vez minikube 
```bash
minikube start --kubernetes-version v1.9.0 --vm-driver hyperv 
```
## Mostrar la información del nodo minkube
```bash
kubectl describe node minikube
```
## Mostrar IP de minkube
```bash
minikube ip
```
## Crear y desplegar un pod con un solo contenedor
```bash
kubectl run my-first-deployment --image=dockercampusmvp/go-hello-world
```
## Mostrar nodes
```bash
kubectl get nodes
```
## Mostrar pods
```bash
kubectl get pods
```
## Mostrar deployments
```bash
kubectl get deployments
```
## Mostrar services
```bash
kubectl get services
```
## Borrar pod
```bash
kubectl delete pod <nombre-pod>
```
## Crear un servicio
Ejemplo de comando que crea un servicio (my-first-service) cuyo tipo es NodePort (veremos más adelante los tipos). Este servicio estará vinculado al deployment my-first-deployment
```bash
kubectl expose deployment my-first-deployment --type=NodePort --name my-first-service --port 80
```
## Lanzar navegador hacia la url publica del servicio
```bash
minikube service my-first-service
```
## Escalar pods
```bash
kubectl scale --replicas=10 deployment/my-first-deployment
```

## Aplicar deployments
```bash
kubectl apply -f deployment.yaml
```

## Obtener los logs del contenedor de un despliege
```bash
kubectl logs <podIdentifier> -c <containerName>
```
## Configuración de clusters
```bash
kubectl config get-contexts
kubectl config use-context <nombre-cluster>
```

## Eliminar un cluster
```bash
kubectl config delete-context <nombre-cluster>
```

# Ingress
## Habilitar ingress en MiniKube
```bash
minikube addons enable ingress
```

# Helm
Herramienta que nos permite instalar aplicaciones en Kubernetes. Para instalar unicamente enemos que incluir el binario en una ruta del path.
## Instalando el gestor de paquetes Tiller para Helm
```bash
helm init
```
## Ver repositorios de charts
```bash
helm repo list
```
## Instalar chart
```bash
helm install nombrerepositorio/nombrechart
```
Ej: helm install stable/wordpress


### Instalar Dahboard kubernetes en Docker CE
```bash
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

### Útiles con Docker

## Unir documentos pdf
Abrir un terminal en la ruta donde tenemos el fichero 0.pdf y 1.pdf
Ejecutamos:
```cmd
$ docker run --rm -v %cd%:/pdf gkmr/pdf-tools pdftk /pdf/0.pdf /pdf/1.pdf cat output /pdf/merged.pdf
```
```bash
> docker run --rm -v $PWD:/pdf gkmr/pdf-tools pdftk /pdf/0.pdf /pdf/1.pdf cat output /pdf/merged.pdf
```
Obtenemos un fichero resultante con los ficheros unidos en uno solo llamado merged.pdf.
OJO! las rutas al montar el volumen, mejor pon tus ficheros en una ruta sin espacios temporal tal que "c:\temp" 

## Obtener de un pdf otro con ciertas páginas
> docker run --rm -v %cd%:/pdf gkmr/pdf-tools pdftk /pdf/0.pdf /pdf/1.pdf cat output /pdf/merged.pdf
> docker run --rm -v %cd%:/pdf gkmr/pdf-tools pdftk /pdf/fullpdf.pdf cat 6-12 27 output pdf/outfile.pdf


Happy Codding. :)











