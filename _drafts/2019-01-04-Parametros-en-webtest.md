---
published: true
date: 20121-01-04 12:00:00 +0100
layout: post
title: Parametros en webtest
author: David Gonzalo
comments: true
categories: [Testing, Azure, Visual Studio, Web]
# featured_image: /public/uploads/2019/01
excerpt: Como parametrizar las urls de un fichero webtest
---
# Grabando un fichero webtest
Un par de apuntes de como hacer la grabación del un archivo .webtest.
<br/>Para VS2017 tienes que tener instalado el componente "Web performance and load testing tools" en caso contrario abre el Visual Studio Installer clic en More-->Modify 
![Visual Studio Installer Modify]({{site.baseurl}}public/uploads/2018/12/vs_installer_modify.png)
Pestaña "Individual components" y en la sección "Debuggint and testing" lo encontrarás:
![Visual Studio Installer, select option Load Testing Tools]({{site.baseurl}}public/uploads/2018/12/vs_installer_component_load_testing_tools.png)

Con esto instalado podrás ejecutar tu proyecto para poder grabar y obtener un fichero con extension .webtest.

## Parametrizando el host 

### Fuentes:
como toda investigación Stacoverflow y algún foro he conseguido encontrar la solución. Aquí la recopilación de los enlaces.
- [url1](http://url1){:target="_blank"}.
- [url2](http://url2){:target="_blank"}.
- [url3](http://url3){:target="_blank"}.
- [url4](http://url4){:target="_blank"}.