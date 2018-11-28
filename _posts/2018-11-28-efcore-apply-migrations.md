---
published: true
date: 2018-11-28 09:24:00 +0100
layout: post
title: Aplicando las migraciones en EF Core
author: David Gonzalo
comments: true
categories: [EFCore, NetCore]
excerpt: Aplicando migraciones en tiempo de ejecución con EF Core.
---
Continuando con las migraciones de EF Core del [post anterior]({{ site.baseurl }}2018/11/20/efcore-migrations), resulta muy útil saber cómo aplicarlas de forma "automática". 
Durante el desarrollo de un proyecto vamos creando migraciones y ejecutándolas con el comando ya conocido ```update-database```. 
Como miembro del equipo puedes estar desarrollando una funcionalidad en la que desconozcas cuando otro de tus compañeros ha necesitado crear una nueva migración, entonces ¿qué pasará cuando nos descarguemos los cambios del compañero? <!--break--> Pues que no se aplicarán los cambios en nuestra base de datos hasta que lo hagamos manualmente. Esto es un poco engorroso y puede producir errores en tiempo de ejecución inesperados. 

Podemos evitar este problema y hacer que el resto del equipo de desarrollo se despreocupe de lanzar el comando update de una tarea que desconoce. 

## Aplicar migraciones al arranque del proyecto
Si queremos asegurarnos de que la BD está con las últimas migraciones creadas, podemos configurar que se apliquen las migraciones en tiempo de ejecución de nuestra aplicación. 
El siguiente método de ejemplo podemos incluirlo dentro de nuestra Startup.cs y llamarlo desde ```Configure(IApplicationBuilder app, IHostingEnvironment env)```
```c#
private void ApplyLastMigrationsEF(IApplicationBuilder app)
{
    var scopeFactory = app.ApplicationServices.GetRequiredService<IServiceScopeFactory>();
    using (var scope = scopeFactory.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<SampleDBContext>();
        dbContext.Database.Migrate();
    }
}
``` 

Si te fijas en el código, únicamente tendremos que obtener el contexto y ejecutar el método ```Migrate()```.
De esta manera migramos nuestra BD al estado de ejecución de nuestra aplicación.

Aquí debajo pongo un ejemplo de lo que podría ser la clase Startup de una API Rest en NetCore.
<script src="https://gist.github.com/dagope/01ce0c4263c3060c7a7458fe7a9e2666.js"></script>


Happy coding!
<br/>
David.