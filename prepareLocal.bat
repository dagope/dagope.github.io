@echo off
setlocal EnableExtensions
echo Script to prepare the file _config.yml to execute in localhost.

chcp 65001

findstr /v /i /c:baseurl _config.yml >_config_temp.yml
del _config.yml
ren _config_temp.yml _config.yml

echo baseurl: / >> _config.yml 
echo done

bundle exec jekyll serve -w
