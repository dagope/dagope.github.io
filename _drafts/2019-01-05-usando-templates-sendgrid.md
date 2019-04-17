---
published: false
date: 2019-01-12 18:24:00 +0100
layout: post
title: Usando plantillas en SendGrid
author: David Gonzalo
comments: true
categories: [SendGrid, Mailing, NetCore, C#]
featured_image: /public/uploads/2018/11/efcore.png
excerpt: Usando sendgrid con plantillas para envio de emails.
---
Hace poco tuve que hacer uso del servicio Send Grid para elaborar una plantilla donde poner datos dinámicos para distribuir por email.
<!--break-->
Desde tu suscripción de Azure puedes abrir una cuenta en SendGrid de una forma muy intuitiva, aquí la doc oficial.

Lo siguiente es crear una plantilla transacciona, este código html de ejemplo:
<pre data-enlighter-language="html">
<p>Hola {{firstName}}</p>
Estos son los pedidos realizados en el día de hoy.
<ol>
  <li>Fecha: {{{windowDate}}}</li>  
  <li>Total Enviados: {{{totalSent}}}</li>
  <li>Total Nuevos: {{{totalNew}}}</li>
  <li>Total Cancelados: {{{totalCancel}}}</li>
</ol>

<table>
  <tr>
    <td>Id Pedido</td>
    <td>Mensaje</td>
  </tr>
  {{#each messages}}
	    <tr>
	      <td>{{this.orderId}}</td>
	      <td>{{this.price}}</td>
	    </tr>
    {{/each}}
</table>
</pre>

Podemos cargar datos de ejemplo y visualizar como quedan para ajustar tu diseño si fuera necesario.
Configuramos un subjet y nombre para nuestra plantilla.


## Creando una app NetCore
Con una aplicación de consola en NetCore pero podrías ejecutarlo desde cualquier aplicación haciendo uso de la api de SendGrid.

- Crea aplicación de consola.

- Añade el paquete nuget SendGrid, la última versión de SendGrid disponible a día de hoy es la 9.10.0
![send grid nuget]({{site.baseurl}}public/uploads/2019/01/sendgrid_nuget.png)

- Configuramos la *ApiKey* que obtenida del portal de Sendgrid y el *TemplateId* 

Con el siguiente código podemos hacer el envio de un mail.

## Actividad de SendGrid
En el apartado Activity podemos ver el estado de todos los envios que realicemos. 

## Consejo
Puedes crear versiones de tus plantillas en SendGrid pero es recomendable llevar el control del codigo html y el json de datos de prueba en ficheros de tu repositorio de codigo fuente, te ahorrarás disgustos.


Documentación donde ver todas las opciones soportdas y el schema de datos.
https://dynamic-templates.api-docs.io/3.0/mail-send-with-dynamic-transactional-templates/v3-mail-send
