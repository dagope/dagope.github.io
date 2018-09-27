---
published: true
layout: post
title: Entity Framework 6 y sus migraciones.
author: David Gonzalo
comments: true
categories: [EF6, NET]
---
En este artículo voy a intentar explicar como usar las migracioness en Entity Framework (EF6) y las operaciones que podemos realizar para acabar manejándolas sin ningún problema. 
Para que esté bien claro, este post es sobre EF6, en uno posterior trataré sobre EF Core. 
<!--break-->
<br/><br/>Esto no pretende ser una guía de EF, por lo que doy por hecho que se conoce EF, como funciona la creación de contextos. Para ello te remito al tutorial con toda la info  [http://www.entityframeworktutorial.net](http://www.entityframeworktutorial.net){:target="_blank"}. 

<!-- TOC -->

- [Migraciones Automáticas y cuándo usarlas](#migraciones-automáticas-y-cuándo-usarlas)
- [Como resetear por completo la BD, eliminando las migraciones y empezando de cero.](#como-resetear-por-completo-la-bd-eliminando-las-migraciones-y-empezando-de-cero)
    - [Extendiendo y personalizando una migración](#extendiendo-y-personalizando-una-migración)
- [Como crear nuevas migraciones:](#como-crear-nuevas-migraciones)
- [Editar una migración creada](#editar-una-migración-creada)
- [Migrar a una versión concreta (Downgrade)](#migrar-a-una-versión-concreta-downgrade)
- [Listado de migraciones en nuestra BD](#listado-de-migraciones-en-nuestra-bd)
- [Depurar el Seed de Inicializacion de datos:](#depurar-el-seed-de-inicializacion-de-datos)
- [Cómo usar las migraciones con el resto del equipo de desarrollo](#cómo-usar-las-migraciones-con-el-resto-del-equipo-de-desarrollo)

<!-- /TOC -->

## Migraciones Automáticas y cuándo usarlas
Tener habilitadas las migraciones automáticas puede ser muy útil cuando arrancamos un proyecto o hacer pruebas de concepto, pero más allá de esos casos yo las desaconsejo totalmente porque prefiero tener el control total que dejarlo en automático.
Para desactivarlas, lo tenemos que marcar por código en la clase *Configuration* que herede de  *DbMigrationsConfiguration*:
```c#
AutomaticMigrationsEnabled = false;
```

## Como resetear por completo la BD, eliminando las migraciones y empezando de cero.
Partiendo de una BD donde ya estábamos trabajando con EF Migrations habilitado, nos interesa eliminar todas las migraciones existentes y crear un punto de control inicial en nuestro proyecto:
<br /> ¡ATENCIÓN! **Esto eliminará todos los datos de la BD** y únicamente si tenemos establecido un Seed() serán los datos que encontraremos al final del proceso.
 
* Si disponemos una clase *Configuration* en nuestro proyecto  con alguna configuracion propia o un Seed() debemos guardarlo y agregarlo más tarde.
* Borramos en el proyecto la carpeta Migrations con todo los ficheros que contenga. Haciendo un backup de los cambios que queremos incorporar más tarde.
* Borramos en la base de datos la tabla __MigrationHistory
* Ahora activamos las Migraciones en el proyecto:
```
Enable-Migrations -ProjectName "App1.Data" -Force
```
 Especificando el parametro *-ProjectName* nos aseguramos de que ejecutamos los comandos sobre el proyecto donde reside nuestro contexto y queremos tener nuestras migraciones. También podemos seleccionarlo en el menú desplegable de la consola de PMC en Visual Studio.
 
* Creamos la primera migración
```bat
Add-Migration Initial
```
Esto nos crea la carpeta Migrations con una clase yyyymmdddhhMMss_Initial.cs y sus metadados asociados.
- Si ejecutamos esta migración sobre la BD y ya existen las mismas tablas en la BD, nos dará un error (lógico)
<br />Como truco podemos abrir el fichero yyyymmdddhhMMss_Initial.cs y en el método Up() agregar al principio una llamada al método Down() para que limpie todo aquello que exista.
<br />Para obtener el script de los cambios que se harán, agregamos el parámetro -Script:
```bat
Update-Database -ProjectName "App1.Data" -verbose  -Force -Script
```
- Con el truco de antes, ejecutamos el comando siguiente y tendremos sincronizada la  BD para arrancar desde cero.
```bat
Update-Database -ProjectName "App1.Data" -verbose
```

### Extendiendo y personalizando una migración
Si la migración Initial queremos que sea un reset completo, automático, y que no falle aunque lo ejecutemos N veces. Hay que ir un paso más allá personalizando y extendiendo operaciones de migración.
Si en el punto anterior hemos borrado la BD y volvemos a ejecutar el mismo update-database obtendremos un error.
<br />*¿Por qué?*
<br />Pues porque el script que se genera de un DropTable no comprueba si la tabla existe previamente.
<br />*¿Y ahora qué hacemos?*
<br/>Para todo hay solución y EF nos permite crear nuestra propia operación y personalizar el código generado en la migración, así que podemos crear un método de extensión llamado *DropTableIfExists* y ejecutar el codigo sql para verificar que la tabla existe, antes de borrarlo. 
La intención es que se ejecute el siguiente script sql (los ejemplos están contra una BD de SqlServer):
```sql
IF EXISTS (SELECT name FROM sys.tables WHERE name = N'tabla' AND object_id = object_id(N'[dbo].[tabla]', N'U'))
DROP TABLE [dbo].[tabla]
```
* Creamos la operación:
```c#
 public class DropTableIfExistsOperation : MigrationOperation
    {
        public string Table { get; private set; }
        public string Schema { get; private set; }
        public DropTableIfExistsOperation(string table): base(null)
        {
            if (table.Contains('.'))
            {
                Schema = table.Split('.')[0];
                Table = table.Split('.')[1];
            }
            else
            {
                Schema = "dbo";
                Table = table;
            }
                


        }
        
        public override bool IsDestructiveChange
        {
            get
            {
                return false;
            }
        }
    }
```
* Creamos la clase que genera el codigo sql sobre la operación que queremos realizar:
```c#
public class CustomSqlServerMigrationSqlGenerator : SqlServerMigrationSqlGenerator
    {
        protected override void Generate(MigrationOperation migrationOperation)
        {
            var operation = migrationOperation as DropTableIfExistsOperation;
            if (operation != null)
            {
                using (var writer = Writer())
                {
                    //writer.WriteLine(template,operation.Table);
                    writer.WriteLine("IF EXISTS (SELECT name FROM sys.tables WHERE name = N'{0}' AND object_id = object_id(N'[{1}].[{0}]', N'U'))", operation.Table, operation.Schema);
                    writer.Write("  DROP TABLE [{1}].[{0}]", operation.Table, operation.Schema);
                    

                    Statement(writer);
                }
            }
        }
    }
```
* Exponemos el método de extensión sobre la clase DbMigration
```c#
public static class Extensions
{
    public static void DropTableIfExists(this DbMigration migration, string table)
    {
        ((IDbMigration)migration).AddOperation(new DropTableIfExistsOperation(table));
    }
}
```
* Ahora en nuestro método Down la migración Initial podemos sustituir los ```DropTable("dbo.tabla")``` por nuestro ```this.DropTableIfExists("dbo.tabla")``` 

<br />Ahora podemos ejecutar:
```bat
Update-Database -ProjectName "App1.Data" -TargetMigration 0 -verbose -Script
```
Estaremos bajando a la migración con nombre *Initial* (la cúal también se puede indicar con valor cero).
Y si ahora ejecutamos nuevamente veremos que no falla:
```bat
Update-Database -ProjectName "App1.Data" -verbose
```

* Con esto ya que podemos eliminar por completo nuestra BD y actualizarla sin problemas a la última migración.

## Como crear nuevas migraciones:
Nuestro código cambia y es normal que nuestra BD también evolucione, creando o borrando nuevos campos, tablas, etc...
<br/>Cuando tengamos listos nuestros cambios ejecutamos el siguiente comando para crear una nueva migración.
```bat
Add-Migration -Name NombreDeMigracion -ProjectName "App1.Data"
```
<br />Esto generará una clase en la carpeta Migrations con el formato *yyyyMMdd_NombreDeMigracion.cs*
<br />En este fichero podremos personalizar lo que nos interese, como por ejemplo inicializar el valor de los campos.
<br />Y para establecer los cambios nuevamente ejecutamos el comando.
```bat
Update-Database -ProjectName "App1.Data" -verbose
```
agregar el comando  -Script si queremos el ScriptSQL de ejecución de cambios.
<br /><br />**Oh! te has olvidado de añadir algo en la migración??**
<br /> que nadie se asuste ;-) vamos a explicarlo en el siguiente punto.

## Editar una migración creada
¿Y si quiero editar una migración sin tener que crear otra nueva con el scaffolding aplicado? 
Durante el desarrollo de una tarea, es muy probable que nos encontremos con la necesidad de cambiar nuestra migración por ejemplo para incluir esa columna que nos haya podido olvidar en un primer momento. Por otra parte tampoco queda muy elegante tener 5 o 6 migraciones para una misma tarea de desarrollo.
<br />Para editar nuestra migración:
- Revisar en que estado se encuentra nuestra BD. Y situarnos en la migración anterior a la que vamos a editar.
```bat
Update-Database -ProjectName "App1.Data" -TargetMigration:Migracionv1
```
- Ejecutar el comando de Add-Migrations indicando el nombre exacto de la migración que queremos editar, por lo general *yyyymmdddhhMMss_NombreDeMigracion*, y agregar el parámetro **-Force** para forzar el re-scaffold de la migración entera. Si no lo haces verás un warning amarillo que te lo indicará.
```bat
Add-Migration -Name full_name_including_timestamp_of_last_migration -ProjectName "App1.Data" -Force
```
- Una vez finalizado veremos como nuestro fichero de migración ha sido actualizado con los cambios que deseamo.

<br/>Si intentamos hacer el proceso de forma manual y no usando los comandos, tendremos problemas al agregar próximas migraciones. El comando *add-migration* también se encarga de modificar el fichero .resx que contiene un valor serializado del estado de la BD. 

podemos consultar la tabla  __MigrationHistory order by MigrationId desc
<br />Para editar nuestra migración: tendremos que ejecutar el comando de Add-Migrations indicando el nombre exacto de la migración que queremos sobrescribir, por lo general *yyyymmdddhhMMss_NombreDeMigracion*, y agregar el parámetro **-Force** para forzar el re-scaffold de la migración entera. Si no lo haces verás un warning amarillo que te lo indicará.
```bat
Add-Migration -Name full_name_including_timestamp_of_last_migration -ProjectName "App1.Data" -Force
```
**OJO!**
<br/> si ya ejecutaste un UpdateDatabase antes de editar la migración, 
sería recomendable poner la BD en el estado anterior a la migración. Y posteriormente volver a realizar un update-database.

## Migrar a una versión concreta (Downgrade)
Para migrar la Bd a una situación en concreto debe indicarse el parámetro **-TargetMigration** al comando update-database.
Tal que así:
```bat
Update-Database -ProjectName "App1.Data" –TargetMigration: NombreDeMigracion
```
<br/>Para volver al inicio del todo y a una base de datos "vacía" (primera migración):
```bat
Update-Database -ProjectName "App1.Data" –TargetMigration: $InitialDatabase.
Update-Database -ProjectName "App1.Data" –TargetMigration 0.
```
## Listado de migraciones en nuestra BD
Para obtener las migraciones que están aplicadas sobre nuestra BD usaremos el siguiente comando
```bat
Get-Migrations -ProjectName "App1.Data"
```

## Depurar el Seed de Inicializacion de datos:
Descomentar o añadir las siguientes líneas en la clase Configuration que sería algo como: *App1.Data.Migrations.Configuration*
```c#
protected override void Seed(App1.Data.Context.ApplicationDbContext context) {
    if (System.Diagnostics.Debugger.IsAttached == false){
        System.Diagnostics.Debugger.Launch();
    }
    System.Diagnostics.Debugger.Break();

[...]
}
```



## Cómo usar las migraciones con el resto del equipo de desarrollo
Hay un artículo muy completo en la documentación de Microsoft que explica con ejemplos claros y sencillos como manejar las migraciones y las diferentes situaciones que nos podemos encontrar al usarlas cuando nuestro equipo de trabajo hay varios programadores que pueden estar cambiando la base de datos.
<br/> Un artículo muy recomendado: [https://msdn.microsoft.com/en-us/data/dn481501.aspx](https://msdn.microsoft.com/en-us/data/dn481501.aspx){:target="_blank"}. 


<br/>
<br/>
<br/>
Espero que alguien más a parte de mi yo futuro encuentre útil estas notas.

Saludos.