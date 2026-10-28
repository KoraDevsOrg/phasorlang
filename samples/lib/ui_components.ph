// ===============================================================================
// LIB/UI_COMPONENTS.PH — CATÁLOGO DE COMPONENTES GENÉRICOS REUTILIZABLES
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// https://github.com/koradevsorg
//
// Componentes Universales de Interfaz de Usuario (Zero-GC a 120 FPS):
// - Aislamiento Estricto de Registros Hoja (orig_x, orig_y, orig_w, orig_h, nw, nh, nx, ny):
//   Ningún componente altera jamás las coordenadas de ventana (hx, hy, w, h) ni los
//   cursores de layout del llamador (tx, ty, dx, dy, ct, cb, clw, clh).
// - Ley de Cadenas Literales PVM: Los textos se invocan directamente con text("...", ...)
//   en el llamador para garantizar indexación directa en STRINGS[] sin números ni NaN.
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. CONTENEDOR TARJETA (UI_CARD) Y SEPARADOR (UI_DIVIDER)
// -------------------------------------------------------------------------------
// Dibuja un contenedor tarjeta en (orig_x, orig_y) de tamaño (orig_w, orig_h)
// con color de fondo (nw) y color de borde perimetral (nh).
ui_card(orig_x, orig_y, orig_w, orig_h, nw, nh) = {
    rect(orig_x, orig_y, orig_w, orig_h, nw)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, nh)
    line(orig_x, orig_y + orig_h, orig_x + orig_w, orig_y + orig_h, nh)
    line(orig_x, orig_y, orig_x, orig_y + orig_h, nh)
    line(orig_x + orig_w, orig_y, orig_x + orig_w, orig_y + orig_h, nh)
    1.0
}

// Dibuja una línea separadora horizontal limpia en (orig_x, orig_y) de ancho (orig_w)
ui_divider(orig_x, orig_y, orig_w, nw) = {
    line(orig_x, orig_y, orig_x + orig_w, orig_y, nw)
    1.0
}

// -------------------------------------------------------------------------------
// 2. INSIGNIA (UI_BADGE_BOX) Y BARRA DE ESTADO (UI_STATUS_BOX)
// -------------------------------------------------------------------------------
// Dibuja el contenedor de una insignia (16 px de alto) sin alterar (hx, hy, w, h, tx, ty)
ui_badge_box(orig_x, orig_y, orig_w, nw) = {
    rect(orig_x, orig_y, orig_w, 16.0, nw)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x30363D)
    line(orig_x, orig_y + 16.0, orig_x + orig_w, orig_y + 16.0, 0x30363D)
    1.0
}

// Dibuja el contenedor de una barra de estado interna (20 px de alto)
ui_status_box(orig_x, orig_y, orig_w, nw) = {
    rect(orig_x, orig_y, orig_w, 20.0, nw)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x21262D)
    1.0
}

// -------------------------------------------------------------------------------
// 3. HIT-BOX UNIVERSAL Y BOTONES REUTILIZABLES (UI_BUTTON_BOX, UI_ICON_BOX)
// -------------------------------------------------------------------------------
// Evalúa si (mx, my) está dentro de [orig_x, orig_y, orig_w, orig_h].
// Usa registros hoja aislados para no sobrescribir jamás (hx, hy, w, h) de la ventana.
ui_hit_box(orig_x, orig_y, orig_w, orig_h, mx, my) = {
    nx = 1.0
    if (mx < orig_x) { nx = 0.0 } else { 1.0 }
    if (mx > (orig_x + orig_w)) { nx = 0.0 } else { 1.0 }
    if (my < orig_y) { nx = 0.0 } else { 1.0 }
    if (my > (orig_y + orig_h)) { nx = 0.0 } else { 1.0 }
    nx
}

