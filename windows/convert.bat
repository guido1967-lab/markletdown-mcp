@echo off
REM convert.bat - Doppio click: converte la cartella di default (o i file/cartelle
REM trascinati sopra questo .bat). Mostra l'output e resta aperto a fine lavoro.
setlocal
set "HERE=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%HERE%convert.ps1" %*
echo.
pause
