

He decidido prepararme para la nueva certigicación de **AZ-203 Azure Developer Associate** y a continuación voy compartir mis notas/explicaciones propias y recursos para la preparación del Examen.

# Recursos principales:

## Resumen de puntos
En el siguiente fork de Github encontrarás enlaces de estudio por cada te punto del temario del examen. Muy útil para empezar a prepararlo:

[https://github.com/dagope/AzureStudyGroups-AZ-203](https://github.com/dagope/AzureStudyGroups-AZ-203)

## Microsoft Learn
Esta plataforma es perfecta para aprender de forma práctica. En el siguiente link ya filtro los resultados por *developer* y *solution architect*

[Plataforma Microsoft Learn][https://docs.microsoft.com/es-es/learn/browse/?roles=solution-architect%2Cdevelope]

## PluralSight
Ruta de estudio creada en pluralsight:
https://app.pluralsight.com/paths/certificate/developing-solutions-for-microsoft-azure-az-203


## Develop Azure Infrastructure as a Service compute solutions (10-15%)

# Azure Batch
Es un servicio para el procesado de programas en lotes de alto rendimiento sin "importarte" la infraestructura. 

Unos ejemplos: 
- Queremos obtener el aúdio de archivos ve video o quizás unir todos los videos en uno solo.
- Codificar un video de gran calidad y pasar de 400mb a 4mb.
- Transformar una cantidad grande de ficheros html a pdf.

Aquí tutorial donde con Azure Batch obtener el audio en mp3 de varios videos en mp4, haciendo uso ffmpeg3.4:
- Web: [https://docs.microsoft.com/es-es/azure/batch/tutorial-parallel-dotnet](https://docs.microsoft.com/es-es/azure/batch/tutorial-parallel-dotnet)
- Código: ```https://github.com/Azure-Samples/batch-dotnet-ffmpeg-tutorial.git```

Prácticas:
- [Ejecución de tareas paralelas en Azure Batch con la CLI de Azure](https://docs.microsoft.com/es-es/learn/modules/run-parallel-tasks-in-azure-batch-with-the-azure-cli/)
- [Creación de una aplicación para ejecutar trabajos de proceso paralelos en Azure Batch](https://docs.microsoft.com/es-es/learn/modules/create-an-app-to-run-parallel-compute-jobs-in-azure-batch/)
