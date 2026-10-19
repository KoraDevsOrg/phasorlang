@echo off
echo Compilando ejecutable nativo AOT sin dependencias...
where gcc >nul 2>nul
if %errorlevel% equ 0 (
    gcc -O3 -std=c99 app_aot.c -lm -o MiJuegoPhasor.exe
    echo [OK] Generado: MiJuegoPhasor.exe
    exit /b 0
)
where clang >nul 2>nul
if %errorlevel% equ 0 (
    clang -O3 app_aot.c -lm -o MiJuegoPhasor.exe
    echo [OK] Generado: MiJuegoPhasor.exe
    exit /b 0
)
echo No se encontro gcc ni clang en PATH. Instala GCC o Clang para compilar nativo.
