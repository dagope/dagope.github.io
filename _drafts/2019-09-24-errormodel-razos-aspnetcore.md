---
published: true
date: 2019-09-23 12:00:00 +0100
layout: post
title: ErrorModel temporal Razos ASPNET CORE
author: David Gonzalo
comments: true
categories: [Razor, NetCore, ASPNET]
# featured_image: /public/uploads/2019/01
excerpt: Como parametrizar las urls de un fichero webtest
---
Esa situación en la que te encuentras un error inesperado y dices "esto ya lo he vivido, pero cómo lo solucioné?¿"
Eso fue lo que me pasó con un error en la generación de archivo temporal de Razor en el fichero 
<!--break-->

# Situación

# Problema
No sé el motivo ni la razón por la que en un equipo con el mismo código uno compila y otro mostraba el error. Seguramente sea algún fichero temporal de cada usuario. 

# Solución

Puedes probar alguna de estas:
- Reiniciar Visual Studio.
- Ejecutar un `dotnet clean`
- Ejecutar un `dotnet restore`
- Eliminar manualmente todas las carpetas bin y obj
- Reiniciar el equipo
- Build y Rebuild.

Quizás con suerte funcione.

Pero la SOLUCION que arregla el problema:
**Establecer en el fichero cshtml el namespace completo al modelo.**

<br> IMAGEN AQUI , PANTALLAZO
