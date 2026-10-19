@echo off
if "%~1"=="bundle" (
    node "%~dp0tools\phasor_bundler.js" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
java -jar "%~dp0phasor.jar" %*
