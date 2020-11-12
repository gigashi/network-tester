@echo off
cd /d %~dp0

set /P PORT="port: "
call ntserver --port %PORT%

PAUSE
