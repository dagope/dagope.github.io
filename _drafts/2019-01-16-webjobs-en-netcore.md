---
published: false
date: 2019-01-16 09:00:00 +0100
layout: post
title: Usando plantillas en SendGrid
author: David Gonzalo
comments: true
categories: [WebJobs, ASPNET, NetCore]
featured_image: /public/uploads/2018/11/efcore.png
excerpt: Creacion de web jobs con la v3.0 de netCore 2.1
---
Con la version del sdk de Azure Web Jobs v3.0 para NetCore se han implentado unos cuantos cambios para facilitar la implementación de un webjob con la version de netCore 2.1.
Para ello vamos a crear un WebJob que se ejecute cuando haya algún cambio en un blob.

<!--break-->
Fuentes: 
https://matt-roberts.me/new-azure-webjobs-3-0-in-net-core-2-with-di-and-configuration/
https://docs.microsoft.com/es-es/azure/azure-functions/functions-bindings-storage-blob
https://github.com/Azure/azure-webjobs-sdk
