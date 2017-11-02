---
published: true
layout: post
title: El error de Visual Studio al depurar un proyecto Web con SSL activado
author: David Gonzalo
comments: true
categories: [VisualStudio, Web]
---
Si estás intentando arrancar la depuración de un proyecto web en Visual Studio y obtienes el siguiente error:
"An error ocurred attempting to determine the process id of dontnet.exe which is hosting your application. One or more errores occurred." Que no cunda el pánico. 
<!--break-->
![Error Visual Studio]({{site.baseurl}}public/uploads/2017/11/error_vs_debug_ssl.jpg)

Es verdad que el mensaje de error no te ayuda nada. 
Y lo que está ocurriendo es que tienes activado el SSL en las propiedades de depuración del proyecto y algo ha pasado con el certificado instalado para localhost. 
<br/>Tenemos varias opciones para solucionarlo:
- **Opción 1 (rápida y barata)**:
<br/>Puedes iniciar una instancia sin depuración  `CTRL` + `F5`. Esto arranca el navegador y te dice que la página es insegura y tendrás que pulsar en algún link donde ponga continuar.
- **Opción 2 (reparando IISExpress)**:
<br/>Esta opción a mí no me ha funcionado pero a la mayoría sí y podría ser tu caso. Tendrás que reparar el IISExpress desde el panel de control de Windows.

![Repair IISExpress]({{site.baseurl}}public/uploads/2017/11/repair_iss_express.jpg)
	
<br/>Una vez hecho verás en la consola MCC de Certificados como se habrá reinstalado localhost. (Debajo de Personal y Certificates). Si  ya existía puedes eliminarlo y volver a reparar IIS Express y aparecerá de nuevo. 
![Consola certificados de windows]({{site.baseurl}}public/uploads/2017/11/mcc.jpg)
	
- **Opción 3 (hazlo tú mismo)**:
<br/>Esta opción a mi me funcionó y no tiene misterio ninguno más que instalar el correcto certificado para localhost. 
    - Inicia la instancion con `CTRL` + `F5`
    - Abrir la url en Internet Explorer
	- Cuando muestre se el aviso del certificado inseguro pulsamos en continuar.
	- Ahora pulsamos en el icono rojo del certificado que aparece de la barra de navegación. Pulsamos en la opción Ver Certificados.
	- Se nos abre una pantalla con el detalle del certificado. Pulsamos en Instalar.
	- En el asistente elegimos la opción de *Local Machine* y lo almacenamos en "Trusted Root Certification Authorities" o en español "Entidades de certificación raíz de confianza".
	- Completamos la instalación y ahora ya podrás iniciar el proyecto pulsando F5 en Visual Studio.
	
- **Opción 4 (JexusManager)**:
<br/>Puedes usar una herramienta como JexusManager, en este enlace explican cómo: 
    [https://blog.lextudio.com/why-chrome-says-iis-express-https-is-not-secure-and-how-to-resolve-that-d906a183f0](https://blog.lextudio.com/why-chrome-says-iis-express-https-is-not-secure-and-how-to-resolve-that-d906a183f0){:target="_blank"}
    

Espero sea de ayuda.

Saludos!