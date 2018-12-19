---
published: true
date: 2018-12-19 10:00:56 +0100
layout: post
title: Performance test fallan sobre Azure Web Apps
author: David Gonzalo
comments: true
categories: [Testing, Azure, Visual Studio, Web]
featured_image: /public/uploads/2018/12/change_tsl_azure.png
excerpt: Solución cuando tu performance test sobre Azure devuelve un error "connection was forcibly closed by the remote host"
---
El otro día realizando unas pruebas de rendimiento sobre una api REST desplegada en una Azure Web App, me encontré que todas las request del test habían fallado. Que raro, porque si ejecuto una de ellas desde el navegador funciona, en cambio todas habian sido rechazadas con el mismo error: 

<span style="color:red">*An existing connection was forcibly closed by the remote host.*</span>
 
Vamos a ver como reproducir el problema y comentamos las soluciones.
<!--break-->
# Reproduciendo el problema:
Desde Visual Studio tengo generado un fichero .webtest, para poder realizar diferentes llamadas sobre los endpoints de mi API rest. 

Algo normal hasta aquí. El problema me lo encontre por dos vías.

- Ejecutando el fichero desde la opción *Performance Test* del App Service en  Azure.
{% include code_image.html 
image='2018/12/error_performance_test.png'
title='Listado de errores de la ejecución del performance test desde el portal de Azure'
target='_blank'
%}

- Ejecutando desde Visual Studio apuntando hacia la web API desplegada en Azure.
{% include code_image.html 
image='2018/12/error_from_visual_studio.png'
title='Performance test, error ejecutando desde el Visual Studio'
target='_blank'
%}


Desde VSTS, el ahora llamado Azure DevOps, también obtendremos el mismo error.

## La causa
El problema reside la configuración de seguridad TSL que tengamos establecida. Si nuestra Web App tiene configurado una versión superior a la 1.0 fallará y nos dará el error <span style="color:red">*An existing connection was forcibly closed by the remote host.*</span>
<br/>Te comento dos posibles soluciones:

# Soluciones
## Solución 1:
Podemos establecer la *Minimum TLS Version* como 1.0 y nos funcionará tanto si ejecutas el test desde Visual Studio como desde Azure. De hecho, esta es la opción para que funcione nuestros *Performance Test* ejecutados desde las opciones de Azure WebApp Azure y Azure DevOps.
{% include code_image.html 
image='2018/12/change_tsl_azure.png'
title='Cambiando TSL en Web App Azure'
target='_blank'
%}

{% include code_note.html 
content='Cuando hagas el cambio dale un marguen de tiempo, aunque Azure notifique que ya está actualizado puede que ejecutes y te siga dando error. Si lo ves necesario reinicia la web app.'
%}

## Solución 2:
Si no queremos cambiar nuestro TSL Version, a día de hoy desde Azure no tenemos una solución. Pero podemos cambiar nuestro fichero .webtest para que la ejecución nos funcione desde Visual Studio.
Para ello tenemos que crear un *Web Test Plug-ins*. Agregamos el siguiente fichero de código al proyecto:
<script src="https://gist.github.com/dagope/a8063404874411314bc7c1f874d01b7d.js"></script>

Después añadimos el plugin en nuestro webtest:
{% include code_image.html 
image='2018/12/insert_Web_plugin_test.png'
title='Agregando Web Test Plugin'
target='_blank'
%}
En la ventana nos debería aparecer nuestro plug-in **TSLPlugin**, sino aparece compila y vuelve a mirar.


Lo seleccionamos, aceptamos y veremos que nos aparecerá una nueva carpeta llamada **Web Test Plug-ins** que contendrá nuestro TSLPlugin.

Ahora si ejecutamos el web test todo debería funcionar perfectamente.

{% include code_note.html 
content='Si estás pensando en utilizar el fichero .webtest con el plugin establecido sobre Azure obtendrás un error que te dirá que Azure no tiene soporte para Plugins de web-test. Buen intento pero a día de hoy es lo que hay.' 
%}


<br/>Saludos!
<br/>David