---
published: true
date: 2023-06-13 05:00:00 +0100
layout: post
title: "PDF utils con docker y cero instalaciones"
author: David Gonzalo
comments: true
categories: [docker, pdf, utils]
excerpt: "Como realizar operaciones con PDF usando docker y sin instalar ningún software adicional."
featured_image: /public/uploads/2023/06/docker-pdf-utils.png
disqus_page_identifier: 202306130500
---

Cuando tienes esa situación de no poder instalar un software adicional o todo lo que encuentras es de pago, poco fiable y lioso para una operación sencilla como unir dos documentos pdf, dividirlo o imprimir solo ciertas páginas. Con docker podemos hacerlo de forma fácil y sencilla. 

Os cuento lo que yo uso principalmente. 

{% include code_image.html 
image='2023/06/docker-pdf-utils.png'
title='Imagen de logo pdf y docker juntos'
%}
<!--break--> 

## Unir documentos pdf
Abrir un terminal en la ruta donde tenemos el fichero 0.pdf y 1.pdf
Ejecutamos:
```bash
λ docker run --rm -v %cd%:/pdf gkmr/pdf-tools pdftk /pdf/0.pdf /pdf/1.pdf cat output /pdf/merged.pdf
```
```bash
> docker run --rm -v $PWD:/pdf gkmr/pdf-tools pdftk /pdf/0.pdf /pdf/1.pdf cat output /pdf/merged.pdf
```
Obtenemos un fichero resultante con los ficheros unidos en uno solo llamado merged.pdf.

OJO! con las rutas al montar el volumen, mejor usar una ruta sin espacios, usa algo como *c:\temp* 

Para sesión interactiva:
```bash
λ docker run --rm -it --entrypoint sh -v %cd%:/pdf gkmr/pdf-tools
```
## comprimir documento pdf
Si al unir los pdfs puede suceder que el tamaño del archivo resultando sea demasiado grande. Para eso podemos usar lo siguiente:

```bash
λ docker run --rm -v %cd%:/pdf gkmr/pdf-tools gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dBATCH  -dQUIET -sOutputFile=pdf/output.pdf pdf/merged.pdf
```

## Obtener de un pdf otro con ciertas páginas
Si queremos obtener únicamente las hojas de un fichero podemos usar el siguiente comando. 
```bash
> docker run --rm -v %cd%:/pdf gkmr/pdf-tools pdftk /pdf/fullpdf.pdf cat 6-12 27 output pdf/outfile.pdf
```

Y si queremos experimentar más sobre pdftk aquí os dejo la web oficial con su documentación.

Happy Codding. :)