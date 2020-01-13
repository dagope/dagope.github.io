---
published: true
date: 2020-01-01 05:00:00 +0100
layout: post
title: "Terraform - Creando un AppService de linux con NetCore"
author: David Gonzalo
comments: true
categories: [netcore, terraform, azure, IaC]
excerpt: "Como crear con terraform un AppService de linux con el runtime de NetCore"
featured_image: /public/uploads/2020/01/terraform-azure-netcore.png
disqus_page_identifier: 202001070500
---

IaC => *Infrastructure as code* o en español *Infrastructura como código*. Lo que viene siendo, automatizar la creación de nuestros recursos con un script de código y de esta manera unir la parte de infraestructura a nuestro proyecto de software. De esta necesidad surgen proyectos como Terraform o Ansible. 

Veremos un ejemplo de cómo crear en Azure un App Service de Linux con una versión específica del runtime.

{% include code_image.html 
image='2020/01/terraform-azure-netcore.png'
title='Imagne post Terraform, azure, netcore, linux'
%}
<!--break--> 

## Creando un App Service de linux con NetCore.

Partiré de que ya tenemos tanto 
[Azure CLI](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest){:target="_blank"} y 
[Terraform](https://www.terraform.io/downloads.html){:target="_blank"} instalados para usar en tu equipo y el provider.tf a nuestra suscripción de Azure creado.

Esta sería la definición de nuestro fichero *main.tf*

- En primer lugar creamos nuestro *Resource Group*
```ini
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_webapp_name
  location = var.location_default_Azure
}
```

- A continuación definimos el ServicePlan
```ini
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
```ini
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

## ¿Cual es la clave para definir nuestro runtime?
La propiedad donde se definq eu runtime correrá nuestro appservice de linux es: **linux_fx_version**
Vamos a ver que valores ponemos.

## ¿Qué valores tengo disponibles?
Si ejecutamos con Azure CLI el siguiente comando obtenemos las opciones de runtime disponibles para webapps en linux.

```bash
az webapp list-runtimes --linux
```

{% include code_image.html 
image='2020/01/az-webapps-list-runtimes-linux.png'
title='Listado de runtimes disponibles en azure webapps de linux'
target='_blank'
%}

Si observamos que los valores para el runtime de NetCore se componen por **DOTNETCORE** + **&#124;** + **VersionNetCore**


# Conclusiones

De momento solo he podido profundizar en Terraform como IaC y en mi opinión aún le queda madurar un poco ser el proyecto que una el mundo de Infra con los Developers. Un punto débil que he podido sufrir es la documentación de Terraform sobre las diferentes opciones en los recursos Azure. Coger experiencia con el manejo del CLI nos vendrá de perlas para obtener esa información que como has visto, a veces está algo escondida.


Happy coding!

David.


# Bonus extra
He encontrado este módulo compartido en internet que nos puede ayudar a la hora de definir nuestro appservice:
[https://github.com/innovationnorway/terraform-azurerm-web-app/tree/master](https://github.com/innovationnorway/terraform-azurerm-web-app/tree/master){:target="_blank"}

