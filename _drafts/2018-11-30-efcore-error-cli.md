---
published: false
date: 2018-11-30 20:24:00 +0100
layout: post
title: EF Core error CLI.
author: David Gonzalo
comments: true
categories: [EFCore, NetCore]
---

## CLI no encuentra la version de EF 
Si, un mensaje como el siguiente al ejecutar un comando vía CLI 
```bat
The specified framework version '2.0' could not be parsed
The specified framework 'Microsoft.NETCore.App', version '2.0' was not found.
...
``` 
![EFCore cli not found framework]({{site.baseurl}}public/uploads/2018/10/efcore_version_not_found.png)
El error viene causado porque el proyecto sobre le que estas ejecutando el comando no tienes referenciado el las DotNetCliToolReference, añadelas via Nuget o editando el proyecto.csproj.
**UPDATE**: este error está solucionado a partir de la versión 2.0.2 de EF. Aunque no parece estar por las pruebas que estoy haciendo. 