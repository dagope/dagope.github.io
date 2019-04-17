---
published: true
date: 2019-04-01 00:00:00 +0100
layout: post
title: Como dockerizar un entorno de Github Pages
author: David Gonzalo
comments: true
categories: [docker, github, jekyll]
excerpt: Como dockerizar un entorno de desarrollo para nuestro github pages.
featured_image: /public/uploads/2019/04/docker-githubpage-devbox.png
disqus_page_identifier: 2019040100
---

El primer artículo que escribí trataba de [cómo crear un blog con github pages]({{ site.baseurl }}2017/10/04/comenzando-blog-creando-entorno) y explicaba paso a paso cómo montar un entorno de desarrollo funcionando con jekyll y ruby.
Yendo un paso más allá, voy a explicar cómo haciendo uso de Docker podemos olvidarnos de instalar nada y tener un entorno de desarrollo fácil, sencillo y listo para compartir entre diferentes entornos.

La finalidad es poder levantar nuestro entorno haciendo un simple `docker-compose up`

<img src="{{site.baseurl}}public/uploads/2019/04/docker-githubpage-devbox.png" style="border:0px" alt="Dev Box de ruby, jekyll, githubpages con docker"  />
<!--break-->

## Creando nuestro Dockerfile
Si navegas a la web de jekyll puedes leer [los requisitos](https://jekyllrb.com/docs/installation/#requirements){:target="_blank"} 
y pasos a seguir para ponerlo a funcionar.
Es toda la info que necesitas para crear tu Dockerfile que finalmente sería:

```docker
FROM ruby:2.5 
RUN apt-get update && apt-get install -y     

ENV CHOKIDAR_USEPOLLING 1
EXPOSE 4000

RUN gem install bundler
COPY Gemfile ./ 
RUN bundle install

RUN mkdir -p /app 
WORKDIR /app

CMD "/bin/bash"
```

Vamos a detallar cada línea:
- `FROM ruby:2.5` 
<br/>Necesitamos una imagen con Ruby superior a 2.4.0 por lo que hemos cogido la versión 2.5 ya existen en dockerhub.
- `RUN apt-get update && apt-get install -y`
<br/>Actualizamos los paquetes.
- `ENV CHOKIDAR_USEPOLLING 1`
<br/>Establecemos esta variable de entorno a valor 1 porque nos facilitará el poder detectar los cambios en nuestros ficheros y que jekyll recompile automáticamente. De esta manera nos libramos de tener que arrancar/parar continuamente el contenedor.
- `EXPOSE 4000`
<br/>Exponemos el puerto 4000 que es el utilizado por defecto en jekyll
- `RUN gem install bundler`
<br/>Gem es el gestor de paquetes de ruby, instalamos bundler que es necesario para jekyll.
- `COPY Gemfile ./ `
<br/>Copiamos sólamente nuestro fichero Gemfile a la imagen. Este fichero define las gemas necesarias para que ruby instale jekyll y los plugins que queramos.
- `RUN bundle install`
<br/>Corremos bundle para que instale las gemas que hagan falta.
- `RUN mkdir -p /app` 
<br/>Creamos una carpeta app donde tener nuestro código.
- `WORKDIR /app`
<br/>Establecemos el directorio de trabajo en la carpeta de nuestra web.
- `CMD "/bin/bash"`
<br/>Dejamos este comando para poder conectarse facilmente al contenedor por consola.

### Ignorando ficheros con .dockerignore
No está de demás tener definido nuestro fichero .dockerignore para asegurarnos que no llega basurilla a la creación de la imagen o ejecución del contenedor.

A mi me gusta asegurarme que *Gemfile.lock* y la carpeta *_site* son ignorados.
``` 
Gemfile.lock
_site
```

## El fichero Gemfile
El código que pongo a continuación corresponde el fichero Gemfile donde configuramos la versión de jekyll a utilizar y plungins soportados por github pages a día de hoy.

```gem
source "https://rubygems.org"

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
gem "jekyll", "~> 3.7.4"

# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima", "~> 2.0"

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
#gem "github-pages", group: :jekyll_plugins

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.6"
  gem 'jekyll-paginate'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.0" if Gem.win_platform?

gem 'jekyll-sitemap'
gem 'jemoji'
```

## Compilando y creando nuestra imagen
Con los ficheros: **Dockerfile, Gemfile, .dockerignore** ya tenemos todo preparado para crear nuestra imagen. 

Para ello ejecutamos el comando build y nombre a la imagen con su tag.
```bash
docker build . -t githubpagesbase:v1.0
```
Para ponerlo aún más fácil, esta imagen ya la compilé yo por ti y la dejé publicada en [dockerhub](https://hub.docker.com/r/dagope/githubpagebase/tags){:target="_blank"} ;) por lo que puedes utilizar un `git pull dagope/githubpagebase:v1.0` y descargarla sin esfuerzo alguno.

Si todo ha ido bien con un `docker images` verás listada la imagen.

## Nuestro Docker Compose
Ha llegado la mejor parte y más divertida. Como hacer nuestro fichero yaml para arrancar nuestra web con jekyll.

Te pongo el código y comentamos cada parte: 
```yaml
version: '3'
services:
  jekyll-build:
    image: dagope/githubpagebase:v1.0
    ports:
      - "4000:4000"
    volumes:
      - .:/app
    working_dir: /app    
    command: >
      sh -c 'bundle install &&
             bundle exec jekyll serve --host 0.0.0.0 -w --drafts --force_polling --config "_config.yml,_config_dev.yml"'
```

Comentando lo más importante del fichero:
- La imagen. Puedes usar la tuya en local si te sientes mejor. Sino puedes usar la mía pública.
- Mapeamos el puerto 4000 del contenedor que está definido en la imagen para poder abrir un navegador y ver como va quedando nuestra web.
- Montamos un volumen sobre nuestra carpeta de código del tipo "bind mount", es decir, el código reside en el host y se comparte al contenedor, de esta manera conseguimos que al guardar cambios en nuestro código jekyll irá recompilando y generando las páginas.
- Establecemos nuestro directorio de trabajo en *app*.
- Command. Se ejecutan varios comandos que detallamos:
    - `bundle install` nos aseguramos de los bundles están correctos
    - `bundle exec jekyll serve`
        - `--host 0.0.0.0`
        - `-w` la opción para ejecutar el watcher del cambio de ficheros
        - `--force_polling` esta opción indica que el watcher sea forzado por *poolling*, sobre todo para evitar problemas desde docker for windows.
        - `--config "_config.yml,_config_dev.yml"` esta opción le decimos a jekyll que por configuración tenemos dos fichero. Suelo usar uno para el entorno desarrollo que queremos lanzar y otro con las configuraciones en producción. Pero esto es totalmente opcional según cada uno lo quiera tener montado.

Ahora solo queda lanzar tu contenedor con un:
```bash
docker-compose up
```

Si todo va bien verás por consola como el contenedor sirve en el puerto 4000 la web. Abre el navegador y pon la url 
[http://localhost:4000](http://localhost:4000){:target="_blank"} y todo funcionando.

**No olvides hacer un `docker-compose down` cuando quieras detener el entorno.**

# Conclusión
Utilizando docker evitamos procesos de instalación de sdk, runtimes, configuraciones, etc... en lo que tardes en descargar la imagen tienes arrancado el proyecto, sin contaminar tú pc. ¿una maravilla verdad? 

Happy coding!
<br/>
David.
