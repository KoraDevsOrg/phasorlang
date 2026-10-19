# ⚡ PhasorLang & Chronos IDE — Ecosistema Autónomo KoraDevs

[![KoraDevs CI/CD](https://github.com/koradevsorg/phasorlang/actions/workflows/koradevs_qa.yml/badge.svg)](https://github.com/koradevsorg)
[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)
[![Zero-GC](https://img.shields.io/badge/Runtime-Zero--GC%20120%20FPS-brightgreen.svg)](#invariante-zero-gc)
[![Multiplataforma](https://img.shields.io/badge/Plataformas-Web%20%7C%20Desktop%20%7C%20Móvil%20%7C%20PWA-58a6ff.svg)](#arquitectura-unificada)

> **PhasorLang** es un Lenguaje de Dominio Específico (DSL) vectorial, cuántico, procedimental y de ultra-alto rendimiento, diseñado con *Simpatía Mecánica* para ejecutar simulaciones científicas, gráficos avanzados y aplicaciones complejas con **cero pausas de Garbage Collector (Zero-GC) a 90-120 FPS sostenidos**.
>
> Desarrollado bajo la organización de código abierto **[KoraDevs](https://github.com/koradevsorg)**.

---

## 🏛️ Arquitectura Unificada Multi-Dispositivo & Multi-Ventana

En PhasorLang, **todos los aplicativos comparten el mismo paradigma arquitectónico universal**:

```
+---------------------------------------------------------------------------------+
| ESPACIO DE TRABAJO PADRE (<main>) — Lienzo Continuo #0B0E14                    |
| Barra Superior Docking Bar: [ CHRONOS WORKSPACE ] [ Zero-GC: 0.0 B | 120 FPS ]  |
+---------------------------------------------------------------------------------+
|                                                                                 |
|   +------------------------------------+   +--------------------------------+   |
|   | <s>1: Ventana de Trabajo 1         |   | <s>2: Lienzo Gráfico / Vista   |   |
|   | Barra de Título Drag & [-] Min     |   | Barra de Título Drag & [-] Min |   |
|   +------------------------------------+   +--------------------------------+   |
|   | • Clipping Estricto por Hardware   |   | • Renderizado 120 FPS Zero-GC  |   |
|   | • Scroll Clamped Bidireccional     |   | • Despacho de Eventos          |   |
|   | • Redimensión Perimetral en 8D     |   | • Agarradera en esquina SE     |   |
|   +------------------------------------+   +--------------------------------+   |
|                                                                                 |
+---------------------------------------------------------------------------------+
| Barra Inferior de Ventanas Minimizadas y Docking                                |
+---------------------------------------------------------------------------------+
```

### 1. En Escritorio (Desktop Canvas):
- El fondo es el espacio de trabajo padre `<main>` (`#0B0E14`).
- Cada ventana hija (`<s>1`, `<s>2`, `<s>3`, ...) flota libremente con:
  - **Arrastre fluido (Drag & Drop)** desde la barra de título.
  - **Redimensión multidireccional en tiempo real (8D)**: Norte, Sur, Este, Oeste y esquinas diagonales, con agarradera visual en la esquina inferior derecha.
  - **Minimizado instantáneo `[-]`/`[+]`** a solo su barra de título para despejar el espacio de trabajo.
  - **Desplazamiento fluido y clamped (Scroll)** con rueda del ratón o arrastre directo de las barras de desplazamiento (scrollbars).

### 2. En Dispositivos Móviles (Smartphones & Tablets < 768px):
- **Ajuste "Llave en Cerradura" (100% Snap)**: La ventana activa toma el 100% del viewport del teléfono.
- **Si la app tiene 1 sola ventana (ej. Calculadora)**: Llena la pantalla móvil limpiamente sin elementos innecesarios.
- **Si la app tiene 2 o 3 ventanas (ej. Graficadora GeoGebra o IDE)**: La barra superior ergonómica (44px) incluye pestañas táctiles inmediatas `[ <s>1 ] [ <s>2 ] [ <s>3 ]` y soporte para gestos táctiles de deslizamiento (swipe) o pellizco (pinch) para orbitar entre las sub-pantallas.

---

## 🌟 Catálogo de Aplicaciones Insignia (KoraDevs Flagship Apps)

Cualquier desarrollador que utilice **Chronos IDE** y **PhasorLang** puede construir, probar y exportar las siguientes familias de aplicaciones usando **exclusivamente código PhasorLang**:

### 🛠️ 1. Herramientas para Ingenieros y Profesionales
* **Calculadoras Gráficas y Vectoriales:** Cálculo matricial, fasorial y funciones matemáticas complejas en tiempo real.
* **Instrumentación y Conversión Técnica:** Conversores de impedancia (Carta de Smith), telecomunicaciones y análisis industrial.
* **Asistentes Profesionales Especializados:** Modelos locales de soporte técnico para resolución de problemas de ingeniería.

### 🔬 2. Aplicaciones Científicas
* **Simuladores de Física Fundamental y Partículas:** Modelado atómico y colisiones continuas de alta energía (estilo CERN).
* **Simulaciones Cosmológicas:** Modelado de materia oscura vs. ordinaria, dinámica gravitacional n-cuerpos, estrellas y supernovas.
* **Laboratorio Científico Local:** Simulación, ajuste y experimentación matemática sin latencia de red.

### 🎬 3. Herramientas Media Procedural (Video y Audio en Tiempo Real)
* **Texto a Video/Audio en Tiempo Real:** Generación audiovisual procedural basada en guiones y señales fasoriales con **0 Bytes de consumo de almacenamiento**.
* **Lector y Conversor Universal de Documentos:** Conversión de documentos a secuencias dinámicas audiovisuales y voz formántica sintetizada nativamente.
* **Streaming y Reproducción Local:** Difusión fluida y reproducción en tiempo real tanto offline como online.

### 🤖 4. Robótica y Electromecánica
* **Simulador de Mundos Virtuales:** Físicas continuas para entrenamiento y telemetría de robots reales y virtuales.
* **Control Embebido:** Percepción espacial, procesamiento de señales fasoriales, cinemática directa/inversa y modulación PWM.

### 🧠 5. Inteligencia Artificial y Asistentes Autónomos
* **Inferencia Local (*Phasor-SLM*):** Modelos compactos de lenguaje y redes neuronales cuánticas (QNN) 100% offline.
* **Asistente Local con Avatar Reactivo:** Comunicación *Full-Duplex* con interrupción de voz inmediata (*Barge-In*), gesticulación procedural y gestión estricta de permisos de red.
* **Agente Co-Creador Integrado:** Asistente embebido en Chronos IDE para asistir en la creación, depuración y optimización de herramientas.

---

## ⚡ Invariante Zero-GC (90+ / 120 FPS Sostenidos)

PhasorLang prohíbe la instanciación de objetos en el montículo (*Heap*) dentro de las rutas críticas de renderizado y simulación:
1. **Memoria Plana SoA (Structure of Arrays)**: Manejo contiguo de datos mediante arreglos planos de tipos primitivos (`Float64Array`, `Uint8Array`).
2. **Puente Ciego de Hardware (PVM Input Registers)**:
   - `R250`: Ancho del Viewport (`width`).
   - `R251`: Alto del Viewport (`height`).
   - `R252`: Coordenada `X` del cursor / puntero táctil.
   - `R253`: Coordenada `Y` del cursor / puntero táctil.
   - `R254`: Estado de pulsación (`0.0` = libre, `1.0` = presionado).
   - `R255`: Delta de desplazamiento de la rueda de scroll (`deltaY`).

---

## 🚀 Inicio Rápido & Comandos de la CLI

El compilador y la suite de herramientas se invocan directamente mediante la herramienta de línea de comandos `phasor`:

### 1. Ejecutar la Batería de Pruebas Unitarias
```bash
phasor test tests/03_test_ui_responsive.fas
```
> Ejecuta la suite de 62 aserciones validando maquetación responsive, scroll, clamping y autocontención de texto en <40 ms PVM.

### 2. Empaquetar a Aplicativo Standalone HTML (1 Solo Archivo)
```bash
phasor bundle samples/calculadora.fas dist/calculadora.html --title "Calculadora Fasorial"
```
> Compila a WebAssembly y genera un único archivo `.html` autocontenido. Ábrelo con doble clic en cualquier navegador (`file:///`) sin requerir servidor HTTP ni sufrir bloqueos CORS.

### 3. Compilar la Calculadora Gráfica Fasorial (GeoGebra Style)
```bash
phasor bundle samples/graficadora_fasorial.ph dist/graficadora_fasorial.html
```
> Aplicativo completo multi-ventana de 3 ventanas hijas: Entrada de Ecuaciones, Plano Complejo + Formas de Onda y Teclado Científico con inversión de fase a 180° en tiempo real.

### 4. Compilar el Demostrador Maestro Multi-Dominio
```bash
phasor bundle samples/demo_koradevs_master.fas dist/demo_koradevs_master.html
```

### 5. Empaquetar Chronos IDE Autónomo
```bash
phasor bundle samples/phasor_ide.ph dist/chronos_ide.html
```

---

## 📁 Estructura del Repositorio

El proyecto sigue una estructura limpia, desacoplada y orientada a la distribución abierta en GitHub:

```text
phasorlang/
├── bin/                       # Binarios y scripts ejecutables CLI (phasor, phasor-bundle)
│   ├── phasor                 # Wrapper Bash para Linux / macOS
│   ├── phasor.bat             # Wrapper Batch para Windows
│   ├── phasor-bundle          # Bundler Bash para Linux / macOS
│   └── phasor-bundle.bat      # Bundler Batch para Windows
├── compiler/                  # Núcleo del Compilador Soberano PhasorLang
│   └── phasor.jar             # Binario del compilador AOT / Bytecode / WASM
├── runtime/                   # Motores de ejecución nativos y Web
│   └── phasor_runtime.js      # Runtime Universal Canvas 2D Zero-GC (120 FPS)
├── tools/                     # Herramientas de soporte y automatización
│   ├── phasor_bundler.js      # Empaquetador universal a Standalone HTML / PWA
│   └── organize_repo.js       # Script de mantenimiento y limpieza del repositorio
├── lib/                       # Biblioteca estándar de PhasorLang (.ph)
│   ├── ui.ph                  # Componentes de interfaz adaptativa y multi-ventana
│   ├── color.ph               # Motor óptico de colores en Hertz (400-750 THz)
│   ├── math.ph                # Operaciones vectoriales, matriciales y fasoriales
│   ├── procedural_video.ph    # Generación de video procedural en tiempo real
│   ├── audio.ph               # Síntesis acústica PCM a 44.1 kHz
│   ├── barge_in_assistant.ph  # Asistente Full-Duplex con interrupción inmediata
│   └── platformer.ph          # Físicas y cinemática en memoria continua SoA
├── samples/                   # Aplicaciones de demostración y prototipos
│   ├── graficadora_fasorial.ph # Calculadora Gráfica GeoGebra (3 ventanas hijas)
│   ├── calculadora.fas        # Calculadora vectorial/fasorial (1 ventana hija)
│   ├── demo_koradevs_master.fas # Demostrador maestro políglota y multi-dominio
│   └── phasor_ide.ph          # Chronos IDE auto-hospedado multi-ventana (2 ventanas)
├── tests/                     # Batería de pruebas unitarias e integración (.fas)
│   ├── 01_test_pvm_jumps.fas  # Control de flujo y saltos condicionales
│   ├── 02_test_hertz_colors.fas # Espectro electromagnético en frecuencias ópticas
│   ├── 03_test_ui_responsive.fas # Validación UI responsive, scroll y multi-ventana
│   ├── 04_test_audio_bargein.fas # Síntesis y cancelación acústica
│   └── 05_test_polyglot_hub.fas  # Integración y contratos políglotas
├── dist/                      # Entregables y aplicativos listos para producción (.html, .wasm)
│   ├── graficadora_fasorial.html # Aplicativo standalone GeoGebra Style
│   ├── calculadora.html       # Aplicativo standalone de Calculadora Fasorial
│   ├── demo_koradevs_master.html # Demostrador maestro standalone
│   └── chronos_ide.html       # Entorno IDE standalone con Live Preview
├── docs/                      # Especificación técnica y guías de arquitectura
├── .github/workflows/         # Automatización de Integración Continua (CI/CD)
│   └── koradevs_qa.yml        # Pipeline de validación de pruebas y GitHub Pages
├── phasor.toml                # Manifiesto de configuración del proyecto
├── LICENSE                    # Licencia MIT de Código Abierto
└── README.md                  # Documentación principal del ecosistema
```

---

## 🤝 Comunidad y Organización

PhasorLang y Chronos IDE son proyectos de código abierto impulsados por la comunidad:
- **Organización Oficial**: [github.com/koradevsorg](https://github.com/koradevsorg)
- **Licencia**: [MIT License](LICENSE) — Abierto para desarrolladores, investigadores y empresas de todo el mundo.
