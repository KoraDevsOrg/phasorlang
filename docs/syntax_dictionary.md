# Diccionario Maestro de Sintaxis PhasorLang v1.0
# Diccionario Maestro de Sintaxis PhasorLang v1.0
## Ecosistema Autónomo KoraDevs & Chronos IDE

> **Directriz de Arquitectura**: PhasorLang es un Lenguaje de Dominio Específico (DSL) vectorial, cuántico, procedimental y de ultra-alto rendimiento. Su invariante fundamental es la ejecución **Zero-GC** (0 bytes asignados en el Heap en rutas críticas) a 90-120 FPS, respaldado por memoria plana en Estructura de Arreglos (SoA) y registros de hardware virtual `R0..R255`.

---

## 📑 Tabla de Contenidos
1. [Filosofía y Modelo de Ejecución](#1-filosofía-y-modelo-de-ejecución)
2. [Palabras Reservadas (Keywords)](#2-palabras-reservadas-keywords)
3. [Tipos de Datos, Primitivas y Registros](#3-tipos-de-datos-primitivas-y-registros)
4. [Primitivas de Memoria Contigua SoA (Zero-GC)](#4-primitivas-de-memoria-contigua-soa-zero-gc)
5. [Primitivas Gráficas y Lienzo Soberano](#5-primitivas-gráficas-y-lienzo-soberano)
6. [Primitivas Matemáticas, Vectoriales y Fasoriales](#6-primitivas-matemáticas-vectoriales-y-fasoriales)
7. [Cálculo Diferencial e Integral (Calculus Zero-GC)](#7-cálculo-diferencial-e-integral-calculus-zero-gc)
8. [Geometría Fractal y Renderizado Procedural en Pantalla](#8-geometría-fractal-y-renderizado-procedural-en-pantalla)
9. [Sintaxis Operativa y Estructura de Control](#9-sintaxis-operativa-y-estructura-de-control)
10. [Módulos, Componentes e Importación](#10-módulos-componentes-e-importación)
11. [Tabla de Opcodes de la PhasorVM (PVM 3-Operand ISA)](#11-tabla-de-opcodes-de-la-phasorvm-pvm-3-operand-isa)
12. [Guía de Inferencia para Desarrolladores y Modelos de IA](#12-guía-de-inferencia-para-desarrolladores-y-modelos-de-ia)

---

## 1. Filosofía y Modelo de Ejecución

1. **Invariante Zero-Allocation (GC-Free)**: Durante los ciclos continuos de ejecución (`tick()`, `render()`), está terminantemente prohibido instanciar objetos en el Heap. Toda la memoria se preasigna al inicio o se gestiona en buffers planos contiguos.
2. **Soberanía del Lenguaje**: Toda la lógica de componentes, cálculo matricial, diseño de interfaz y respuesta al usuario se escribe en **código puro PhasorLang (`.ph`)**.
3. **PVM Virtual Hardware Registers**: El entorno anfitrión (Web Canvas, Android Surface o Desktop Nativo) actúa únicamente como puente transparente de E/S mediante los registros `R0..R255`.

---

## 2. Palabras Reservadas (Keywords)

| Palabra Reservada | Propósito Semántico | Ejemplo de Uso |
| :--- | :--- | :--- |
| `signal` | Declara una señal reactiva global en memoria plana. Mantiene su valor a lo largo de los frames. | `signal ide_fps = 120.0` |
| `screen` | Define una pantalla declarativa de renderizado que se evalúa por frame. | `screen main { cls(0x0D1117) }` |
| `action` | Define un bloque de lógica reactiva para responder a eventos (botones o atajos). | `action act_run { paused = 0.0 }` |
| `import` | Importa módulos y bibliotecas estándar reutilizables (`.ph` o `.fas`). | `import "lib/ui.ph"` |
| `struct` | Declara estructuras de datos mapeadas a canales contiguos de memoria SoA. | `struct Token { type: Float, len: Float }` |
| `while` | Bucle iterativo determinista de cómputo numérico o procedimental. | `while (i < 10.0) { i = i + 1.0 }` |
| `if` | Bifurcación condicional de ejecución. | `if (x > 100.0) { x = 0.0 }` |
| `else` | Rama alternativa en una bifurcación condicional. | `if (sw < 768.0) { m = 0.0 } else { m = 1.0 }` |
| `return` | Retorna un valor escalar o vectorial desde una función. | `return x * 2.0` |
| `true` | Constante lógica equivalente al escalar `1.0`. | `activo = true` |
| `false` | Constante lógica equivalente al escalar `0.0`. | `pausado = false` |

---

## 3. Tipos de Datos, Primitivas y Registros

### Tipos Nativos
- **`Float`**: Número de punto flotante de 64 bits (IEEE 754). Es el tipo escalar universal de cómputo en PVM.
- **`Vec3`**: Vector SIMD tridimensional / Fasor Polar. Representa magnitudes espaciales `[x, y, z]` o fasores eléctricos `[Magnitud, Ángulo_Grados, Componente_Z]`.
  ```phasor
  v_smith: Vec3 = [120.0, 45.0, 0.0]  // 120 V a 45 grados
  ```
- **`Complex`**: Número complejo nativo compuesto por parte real y parte imaginaria (`re + j*im`).

### Banco de Registros PVM (`R0..R255`) — Hardware & Periféricos Directos
La Phasor Virtual Machine expone 256 registros primitivos directos accesibles como lenguaje máquina/ensamblador sin capas intermedias:

| Rango / Registro | Denominación | Función y Descripción Operativa |
| :--- | :--- | :--- |
| `R0 .. R199` | Registros Locales de Cómputo | Variables locales, escalares, cálculo vectorial SIMD y temporales de funciones. |
| **Puntero y Ratón Nativo** | | |
| `R250` | `VIEWPORT_WIDTH` | Ancho actual en píxeles del lienzo/pantalla inyectado por el anfitrión. |
| `R251` | `VIEWPORT_HEIGHT` | Alto actual en píxeles del lienzo/pantalla inyectado por el anfitrión. |
| `R252` | `POINTER_X` | Coordenada X actual del puntero del ratón o toque táctil en pantalla. |
| `R253` | `POINTER_Y` | Coordenada Y actual del puntero del ratón o toque táctil en pantalla. |
| `R254` | `POINTER_DOWN` | Clic primario (izquierdo): `1.0` si está presionado, `0.0` si está libre. |
| `R248` | `POINTER_RIGHT` | Clic secundario (derecho): `1.0` si está presionado, `0.0` si está libre. |
| `R249` | `POINTER_MIDDLE` | Clic terciario (rueda central pulsada): `1.0` presionado, `0.0` libre. |
| `R255` | `SCROLL_WHEEL_Y` | Delta de desplazamiento vertical de la rueda del ratón (`deltaY`). |
| `R247` | `SCROLL_WHEEL_X` | Delta de desplazamiento horizontal de la rueda del ratón (`deltaX`). |
| `R229` | `SYS_CURSOR_SHAPE` | Salida de forma de cursor: 0=default, 1=pointer, 2=text, 3=move, 4=ew-resize, 5=ns-resize, 6=nwse-resize, 7=nesw-resize, 8=grabbing. |
| **Gamepad USB / Bluetooth & Robótica** | | |
| `R240` | `GAMEPAD_CONNECTED` | Estado del mando: `1.0` si hay un joystick/gamepad conectado, `0.0` si no. |
| `R241` | `GAMEPAD_LX` | Stick analógico izquierdo Eje X: Rango continuo `[-1.0 .. +1.0]`. |
| `R242` | `GAMEPAD_LY` | Stick analógico izquierdo Eje Y: Rango continuo `[-1.0 .. +1.0]`. |
| `R243` | `GAMEPAD_RX` | Stick analógico derecho Eje X: Rango continuo `[-1.0 .. +1.0]`. |
| `R244` | `GAMEPAD_RY` | Stick analógico derecho Eje Y: Rango continuo `[-1.0 .. +1.0]`. |
| `R245` | `GAMEPAD_BTN_A` | Botón A / Cruz / Disparador primario: `1.0` presionado, `0.0` libre. |
| `R246` | `GAMEPAD_BTN_B` | Botón B / Círculo / Freno o retroceso: `1.0` presionado, `0.0` libre. |
| `R238` | `GAMEPAD_BTN_X` | Botón X / Cuadrado / Acción auxiliar: `1.0` presionado, `0.0` libre. |
| `R239` | `GAMEPAD_BTN_Y` | Botón Y / Triángulo / Menú o modo: `1.0` presionado, `0.0` libre. |
| `R234` | `GAMEPAD_LB` | Bumper / Gatillo superior izquierdo L1: `1.0` presionado, `0.0` libre. |
| `R235` | `GAMEPAD_RB` | Bumper / Gatillo superior derecho R1: `1.0` presionado, `0.0` libre. |
| `R236` | `GAMEPAD_LT` | Gatillo analógico izquierdo L2: Presión analógica `[0.0 .. 1.0]`. |
| `R237` | `GAMEPAD_RT` | Gatillo analógico derecho R2: Presión analógica `[0.0 .. 1.0]`. |
| `R233` | `GAMEPAD_DPAD` | Cruceta direccional digital (Máscara: 1=Arriba, 2=Der, 4=Abajo, 8=Izq). |
| **Teclado Físico Directo** | | |
| `R230` | `KEY_CODE` | Código numérico ASCII/Virtual Key de la tecla pulsada (ej. 32=Espacio, 27=Esc). |
| `R231` | `KEY_DOWN` | Estado de tecla: `1.0` si hay tecla sostenida en el frame, `0.0` libre. |
| `R232` | `KEY_MODIFIERS` | Modificadores activos (Bitmask: 1=Shift, 2=Control, 4=Alt, 8=Meta). |

---

### Ejemplos Prácticos de Captura de Periféricos en PhasorLang

#### 1. Telemetría y Control de Brazo Robótico (Gamepad USB)
```phasor
// Control cinemático de articulaciones en tiempo real
if (R240 > 0.0) {
    vel_x = R241 * 5.0      // Velocidad base desde stick izquierdo X
    vel_y = R242 * 5.0      // Velocidad elevación desde stick izquierdo Y
    pinza_apertura = R237   // Apertura analógica proporcional del gatillo RT (0..1)
    if (R245 > 0.0) {
        activar_iman = 1.0  // Botón A activa electroimán
    }
}
```

#### 2. Detección Nativa de Clics de Ratón para Interfaces de Ventana
```phasor
// Clic izquierdo (R254) arrastra; Clic derecho (R248) abre menú contextual
if (R254 > 0.0) {
    if (R252 >= win_x && R252 <= win_x + win_w && R253 >= win_y && R253 <= win_y + 28.0) {
        win_dragging = 1.0
    }
}
if (R248 > 0.0) {
    menu_contextual_abierto = 1.0
    menu_x = R252
    menu_y = R253
}
```

---

## 4. Primitivas de Memoria Contigua SoA (Zero-GC)

PhasorLang implementa **Structure of Arrays (SoA)** para garantizar localidad espacial de caché y cero recolección de basura:

```phasor
// Reserva un buffer contiguo en PVM
// Canales = Número de campos de la estructura
// Capacidad = Máximo número de elementos
buffer = alloc_soa(canales, capacidad)

// Almacena un valor en el canal y posición especificada (O(1))
set_soa(buffer, canal, indice, capacidad, valor)

// Recupera un valor desde el canal y posición especificada (O(1))
valor = get_soa(buffer, canal, indice, capacidad)
```

### Ejemplo de Estructura de Partículas SoA:
```phasor
MAX_PARTICULAS = 1024.0
// 4 canales: 0=pos_x, 1=pos_y, 2=vel_x, 3=vel_y
particulas = alloc_soa(4.0, MAX_PARTICULAS)

// Inicializar partícula #0
set_soa(particulas, 0.0, 0.0, MAX_PARTICULAS, 100.0) // x = 100.0
set_soa(particulas, 1.0, 0.0, MAX_PARTICULAS, 200.0) // y = 200.0
set_soa(particulas, 2.0, 0.0, MAX_PARTICULAS, 1.5)   // vx = 1.5
set_soa(particulas, 3.0, 0.0, MAX_PARTICULAS, -0.5)  // vy = -0.5

// Lectura de posición X
px = get_soa(particulas, 0.0, 0.0, MAX_PARTICULAS)
```

---

## 5. Primitivas Gráficas y Lienzo Soberano

Todas las primitivas emiten bytecodes PVM directos procesados a 120 FPS:

### 1. Limpieza de Pantalla
```phasor
cls(color_hex)
// Ejemplo: Limpiar con fondo oscuro KoraDevs
cls(0x0D1117)
```

### 2. Rectángulo Relleno
```phasor
rect(x, y, ancho, alto, color_hex)
// Ejemplo: Barra de herramientas
rect(0.0, 0.0, 800.0, 48.0, 0x161B22)
```

### 3. Círculo y Circunferencias
```phasor
circle(centro_x, centro_y, radio, color_hex)
// Ejemplo: Punto de breakpoint rojo o nodo fasorial
circle(14.0, 145.0, 4.0, 0xF85149)
```

### 4. Líneas Vectoriales
```phasor
line(x1, y1, x2, y2, color_hex)
// Ejemplo: Separador de panel
line(0.0, 48.0, 800.0, 48.0, 0x30363D)
```

### 5. Texto Tipográfico Monoespaciado
```phasor
text(cadena_o_variable, x, y, tamano_px, color_hex)
// Ejemplo: Etiqueta de código
text("signal ide_fps = 120.0", 54.0, 125.0, 11.0, 0x3FB950)
```

### 6. Botones Interactivos con Hit-Testing
```phasor
btn(etiqueta, x, y, ancho, alto, accion_id, color_hex)
// Ejemplo: Botón de compilación automática
btn("⚙ Compilar HTML", 650.0, 8.0, 140.0, 32.0, act_self_compile, 0x8957E5)
```

### 7. Recorte de Hardware Scissor Clipping (`clip` / `unclip`)
Permite confinar el dibujado de cualquier sub-ventana o panel estrictamente a un rectángulo `[x, y, ancho, alto]` para que el contenido desbordado se oculte suavemente píxel a píxel detrás del marco sin afectar otras ventanas ni el fondo espacial:
```phasor
clip(x, y, ancho, alto)
// Todo comando rect(), circle(), line(), text() posterior se recorta al rectángulo
text("Contenido con scroll suave", x - scroll_x, y - scroll_y, 9.0, 0x58A6FF)
unclip()
// O mediante los encapsuladores de lib/ui_scrollbar.ph:
sb_begin_clip(hx, hy, w, h, top, cw, ch)
// ... dibujar contenido ...
sb_end_clip()
```

---

## 6. Primitivas Matemáticas, Vectoriales y Fasoriales

### Funciones Escalares
- `sin(rad)`: Seno trigonométrico.
- `cos(rad)`: Coseno trigonométrico.
- `tan(rad)`: Tangente trigonométrica.
- `sqrt(val)`: Raíz cuadrada de valor absoluto.
- `abs(val)`: Valor absoluto.
- `pow(base, exp)`: Potenciación.
- `mod(a, b)` o `a % b`: Módulo / residuo entero.

### Álgebra Vectorial SIMD (`Vec3`)
- `v = [mag, ang, z]`: Creación de fasor en coordenadas polares.
- `vec3_add(v1, v2)`: Suma vectorial / fasorial superpuesta.
- `vec3_sub(v1, v2)`: Resta vectorial.
- `vec3_scale(v, factor)`: Escalamiento por escalar.
- `vec3_dot(v1, v2)`: Producto punto / escalar.
- `vec3_cross(v1, v2)`: Producto cruz vectorial en 3D.
- `vec3_mag(v)`: Magnitud euclidiana `sqrt(x^2 + y^2 + z^2)`.
- `vec3_norm(v)`: Normalización unitaria del vector.

---

## 7. Cálculo Diferencial e Integral (Calculus Zero-GC)

PhasorLang permite calcular integrales definidas, integrales continuas de señales temporales, derivadas numéricas y potencia media de fasores mediante algoritmos deterministas a 120 FPS sin asignar objetos en el Heap:

```phasor
import "lib/calculus.ph"
```

### 1. Integral Definida por Regla Trapezoidal Compuesta
Calcula el área bajo la curva $I = \int_{a}^{b} f(x)\,dx$ subdividiendo el intervalo en $N$ pasos:
```phasor
// Parámetros: f_id (1=sin, 2=cos, 3=x^2, 4=x^3-x, 5=Gauss), a, b, n_steps
// Ejemplo: ∫_0^π sin(x) dx ≈ 2.0000
area_seno = integral_trapezoidal(1.0, 0.0, 3.14159265, 100.0)

// Ejemplo: Área bajo parábola x^2 de 0 a 3: ∫_0^3 x^2 dx = 9.0000
area_parabola = integral_trapezoidal(3.0, 0.0, 3.0, 120.0)
```

### 2. Integral de Alta Precisión por Regla de Simpson 1/3 (Orden 4)
Para funciones de orden superior o alta convergencia geométrica:
```phasor
// Parámetros: f_id, a, b, n_pares (genera 2*n_pares subdivisiones)
area_exacta = integral_simpson(3.0, 0.0, 3.0, 50.0) // 9.0000 exacto
```

### 3. Integración Temporal Reactiva en Tiempo Real (Euler / DSP / PID / Física)
Para acumular aceleración a velocidad, o velocidad a posición dentro del bucle continuo `tick()`:
$$y_k = y_{k-1} + (x_k \cdot \Delta t)$$
```phasor
// Parámetros: accum, valor_instantaneo, dt, limite_antiwindup
signal vel_y = 0.0
signal pos_y = 100.0
dt = 0.00833 // ~120 FPS

pos_y = integral_step(pos_y, vel_y, dt, 1000.0)
```

### 4. Diferenciación Numérica Central (Derivadas $f'(x)$)
Aproximación finita de orden 2:
$$f'(x) \approx \frac{f(x+h) - f(x-h)}{2h}$$
```phasor
// Parámetros: f_id, x, h_step
// Ejemplo: Derivada de sin(x) en x = π/2 -> cos(π/2) = 0.0
pendiente = derivative_central(1.0, 1.5707963, 0.0005)
```

### 5. Integral Fasorial de Potencia Eléctrica RMS
Calcula la potencia activa disipada integrando el producto fasorial de voltaje y corriente en un ciclo de red $T = 1/f$:
$$P = \frac{1}{T}\int_{0}^{T} v(t) \cdot i(t)\,dt$$
```phasor
// Parámetros: v_mag, v_ang_deg, i_mag, i_ang_deg, freq_hz, pasos
p_activa = integral_potencia_rms(120.0, 0.0, 10.0, 30.0, 60.0, 200.0)
```

---

## 8. Geometría Fractal y Renderizado Procedural en Pantalla

Los fractales son estructuras auto-similares de complejidad infinita generadas matemáticamente. En PhasorLang se calculan mediante bucles iterativos `while` en memoria plana y se proyectan directamente sobre la pantalla Canvas a 120 FPS mediante primitivas gráficas (`rect`, `line`, `circle`):

```phasor
import "lib/fractal_ui.ph"
```

### 1. Conjunto de Julia Dinámico ($z = z^2 + c$)
Se itera cada coordenada del plano complejo verificando si escapa del radio de escape $|z|^2 > 4.0$. El ratio de escape se mapea a frecuencias espectrales en Hertz (óptica) o colores RGB:
```phasor
// Dibuja panel de Julia en (px, py, ancho, alto) con c = -0.7 + 0.27j y paso de 4px
render_julia_panel(50.0, 80.0, 320.0, 220.0, -0.7, 0.27, 4.0)
```

### 2. Conjunto de Mandelbrot ($z_{n+1} = z_n^2 + c$, $z_0 = 0$)
Permite exploración con zoom interactivo y centrado dinámico mediante registros del ratón `R252, R253`:
```phasor
// Parámetros: px, py, pw, ph, zoom, center_x, center_y, step_size
render_mandelbrot_panel(400.0, 80.0, 320.0, 220.0, 1.5, -0.5, 0.0, 4.0)
```

### 3. Curvas y Copo de Nieve de Koch (Fasores de 60°)
Se genera geométricamente aplicando rotaciones fasoriales continuas de $60^\circ$ ($\cos 60^\circ = 0.5, \sin 60^\circ = 0.8660254$):
```phasor
// Dibuja copo de nieve fractal de Koch centrado en (cx, cy) con radio 70px
koch_snowflake_hz(200.0, 360.0, 70.0, 3.0, 5.5e14)
```

### 4. Componentes UI Fractales
Botones con bordes fractales reactivos que vibran visualmente con la frecuencia en Hertz:
```phasor
fractal_button("⚡ Ejecutar Fractal", 100.0, 480.0, 200.0, 40.0, act_run, 4.8e14)
```

### 5. ¿Es esto de diseño o de cómputo?
- **Es de Cómputo Puro**: El cálculo de la ecuación fractal ($z^2+c$, iteraciones de escape, rotaciones fasoriales) ocurre en la máquina virtual PVM a 120 FPS sin tocar el Garbage Collector.
- **Es de Diseño Visual**: La proyección en pantalla transforma esos números complejos en arte visual procedural, degradados de color en Hertz, fondos reactivos de ventanas y botones ergonómicos para el usuario.

---

## 9. Sintaxis Operativa y Estructura de Control

### Declaración de Funciones
Las funciones se declaran mediante la sintaxis de bloque funcional `=` `{ ... }`:
```phasor
calcular_impedancia(r, x_ind) = {
    z_mag = sqrt((r * r) + (x_ind * x_ind))
    z_mag
}
```

### Operadores Aritméticos
`+` (suma), `-` (resta), `*` (multiplicación), `/` (división con guardia anti-cero), `%` (módulo).

### Operadores de Comparación y Lógica
- `==`: Igualdad escalar.
- `!=`: Desigualdad escalar.
- `<`: Menor que.
- `<=`: Menor o igual que.
- `>`: Mayor que.
- `>=`: Mayor o igual que.

### Bloques Condicionales
```phasor
if (sw < 768.0) {
    ide_modo_escritorio = 0.0
} else {
    ide_modo_escritorio = 1.0
}
```

### Bucles de Cómputo Determinista
```phasor
px = 0.0
while (px < 500.0) {
    wave_y = cy + (sin(px * 0.05) * 30.0)
    circle(px, wave_y, 1.5, 0x3FB950)
    px = px + 6.0
}
```

---

## 10. Módulos, Componentes e Importación

PhasorLang utiliza un sistema de resolución modular basado en `import`:

```phasor
import "lib/color.ph"
import "lib/calculus.ph"
import "lib/fractal_ui.ph"
import "lib/ui_ide_menu.ph"
```

### Reglas de Importación:
1. Las directivas `import` se colocan al inicio del archivo fuente.
2. El compilador resuelve las rutas de forma recursiva construyendo un único árbol sintáctico unificado.
3. Al compilar a HTML con `phasor bundle`, todos los imports se empaquetan en el componente `<phasorcode>`.

---

### Catálogo de Componentes Oficiales de UI (KoraDevs)

#### Componente: `lib/ui_scrollbar.ph` (Barras de Desplazamiento 2D Neón)
Referencia directa del componente fuente: [`lib/ui_scrollbar.ph`](file:///d:/Documents/SketchWarePro/lib/ui_scrollbar.ph)

Diseñado con el estándar visual de **Chronos IDE / Phasor IDE**:
- **Estética Neón**: Pista oscura (`0x161B22`) con bordes perimetrales (`0x21262D`), thumb azul cian neón (`0x58A6FF`) y reactivo en arrastre (`0x79C0FF`).
- **Grosor Ergonómico**: Pista de `8.0` px y pulgar de `6.0` px con radio visual.
- **Reserva de Esquina**: Margen de `16.0` px en la esquina inferior-derecha para convivir con los tiradores de redimensión 8D (`SE`).
- **Zona de Captura Amplia**: Hit-testing con tolerancia de `14.0` px para que el agarre táctil o con cursor sea infalible.
- **Escudo de Oclusión Perimetral (Viewport Shield)**: Sella automáticamente cualquier desborde de contenido detrás de las columnas del scrollbar y los bordes de la ventana, permitiendo que elementos grandes (texto, círculos fasoriales, diagramas) se deslicen y oculten suavemente detrás del marco sin desapariciones mágicas ni manchas en el fondo exterior.
- **Invariante Zero-GC**: Cero asignaciones en memoria Heap a 120 FPS, optimizado para el límite canónico de registros locales PVM (`R0..R229`).

##### 1. Uso Declarativo Rápido para Plantillas y Sub-pantallas (Opción B)
Para desarrolladores de aplicaciones o plantillas que solo desean activar el scroll con un flag estándar (`scroll: true` / `1.0`):

```phasor
import "lib/ui_scrollbar.ph"

screen mi_pantalla {
    // Coordenadas y dimensiones de la ventana
    hx = 50.0; hy = 80.0; w = 480.0; h = 360.0; top = 28.0
    cw = 800.0; ch = 1200.0 // Contenido lógico más grande que la ventana
    
    // Contenido desplazado con sc_x y sc_y ...
    
    // Inserción automática del componente de scrollbars 2D (último argumento = 1.0 / true)
    ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, sc_x, sc_y, active_axis, 1.0)
}
```

##### 2. Uso Procedural de Bajo Nivel para Desarrolladores Avanzados (Opción A)
Para desarrolladores que construyen sus propios controles o desean personalizar dimensiones, agarres o colores:

```phasor
import "lib/ui_scrollbar.ph"

// Métricas de viewport
clw = sb_client_w(w)
clh = sb_client_h(h, top)
limit_x = sb_max_scroll_x(cw, clw)
limit_y = sb_max_scroll_y(ch, clh)

// Detección de hit en barra vertical (0=nada, 1=thumb, 2=pista)
hit_v = sb_hit_test_v(hx, hy, w, h, top, cw, ch, sc_y, mx, my)

// Cálculo de offset al agarrar el thumb
grab_y = sb_calc_grab_v(hx, hy, w, h, top, cw, ch, sc_y, hit_v, my)

// Desplazamiento continuo al arrastrar el ratón
nuevo_sc_y = sb_apply_drag_v(hx, hy, w, h, top, cw, ch, grab_y, my)

// Renderizado directo
render_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, sc_x, sc_y, active_axis)
```

---

## 11. Tabla de Opcodes de la PhasorVM (PVM 3-Operand ISA)

| Opcode Hex | Mnemónico | Operandos | Descripción |
| :--- | :--- | :--- | :--- |
| `0x00` | `OP_NOP` | Ninguno | Sin operación / ciclo nulo. |
| `0x01` | `OP_LOAD_K` | `dst, s1` | Carga constante numérica del pool en `R[dst]`. |
| `0x02` | `OP_MOV` | `dst, s1` | Copia registro escalar y fasor polar `R[dst] = R[s1]`. |
| `0x03` / `0x10` | `OP_ADD` | `dst, s1, s2` | Suma escalar o de números complejos. |
| `0x04` / `0x11` | `OP_SUB` | `dst, s1, s2` | Resta escalar o de números complejos. |
| `0x05` / `0x12` | `OP_MUL` | `dst, s1, s2` | Multiplicación escalar o fasorial. |
| `0x06` / `0x13` | `OP_DIV` | `dst, s1, s2` | División escalar segura con guardia contra división por cero. |
| `0x14` | `OP_POW` | `dst, s1, s2` | Potencia matemática `s1^s2`. |
| `0x15` | `OP_MOD` | `dst, s1, s2` | Residuo entero / módulo. |
| `0x16` | `OP_SQRT` | `dst, s1` | Raíz cuadrada de valor absoluto. |
| `0x17` | `OP_SIN` | `dst, s1` | Seno trigonométrico. |
| `0x18` | `OP_COS` | `dst, s1` | Coseno trigonométrico. |
| `0x19` | `OP_TAN` | `dst, s1` | Tangente trigonométrica. |
| `0x1C` | `OP_ABS` | `dst, s1` | Valor absoluto. |
| `0x21` | `OP_CMP_EQ` | `dst, s1, s2` | `1.0` si `s1 == s2`, sino `0.0`. |
| `0x22` | `OP_CMP_NEQ` | `dst, s1, s2` | `1.0` si `s1 != s2`, sino `0.0`. |
| `0x23` | `OP_CMP_LT` | `dst, s1, s2` | `1.0` si `s1 < s2`, sino `0.0`. |
| `0x24` | `OP_CMP_LTE` | `dst, s1, s2` | `1.0` si `s1 <= s2`, sino `0.0`. |
| `0x25` | `OP_CMP_GT` | `dst, s1, s2` | `1.0` si `s1 > s2`, sino `0.0`. |
| `0x26` | `OP_CMP_GTE` | `dst, s1, s2` | `1.0` si `s1 >= s2`, sino `0.0`. |
| `0x40` | `OP_JMP` | `target_pc` | Salto incondicional de Program Counter. |
| `0x41` | `OP_JMP_IF_ZERO`| `cond, target_pc`| Salto condicional si `R[cond] == 0.0`. |
| `0x50` | `OP_UI_CLS` | `col` | Limpieza total de canvas con color. |
| `0x51` | `OP_UI_RECT` | `x, y, w, h, col`| Dibujado de rectángulo relleno. |
| `0x52` | `OP_UI_CIRCLE` | `cx, cy, r, col` | Dibujado de círculo o punto fasorial. |
| `0x53` | `OP_UI_LINE` | `x1, y1, x2, y2, col`| Dibujado de segmento de línea. |
| `0x54` | `OP_UI_TEXT` | `str_id, x, y, col`| Dibujado de texto desde tabla de cadenas. |
| `0x56` | `OP_UI_BTN` | `label, x, y, w, h, act, col`| Botón con hit-testing de clic automático. |
| `0x5A` | `OP_UI_CLIP` | `x, y, w, h` | Activa Scissor Clipping rectangular de hardware (`ctx.clip()`). |
| `0x5B` | `OP_UI_UNCLIP` | Ninguno | Restaura el estado de recorte anterior (`ctx.restore()`). |
| `0x60` | `OP_VEC3_LOAD` | `dst, x, y, z` | Carga de vector SIMD o fasor polar. |
| `0x61` | `OP_VEC3_ADD` | `dst, s1, s2` | Suma SIMD de 3 canales. |
| `0x64` | `OP_VEC3_DOT` | `dst, s1, s2` | Producto punto escalar de vectores. |
| `0x66` | `OP_VEC3_MAG` | `dst, s1` | Magnitud vectorial. |
| `0x70` | `OP_SOA_ALLOC` | `dst, canales, cap`| Reserva de memoria contigua SoA. |
| `0x71` | `OP_SOA_LOAD` | `dst, buf, ch, idx`| Lectura directa en estructura SoA. |
| `0x72` | `OP_SOA_STORE`| `val, buf, ch, idx`| Escritura directa en estructura SoA. |
| `0xFF` | `OP_HALT` | Ninguno | Finaliza la ejecución del ciclo actual. |

---

## 12. Guía de Inferencia para Desarrolladores y Modelos de IA

Para que cualquier desarrollador o modelo de lenguaje (como **Phasor-SLM** o asistentes autónomos) genere código PhasorLang válido y de máximo rendimiento:

1. **Estructura Mínima Obligatoria**:
   ```phasor
   // 1. Declaración de señales reactivas
   signal t_global = 0.0

   // 2. Pantalla principal obligatoria
   screen main {
       cls(0x0D1117)
       t_global = t_global + 1.0

       // Lectura de registros de pantalla
       vw = R250
       vh = R251

       // Dibujo reactivo
       circle(vw * 0.5, vh * 0.5, 50.0, 0x58A6FF)
   }
   ```
2. **Prohibición Absoluta de Objetos en Heap**: No intentar usar `new`, crear cadenas dinámicas dentro de bucles `while`, o instanciar arrays dinámicos. Usar `alloc_soa` para colecciones.
3. **Coordenadas y Clamping**: En interfaces con scroll, siempre acotar las posiciones mediante sentencias `if (sc_y < 0.0) { sc_y = 0.0 }` y limitar el dibujado dentro del contenedor de la ventana.
4. **Interactividad**: Los botones siempre invocan bloques `action` o funciones modulares con detección de bordes (`ui_hit_box`, `ui_tree_hit`). El estado visual se actualiza modificando señales (`signals`).
5. **Disciplina de Bloques Planos PVM (Flat Block Watermark)**: En funciones con múltiples comprobaciones condicionales, asignar primero el resultado de una función a una variable canónica (`hit = ui_hit_box(...)`) a nivel de bloque antes del `if (hit == 1.0) { ... }`. Así el emisor PVM libera automáticamente los registros temporales tras cada sentencia.

---

## 13. Estándar Oficial de Nuevo Proyecto (`samples/template_new_project/main.ph`)

Todo aplicativo nuevo creado en **Chronos IDE** (o mediante el botón **`+ Proyecto`** del Explorador) utiliza por defecto la **Arquitectura Espacial Estándar de PhasorLang**, salvo que el desarrollador indique explícitamente lo contrario:

1. **Contenedor Principal Toroidal (`lib/ui_spatial_main.ph`)**:
   - Provee el fondo espacial infinito de `360°` con grilla fasorial y paneo libre mediante arrastre en el espacio vacío o Gamepad USB.
2. **Ventana Inicial `Screen 1` Activa en Blanco (`lib/ui_window_frame.ph` + `lib/ui_scrollbar.ph`)**:
   - Se instancia por defecto una ventana flotante **`Screen 1`** completamente funcional con:
     - Arrastre desde su barra de título y botón de minimizado (`[-]` / `[+]`).
     - Redimensionamiento en 8 direcciones (`N, S, E, W, NE, NW, SE, SW`) con cursores nativos (`R229`).
     - **Scissor Clipping Suave de Hardware (`sb_begin_clip` / `sb_end_clip`)** y **Scrollbars 2D Neón (`ui_subscreen_scrollbars`)** activos en blanco listos para recibir contenido.
3. **Libertad Total del Desarrollador**:
   - El desarrollador escribe su código dentro de `render_screen_1_content(hx, hy, w, h, is_min, dx, dy, act)`, o puede eliminar `Screen 1` o duplicar su estructura para crear múltiples pantallas (`Screen 2`, `Screen 3`, etc.).

### Estructura Base de `main.ph` (Nuevo Proyecto):
```phasor
import "lib/ui_spatial_main.ph"
import "lib/ui_window_frame.ph"
import "lib/ui_viewport.ph"
import "lib/ui_scrollbar.ph"
import "lib/ui_components.ph"

render_screen_1_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = 28.0; cw = s1_cw; ch = s1_ch
        rect(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0, 0x090D13)

        sb_begin_clip(hx, hy, w, h, top, cw, ch)
        tx = hx + 20.0 - dx
        ty = hy + 48.0 - dy

        // --- ESCRIBE AQUÍ EL CONTENIDO DE TU APLICACIÓN ---
        ui_card(tx, ty, 480.0, 96.0, 0x0D1117, 0x21262D)
        ui_badge_box(tx + 14.0, ty + 14.0, 48.0, 0x238636)
        text("READY", tx + 21.0, ty + 17.0, 8, 0xFFFFFF)

        sb_end_clip()
        ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, 1.0)
        1.0
    }
}
```

---

## 14. Catálogo de Componentes Reactivos Gen-2 (`lib/ui_components.ph`)

PhasorLang soporta paso nativo de parámetros de texto (`label_str` con propagación de tipo `TOK_STR` / `isString = 2` en `BytecodeEmitter` y `PhasorVM`) e **Immediate-Mode UI (IMGUI) de 1 sola línea**: cada componente renderiza la geometría retro-cyberpunk, el texto nítido, el **Hover en tiempo real a 120 FPS** y evalúa la colisión del cursor (`mx, my`) en una única llamada, sin duplicar código entre renderizado e interacción.

| Función / Componente | Firma de Parámetros | Propósito y Retorno Reactivo |
| :--- | :--- | :--- |
| **`ui_button`** | `ui_button(label_str, orig_x, orig_y, orig_w, orig_h, act, nw, mx, my)` | Botón reactivo universal de 1 línea con texto `"..."`, estado activo (`act == 1.0`) y **Hover automático**. Retorna `1.0` cuando el cursor está sobre el botón, o `0.0` fuera. |
| **`ui_tree_node`** | `ui_tree_node(label_str, orig_x, orig_y, orig_w, depth, is_dir, dir, act, nw, mx, my)` | Nodo declarativo de árbol (*TreeView*) de 1 línea con sangría `depth * 14 px`, guía `├─`, chevron `v`/`>`, icono vectorial procedural, indicador de edición (`●`), botón `[⋮]` con hover propio y texto `"..."`. Retorna `0.0` (fuera), `1.0` (sobre la fila) o `2.0` (sobre el botón `[⋮]`). |
| **`ui_context_menu`** | `ui_context_menu(label_str, orig_x, orig_y, orig_w, orig_h)` | Menú emergente (*Popover / Context Menu*) con sombra proyectada multicapa, marco neón y barra de título con texto `"..."`. |
| **`ui_menu_item`** | `ui_menu_item(label_str, orig_x, orig_y, orig_w, nw, mx, my)` | Opción interactiva de menú emergente con barra de resaltado **Hover** e indicador lateral cian. Retorna `1.0` si el cursor está sobre la opción, o `0.0` fuera. |
| **`ui_badge`** | `ui_badge(label_str, orig_x, orig_y, orig_w, nw, nh)` | Píldora/insignia (*Badge*) de 1 línea con fondo `nw`, borde luminoso y etiqueta `"..."` en color `nh`. |
| **`ui_status_bar`** | `ui_status_bar(label_str, orig_x, orig_y, orig_w, nw, nh)` | Barra de estado / cabecera compacta de 1 línea con fondo `nw` y texto `"..."` en color `nh`. |
| **`ui_card`** | `ui_card(orig_x, orig_y, orig_w, orig_h, nw, nh)` | Tarjeta contenedora rectangular con fondo `nw` y borde perimetral de 1 px `nh` sin alterar `hx, hy, w, h`. |
| **`ui_divider`** | `ui_divider(orig_x, orig_y, orig_w, nw)` | Línea separadora horizontal limpia para dividir secciones dentro de tarjetas o paneles. |
| **`ui_hit_box`** | `ui_hit_box(orig_x, orig_y, orig_w, orig_h, mx, my)` | Hit-testing rectangular plano Zero-GC. Retorna `1.0` si `(mx, my)` está dentro del área, o `0.0` fuera. |

### Comparativa de Ergonomía ("Antes vs. Después" en PhasorLang):
```phasor
import "lib/ui_components.ph"

// ANTES (3 pasos manuales + funciones separadas de clic y render):
// ui_button_box(tx + 8.0, ty + 42.0, 56.0, 18.0, 0.0, 0x1F6FEB)
// text("Abrir", tx + 18.0, ty + 46.0, 8, 0x58A6FF)
// hit = ui_hit_box(tx + 8.0, ty + 42.0, 56.0, 18.0, mx, my)

// AHORA (1 sola línea declarativa con Hover en vivo + Texto + Hit-Test):
if (ui_button("Abrir", tx + 8.0, ty + 42.0, 48.0, 18.0, 0.0, 0x1F6FEB, mx, my) == 1.0) {
    if (exp_click_pending == 1.0) { exp_open_selected_in_editor() } else { 1.0 }
} else { 1.0 }

// Árbol jerárquico completo con Hover, Clic Simple y Menú Emergente [⋮] en 1 línea por nodo:
exp_node("samples/ (Aplicativos)", 0.0, 1.0, exp_d1, 1.0, -1.0, 0xF2CC60, tmx, bmy)
exp_node("main.ph (Plantilla Base)", 1.0, 0.0, 0.0, 11.0, 1.0, 0x58A6FF, tmx, bmy)
```
