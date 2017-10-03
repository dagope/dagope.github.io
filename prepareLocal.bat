@echo off
setlocal EnableExtensions
echo Script to prepare the file _config.yml to execute in localhost.

bundle exec jekyll serve -w --config "_config.yml,_config_dev.yml"
