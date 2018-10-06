---
published: true
layout: post
title: Entity Framework 6 y sus migraciones.
author: David Gonzalo
comments: true
categories: [EF6, NET]
---
En este artículo voy a intentar explicar cómo usar las migraciones en Entity Framework (EF6) y las operaciones que podemos realizar para acabar manejándolas sin ningún problema. 
Para que esté bien claro, este post es sobre EF6, en uno posterior trataré sobre EF Core. 

<!--break-->
<!-- TOC -->

- [Migraciones Automáticas y cuándo usarlas](#migraciones-automáticas-y-cuándo-usarlas)
- [Habilitar migraciones en una BD y viendo el detalle](#habilitar-migraciones-en-una-bd-y-viendo-el-detalle)
    - [Extendiendo y personalizando una migración](#extendiendo-y-personalizando-una-migración)
- [Como crear nuevas migraciones:](#como-crear-nuevas-migraciones)
- [Editar una migración creada](#editar-una-migración-creada)
- [Crear una migración vacía](#crear-una-migración-vacía)
    - [Cómo agrear mi script SQL a una migración](#cómo-agrear-mi-script-sql-a-una-migración)
- [Migrar a una versión concreta (Downgrade)](#migrar-a-una-versión-concreta-downgrade)
- [Listado de migraciones en nuestra BD](#listado-de-migraciones-en-nuestra-bd)
- [Depurar el Seed de Inicializacion de datos:](#depurar-el-seed-de-inicializacion-de-datos)
- [Cómo usar las migraciones con el resto del equipo de desarrollo](#cómo-usar-las-migraciones-con-el-resto-del-equipo-de-desarrollo)

<!-- /TOC -->

<br/>Esto no pretende ser una guía de EF, por lo que doy por hecho que se conoce EF, y como funciona la creación de contextos. Sino para ello que mejor que una web con del tutorial con toda la info  [http://www.entityframeworktutorial.net](http://www.entityframeworktutorial.net){:target="_blank"}. 


## Migraciones Automáticas y cuándo usarlas
Tener habilitadas las migraciones automáticas puede ser muy útil cuando arrancamos un proyecto o hacer pruebas de concepto, pero más allá de esos casos yo las desaconsejo totalmente porque prefiero tener el control total que dejarlo en automático.
Para desactivarlas, lo tenemos que marcar por código en la clase *Configuration* que herede de  *DbMigrationsConfiguration*:
```c#
AutomaticMigrationsEnabled = false;
```
## Habilitar migraciones en una BD y viendo el detalle
* Lo primero que tenemos que hacer para tener disponibles las migraciones, es agregar los paquetes Nuget a nuestro proyecto. Buscamos EntityFramework en el *Manage NuGet Package* o bien por la PMC (*Package Manage Console*):
Es bueno que nos acostumbremos a usar la consola porque a partir de aquí ejecutaremos todos los comandos de migraciones sobre ella.
```bat
Install-Package EntityFramework
```
* A continuación, activamos las Migraciones en el proyecto que queramos de nuestra solución. Para indicarle un proyecto concreto usaremos el parámetro *-ProjectName "Nombre.Del.Proyecto", en los siguientes ejemplos usaremos el valor *App1.Data*.
<br/> Recuerda que el comando se ejecuta desde la PCM
```bat
Enable-Migrations -ProjectName "App1.Data" 
```
Esto nos creará una carpeta *Migrations* y un fichero *Configuration.cs* donde podemos cambiar el comportamiento de las migraciones sobre el contexto. Aqui es donde tenemos la opción de habilitar las migraciones automáticas, o de establecer una inicialización de datos. 

- Si no tenemos un contexto nos dará un error. 
- Si no tenemos configurada la cadena de conexión en nuestro fichero de configuración, nos dará error.

* A modo de ejemplo pongo este contexto, y configurar una cadena de conexión con el nombre *Default*

```c#
public class SampleDbContext : DbContext
{
    public IDbSet<User> Users { get; set; }

    static SampleDbContext()
    {
    }

    public SampleDbContext() : base("name=Default")
    {

    }
    
    
    protected override void OnModelCreating(DbModelBuilder modelBuilder)
    {
        this.CommonModelCreating(modelBuilder);
        
        base.OnModelCreating(modelBuilder);
    }

    private void CommonModelCreating(DbModelBuilder modelBuilder)
    {
        
    }
    
}
```
* Creamos la primera migración
```bat
Add-Migration Initial
```
Esto nos crea en la carpeta *Migrations* una clase *yyyymmdddhhMMss_Initial.cs* con dos ficheros más asociados:
- yyyymmdddhhMMss_Initial.cs
<br/> Esta clase contiene los métodos Up() y Down(). En su interior encontrarás el código de creación/borrado de tablas/columnas que el scaffolding detectó en los cambios de tus entidades.
- yyyymmdddhhMMss_Initial.Designer.cs
<br/> Genera el código con los datos referentes a la migración creada y la referencia al fichero de recursos resx.
- yyyymmdddhhMMss_Initial.resx
A modo informativo este fichero de recursos contiene un snapshot del esquema de base de datos referente a nuestro contexto en la migración actual. Aunque el valor está serializado, le sirve a las herramientas para controlar el estado de nuestra DB en comparación a nuestro código. Si algo no fuese bien nos daría un error.
<br/> 
Ambos ficheros son de generación de código por parte del programa y no deberíamos hacer ningún cambio sobre ellos.


* Para ejecutar la migración sobre la BD: 
```bat
Update-Database -ProjectName "App1.Data" -verbose -Script
```
El parámetro -Script es opcional. Si lo indicamos obtendremos el script sql de los cambios que se ejecutarán.

Ahora si inspeccionamos la tabla *__MigrationHistory* veremos el registro correspondiente a la migración creada.
![Select Migration]({{site.baseurl}}public/uploads/2018/10/SelectMigration.jpg)


### Extendiendo y personalizando una migración
Si la migración Initial queremos que sea un reset completo, automático, y que no falle aunque lo ejecutemos N veces, hay que ir un paso más allá personalizando y extendiendo operaciones de migración.
Si en el punto anterior hemos borrado la BD y volvemos a ejecutar el mismo update-database obtendremos un error.
<br />*¿Por qué?*
<br />Pues porque el script que se genera de un DropTable no comprueba si la tabla existe previamente.
<br />*¿Y ahora qué hacemos?*
<br/>Para todo hay solución y EF nos permite crear nuestra propia operación y personalizar el código generado en la migración, así que podemos crear un método de extensión llamado *DropTableIfExists* y ejecutar el código sql para verificar que la tabla existe, antes de borrarlo. 
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
* Creamos la clase que genera el código sql sobre la operación que queremos realizar:
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
- Una vez finalizado veremos como nuestro fichero de migración ha sido actualizado con los cambios que deseamos.

<br/>Si intentamos hacer el proceso de forma manual y no usando los comandos, tendremos problemas al agregar próximas migraciones. El comando *add-migration* también se encarga de modificar el fichero .resx que contiene un valor serializado del estado de la BD. 

podemos consultar la tabla  __MigrationHistory order by MigrationId desc
<br />Para editar nuestra migración: tendremos que ejecutar el comando de Add-Migrations indicando el nombre exacto de la migración que queremos sobrescribir, por lo general *yyyymmdddhhMMss_NombreDeMigracion*, y agregar el parámetro **-Force** para forzar el re-scaffold de la migración entera. Si no lo haces verás un warning amarillo que te lo indicará.
```bat
Add-Migration -Name full_name_including_timestamp_of_last_migration -ProjectName "App1.Data" -Force
```
**OJO!**
<br/> si ya ejecutaste un UpdateDatabase antes de editar la migración, 
sería recomendable poner la BD en el estado anterior a la migración. Y posteriormente volver a realizar un update-database.

## Crear una migración vacía
Hay veces que podemos tener cambios en objetos de nuestra BD que no interfieren directamente sobre nuestro contexto y el scaffolding no lo detecta. Cambios por ejemplo en un *store procedure*, function, views, etc...
<br/>Para tener controlados en nuestro historial de migraciones este tipo de cambios , tenemos que generar una migración vacía.
<br/>¿Cómo se hace?
<br/>Exactamente de la misma manera que creando una migración normal.
```bat
Add-Migration -Name ChangesInStoreProcedures -ProjectName "App1.Data" 
```
Esto nos genera nuestra migración con la diferencia de que los métodos Up() y Down() están vacíos.

### Cómo agrear mi script SQL a una migración
Para ejecutar cualquier script sql en los métodos Up() y Down() de nuestro fichero migration, tenemos el método Sql(...) heredado de DbMigration.
<br/>¿Queremos agregar una vista al modelo de datos? Pues un ejemplo sería así:
```c#
public partial class ChangesInViews : DbMigration
    {
        public override void Up()
        {
            string scriptSql = @"
CREATE VIEW [dbo].[vw_Users]
AS
    select Id, Name, Email, IsBlocked
    from dbo.Users
GO
";
            Sql(scriptSql);
        }
        
        public override void Down()
        {
            string scriptSql = @"DROP VIEW [dbo].[vw_Users]";

            Sql(scriptSql);
        }
    }
```
Obviamente, si el escript no es correcto la migración fallará. Es tú responsabilidad que se ejecute correctamente, tanto para Up() como para Down().

## Migrar a una versión concreta (Downgrade)
Para migrar la Bd a una situación en concreto debe indicarse el parámetro **-TargetMigration** al comando update-database.
Tal que así:
```bat
Update-Database -ProjectName "App1.Data" –TargetMigration NombreDeMigracion
```
<br/>Para volver al inicio del todo y a una base de datos "vacía" (primera migración):
```bat
Update-Database -ProjectName "App1.Data" –TargetMigration $InitialDatabase.
```
o también indicando un cero:
```bat
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