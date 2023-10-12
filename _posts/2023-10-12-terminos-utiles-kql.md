---
published: true
date: 2023-10-12 00:00:00 +0100
layout: post
title: "Términos útiles y trucos para KQL y Application Insights"
author: David Gonzalo
comments: true
categories: [kql, applicationinsights, azure]
excerpt: "trucos para usar en KQL para por ejemplo nuestras queries en application insights."
featured_image: /public/uploads/2023/10/kql_trucos01.jpg
disqus_page_identifier: 202310120500
codeStyle: enlighterjs
---
<img src="{{site.baseurl}}public/uploads/2023/10/kql_trucos01.jpg" style="border:0px;" alt="KQL trucos"  />
A continuación, encontrarás un resumen de los conceptos y términos básicos para manejarte con KQL por Application Insights perfectamente. Entender cuáles son las tablas importantes y sus campos principales. Y por supuesto las funciones más usadas y un ejemplo explicativo para manejarte sin problemas con KQL.
<!--break--> 

## Tablas y campos importantes
### requests
Esta tabla contiene información sobre las solicitudes HTTP realizadas a tu aplicación, incluyendo detalles como la URL, el método HTTP, el código de respuesta, el tiempo de respuesta y más.

|timestamp			| La marca de tiempo de la solicitud.|
|id 				| Un identificador único para la solicitud.|
|name 				| El nombre de la solicitud.|
|duration 			| La duración de la solicitud en milisegundos.|
|resultCode 		| El código de respuesta HTTP de la solicitud (por ejemplo, 200, 404).|
|url 				| La URL de la solicitud.|
|customDimensions 	| Las dimensiones personalizadas asociadas con el evento.|
|cloudRoleName		| generalmente contiene el nombre de la función, servicio o componente en la nube que está generando la telemetría. 

### traces
Esta tabla contiene registros de trazas o mensajes que puedes generar desde tu aplicación. Es útil para registrar información adicional sobre el comportamiento de tu aplicación.

|timestamp			| La marca de tiempo del registro de seguimiento.
|message			| El mensaje de registro.
|severityLevel		| El nivel de gravedad del registro (por ejemplo, Information, Warning, Error).
|loggerName			| El nombre del registrador.
|customDimensions	| Las dimensiones personalizadas asociadas con el evento.
|cloudRoleName		| generalmente contiene el nombre de la función, servicio o componente en la nube que está generando la telemetría. 

### exceptions
Esta tabla contiene detalles sobre las excepciones o errores que ocurren en tu aplicación, incluyendo el tipo de excepción, la pila de llamadas y la hora en que ocurrió.

|timestamp			| La marca de tiempo de la excepción.
|type				| El tipo de excepción.
|message			| El mensaje de la excepción.
|outerMessage		| El mensaje de la excepción externa si corresponde.
|handledAt			| Indica si la excepción fue manejada o no.
|customDimensions	| Las dimensiones personalizadas asociadas con el evento.
|cloudRoleName		| generalmente contiene el nombre de la función, servicio o componente en la nube que está generando la telemetría. 

### dependencies
Aquí encontrarás información sobre las llamadas a servicios externos o dependencias de tu aplicación, como bases de datos, servicios web, etc. Puedes ver detalles como el tipo de dependencia, el tiempo de respuesta y el éxito o fracaso de la llamada.

|timestamp			| La marca de tiempo de la dependencia.
|type				| El tipo de dependencia (por ejemplo, SQL, HTTP).
|target				| El destino de la dependencia (por ejemplo, la URL de un servicio externo).
|success			| Indica si la dependencia se realizó con éxito o no.
|resultCode			| El código de respuesta de la dependencia.
|customDimensions	| Las dimensiones personalizadas asociadas con el evento.
|cloudRoleName		| generalmente contiene el nombre de la función, servicio o componente en la nube que está generando la telemetría. 


### customEvents
Puedes registrar eventos personalizados en tu aplicación y consultar esta tabla para obtener información específica sobre esos eventos. Esto es útil para rastrear eventos importantes en tu aplicación.

|timestamp			| La marca de tiempo del evento personalizado.
|name				| El nombre del evento personalizado.
|customDimensions	| Las dimensiones personalizadas asociadas con el evento.


## Funciones más usadas

Aquí tienes un listado de algunas de las características de filtros y funciones más utilizados en Kusto Query Language (KQL) junto con su definición y ejemplos de su uso:

### Filtros:

#### *where*
Se utiliza para filtrar filas que cumplan con una condición específica.
-  Ejemplo: Filtrar solicitudes con un código de respuesta igual a 200.
<pre data-enlighter-language="sql">
datatable 
| where resultCode == 200
</pre>

#### *project*
Se utiliza para seleccionar columnas específicas para incluir en los resultados de la consulta.
- Ejemplo: Seleccionar solo las columnas "timestamp" y "name".
<pre data-enlighter-language="sql">
datatable 
| project timestamp, name
</pre>
	
