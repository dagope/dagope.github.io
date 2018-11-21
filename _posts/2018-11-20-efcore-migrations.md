---
published: true
date: 2018-11-20 15:00:56 +0100
layout: post
title: Entity Framework Core y sus migraciones.
author: David Gonzalo
comments: true
categories: [EFCore, NetCore]
---
En esta ocasión voy a comentar las tareas que podemos realizar en las Migrations de Entity Framework Core (EFCore), y saber qué hacer con cada uno de los comandos.
Difieren un poco de las usadas en EF6, que ya comenté en un artículo anterior y puedes leer [aquí]({{ site.baseurl }}2018/09/27/EF6-migraciones-comandos).

<!--break-->

<br/>Esto no pretende ser una guía de EF Core, por lo que se recomienda tener conocimientos sobre el funcionamiento del mismo y de la creación de contextos. Para ello que mejor que un tutorial con toda la info:
[http://www.entityframeworktutorial.net/efcore/entity-framework-core.aspx](http://www.entityframeworktutorial.net/efcore/entity-framework-core.aspx){:target="_blank"}. 

Para las tareas que voy a explicar es suficiente con el uso de los comandos desde la PMC (*Package Manage Console*). También es bueno que conozcas los comandos desde la CLI *(Command Line Interface)*, hacen uso del tooling de dotnet y tienen más opciones de manejo.

Vamos con el contenido:
- [Migraciones Automáticas en EF Core](#migraciones-automáticas-en-ef-core)
- [Habilitar migraciones en una BD y viendo el detalle](#habilitar-migraciones-en-una-bd-y-viendo-el-detalle)
- [Como crear nuevas migraciones](#como-crear-nuevas-migraciones)
- [Editar la migración creada](#editar-la-migración-creada)
- [Crear una migración vacía](#crear-una-migración-vacía)
    - [Cómo agregar mi script SQL a una migración](#cómo-agregar-mi-script-sql-a-una-migración)
- [Migrar a una versión concreta (Downgrade)](#migrar-a-una-versión-concreta-downgrade)
- [Eliminar una migración](#eliminar-una-migración)
- [Listado de migraciones en nuestra BD](#listado-de-migraciones-en-nuestra-bd)


## Migraciones Automáticas en EF Core
En el [post de EF6]({{ site.baseurl }}2018/09/27/EF6-migraciones-comandos/#migraciones-automáticas-y-cuándo-usarlas) os aconsejaba no utilizar las migraciones automáticas y tener más control sobre las mismas. 
Pues bien, si seguís ese consejo vais por buen camino a la hora de migrar hacia EFCore ya que esta *"feature"* no ha sido incluida y tampoco se la espera. Como bien explica Diego Vega en este [issue de github](https://github.com/aspnet/EntityFrameworkCore/issues/6214#issuecomment-239519498){:target="_blank"},  *la experiencia de migraciones basadas en código han mostrado ser más manejables*.

Por lo tanto, **las migraciones automáticas son cosa del pasado**. Si no las usabas en EF6 tienes camino aprendido ;-)

## Habilitar migraciones en una BD y viendo el detalle
Las migraciones son parte del cómo funciona EF Core y no es necesario ejecutar ningún comando ni realizar nada especial como se hace con EF6. Obviamente, sus paquetes nuget tienen que ser referenciados en el proyecto.
<br/>Cuando creas la primera migración con el commanto ```Add-migration``` obtendrás una nueva carpeta *Migrations* y 3 ficheros:
- Carpeta **Migrations**:
<br/>Aquí se almacenarán todos los ficheros con el código de las migraciones que vayas creando durante el desarrollo de tu proyecto.
- **yyyymmdddhhMMss_MigrationName.cs**
<br/> Esta clase contiene los métodos Up() y Down(). En su interior encontrarás el código de creación/borrado de tablas/columnas que el scaffolding detectó en los cambios de tus entidades.
- **yyyymmdddhhMMss_MigrationName.Designer.cs**
<br/> Si ojeas verás que es el snapshot de tu esquema en la migración que has creado.
- **ContextNameModelSnapshot.cs**
<br/> Este fichero contiene el snapshot de los cambios de tu migración. Sirve para que detectar tus cambios cuando vas creando migraciones.


## Como crear nuevas migraciones
Cuando tengamos listos nuestros cambios ejecutamos el siguiente comando para crear una nueva migración.
```bat
Add-Migration -Name NombreDeMigracion -Project "App1.Data" -context SampleDbContext
```
<br />Esto crea una clase en la carpeta Migrations con el formato *yyyyMMdd_NombreDeMigracion.cs*
<br />Aquí podemos personalizar lo que nos interese, como por ejemplo inicializar el valor de los campos, etc... Pero ten en cuenta que las personalizaciones son únicas, es decir, si eliminas la migración y la vuelves a crear, tendrás que codificarlas de nuevo.
<br />Y como siempre, para establecer los cambios ejecutamos el comando.
```bat
Update-Database -ProjectName "App1.Data" -verbose
```

## Editar la migración creada
Cuando queremos incluir más cambios de nuestro modelo en una migración ya creada:

- Eliminar la última migración. 
```bat
remove-migration -context SampleDbContext
```
- Creamos de nuevo la migración. En este punto podríamos cambiar el nombre si lo deseamos.
```bat
Add-Migration -Name NombreDeMigracion -Project "App1.Data" -context SampleDbContext
```

Recuerda que si tienes algún script sql o modificación que hayas realizado en la migración debes hacer una copia de ese código para añadirlo en el último paso.

## Crear una migración vacía
Hay veces que podemos tener cambios en objetos de nuestra BD que no interfieren directamente sobre nuestro contexto y el scaffolding no lo detecta. Cambios por ejemplo en un *store procedure*, function, views, etc...
<br/>Para tener controlados en nuestro historial de migraciones este tipo de cambios, tenemos que generar una migración vacía.
<br/>¿Cómo se hace?
<br/>Exactamente de la misma manera que creando una migración normal.
```bat
Add-Migration -Name ChangesInStoreProcedures -Project "App1.Data" -context SampleDbContext
```
Esto nos genera nuestra migración con la diferencia de que los métodos Up() y Down() están vacíos.
Si te fijas el fichero *SampleDbContextModelSnapshot.cs* no ha cambiado porque no se han detectado cambios. 
Si utilizas git u otro control de versiones en tu proyecto es fácil observar los ficheros que se han creado y modificados, incluso comparar con versiones anteriores para observar que se hizo.

No olvidemos que ambos métodos deben ser implementados y probados. Es un error muy común centrarse solo en el código para el Up() olvidarse del Down(). Es tú responsabilidad que la migración pueda ser ejecutada en cualquier dirección. Así que codifiquemos ambos, ejecutemos el comando para upgrade y después para downgrade. Así aseguramos que no la líamos.

**Recuerda**: tan importante es el método Down() como el Up().


### Cómo agregar mi script SQL a una migración
En los métodos Up() y Down() tienes el parámetro migrationBuilder que tiene un método SQL() para pasarle un string que ejecutar.
```c#
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.Sql(@"Create Function fn_MyFunction() [...] ");
}
```

## Migrar a una versión concreta (Downgrade)
Para migrar la BD a una situación en concreto debe indicarse el parámetro **-Migration** al comando update-database.
Tal que así:
```bat
Update-Database –Migration NombreDeMigracion -Project "App1.Data" -context SampleDbContext
```
<br/>Para volver al inicio del todo y a una base de datos "vacía" (sin ninguna migración aplicada):
```bat
Update-Database -Migration 0 -Project "App1.Data" -Context ClientDbContext
```


## Eliminar una migración
El comando Remove-Migration eliminar la última creada.
```bat
remove-migration -context SampleDbContext
```
Ten cuenta que si la migración ha sido aplicada a la base de datos con un *update-database* obtendrás un error avisándote que primero debes hacer un downgrade a la versión anterior.

## Listado de migraciones en nuestra BD
Para saber que migraciones están aplicadas sobre la BD, la mejor opción es ejecutar la siguiente query:
```sql
select * from __EFMigrationsHistory
```
A día de hoy no tenemos comando como en EF6 desde la PCM para listar las migraciones, pero podemos hacerlo por CLI ejecutando:
```bat
dotnet ef migrations list -Project "App1.Data" -context SampleDbContext
```

<br/><br/>

Happy coding!
<br/>
David.