// Dibuja la caja estilizada de un botón: nw=1.0 activo (color nh), nw=0.0 normal (0x161B22)
ui_button_box(orig_x, orig_y, orig_w, orig_h, nw, nh) = {
    if (nw == 1.0) {
        rect(orig_x, orig_y, orig_w, orig_h, nh)
        line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x58A6FF)
        line(orig_x, orig_y + orig_h, orig_x + orig_w, orig_y + orig_h, 0x58A6FF)
        line(orig_x, orig_y, orig_x, orig_y + orig_h, 0x58A6FF)
        line(orig_x + orig_w, orig_y, orig_x + orig_w, orig_y + orig_h, 0x58A6FF)
    } else {
        rect(orig_x, orig_y, orig_w, orig_h, 0x161B22)
        line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x30363D)
        line(orig_x, orig_y + orig_h, orig_x + orig_w, orig_y + orig_h, 0x30363D)
        line(orig_x, orig_y, orig_x, orig_y + orig_h, 0x30363D)
        line(orig_x + orig_w, orig_y, orig_x + orig_w, orig_y + orig_h, 0x30363D)
    }
    1.0
}

// Dibuja la caja de un botón de icono compacto cuadrado (orig_w x 20.0)
ui_icon_box(orig_x, orig_y, orig_w, nw) = {
    if (nw == 1.0) {
        rect(orig_x, orig_y, orig_w, 20.0, 0x1F6FEB)
        line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x58A6FF)
        line(orig_x, orig_y + 20.0, orig_x + orig_w, orig_y + 20.0, 0x58A6FF)
    } else {
        rect(orig_x, orig_y, orig_w, 20.0, 0x161B22)
        line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x30363D)
        line(orig_x, orig_y + 20.0, orig_x + orig_w, orig_y + 20.0, 0x30363D)
    }
    1.0
}

// -------------------------------------------------------------------------------
// 4. COMPONENTE DE FILA DE ÁRBOL JERÁRQUICO (UI_TREE_ROW & UI_TREE_HIT)
// -------------------------------------------------------------------------------
// Dibuja la fila completa de un nodo del Explorador (Carpeta o Archivo) con:
// - Fondo de selección (min_w == 1.0) y barra lateral neón
// - Guía de rama en L (├─) cuando nw (depth) > 0.0
// - Chevron (v / >) + Icono vectorial de carpeta (nh == 1.0) o archivo (nh == 0.0)
// - Indicador de edición en vivo (● dorado) y botón de 3 puntos [⋮] al frente
// Retorna: coordenada X exacta (nx) donde dibujar el texto del archivo/carpeta.
// Parámetros (100% aislados de hx, hy, w, h, tx, ty, clw):
//   orig_x, orig_y : Inicio de la fila
//   orig_w         : Ancho de la fila
//   nw             : Nivel de profundidad (0.0=carpeta raíz, 1.0=archivo hijo)
//   nh             : 1.0=Carpeta, 0.0=Archivo
//   orig_h         : 1.0=Carpeta abierta (o Archivo modificado ●), 0.0=cerrada/normal
//   min_w          : 1.0=Fila seleccionada actualmente, 0.0=no seleccionada
//   min_h          : Color semántico del icono
ui_tree_row(orig_x, orig_y, orig_w, nw, nh, orig_h, min_w, min_h) = {
    nx = orig_x + (nw * 16.0)

    // 1. Fondo de fila seleccionada + acento lateral neón
    if (min_w == 1.0) {
        rect(orig_x, orig_y - 3.0, orig_w, 18.0, 0x162234)
        rect(orig_x, orig_y - 3.0, 3.0, 18.0, 0x58A6FF)
    } else { 1.0 }

    // 2. Guía de jerarquía en L (├─) para archivos hijos
    if (nw > 0.0) {
        line(nx - 10.0, orig_y - 3.0, nx - 10.0, orig_y + 15.0, 0x21262D)
        line(nx - 10.0, orig_y + 6.0, nx - 3.0, orig_y + 6.0, 0x30363D)
    } else { 1.0 }

    // 3. Chevron + Icono vectorial procedural (Carpeta vs Archivo)
    if (nh == 1.0) {
        if (orig_h == 1.0) {
            text("v", nx, orig_y, 8, 0xF2CC60)
            rect(nx + 10.0, orig_y, 4.0, 2.0, 0xF2CC60)
            rect(nx + 10.0, orig_y + 2.0, 10.0, 8.0, 0xF2CC60)
        } else {
            text(">", nx, orig_y, 8, 0x8B949E)
            rect(nx + 10.0, orig_y, 4.0, 2.0, 0x8B949E)
            rect(nx + 10.0, orig_y + 2.0, 10.0, 8.0, 0x484F58)
        }
        nx = nx + 24.0
    } else {
        rect(nx + 2.0, orig_y, 8.0, 10.0, 0x161B22)
        line(nx + 2.0, orig_y, nx + 10.0, orig_y, min_h)
        line(nx + 2.0, orig_y + 10.0, nx + 10.0, orig_y + 10.0, min_h)
        rect(nx + 4.0, orig_y + 3.0, 4.0, 4.0, min_h)
        nx = nx + 16.0
    }

    // 4. Indicador de archivo modificado (●) y botón de menú de 3 puntos [⋮] al frente
    ny = (orig_x + orig_w) - 22.0
    if (ny > (nx + 40.0)) {
        if (nh == 0.0) {
            if (orig_h == 1.0) {
                circle(ny - 6.0, orig_y + 5.0, 3.0, 0xF2CC60)
            } else { 1.0 }
        } else { 1.0 }

        if (min_w == 1.0) {
            rect(ny, orig_y - 2.0, 18.0, 14.0, 0x21262D)
            line(ny, orig_y - 2.0, ny + 18.0, orig_y - 2.0, 0x58A6FF)
            text("⋮", ny + 6.0, orig_y - 1.0, 9, 0x58A6FF)
        } else {
            rect(ny, orig_y - 2.0, 18.0, 14.0, 0x0D1117)
            line(ny, orig_y - 2.0, ny + 18.0, orig_y - 2.0, 0x21262D)
            text("⋮", ny + 6.0, orig_y - 1.0, 9, 0x8B949E)
        }
    } else { 1.0 }

    nx
}

