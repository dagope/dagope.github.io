---
layout: post
title: Cómo "dockerizar" un entorno de Github Pages
author: David Gonzalo
comments: true
categories: [docker, github, jekyll]
excerpt: Cómo dockerizar un entorno de desarrollo para nuestro github pages.
featured_image: /docker-githubpage-devbox.png
featured_image: /public/uploads/2019/04/docker-githubpage-devbox.png
published: false
# POST PUblicado en CAMPUSMVP en el link: https://www.campusmvp.es/recursos/post/como-dockerizar-un-entorno-de-github-pages.aspx
---

En la [serie de artículos](https://www.campusmvp.es/recursos/post/crea-tu-propia-pagina-o-blog-gratis-con-jekyll-y-github-parte-1-primeros-pasos.aspx) de **David Charte** sobre cómo escribir un blog y generar webs estáticas con Jekyll para GitHub Pages, aprendimos los conceptos y detalles para conseguir
[un entorno local](https://www.campusmvp.es/recursos/post/crea-tu-propia-pagina-o-blog-gratis-con-jekyll-y-github-parte-2-publicando-posts.aspx) de desarrollo con Ruby y Jekyll. Dale un repaso antes de seguir leyendo.

Profundizando un paso más, vamos a explicar cómo haciendo uso de Docker podemos olvidarnos de cualquier proceso de instalación y conseguir **un entorno fácil, sencillo y listo para compartir** entre diferentes equipos sin importar el SO (MacOS/Windows/Linux) y sin "ensuciar" el sistema con instalaciones.

En este artículo aprenderemos a crear nuestra imagen base de Docker para finalmente ejecutar nuestro entorno local con un simple `docker-compose up`.

No entraremos en procesos de instalación de Docker, si quieres aprender más sobre ello te aconsejo que eches un vistazo al [curso de Docker](https://www.campusmvp.es/catalogo/Product-Docker-y-Kubernetes-desarrollo-y-despliegue-de-aplicaciones-basadas-en-contenedores_237.aspx) en CampusMVP.

<img src="/public/uploads/2019/04/docker-githubpage-devbox.png" style="border:0px" alt="Imagen ornamental, un logo de Docker soportando a Ruby, Jekyll y GitHub pages"  />

## Creando nuestro Dockerfile

Si navegas a la documentación de Jekyll puedes leer [los requisitos](https://jekyllrb.com/docs/installation/#requirements) y pasos a seguir para ponerlo a funcionar.

Esta es toda la información que necesitamos para crear nuestro Dockerfile:

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

Comentemos al detalle cada línea:

- `FROM ruby:2.5`
<br/>Necesitamos una imagen con Ruby superior a 2.4.0 por lo que hemos escogido la versión 2.5 que ya existe en Docker Hub.
- `RUN apt-get update && apt-get install -y`
<br/>Actualizamos el sistema y paquetes.
- `ENV CHOKIDAR_USEPOLLING 1`
<br/>Establecemos esta variable de entorno al valor 1 porque nos ayuda en la detección de cambios sobre nuestros ficheros de código. Así Jekyll recompila automáticamente y nos libramos de tener que arrancar/parar continuamente el contenedor.
- `EXPOSE 4000`
<br/>Exponemos el puerto 4000 utilizado por defecto en Jekyll.
- `RUN gem install bundler`
<br/>Gem es el gestor de paquetes de Ruby, instalamos *bundler* que es necesario para Jekyll.
- `COPY Gemfile ./ `
<br/>Copiamos solamente nuestro fichero `Gemfile` a la imagen (ahora veremos cómo construirlo). Este fichero define las gemas necesarias para nuestro blog y que Ruby instale Jekyll y los plugins que queramos.
- `RUN bundle install`
<br/>Ejecutamos Bundle para instalar las gemas.
- `RUN mkdir -p /app`
<br/>Creamos una carpeta `app` en donde tener nuestro código.
- `WORKDIR /app`
<br/>Establecemos el directorio de trabajo en la carpeta creada.
- `CMD "/bin/bash"`
<br/>Dejamos este comando para poder conectarnos fácilmente al contenedor por consola.

### Ignorando ficheros con .dockerignore

No está de más tener definido nuestro fichero `.dockerignore` para asegurarnos que no llegan archivos innecesarios a la creación de la imagen o a la ejecución del contenedor.

Te recomiendo que te asegures de que `Gemfile.lock` y la carpeta `_site` están en la lista de ignorados:

```
Gemfile.lock
_site
```

## El fichero Gemfile

El código que pongo a continuación corresponde el fichero `Gemfile` en el que configuramos la versión de Jekyll a utilizar y los `plugins` soportados por GitHub Pages a día de hoy:

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

Con estos ficheros `Dockerfile`, `Gemfile` y `.dockerignore` ya tenemos todo preparado para crear nuestra imagen para Docker.

Para construirla ejecutamos el comando `build` y le damos un nombre a la imagen con su correspondiente `tag`:

```bash
docker build . -t githubpagesbase:v1.0
```

Para ponértelo aún más fácil, esta imagen la he compilado por ti y la he publicado en [Docker Hub](https://hub.docker.com/r/dagope/githubpagebase/tags){:target="_blank"} 😉.

Puedes utilizarla haciendo un `git pull dagope/githubpagebase:v1.0` y descargarla sin esfuerzo alguno.

Si todo ha ido bien con un `docker images` verás listada la imagen.
Una imagen que contiene todas las dependencias que necesitamos para ejecutar nuestra web.

![Resultado de listar la imagen con docker images](/public/uploads/2019/04/docker-images-githubpages.png)

Si decides personalizar la imagen con alguna otra característica te aconsejo que la subas a un repositorio público como [Docker Hub](https://hub.docker.com). Te ahorrarás tener que volver a generarla en otras máquinas docker y podrás hacer uso de ella directamente en el siguiente paso.

## Nuestro Docker Compose

Ha llegado la mejor parte y más divertida: cómo hacer nuestro fichero *yaml* para arrancar nuestra web creada con Jekyll.

Creamos un fichero `docker-compose.yml` en la raíz de nuestro repositorio web con la siguiente definición:

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

- **`image`**: podemos usar la que hemos creado localmente o usar la publicada directamente.
- **`ports`**: mapeamos a nuestro host el puerto `4000` del contenedor que hemos expuesto en la imagen. Así podremos abrir un navegador y ver como va quedando nuestra web.
- **`volumes`**: montamos un volumen sobre nuestra carpeta de código del tipo "bind mount", es decir, el código reside en el `host` (nuestro PC) y se comparte al contenedor Docker, de esta manera mantenemos el código en local para poder editarlo y, al guardar los cambios, Jekyll irá recompilando y generando las páginas.
- **`working_dir`**: establecemos nuestro directorio de trabajo en `app`.
- **`command`**: se ejecutan varios comandos que detallamos:
    - `bundle install`: nos aseguramos de tenemos todas las dependencias instaladas correctamente.
    - `bundle exec jekyll serve`: lanza el servidor Jekyll.
        - `--host 0.0.0.0`: especificamos el host `0.0.0.0` (que quiere decir que escuche en todas las direcciones disponibles), si no tendremos problemas para poder acceder al servidor desde nuestro navegador.
        - `-w`: la opción para ejecutar el *watcher* y detectar cambios en ficheros.
        - `--force_polling`: este parámetro indica que el *watcher* sea forzado por *polling*, es decir, a intervalos regulares, sobre todo para evitar problemas desde Docker for Windows.
        - `--config "_config.yml,_config_dev.yml"`: con esta opción le decimos a Jekyll que por configuración tenemos dos ficheros. Normalmente se usa uno para el entorno desarrollo que queremos lanzar y otro con las configuraciones en producción. Pero esto es totalmente opcional según cada uno.

Ahora solo queda lanzar tu contenedor con un:

```bash
docker-compose up
```

Si todo va bien verás por consola cómo el contenedor sirve la web en el puerto 4000. Ahora abre un navegador y escribe la dirección:

`http://localhost:4000`

y deberías ver todo funcionando correctamente.

>**Importante**: No olvides hacer un `docker-compose down` cuando quieras detener el entorno.

# Conclusión

Hemos podido aplicar la tecnología de contenedores que nos ofrece Docker para tener un entorno de desarrollo mucho más versátil y fácil de replicar en cualquier PC. Para este proyecto muy simple como es la construcción de webs estáticas hemos preparado un entorno con Ruby, instalado dependencias, compilado nuestro código, ejecutado un servidor web. Todo ello sin haber realizado ningún proceso de instalación de SDKs, Runtimes, Configuraciones, etc... en lo que tardes en descargar la imagen tienes arrancado el proyecto.

Si te imaginas en un proyecto más grande, que tenga varias APIs REST (una en .NET, otra en Java, en Go...), varios portales Web, más de una base de datos (MySQL, SQLServer), _scripts_ de migraciones de datos, tareas en segundo plano... ¿Cuánto tardarías en arrancar todo localmente?

Happy coding!