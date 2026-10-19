@echo off
echo ================================================================
echo   CHRONOS IDE — DEXACION OPTIMIZADA CON D8 v1.8 / MIN-API 21
echo ================================================================
set D8_PATH="C:\Users\dapcd\AppData\Local\Android\Sdk\build-tools\36.0.0\d8.bat"
if not exist %D8_PATH% set D8_PATH=d8.bat
%D8_PATH% --release --min-api 21 --output . ..\..\data\603\files\java\bin\*.class
if %errorlevel% equ 0 (
    echo [OK] Generado classes.dex con exito para Sketchware Pro.
) else (
    echo [ERROR] Fallo la dexacion con D8.
)
