# Dagope blog's 
[![Build Status](https://travis-ci.com/dagope/dagope.github.io.svg?branch=master)](https://travis-ci.com/dagope/dagope.github.io)

![GitHub](https://img.shields.io/github/license/dagope/dagope.github.io.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/dagope/dagope.github.io.svg)
![GitHub repo size in bytes](https://img.shields.io/github/repo-size/dagope/dagope.github.io.svg)

# Introduction

If you want how build a blog like this in github pages, you have written a post with all steps [here](https://dagope.github.io/2017/10/04/comenzando-blog-creando-entorno/){:target="_blank"} (spanish)


## Tips to write

### Write section Note
```
{% include code_note.html 
title='optional custom title'
content='text content note' 
%}
```
### Insert image
```
{% include code_image.html 
image='path/to/image.png'
title='title image'
target='_blank'
%}
```

### Link with target blank
sample: 
```
[text here](https://twitter.com/dagope){:target="_blank"}
```

# Environment local - using Docker
## Run 
Open a terminal with project path and execute:
```
docker-compose up
```
## Stop 
Key press `CTRL + C` to finish server and run:
```
docker-compose down
```

## Build base image
```
 docker build -t githubpagebase:v1.0 .
```

### More useful commands
Run container from bash or powershell
```
docker run --rm -it -p 4000:4000 -v ${PWD}:/app -w /app githubpagebase /bin/bash
```
 
Run container from windows command line
```
docker run --rm -it -p 4000:4000 -v %cd%:/app -w /app githubpagebase /bin/bash
```

Run jekyll serve:
```
bundle exec jekyll serve --host 0.0.0.0 -w --config "_config.yml,_config_dev.yml"
```

Run container with jekyll serve:
```
> docker run --rm -it -p 4000:4000 -v %cd%:/app -w /app githubpagebase:v1.0 /bin/bash -c "'bundle install && bundle exec jekyll serve --host 0.0.0.0 -w --config '_config.yml,_config_dev.yml'""
```