// Hit-testing aislado de una fila de ui_tree_row (alto estándar 18.0 px):
// Retorna: 0.0 = fuera, 1.0 = clic en fila (abrir/expandir), 2.0 = clic en botón [⋮]
ui_tree_hit(orig_x, orig_y, orig_w, mx, my) = {
    nx = 1.0
    if (mx < orig_x) { nx = 0.0 } else { 1.0 }
    if (mx > (orig_x + orig_w)) { nx = 0.0 } else { 1.0 }
    if (my < (orig_y - 3.0)) { nx = 0.0 } else { 1.0 }
    if (my >= (orig_y + 15.0)) { nx = 0.0 } else { 1.0 }
    if (nx == 1.0) {
        if (mx >= ((orig_x + orig_w) - 24.0)) { nx = 2.0 } else { 1.0 }
    } else { 1.0 }
    nx
}

// -------------------------------------------------------------------------------
// 5. MENÚ CONTEXTUAL FLOTANTE DE 3 PUNTOS (UI_CONTEXT_BOX)
// -------------------------------------------------------------------------------
// Dibuja el contenedor flotante del menú contextual con sombra, cabecera y 5 filas
// sin tocar jamás (hx, hy, w, h, tx, ty) de la ventana anfitriona.
ui_context_box(orig_x, orig_y, orig_w, orig_h) = {
    rect(orig_x + 3.0, orig_y + 3.0, orig_w, orig_h, 0x090D13)
    rect(orig_x, orig_y, orig_w, orig_h, 0x161B22)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x58A6FF)
    line(orig_x, orig_y + orig_h, orig_x + orig_w, orig_y + orig_h, 0x30363D)
    line(orig_x, orig_y, orig_x, orig_y + orig_h, 0x30363D)
    line(orig_x + orig_w, orig_y, orig_x + orig_w, orig_y + orig_h, 0x30363D)
    rect(orig_x + 1.0, orig_y + 1.0, orig_w - 2.0, 18.0, 0x0D1117)
    line(orig_x, orig_y + 19.0, orig_x + orig_w, orig_y + 19.0, 0x21262D)
    1.0
}