#### *extend*
Permite agregar columnas calculadas a los resultados.
- Ejemplo: Calcular la duración en segundos.
<pre data-enlighter-language="sql">
datatable 
| extend durationInSeconds =duration /1000
</pre>
	
#### *summarize*	
Se utiliza para realizar agregaciones en los datos, como sumas, promedios o contar filas.
- Ejemplo: Contar el número de solicitudes por código de respuesta.
<pre data-enlighter-language="sql">
datatable 
| summarize RequestCount = count() by resultCode
</pre>
	
#### *join* 
Permite unir dos tablas en función de una condición.
- Ejemplo: Unir tablas de solicitudes y excepciones por ID de solicitud.
<pre data-enlighter-language="sql">
requests 
| join kind = inner(exceptions) on operation_Id 
</pre>
	 
### Funciones:

#### *avg*
Calcula el promedio de los valores en una columna.
- Ejemplo: Calcular el tiempo promedio de respuesta de las solicitudes.
<pre data-enlighter-language="sql">
datatable 
| summarize AvgResponseTime = avg(duration) 
</pre>

#### *count* 
Cuenta el número de filas en una tabla.
- Ejemplo: Contar el número total de excepciones.
<pre data-enlighter-language="sql">
exceptions
| count
</pre>

#### *min* y *max*
Encuentra el valor mínimo y máximo en una columna.
- Ejemplo: Encontrar el valor mínimo de una métrica.
<pre data-enlighter-language="sql">
datatable 
| summarize MinValue =min(metricValue)
</pre>

#### *distinct*
Encuentra valores únicos en una columna.
- Ejemplo: Encontrar valores únicos en la columna "userId."
<pre data-enlighter-language="sql">
datatable 
| distinct userId 
</pre>

#### *make_datetime*
Se utiliza para crear un valor de fecha y hora personalizado utilizando componentes de fecha y hora, como año, mes, día, hora, minuto, segundo y milisegundo. Esto es útil cuando deseas construir manualmente una marca de tiempo en lugar de depender de una columna de fecha y hora existente en tus datos.
- Sintaxis: `make_datetime(year, month, day, hour, minute, second, millisecond)`
	- year: El año.
	- month: El mes (1-12).
	- day: El día del mes.
	- hour: La hora (0-23).
	- minute: El minuto (0-59).
	- second: El segundo (0-59).
	- millisecond: El milisegundo (0-999).
	
- Ejemplo: 
<pre data-enlighter-language="sql">
datatable 
| extend customTimestamp = make_datetime(2023, 1, 1, 12, 30, 45, 500)
</pre>

#### *Bin*
Se utiliza para agrupar valores en intervalos o contenedores. Puedes especificar el tamaño del intervalo y el punto de inicio del primer intervalo. La función render puede tomar varios tipos de visualización, como *timechart* (gráfico de tiempo), *barchart* (gráfico de barras), *piechart* (gráfico circular), *table* (tabla) y otros. El tipo de visualización que elijas depende de tus necesidades y de cómo desees presentar tus datos.
- Ejemplo de uso:
	Supongamos que tienes una tabla de datos con una columna que representa la duración en segundos y deseas agrupar estas duraciones en intervalos de 10 segundos para analizar la distribución de las duraciones. Puedes usar la función bin de la siguiente manera:
<pre data-enlighter-language="sql">
datatable
| summarize Count = count() by bin(DurationInSeconds, 10)
</pre>

### Un par que son básicas
#### *order by*
Se utiliza para ordenar los resultados de una consulta en función de una o más columnas específicas. Puedes utilizar order by para organizar los datos en un orden específico, ya sea ascendente o descendente, lo que facilita la identificación de tendencias, valores máximos o mínimos, entre otros.
- Ejemplo: Encontrar valores únicos en la columna "userId."
<pre data-enlighter-language="sql">
requests 
| order by timestamp desc 
</pre>
	
#### *render*
Se utiliza para generar visualizaciones a partir de los resultados de una consulta KQL. Puedes especificar el tipo de visualización que deseas, como gráficos de líneas, gráficos de barras, tablas, entre otros. La función render se aplica al final de una consulta para mostrar visualmente los datos recuperados.
- Ejemplo de uso:
	Supongamos que tienes una consulta que recopila datos de rendimiento de solicitudes en Application Insights y deseas visualizar estos datos en un gráfico de líneas. Puedes usar la función render de la siguiente manera:
<pre data-enlighter-language="sql">
datatable
| summarize AvgResponseTime = avg(duration) by bin(timestamp, 1h)
| render timechart
</pre>
		
En este ejemplo, hemos agrupado el tiempo de respuesta promedio de las solicitudes en intervalos de 1 hora utilizando la función bin. Luego, aplicamos la función render con el tipo de visualización "timechart" para generar un gráfico de líneas que muestra la evolución del tiempo de respuesta promedio a lo largo del tiempo.







Espero te sea de ayuda todo esto.

Happy Codding!