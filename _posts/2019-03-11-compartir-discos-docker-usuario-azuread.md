---
published: true
date: 2019-03-11 00:00:00 +0100
layout: post
title: Compartir discos con Docker cuando usamos un usuario del AzureAD
author: David Gonzalo
comments: true
categories: [docker, azure]
excerpt: Solución a compartir discos con Docker cuando tu usuario pertenece a un Azure AD.
featured_image: /public/uploads/2019/03/docker_move.png
disqus_page_identifier: 2019031100
---

A día de hoy, existe un 
[issue](https://github.com/docker/for-win/issues/132){:target="_blank"}
(aún sin arreglar) en Docker CE for Windows que si has iniciado sesión con un usuario del Azure Active Directory (AzureAD) docker no es capaz de compartir los discos. Por mucho que lo intentes y aunque le pongas las credenciales correctas vuelves a comprobar y los discos siguen sin estar compartidos. Esto es un gran problema porque no podrás crear ningún volumen sobre tus contenedores.

{% include code_image.html 
image='2019/03/docker_share_drive_azuread_user.png'
title='Error compartiendo discos en docker con usuario del AzureAD'
%}
<!--break--> 

#### Solución

La solución encontrada ha sido **crear un usuario local en Windows que sea Administrador y usar sus credenciales.**. 
Sencillo arreglo tras interpretar los errores en el log de Docker y comprenderlos. Agradecer e los cracks Edu 
[@eiximenis](https://www.twitter.com/eiximenis/){:target="_blank"}
y Jose Corral 
[@jmanuelcorral](https://www.twitter.com/jmanuelcorral/){:target="_blank"}
, por la ayuda prestada 👍 .

Fácil de hacer así que vamos ello:

- Creamos un usuario local en Windows. Por ejemplo:
```
User: DockerAdmin 
Pwd: 123456
```
Obviamente **usa una password segura** y no la del ejemplo.

- Inicia sesión en Windows con `nombrepc\DockerAdmin`
<br/>Si no sabes el nombre de tu máquina escribe `hostname` en consola y lo obtendrás.

- Tras el proceso de bienvenida al nuevo usuario, finaliza sesión y vuelve a iniciar con el usuario del Azure AD.

- Abre las Settings de Docker Desktop. Botón derecho en el icono de docker en la bandeja de entrada.

- Ve hacia Shared Drives, selecciona los discos a compartir, y pulsa Apply.

- Ahora se nos abrirá el dialogo para introducir las credenciales de usuario. Este es el momento de poner el usuario que acabamos de crear `hostname`\DockerAdmin y la password.

- Si todo ha funcionado correctamente los discos aparecerán marcados.

-Si pruebas a ejecutar:
<br/>`docker run --rm -v c:/Users:/data alpine ls /data`
<br/>Verás que ahora funciona correctamente 😃

Happy coding!
<br/>
David.
