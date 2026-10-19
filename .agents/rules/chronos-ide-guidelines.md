---
trigger: always_on
description: Directrices maestras de arquitectura, rendimiento Zero-GC, ecosistema multiplataforma KoraDevs y PhasorLang autónomo.
---

# PhasorLang & Chronos IDE — Directrices Maestras de Arquitectura (KoraDevs)

## 1. Contexto, Misión y Ecosistema Autónomo
- **Organización**: **KoraDevs** ([github.com/koradevsorg](https://github.com/koradevsorg)).
- **Lenguaje Central**: **PhasorLang** — Lenguaje de Dominio Específico (DSL) vectorial, cuántico, procedimental y de ultra-alto rendimiento.
- **Entorno de Desarrollo**: **Chronos IDE** — IDE autónomo y multiplataforma (Web / Desktop / PWA / Antigravity / VS Code) con compilación en caliente (*Hot-Reloading*), Live Preview a 90-120 FPS y exportación a aplicativos HTML autocontenidos (1 solo archivo ejecutable).
- **Emancipación Total de Sketchware Pro**: El lenguaje es 100% independiente de Sketchware Pro, de Java 7 y de entornos móviles cerrados. Se compila y distribuye como binario/herramienta CLI (`phasor`), WebAssembly y bibliotecas modulares estándar (`.ph` y `.fas`).
- **Filosofía Abierta y Políglota**: PhasorLang es el motor de cómputo y render nativo de máximo rendimiento, mientras que KoraDevs es un hub políglota donde conviven e interactúan módulos en PhasorLang, Rust, C++, Python, JavaScript y Java.

---

## 2. Catálogo de Aplicaciones Insignia (KoraDevs Flagship Apps)
Cualquier desarrollador que utilice Chronos IDE debe poder construir, probar y exportar las siguientes familias de aplicaciones usando **exclusivamente código PhasorLang**:

### 🛠️ 1. Herramientas para Ingenieros y Profesionales
* **Calculadoras Gráficas Avanzadas**: Cálculo matemático, vectorial, matricial y fasorial en tiempo real.
* **Instrumentación y Conversión Técnica**: Conversores de impedancia (Carta de Smith), telecomunicaciones y análisis industrial.
* **Asistentes Profesionales Especializados**: Modelos de soporte técnico para resolución de problemas de ingeniería.

### 🔬 2. Aplicaciones Científicas
* **Simuladores de Física Fundamental y Partículas**: Modelado atómico y colisiones continuas de alta energía (estilo CERN).
* **Simulaciones Cosmológicas**: Modelado de materia oscura vs. ordinaria, dinámica gravitacional de cuerpos celestes, estrellas y supernovas.
* **Entornos de Entrenamiento Científico**: Laboratorio local para simulación, ajuste y experimentación matemática sin latencia.

### 🎬 3. Herramientas Media Procedural (Video y Audio en Tiempo Real)
* **Texto a Video/Audio en Tiempo Real**: Generación audiovisual procedural basada en guiones y señales fasoriales sin consumo de almacenamiento masivo (*Zero-Storage*).
* **Lector y Conversor Universal de Documentos**: Conversión de archivos PDF, Word o texto plano a secuencias dinámicas de video y voz formántica sintetizada nativamente.
* **Streaming y Reproducción Local**: Difusión fluida y reproducción en tiempo real de contenidos procedurales tanto offline como online.

### 🤖 4. Robótica y Electromecánica
* **Simulador de Mundos Virtuales**: Entornos de físicas continuas para entrenamiento y telemetría de robots reales y virtuales.
* **Modelos de Control Embebido**: Agentes con percepción espacial, audio, procesamiento de señales, cinemática directa/inversa y modulación de pulsos PWM.

### 🧠 5. Inteligencia Artificial y Asistentes Autónomos
* **Entrenamiento e Inferencia Local (*Phasor-SLM*)**: Modelos pequeños de lenguaje y redes neuronales cuánticas (QNN) 100% offline.
* **Asistente Local con Avatar Reactivo**: Agente conversacional con comunicación *Full-Duplex* (interrupción inmediata por voz / *Barge-In*), gesticulación procedural y **gestión estricta de permisos de red** (solicitud explícita de autorización al usuario antes de emitir cualquier petición externa).
* **Agente Co-Creador de KoraDevs**: Asistente integrado en el IDE para asistir a la comunidad en la creación, depuración y optimización de nuevas herramientas.

---

## 3. Directrices Obligatorias de Arquitectura y Rendimiento

### I. Invariante Zero-Allocation (GC-Free Runtime a 90+ / 120 FPS)
1. **PROHIBICIÓN EN RUTAS CRÍTICAS**:
   - Queda estrictamente prohibido instanciar objetos en el montículo (*Heap*) dentro de los bucles iterativos de simulación y renderizado: `tick()`, `render()`, `onDraw()`, `renderFrame()`, `doFrame()` o manejadores continuos de eventos.
   - Prohibido hacer `new Paint()`, `new Path()`, `new RectF()`, `new ArrayList()`, `new Object()`, `new StringBuilder()` o crear arreglos dinámicos en cada frame.
2. **PATRONES DE ALTO RENDIMIENTO**:
   - **Memoria Plana SoA (Structure of Arrays)**: Estructuras contiguas de memoria (ej. buffers de 64 KB en PVM) para almacenamiento eficiente y caché amigable.
   - **Reutilización Estricta de Objetos y Variables**: Instanciación única en constructores o métodos de inicialización (`init()`), reutilizando instancias con métodos de reinicio (`reset()`, `set()`).
   - **Buffers Primitivos y Circulares**: Manejo de datos mediante arreglos planos de tipos primitivos (`float[]`, `double[]`, `boolean[]`, `Float64Array`).

---

### II. Soberanía del Lenguaje y Registros de Hardware (PVM Input Registers)
1. **Control 100% en PhasorLang**: La lógica de layout, el empaquetado de texto (*wrap*), la tipografía responsiva, el clamping de coordenadas y el estado de componentes UI deben ser programables en código puro PhasorLang.
2. **Desacoplamiento del Host**: El runtime (Web Canvas o motor nativo) actúa únicamente como puente ciego de entrada/salida:
   - `R250`: Ancho del Viewport (`width`).
   - `R251`: Alto del Viewport (`height`).
   - `R252`: Coordenada `X` del cursor / puntero táctil.
   - `R253`: Coordenada `Y` del cursor / puntero táctil.
   - `R254`: Estado de pulsación (`0.0` = libre, `1.0` = clic/toque sostenido).
   - `R255`: Delta de desplazamiento de la rueda de scroll (`deltaY`).
3. **Distribución en un Solo Archivo (Standalone HTML)**: La canalización de exportación debe ser capaz de empaquetar el runtime, el WASM/Bytecode y los recursos en un único documento HTML autónomo ejecutable sin dependencias externas.

---

### III. Desacoplamiento de Módulos (Clean Architecture)
1. **Núcleo Aritmético Agnóstico**: `PhasorEngine` y `PVM` deben permanecer puros y desacoplados de APIs propietarias.
2. **Contrato de Extensión Universal**: Cualquier módulo (`ui`, `math`, `quantum`, `game`, `rob`, `cern`, `media`, `net`, `sec`) debe implementar un contrato estandarizado y registrarse de forma modular en el registro de extensiones.
3. **Extracción Segura de Argumentos**: Validación estricta de tipos en el paso de argumentos para evitar excepciones en tiempo de ejecución.

---

### IV. Estándar de Entrega de Código
1. **Cero Comentarios Evasivos y Cero Placeholders**: Al crear o modificar código, entregar siempre las clases, funciones y archivos COMPLETOS y listos para producción.
2. **Preservación de Pruebas Unitarias**: Todo cambio en la biblioteca estándar o en el motor de ejecución debe validar y mantener en verde el 100% de la batería de pruebas en `tests/`.
