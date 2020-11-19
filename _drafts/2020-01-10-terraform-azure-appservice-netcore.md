---
published: true
date: 2020-01-18 05:00:00 +0100
layout: post
title: "Terraform - Creando un AppService de linux con NetCore"
author: David Gonzalo
comments: true
categories: [netcore, terraform, azure, IaC]
excerpt: "Como crear con terraform un AppService de linux con el runtime de NetCore"
featured_image: /public/uploads/2020/01/terraform-azure-netcore.png
disqus_page_identifier: 202001070500
---

IaC => *Infrastructure as code* o en español *Infrastructura como código*. Lo que viene siendo, automatizar la creación de nuestros recursos con un script de código y de esta manera unir la parte de infraestructura a nuestro proyecto de software. De esta necesidad surgen proyectos como [Terraform](https://www.terraform.io/), [Ansible](https://www.ansible.com/) o recien llegado [Pulumi](https://www.pulumi.com/). 

En este pequeño ejemplo cómo crear en Azure un App Service de Linux con una versión específica del runtime. Sabremos de donde poder sacar la información necesaria para indicar todos los parámetros de Terraform.

{% include code_image.html 
image='2020/01/terraform-azure-netcore.png'
title='Imagne post Terraform, azure, netcore, linux'
%}
<!--break--> 

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_webapp_name
  location = var.location_default_Azure
}


### Requisitos principales
A modo recordatorio la estructura de ficheros de código que usaré para la definición de nuestro entorno terraform será:
- main.tf --> definición principal de nuestro código terraform
- vars.tf --> definición de variables usadas, con sus valores por defectos.
- vars.auto.tfvars --> asignación del valor de las variables definidas en vars.tf
- vars.secrets.tfvars --> este fichero 
- outputs.tf --> variables de salida tras la ejecución 
- provider.tf --> definición del proveedor usado en terraform 
Esta sería la definición de nuestro fichero *main.tf*
- versions.tf --> configuraciónes de la versión ejecutada en terraform
Aqui como configurar el remote state.
https://blog.jcorioland.io/archives/2019/09/09/terraform-microsoft-azure-remote-state-management.html
https://blog.jcorioland.io/archives/2019/09/09/terraform-microsoft-azure-remote-state-management.html

## Creando un App Service de linux con NetCore.

Partiré de que ya tenemos tanto 
[Azure CLI](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest){:target="_blank"} y 
[Terraform](https://www.terraform.io/downloads.html){:target="_blank"} instalados para usar en tu equipo y el provider.tf a nuestra suscripción de Azure creado.

- En primer lugar creamos nuestro *Resource Group*
```hcl
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_webapp_name
  location = var.location_default_Azure
}
```

- A continuación definimos el ServicePlan
```hcl
resource "azurerm_app_service_plan" "main" {
  name                = "miserviceplan"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier      = "Basic"
    size      = "B1"
  }
}
```
{% include code_note.html 
content='Ojo con nuestro SKU. Si intentamos alguna combinación que no sea soportada puede que recibamos un error super-descriptivo del tipo: 
<br><strong><em>Failure sending request: StatusCode=0 -- Original Error: autorest/azure: Service returned an error. Status=&lt;nil&gt; &lt;nil&gt;</em></strong> 
<br>Por lo menos sucede en versión 1.39 de azurerm y 0.12 de terraform.'
%}

- Ahora el App Service:
```hcl
resource "azurerm_app_service" "main" {
  name                = "miwebapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  site_config {
    linux_fx_version = "DOTNETCORE|3.0"
    scm_type         = "LocalGit"
  }
  
  depends_on = [azurerm_app_service_plan.main]
}
```

Con este código mostrado, ya estaría funcionando pero vamos a explicar un poco los parámetros importantes.

## ¿Cual es la clave para definir nuestro runtime netcore 3.0?
Es facil identificarlo en el código de arriba. La propiedad donde se define que runtime NetCore correrá nuestro AppService de linux es: **linux_fx_version**

## Y ¿Qué valores tengo disponibles?
Para averiguar que valores serían los correctos tenemos la ayuda de Azure CLI. Si ejecutamos el siguiente comando:
```bash
az webapp list-runtimes --linux
```
Obtenemos las opciones de runtime disponibles para webapps en linux:

{% include code_image.html 
image='2020/01/az-webapps-list-runtimes-linux.png'
title='Listado de runtimes disponibles en azure webapps de linux'
target='_blank'
%}

Si observamos los valores listados, además de Node, Java y demás, podemos ver que el runtime de NetCore se compone por **DOTNETCORE** + **&#124;** + **VersionNetCore**
lo mismo sucede para PHP, Node, etc...

# Conclusiones

De momento solo he podido profundizar en Terraform como IaC y en mi opinión aún le queda madurar un poco ser el proyecto que una el mundo de Infra con los Developers. Un punto débil que he podido sufrir es la documentación de Terraform sobre las diferentes opciones en los recursos Azure. Coger más experiencia en el manejo del CLI de Azure es esencial para obtener esa información que como la que vimos, a veces está algo "escondida".


Happy coding!

David.


# Bonus extra
He encontrado este módulo compartido en internet que nos puede ayudar a la hora de definir nuestro AppService:
[https://github.com/innovationnorway/terraform-azurerm-web-app/tree/master](https://github.com/innovationnorway/terraform-azurerm-web-app/tree/master){:target="_blank"}

