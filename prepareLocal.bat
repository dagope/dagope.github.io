@echo off
setlocal EnableExtensions

REM echo Installing missing gems:
REM bundle install

echo Script to prepare the file _config.yml to execute in localhost.
bundle exec jekyll serve -w --config "_config.yml,_config_dev.yml"
