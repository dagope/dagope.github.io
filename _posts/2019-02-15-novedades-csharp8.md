---
published: false
date: 2019-02-15 00:00:00 +0100
layout: post
title: Novedades de C# 8.0 al escenario
author: David Gonzalo
comments: true
categories: [C#, Net]
excerpt: Cómo son vistas las novedades de c# 8.0 por quienes las usarán.
words: 2433
---
El pasado 23 de enero tuve el placer de compartir escenario en la [@NetCoreConf](https://twitter.com/netcoreconf){:target="_blank"} de Barcelona con mi amigo 
[@fernandoescolar](https://twitter.com/fernandoescolar){:target="_blank"}
, y exponer las novedades que nos traerá C# 8.0 en este 2019. Puede que estés pensando "¡uff! eso debió ser una buena siesta y este post de resumen apunta a lo mismo", así que siendo conscientes de que podría producirse tal situación, decidimos aplicar la escala HotCrazy que en su día hizo Fernando con [la versión 7.0](http://fernandoescolar.github.io/2016/11/16/csharp-7/){:target="_blank"},
 pero en esta ocasión sería la audiencia la encargada de evaluar y poner nota a las diferentes *features*. 

En este artículo explicaré cada una de las novedades y veremos las puntuaciones obtenidas del público.
  <!--break--> 
 <div class="note note">
    <ul>
        <li>El público en ningún momento ha sido coaccionado para su votación.</li>
        <li>Los resultados no han sido manipulados (a pesar de los trols). </li>
        <li>Y ningún gatito ha sido maltratado.</li>
    </ul>
</div>



## Antes de empezar
Es bueno conocer un poco de historia, tan importante es saber de dónde viene un lenguaje como a donde se dirige. 
Si estás interesado en los orígenes de C# te recomiendo 
[este artículo](http://fernandoescolar.github.io/2019/02/05/historia-csharp/){:target="_blank"}
donde Fernando lo ha resumido muy bien hasta el día de hoy. 

Por otro lado, vamos a comentar brevemente como va esto de la escala _hot-crazy_.

![escala sexy loca]({{site.baseurl}}public/uploads/2019/02/hot_crazy.jpg)

Cada *feature* estará representada en el eje Y por lo útil que nos resulta y en el eje X lo extraño/loco/incomprensible (pon el sinónimo que quieras) que nos parece su implementación.
El objetivo es estar por encima de _la diagonal Vicky Mendoza_ (x=y) para poder considerarse una buena *feature*.

<br/>¡Bueno vamos a meternos en harina!

## Nullable reference types
El propósito de esta nueva característica es ayudar con la gestión de valores “null” en nuestras variables mediante warnings. 
La idea es "obligar" a marcar los tipos de referencia, p.ej: ```string``` o cualquier otra clase, como nulos haciendo uso del ya conocido símbolo de interrogación ```?```.

Si ejecutamos este código sobre C#7.0 obtendríamos un error en tiempo de ejecución:
```csharp
using static System.Console;
class Program
{
    static void Main(string[] args)
    {
        string s = null;
        WriteLine($"The first letter of {s} is {s[0]}"); //Se produce un error porque s es null ---> NullReferenceException
    }
}
```
Si intentamos nular el tipo string con ```string? s= null``` verás que el editor te avisa de que solo puedes nular tipos que sean non-nullable, y ```string``` es uno de ellos. 
{% include code_image.html 
image='2019/02/csharp8_error_string_null_c7.png'
title='Error cuando marcamos null en tipo string en CSharp 7'
target='_blank'
%}

Y aquí es donde la feature que trae C# 8.0 aparece. Con el código de arriba obtendríamos un warning en la línea que en tiempo de ejecución nos estaba fallando.
Lo bueno es que **ahora podemos marcar los tipos nulables** y que el compilador sepa donde hacemos uso de ellos, mostrándonos un warning en el caso de no validar correctamente el valor null.

Y el código anterior con C#8.0 nos quedaría así:
```csharp
using static System.Console;
class Program
{
    static void Main(string[] args)
    {
        string? s = null;
        WriteLine($"The first letter of {s} is {s[0] ?? 'null' }");
    }
}
```

¿Que ganamos? **Evitar posibles errores en tiempo de ejecución.**

Parece que el público se ha dado cuente de ello.

> <p><b>Valoración del público</b>:</p>
> <p>Useful = <b>6.0</b></p>
> <p>Crazy = <b>3.5</b></p>


## Async streams
Para facilitar el flujo de iteraciones de forma asíncrona en casos donde queremos leer datos sin bloquear la ejecución de un proceso, aparece ```IAsyncEnumerable```, que no es lo mismo que hacer ```async-await``` de una tarea que retorana un IEnumerable. 

Mejor explicarlo con un ejemplo de código que con tanta prosa.

```csharp
static async Task Main(string[] args)
{
    foreach(var data in await GetBigResultsAsync())
    {
        Console.WriteLine($"{DateTime.Now.ToString()}  => {data}");
    }
 
    Console.ReadLine();
}
 
static async Task<IEnumerable<int>> GetBigResultsAsync()
{
    List<int> data = new List<int>();
    for (int i = 1; i <= 10; i++)
    {
        await Task.Delay(1000); //Simulate waiting for external API
        data.Add(i);
    }
 
    return data;
}
```
En el código de arriba el método GetBigResultsAsync() simula que tarda 1 segundo en obtener un dato numérico. 
Iterando 10 veces tardaremos 10 segundos en devolver todos los datos en nuestra list.
Está sucediendo que desde el primer segundo ya tenemos un dato que podría estar aprovechando los otros 9 segundos para ir procesándose. ¡Estamos desperdiciando un tiempo precioso de poner nuestra CPU a tope!

Pero se ejecuta en bloque y no puedo utilizar ```yield``` para devolver el dato. ¿Cómo lo arreglo? 


Pues con el nuevo ```IAsyncEnumerable``` y el  ```await foreach``` podemos transformar el código dejándolo tal que así:

```csharp
static async Task Main(string[] args)
{
    await foreach(var data in GetBigResultsAsync())
    {
        Console.WriteLine($"{DateTime.Now.ToString()}  => {data}"); //Processing data
    }
 
    Console.ReadLine();
}
 
static async IAsyncEnumerable<int> GetBigResultsAsync()
{
    for (int i = 1; i <= 10; i++)
    {
        await Task.Delay(1000); //Simulate waiting for external API
        yield return i;
    }
}
```

¿Te cuesta verlo? Te ayudará la siguiente animación que compara la ejecución de ambos códigos.

{% include code_image.html 
image='2019/02/demo_csharpo8_async_streams.gif'
title='Async Streams new feature Csharp 8 '
target='_blank'
%}

Si quieres ejecutarlo tú te dejo este ejemplo en mi GitHub:
<br/>[https://github.com/dagope/chsarp8_async_streams](https://github.com/dagope/chsarp8_async_streams){:target="_blank"}

> <p><b>Valoración del público</b>:</p>
> <p>Useful = <b>7.0</b></p>
> <p>Crazy = <b>4.0</b></p>


## Rangos e Índices
Los tipos ```Range``` e ```Index``` llegan con la finalidad de ayudarnos en el manejo de una colección.
Se aplican sobre un array o cualquier objeto que cumpla con la interfaz ```IEnumerator``` y se declaran entre corchetes los índices de inicio y fin separados por dos puntos seguidos.
El índice contiene el valor que nos indica la posición del array a delimitar.


Su sintaxis sería:
```csharp
Index indexStart = 1;
Index indexEnd = ^5;
Range range = people[2..^5];
Range range = people[indexStart..indexEnd])
```

Vamos a ver como funcionan con el código:

```csharp
var people = new string[] {
    "Elena", "Armando", "Dolores", "Aitor", 
    "Leia", "Vader", "Yoda", "Skywalker"
};   
foreach (var p in people[0..3]) Console.Write($"{p}, ");    // Elena, Armando, Dolores, Aitor, 
foreach (var p in people[0..^5]) Console.Write($"{p}, ");   // Elena, Armando, Dolores, Aitor, 
foreach (var p in people[^4]) Console.Write($"{p}, ");      // Leia, Vader, Yoda, Skywalker, 
foreach (var p in people[6..]) Console.Write($"{p}, ");     // Yoda, Skywalker, 
foreach (var p in people[..]) Console.Write($"{p}, ");      // Elena, Armando, Dolores, Aitor, Leia, Vader, Yoda, Skywalker,
```

Vemos que aparece en acción un nuevo símbolo, el ```^``` circunflejo:
<br/>El uso del ```^``` circunflejo nos indica que nuestro valor del índice **comienza desde el final**.
Si pensamos en que se podría usar el ```^0```, en realidad estaríamos intentando acceder al elemento siguiente al último y como no hay no puedes llegar a él. 
Para coger elementos desde el final hacia el principio, **debemos empezar a contar los índices desde 1** y no desde 0.


Viendo el ejemplo sacamos las siguientes reglas para los índices:
- Puedo traerme un rango indicando la posicion inicio y fin tal que ```people[0..3]```
- Si quiero limitar por el final puedo omitir el indice de inicio tal que ```people[..3]```
- Si quiero limitar por el principio tambien puedo decir que comience desde *Length - posicion*, es decir ```people[^4]```
- Si quiero limitar por el principio puedo omitir el índice final tal que ```people[6..]```
- La ausencia de alguno de los índices en el rango se tomará como el inicio que delimita. Por lo tanto si omito el de inicio contará desde 0, si omito el de final tomará la última posición, sería el ```people.Length```
- Puedo omitir cualquiera de los limites indices y el rango tendría todos los valores, siendo como el valor normal entonces: 
<br/>```people[..].Length == people.Length``` 
<br/>Curioso, no?


> <p><b>Valoración del público</b>:</p>
> <p>Useful = <b>5.0</b></p>
> <p>Crazy = <b>6.5</b></p>

Parece que no caló muy bien el nuevo símbolo ^ y la gente lo encontró algo más Crazy que Useful.

## Recursive patterns

C# cada vez está cogiendo más características de los lenguajes funcionales y esta es una de ellas. ¿te suena 
[*Pattern Matching*](https://www.campusmvp.es/recursos/post/Pattern-matching-en-lenguajes-de-programacion-funcionales.aspx){:target="_blank"}
? Si es así no te costará entender esto.

Partiendo de una clase definida *Student*:
```csharp
class Student
{
    public string Name { get; set; }
    public bool Graduated { get; set; }
}
```

Si tenemos un array de objetos definidos como:

```csharp
var People = new object[] {
    new Student(){Name = "Leia", Graduated= false},
    new Student(){Name = "Yoda", Graduated= true},
    new Student(){Name = "Skywalker", Graduated= false},
}
```
En C#7 para obtener los nombres de los no graduados haríamos un ```foreach``` con una condición ```if``` y devolviendo el nombre del objeto que cumpliese la condición.

Sí, también podríamos usar Linq pero añadimos una dependencia a nuestra clase y tampoco es la finalidad del ejemplo.

El código sería:
```csharp
IEnumerable<string> GetNameStudentsNotGraduated()
{
    foreach (var p in People)
    {
        if (p is Student && !p.Graduated)
        {
            string name = p.Name;
            yield return name;
        }

    }
}
```

Y en C#8 lo podemos transformar hacia: 
```csharp
IEnumerable<string> GetNameStudentsNotGraduated()
{
    foreach (var p in People)
    {
        if (p is Student { Graduated: false, Name: string name }) 
            yield return name;
    }
}

```

Observamos que simplifica bastante la condición del ```if``` si pensamos en el filtrado que queremos hacer de nuestra colección. Debe cumplir que sea un objeto de tipo ```Student``` y con ```Graduated == false```. Además la propiedad ```Name``` me la asigne a una variable ``` string name ``` que usaré para agregarla con el ```yield``` a mi coleccion de nombres que devuelve mi función.

En mi opinión creo que es bastante más útil que *Crazy*. Y dada las valoraciones obtenidas parece que la gente optó más por el Crazy.

> <p><b>Valoración del público</b>:</p>
> <p>Useful = <b>5.0</b></p>
> <p>Crazy = <b>7.5</b></p>

## Switch expressions

Esta característica viene a elevar los bloques ```switch``` a su máxima potencia tras haberse metido una buena fumada. 

1. Ahora podremos olvidarnos del ```case``` y en su lugar poner la "condición" de varias maneras:
 - Puedo seguir usando mi palabra ```when```, esto ya viene de C#7.
 - Y ¿por qué no un *Pattern matching* que acabamos de ver antes? Pues sí, puedes y te olvidas del uso de ```when```.
 - Y ¿por qué no un *Pattern matching* que acabamos de ver antes? Pues sí, puedes.
 - ¿por qué no un *Pattern matching* que acabamos de ver antes?

```csharp
return o switch
{
    Point p when p.X == 5 && p.Y == 5   => "Hight 5",   //Disponible en C# 7.0
    Point { X: 0, Y: 0 }                => "origin",    //Por pattern matching
    Point { X: var x, Y: var y }        => $"{x}, {y}", //Por pattern matching
    Point(-5, -5)                       => "Low",       //Por deconstruccion
    Point(var x, var y)                 => $"{x}, {y}", //Por deconstruccion
    _                                   => "unknown"
};
```
<small>_Ojo: no copies este código tal cual, es probable que la combinación de las cláusulas falle, se muestra a modo de ejemplo_</small>

- Olvidarnos del ```default``` y poner  ```_``` ya estaba en C# 7.0, no viene mal recordarlo porque escribir 7 caracteres a 1 es la vagancia máxima.

2. El cuerpo de cada función lo podemos expresar en una misma tras el ``=>``, y de paso también olvidarnos del ```break;``` al final. 
Esto lo compro, me gusta.

```csharp
var area = figure switch 
{
    Rectangle r => r.Width * r.Height,
    Circle c    => Math.PI * c.Radius * c.Radius,
    _           => 0
};
```

Bien, pues la imaginación es tu límite en lo que puedes hacer dentro de un ```switch```.

> <p><b>Valoración</b>:</p>
> <p>Useful = <b>4.0</b></p>
> <p>Crazy = <b>8.0</b></p>

Era de esperar.


## Implicit constructors

Hacía falta un poco de 
[*azúcar*](https://es.wikipedia.org/wiki/Az%C3%BAcar_sint%C3%A1ctico){:target="_blank"}
para digerir bien lo anterior y aquí llega un poco. 
Esta característica cumple con la ley de los vagos de no escribir lo que es evidente.

Si tenemos un array de Personas y queremos inicializarlo, 
¿Por qué tengo que poner un ```new Person(...)``` a cada elemento si ya el array está tipado?
Pues dicho y hecho, ahora podremos omitirlo porque no tiene sentido:

```csharp
Person[] people =
{
    new ("Elena", "Nito", "del Bosque"),
    new ("Armando", "Bronca", "Segura"),
    new ("Dolores", "Cabeza", "Baja"),
    new ("Aitor", "Tilla", "del Bosque"),
};
```

> <p><b>Valoración</b>:</p>
> <p>Useful = <b>7.0</b></p>
> <p>Crazy = <b>2.0</b></p>

Esto ha gustado ;)

## Using declaration

Seguro que estás acostumbrado en utilizar los bloques ```using``` para abrir una conexión a base de datos, o en un ```Stream``` para la lectura del fichero, etc...
 en todas esas ocasiones nos asegurar que nuestro objeto Disposable ejecute su método Dispose() al finalizar el código que engloba el bloque using.
Algo como:
```csharp
static void Main(string[] args)
{
    using (var disposable = CreateDisposable(args))
    {
          ...
    } // disposable is disposed here
}
```

Con esta nueva característica ahora podremos indicar el ámbito del using sobre una variable, sin necesidad de encapsular el código dentro de un bloque ```using```.
El método Dispose() del objeto se ejecutará cuando su ámbito finalice.

```csharp
static void Main(string[] args)
{
    using var disposable = CreateDisposable(args);
    ...
} // disposable is disposed here
```

Existen algunas limitaciones sobre el uso:
- No puedes reasignar una variable
```csharp
using var stream = file1.Open();
stream = file2.Open();
```

- No se puede enlazar a una variable de salida
```csharp
if (myCustomMethod(
    out using var stream, // Error
    ref size)
)
{
    // our code
}
```

> <p><b>Valoración del público</b>:</p>
> <p>Useful = <b>6.0</b></p>
> <p>Crazy = <b>2.5</b></p>

Parece que tuvo buena aceptación.

## Default interfaces

Bueno, y hemos llegado a la característica de la polémica. Como si de un debate político fuese, existen posturas de todos los colores, y se han escrito muchas opiniones al respecto. Se lleva años hablando del tema de si las Interfaces deberían implementar código.

Al final ha llegado, y esto es lo que podemos hacer.

```csharp
interface ILogger
{
    void Log(LogLevel level, string message);
    void Log(Exception ex) => Log(LogLevel.Error, ex.ToString()); // New overload
}

class ConsoleLogger : ILogger
{
    public void Log(LogLevel level, string message) { ... }
    // Log(Exception) gets default implementation
}

```

En mi opinión, de siempre una interfaz se ha definido como un "contrato" que todo objeto debe cumplir. Si ese "contrato" no lo cumples en su totalidad no es un objeto válido. Bien, pues que ahora una *interface* pueda incluir código por defecto es como exponer un "contrato" con letra pequeña si no lo cumples. Una letra pequeña que nadie lee o se nos olvida leer en profundidad.

Parece ser que la influencia de lenguajes como Java y Switch a través de Xamarin han acabado trayendo esta característica y nos deja a los programadores la responsabilidad de usarla ~~correctamente~~.


> <p><b>Valoración del público</b>:</p>
> <p>Useful = <b>4.5</b></p>
> <p>Crazy = <b>5.5</b></p>

Había un polizón javero entre el público que seguro moderó los resultados ;-P


## Conclusiones

Tras el evento hemos publicamos una [página web con las estadísticas de las votaciones](https://netcoreapp.azurewebsites.net/), pero como no creo que la tengamos para siempre online, vamos a hacer unas capturas a continuación:

{% include code_image.html 
image='2019/02/bcn_netcoreconf_results_crazyhot_1.png'
title='Grafico con diagonal Vicky Mendoza'
target='_blank'
%}

{% include code_image.html 
image='2019/02/bcn_netcoreconf_results_crazyhot_2.png'
title='Grafico con resultados positivos negativos según diagonal Vicky Mendoza'
target='_blank'
%}

Estos son los datos, tuyas son las conclusiones.

### Bonus y referencias:
Este artículo tiene su hermano mellizo en el post escrito por Fernando en su blog. Te recomiendo que lo leas, aunque se parecen se complementan.

Y como sabrás, Visual Studio 2019 está al caer y con su presentación llegarán todas estas features de C# 8.0, si algo cambia (cosa que dudo) lo veremos el próximo 2 de abril con la presentación que puedes seguir online.
<blockquote class="twitter-tweet" data-lang="es"><p lang="en" dir="ltr">The Visual Studio 2019 Launch Event is Coming April 2nd, 9:00am PT.<br><br>Whether you&#39;re a C#, C++, or Python dev &amp; target the web, desktop, or cloud, we&#39;ll have demos &amp; sessions for all the new goodies coming to <a href="https://twitter.com/hashtag/VS2019?src=hash&amp;ref_src=twsrc%5Etfw">#VS2019</a>.<br><br>Save the date &amp; join us: <a href="https://t.co/uGthsbkv7h">https://t.co/uGthsbkv7h</a> <a href="https://t.co/LsgZjglrzE">pic.twitter.com/LsgZjglrzE</a></p>&mdash; Visual Studio (@VisualStudio) <a href="https://twitter.com/VisualStudio/status/1096095478628917254?ref_src=twsrc%5Etfw">14 de febrero de 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Y si quieres profundizar más te unas referencias útiles:
<br/>[https://blogs.msdn.microsoft.com/dotnet/2018/11/12/building-c-8-0/](https://blogs.msdn.microsoft.com/dotnet/2018/11/12/building-c-8-0/){:target="_blank"}
<br/>[https://blogs.msdn.microsoft.com/dotnet/2019/01/24/do-more-with-patterns-in-c-8-0/](https://blogs.msdn.microsoft.com/dotnet/2019/01/24/do-more-with-patterns-in-c-8-0/){:target="_blank"}
<br/>[https://vcsjones.com/2019/01/30/csharp-8-using-declarations/](https://vcsjones.com/2019/01/30/csharp-8-using-declarations/){:target="_blank"}
<br/>[https://dotnetcoretutorials.com/2019/01/09/iasyncenumerable-in-c-8/](https://dotnetcoretutorials.com/2019/01/09/iasyncenumerable-in-c-8/){:target="_blank"}


### Bonus Barcelona NetCoreConf:
Fue un gran evento y creo que nos divertimos dejando la vara de medir al público. Como un gran poder conlleva una gran responsabilidad, decidimos premiar la implicación del público con un obsequio al más *Crazy* y el más *Useful*. En secreto diseñamos e imprimimos en 3D dos premios de los que no existen réplicas (de momento). Espero que sus dueños sepan valorarlo y los mantengan a buen recaudo.
<iframe id="vs_iframe" src="https://www.viewstl.com/?embedded&url=https://www.thingiverse.com/download:6080355&color=white&bgcolor=gray&shading=flat&rotation=yes&orientation=bottom" style="border:0;margin:0;width:100%;height:400px;"></iframe>
El diseño lo he dejado [aquí publicado.](https://www.thingiverse.com/thing:3434291){:target="_blank"}

Y el momento de tal honorable reconcomiendo:
<blockquote class="twitter-tweet" data-lang="es"><p lang="es" dir="ltr">Y aquí la foto finish de la Hot Crazy C# junto con <a href="https://twitter.com/fernandoescolar?ref_src=twsrc%5Etfw">@fernandoescolar</a>: la entrega de nuestro reconocimiento (único y exclusivo) al +Crazy y al +Usefull de entre los votos del público.  <a href="https://twitter.com/hashtag/netcoreconf?src=hash&amp;ref_src=twsrc%5Etfw">#netcoreconf</a> <a href="https://twitter.com/hashtag/lohemospasadogenial?src=hash&amp;ref_src=twsrc%5Etfw">#lohemospasadogenial</a> <a href="https://t.co/qgjyzJmLNn">pic.twitter.com/qgjyzJmLNn</a></p>&mdash; David Gonzalo (@dagope) <a href="https://twitter.com/dagope/status/1089629650664521730?ref_src=twsrc%5Etfw">27 de enero de 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Agradecer a la organización por haber tenido la oportunidad de participar en un gran evento de comunidad.
Nos vemos en otra.

Happy coding!
<br/>
David.