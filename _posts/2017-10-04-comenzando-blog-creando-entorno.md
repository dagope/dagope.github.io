---
published: true
date: 2017-10-04 00:00:00 +0100
layout: post
title: Cómo montar un blog para dedicarme a lo importante, escribir.
author: David Gonzalo
comments: true
categories: [Jekyll, Blog]
excerpt: Pasos a seguir para crear un blog con Jekyll en GitHubPages y tener un entorno local donde crear artículos antes de publicarlos.
---
La finalidad de este artículo es detallar los pasos a seguir para crear un blog como este y tener un entorno de desarrollo en local (Windows) donde poder previsualizar de forma sencilla los artículos antes de publicarlos.
<!--break-->Y de esta manera, si cambio de PC, tengo todos los pasos detallados para que mi memoria no sufra, asi que vamos a ello.
# Contenido
<!-- TOC -->

- [Contenido](#contenido)
- [Requisitos para que todo funcione](#requisitos-para-que-todo-funcione)
    - [Descargando Ruby y kit de desarrollo utilizados:](#descargando-ruby-y-kit-de-desarrollo-utilizados)
    - [Instalando Ruby (Windows)](#instalando-ruby-windows)
    - [Instalando Ruby (Ubuntu)](#instalando-ruby-ubuntu)
    - [Instalando Jekyll (Windows/Ubuntu)](#instalando-jekyll-windowsubuntu)
- [Creando el blog](#creando-el-blog)
    - [Preparando el repositorio](#preparando-el-repositorio)
    - [Preparando entorno](#preparando-entorno)
    - [Configurando el blog](#configurando-el-blog)
    - [Compilando y arrancando en local](#compilando-y-arrancando-en-local)
    - [Publicando y viendo la magia de GitHubPages](#publicando-y-viendo-la-magia-de-githubpages)
- [Configurando comentarios.](#configurando-comentarios)
- [Trabajando más cómodo con VS Code.](#trabajando-más-cómodo-con-vs-code)
- [Configuración en Local/Dev y en Producción](#configuración-en-localdev-y-en-producción)
- [Guía para agregar nuevos artículos](#guía-para-agregar-nuevos-artículos)
- [Bonus: más comandos jekyll](#bonus-más-comandos-jekyll)

<!-- /TOC -->
# Requisitos para que todo funcione
<div class="message">Lo descrito en este blog hace referencia a un entorno con Windows instalado. Aunque se detalla la instalación sobre un Ubuntu.
</div>
- Tener una cuenta en GitHub o [crearla](https://github.com){:target="_blank"}.
- Tener Git instalado en el equipo. [instalación y tutorial](https://git-scm.com/book/es/v1/Empezando-Instalando-Git){:target="_blank"}
- Usaremos Visual Studio Code como editor. [descargar](https://code.visualstudio.com/download){:target="_blank"}

## Descargando Ruby y kit de desarrollo utilizados:
* Ruby: Ruby 2.3.3 (x64) [descagar](https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.3.3-x64.exe)

* Development KIT For use with Ruby 2.0 to 2.3 (x64 - 64bits only) 
[descargar](https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe)
	
Para probar otras versiones ir a la [página oficial](https://rubyinstaller.org/downloads/) pero siempre cuidado con que el Development Kit y la versión de Ruby sean compatibles.

## Instalando Ruby (Windows)
* Instalar Ruby en C:\Ruby
<br/>y marcar la opción de agregar ruby al path sistema
![Install options ruby]({{site.baseurl}}public/uploads/2017/10/install_ruby.png)


* Descomprimir DevKit en C:\RubyDevKit
* Abrir línea de comandos y nos situamos en la carpeta donde descomprimimos c:\RubyDevKit y ejecutar:
{% highlight shell %}
ruby dk.rb init
ruby dk.rb install
{% endhighlight %}
![Install dev kit ruby]({{site.baseurl}}public/uploads/2017/10/install_dev_kit_ruby.png)

## Instalando Ruby (Ubuntu)
* Ejecutar los comandos:
```bash
sudo apt-get update
sudo apt-get install ruby ruby-dev make gcc
sudo apt-get install gcc ruby-dev libxslt-dev libxml2-dev zlib1g-dev
```

## Instalando Jekyll (Windows/Ubuntu)
Desde la misma línea de comandos antes abierta:
* Instalar jekyll con el comando
```bash
gem install jekyll
```	
Si te sale el bloqueo del Firewall de windows permitidle acceso.

* Instalar bundler
```bash
gem install bundler
```
* Instalar rouge
```bash
gem install rouge
```
* Instalar jeykyll watch
```bash
gem install wdm 
```

# Creando el blog
La manera más sencilla de crear nuestro blog es partir de uno ya existente y usarlo como base para luego personalizarlo a nuestro gusto.
Aquí tenéis una lista de temas de blogs Jekyll. [Jekyll themes](https://github.com/jekyll/jekyll/wiki/Themes){:target="_blank"}
<br/>**¡NOTA!** En este articulo los ejemplos son sobre el repositorio de este mismo blog. Donde ya está configurada y adaptada la plantilla. Si elijes otra plantilla tendrás que instalar los paquetes *gem* que necesite y revisar la configuración. 

## Preparando el repositorio 
Lo más importante, es tener cuenta en [GitHub](https://github.com){:target="_blank"}. Si no la tienes créala. 
GitHub Será nuestro repositorio y a la vez nuestro hosting. Todo de forma gratuita y libre.
Con tu cuenta creada, inicia sesión y te doy 2 opciones: 
* Opción 1: Crear repositorio de cero.
    <br/>Puedes elegir esta opción si quieres empezar con un repositorio vacío y subir el proyecto más tarde. Únicamente ten en cuenta de nombrar al repositorio con *username*.github.io
![New repository]({{site.baseurl}}public/uploads/2017/10/create_new_repository_blog.png)

* Opción 2: Crear repositorio por Fork
    - Hacer un Fork del proyecto plantilla elegido. Si no sabes cómo hacerlo [aquí te explican cómo.](https://frontendlabs.io/3266--que-es-hacer-fork-repositorio-y-como-hacer-un-fork-github){:target="_blank"}.
    - Navegar hasta Settings de nuestro proyecto y cambiar el **Repository name** por el valor *username*.github.io siendo el *username* vuestro nombre de usuario de github. Como se ve en la imagen de ejemplo de la opción 1.

## Preparando entorno
Tenéis que tener instalado el tooling de Git en vuestra máquina. [Mas info aquí](https://git-scm.com/book/es/v1/Empezando-Instalando-Git){:target="_blank"}
- Ir a vuestra carpeta de trabajo p.ej: c:\proyectos\
- Abrir la consola en esa carpeta. Y ejecutar para este ejemplo:
```bash
git clone https://github.com/dagope/dagope.github.io.git
```
*UPDATE 01/11/17*: he dejado en este repositorio una plantilla base:
```bash
git clone https://github.com/dagope/TemplateBlog.git
```
- Si fuieste por la opción 1 tendrás que descomprimir tu plantilla en esta carpeta.

- Situar la consola sobre el repositorio y descargamos los paquetes utilizados:
```bash
bundle install 
```

## Configurando el blog
Abre el fichero *_config.yml* con tu editor favorito.
Debemos configurar:
<br/>**url**: http://username.github.io
<br/>**baseurl**: http://username.github.io/ 
<br/>**repository**: *username*/*username*.github.io
<br/>**userdisqus**: usuario de la plataforma disqus para los comentarios [ver más abajo](#configurando-comentarios-para-los-artículos)

Y personalizaremos las propiedades:
<br/>*title* 
<br/>*tagline*
<br/>*description*
<br/>*author*
<br/>*name*
<br/>*twitter*

## Compilando y arrancando en local
Llegados a este punto únicamente tendrás que ejecutar el siguiente comando sobre la carpeta de trabajo:
```bash
bundle exec jekyll serve -w --config "_config.yml,_config_dev.yml"
```
Si no hay errores se ejecutará un servidor web sobre el puerto 4000 y ya podremos navegar a la url  http://127.0.0.1:4000
![Start jekyll]({{site.baseurl}}public/uploads/2017/10/runing_jekyll.png)

¡Y ya tenemos nuestro blog en local!



## Publicando y viendo la magia de GitHubPages
Cuando ya tengamos creado un nuevo articulo la magia de publicarlo en la web es de GitHubPages.
Solamente nos encargamos de hacer commit y push de los cambios hacia el repositorio.
```bash
git add .
git commit -m "siempre un comentario"
git push origin master
```
¡Así de fácil!

# Configurando comentarios.
Para que los visitantes puedan dejar comentarios en post utilizamos la plataforma disqus.com que ya se encuentra instalada en esta plantilla. 
Crea una cuenta en Disqus y dar de alta tu blog.
Luego configura en el fichero *_config.yml* el parámetro *userdisqus* con el usuario que has dado de alta.

# Trabajando más cómodo con VS Code.
Este repositorio se encuentra ya configurado para trabajar con Visual Studio Code de una forma más rápida y cómoda.
La carpeta .vscode tiene definida los ficheros que automatizan para la compilación y lanzar el navegador.
Estos son los atajos de teclado:
- Ejecutando tarea:
<strong>`CTRL` + `SHIFT` + `P`</strong> --> Run Task Dev -> Local
- Compilación:
<strong>`CTRL` + `SHIFT` + `B`</strong>

# Configuración en Local/Dev y en Producción
En este repositorio hay creados dos ficheros de configuración:
- **Configuración Local/Dev:**
    El fichero _config_dev.yml configura los valores que ejecutamos en nuestro entorno local, tomando de base el fichero de producción. En este blog modificamos el valor de la clave *baseurl* con `/` para el entorno local.
- **Configuración Producción:**
    El fichero _config.yml es el fichero que será usado para el entorno de producción por GitHubPages, y el que modificamos en el punto de [arriba](#configurando-el-blog).

# Guía para agregar nuevos artículos
Abrimos la carpeta de trabajo con el editor Visual Studio Code (puedes usar el que más te guste). 
<br/>De la estructura del blog debemos de saber lo básico y seguir unas reglas para no generar desorden. Enumero las siguientes:
* Las articulos se crean en la carpeta *_posts*
* Los archivos seguirán la nomenclatura yyyy-mm-dd-titulo-de-mi-ariculo.md
* Al ser archivos .md se acepta el lenguaje markdown. Compatible con html.
* El contenido (imágenes, ficheros, etc...) se incluyen en la carpeta *public/uploads/yyyy/mm* 
* En cada post tenemos habilitadas una serie de propiedades al inicio del fichero:
    - *published*: true,false si no queremos que se publique el articulo
    - *layout*: post = la plantilla a usar, que por normal no cambiaremos
    - *title*: título del articulo
    - *author*: autor
    - *comments*: true,false para habilitar los comentarios
    - *categories*: array con las categorías en las que incluir el artículo [categoria1, categoria2 ...]
* Para conseguir un de resumen de las primeras lineas del blog hacer uso del código `<!--break-->` 


# Bonus: más comandos jekyll
*bundle exec jekyll serve -w --drafts*
<br/>Ejecuta incluyendo los archivos en carpeta _drafts
*bundle exec jekyll serve -w --config "_config.yml,_config_dev.yml"*
<br/>Ejecuta incluyendo los archivos en carpeta _drafts