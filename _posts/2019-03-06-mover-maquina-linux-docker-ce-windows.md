---
published: true
date: 2019-03-06 00:00:00 +0100
layout: post
title: Moviendo la máquina Linux de Docker CE for Windows
author: David Gonzalo
comments: true
categories: [Docker, Net]
excerpt: Moviendo la máquina de Docker CE for Windows para optimizar nuestro espacio en disco.
featured_image: /public/uploads/2019/03/docker_move.png
disqus_page_identifier: 2019030600

---
Cuando tenemos instalado **Docker CE for Windows** y configurado para imágenes linux, en realidad tenemos una máquina HyperV con una distro de linux ejecutándose y que hace de intermediaria para que todo parezca que funciona como si de magia negra se tratase. Pero, ¿qué pasa cuando te vas quedando sin espacio según vas descargando más y más imágenes docker?
<img src="{{site.baseurl}}public/uploads/2019/03/docker_move.png" style="border:0px" alt="Moviendo docker"  />
<!--break--> 

La solución no pasa por configuraciones en ficheros json de docker, olvídate de eso, lo más simple es mover el disco virtual usado por HyperV para ejecutar la distro de Linux hacia otra partición donde tengas más espacio. Ese disco virtual es un fichero que se llama **MobyLinuxVM.vhdx**.


#### ¿Dónde está MobyLinuxVM.vhdx?
Puedes averiguar la ruta del fichero que hace uso Docker desde el HyperV Manager:
- Selecciona la máquina **MobyLinuxVM**.

- Entra en Settings.

- Selecciona HardDrive MobyLinuxVM.hdx.

- Verás la ruta en la sección Virtual hard disk. <br/>Probablemente sea: `C:\Users\Public\Documents\Hyper-V\Virtual hard disks`

{% include code_image.html 
image='2019/03/docker_where_is_mobylinuxvm_hyper_v.png'
title='Donde encontrar la ruta de MobyLinuxVM'
%}

#### Moviendo vhd y configurando Link
- Lo primero, hay que parar Docker Desktop antes de continuar.
{% include code_image.html 
image='2019/03/docker_stop.png'
title='Parando Docker en Windows 10'
target='_blank'
%}

- Ahora que ya tienes localizado el fichero vhdx, muévelo a tu nueva ruta, por ejemplo, `D:\HyperV-disks\MobyLinuxVM.vhdx`

- Elimina la carpeta `Virtual hard disks` de la ruta `C:\Users\Public\Documents\Hyper-V\`

- Abre una consola en modo administrador y ejecutas:
```bash
mklink /J "C:\Users\Public\Documents\Hyper-V\Virtual hard disks" "D:\HyperV-disks"
```
{% include code_image.html 
image='2019/03/docker_console_create_link.png'
title='Resultado de creación de mklink'
%}

- Inicia Docker Desktop. 


Docker debería ser iniciado sin problema. Vamos a comprobar los cambios y nos descargamos una imagen, por ejemplo:
```bash
docker pull microsoft/azure-cli:2.0.59
```

Si observamos el fichero `D:\HyperV-disks\MobyLinuxVM.vhdx` veremos que está modificándose conforme la descarga avanza.

Y así sin desinstalar Docker ni hacer raras configuraciones optimizamos nuestro espacio en disco.

Happy coding!
<br/>
David.


## Bonus
Si quieres hacer búsquedas de ficheros en windows, te recomiendo usar el programa 
[Search Everything](https://www.voidtools.com/es-es/){:target="_blank"} 
, útil, rápido y gratis. Aunque puedes dejar una donación ;-)

