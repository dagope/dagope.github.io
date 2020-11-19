---
published: true
date: 2020-10-18 05:00:00 +0100
layout: post
title: "Solucion para usar puertos reservados por Docker"
author: David Gonzalo
comments: true
categories: [docker, iisexpress, visualstudio]
excerpt: "Cuales son los puertos reservados por docker (aunque no los use) y como utilizarlos para tus desarrollos."
featured_image: 
disqus_page_identifier: 20201018070500
---
{% include code_image.html 
image='2020/10/error VS2019 - IIS Express.png'
title='Imagen del error de VS2019 sobre IIS Express.'
%}

Hace poco me instalé de nuevo docker en mi equipo, esta vez con WSL2 activado. Muy feliz y contento que todo funcionaba muy bien. Y al día siguiente uno de los proyectos lo arranqué y obtuve un error de que el puerto estaba ocupado. 

¿Como lo solucioné? 
<!--break--> 
Te contaré como llegué a la conclusión de que docker era el culpable y de como nuevamente Stackoverflow me confirmó mis sospechas.

## El error: 
Al intentar arrancar mi proyecto desde Visual Studio obtuve un 
```bash
Starting IIS Express ...
Failed to register URL "http://localhost:3000/" for site "XXXXXXXX.Api" application "/". Error description: The process cannot access the file because it is being used by another process. (0x80070020)
IIS Express is running.
```

{% include code_image.html 
image='2020/10/error VS2019 - IIS Express_Output.png'
title='Detalle del error en la ventana Ouput de Visual Studio.'
%}

## Mis sospechas



## La causa
Gracias a la respuesta de un StackOverflow pude confirmar mis sospechas y dar la causa.
https://stackoverflow.com/a/59610178/2319458

Podemos ver los puertos reservados ejecutando el siguiente comando:
```
netsh interface ipv4 show excludedportrange protocol=tcp
```

{% include code_image.html 
image='2020/10/excludedportrange_with_docker_and_hyperv_active.png'
title='Rangos de puertos excluidos del tcp.'
%}

## Solución 1
- Desactivar HyperV desde el terminal (en modo administrador) y <b>Reiniciar el pc</b>:
```bash
bcdedit /set hypervisorlaunchtype off
```
No olvidar reiniciar el PC.
- Ahora podremos arrancar nuestra solución.

Cuando quieras usar docker tienes que volver a iniciar el : 
- Activar de nuevo  HyperV desde el terminal (en modo administrador):
```bash
bcdedit /set hypervisorlaunchtype auto 
```
Reiniciamos el PC.

## La posible mejor solución (por probar)

- Desactivar HyperV desde el terminal (en modo administrador) y <b>Reiniciar el pc</b>:
```bash
bcdedit /set hypervisorlaunchtype off
```
No olvidar reiniciar el PC.

- Ejecutar de nuevo el comando para ver los puertos excluidos.
```
netsh interface ipv4 show excludedportrange protocol=tcp
```
En mi caso se ve así:
{% include code_image.html 
image='2020/10/excludedportrange_with_docker_and_hyperv_disabled.png'
title='Rangos de puertos excluidos del tcp tras desactivar hyperv.'
%}

- Ahora añadimos los puertos que queremos reservar para mi aplicación y que hyperv los reserve para docker. En mi caso eran el 3000 y el 3001.

```bash
netsh int ipv4 add excludedportrange protocol=tcp startport=3000 numberofports=1 store=persistent
netsh int ipv4 add excludedportrange protocol=tcp startport=3001 numberofports=1 store=persistent
```
Mostrando de nuevo el listado en mi caso se vería así:
{% include code_image.html 
image='2020/10/puertos_reservados.png'
title='Puertos reservados 3000 y 3001.'
%}


- Activar de nuevo  HyperV desde el terminal (en modo administrador):
```bash
bcdedit /set hypervisorlaunchtype auto 
```
Reiniciamos el PC.

- Ahora podemos comprobar nuestro listado de nuevo que ha crecido y donde se hyperv añadió sus rangos pero se mantienen los que hemos reservado

{% include code_image.html 
image='2020/10/excludedportrange_with_docker_and_hyperv_active_after_ports_reserved.png'
title='Puertos de hyperv y docker junto con los 3000 y 3001.'
%}

- Solo queda comprobar que nuestro proyecto arranca sin problemas desde Visual Studio.


Happy Codding.

