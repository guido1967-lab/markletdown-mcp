@echo off
REM ============================================================
REM  Converti in Markdown — Installazione Windows
REM  DOPPIO CLICK su questo file per installare tutto.
REM  (I file .ps1 non si avviano col doppio click: ci pensa questo.)
REM ============================================================
cd /d "%~dp0"
echo.
echo  Installazione di "Converti in Markdown" in corso...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File '.\install.ps1'; Unblock-File '.\convert.ps1'; & '.\install.ps1'"
echo.
echo  ------------------------------------------------------------
echo  Se sopra vedi "Fatto!", l'installazione e' riuscita.
echo  Ora: tasto destro su un file/cartella nel File Explorer
echo       --^> Converti in Markdown
echo  ------------------------------------------------------------
echo.
pause
