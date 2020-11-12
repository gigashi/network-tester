@echo off
cd /d %~dp0

set /P SERVER="server: "
set /P PORT="port: "
type send_data | call ntclient --server %SERVER% --port %PORT%

PAUSE
