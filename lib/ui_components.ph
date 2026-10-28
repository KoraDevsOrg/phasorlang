// ===============================================================================
// LIB/UI_COMPONENTS.PH — CATÁLOGO DE COMPONENTES REACTIVOS MODERNOS (IMGUI)
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// https://github.com/koradevsorg
//
// Arquitectura de Componentes de Segunda Generación (Zero-GC a 120 FPS):
// 1. Paso Nativo de Cadenas (TOK_STR -> regTypes=5 -> OP_UI_TEXT modo 2):
//    Los componentes reciben directamente textos ("...") en `label_str` y los
//    renderizan en una sola llamada limpia y legible.
// 2. Interacción Reactiva Unificada (Render + Live Hover + Single-Click Hit):
//    `ui_button`, `ui_tree_node` y `ui_menu_item` iluminan automáticamente el
//    elemento bajo el cursor (mx, my) en tiempo real y retornan 1.0 (o 2.0 en [⋮])
//    para ejecutar acciones con un solo clic simple sin duplicar código.
// 3. Aislamiento Total de Registros Hoja (orig_x, orig_y, orig_w, orig_h, nw, nh, nx, ny):
//    Jamás colisionan con (hx, hy, w, h, tx, ty, dx, dy, ct, cb, clw, clh).
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. CONTENEDORES ESTRUCTURALES (UI_CARD, UI_DIVIDER, UI_BADGE, UI_STATUS_BAR)
// -------------------------------------------------------------------------------
// Dibuja una tarjeta contenedora en (orig_x, orig_y) de tamaño (orig_w, orig_h)
// con fondo (nw) y borde perimetral de 1 px (nh).
ui_card(orig_x, orig_y, orig_w, orig_h, nw, nh) = {
    rect(orig_x, orig_y, orig_w, orig_h, nw)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, nh)
    line(orig_x, orig_y + orig_h, orig_x + orig_w, orig_y + orig_h, nh)
    line(orig_x, orig_y, orig_x, orig_y + orig_h, nh)
    line(orig_x + orig_w, orig_y, orig_x + orig_w, orig_y + orig_h, nh)
    1.0
}

// Dibuja una línea divisoria horizontal limpia de ancho (orig_w) y color (nw)
ui_divider(orig_x, orig_y, orig_w, nw) = {
    line(orig_x, orig_y, orig_x + orig_w, orig_y, nw)
    1.0
}

// Dibuja el contenedor de una insignia (16 px de alto)
ui_badge_box(orig_x, orig_y, orig_w, nw) = {
    rect(orig_x, orig_y, orig_w, 16.0, nw)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x30363D)
    line(orig_x, orig_y + 16.0, orig_x + orig_w, orig_y + 16.0, 0x30363D)
    1.0
}

// Dibuja una insignia completa con texto en 1 sola línea
ui_badge(label_str, orig_x, orig_y, orig_w, nw, nh) = {
    ui_badge_box(orig_x, orig_y, orig_w, nw)
    text(label_str, orig_x + 5.0, orig_y + 3.0, 8, nh)
    1.0
}

// Dibuja una barra de estado interna (20 px de alto) con texto
ui_status_bar(label_str, orig_x, orig_y, orig_w, nw, nh) = {
    rect(orig_x, orig_y, orig_w, 20.0, nw)
    line(orig_x, orig_y, orig_x + orig_w, orig_y, 0x21262D)
    text(label_str, orig_x + 8.0, orig_y + 5.0, 8, nh)
    1.0
}

// -------------------------------------------------------------------------------
// 2. HIT-TESTING Y BOTONES REACTIVOS CON HOVER EN VIVO (UI_BUTTON)
// -------------------------------------------------------------------------------
// Retorna 1.0 si el puntero (mx, my) está dentro del rectángulo [orig_x, orig_y, orig_w, orig_h]
ui_hit_box(orig_x, orig_y, orig_w, orig_h, mx, my) = {
    nx = 1.0
    if (mx < orig_x) { nx = 0.0 } else { 1.0 }
    if (mx > (orig_x + orig_w)) { nx = 0.0 } else { 1.0 }
    if (my < orig_y) { nx = 0.0 } else { 1.0 }
    if (my > (orig_y + orig_h)) { nx = 0.0 } else { 1.0 }
    nx
}

// Caja base de botón sin hover (compatibilidad)
ui_button_box(orig_x, orig_y, orig_w, orig_h, nw, nh) = {
    if (nw == 1.0) {
        ui_card(orig_x, orig_y, orig_w, orig_h, nh, 0x58A6FF)
    } else {
        ui_card(orig_x, orig_y, orig_w, orig_h, 0x161B22, 0x30363D)
    }
    1.0
}

// Caja base de botón de icono compacto (compatibilidad)
ui_icon_box(orig_x, orig_y, orig_w, nw) = {
    ui_button_box(orig_x, orig_y, orig_w, 20.0, nw, 0x1F6FEB)
    1.0
}

// Botón Reactivo Moderno en 1 sola línea:
// - Ilumina su fondo y borde automáticamente en Hover cuando (mx, my) pasa por encima
// - Muestra estado activo si nw == 1.0 (con color nh)
// - Dibuja `label_str` con color `min_w`
// - Retorna 1.0 si el puntero está encima (listo para `if (exp_click == 1.0)`), o 0.0 fuera.
ui_button(label_str, orig_x, orig_y, orig_w, orig_h, nw, nh, min_w, mx, my) = {
    ny = ui_hit_box(orig_x, orig_y, orig_w, orig_h, mx, my)
    if (nw == 1.0) {
        ui_card(orig_x, orig_y, orig_w, orig_h, nh, 0x79C0FF)
        text(label_str, orig_x + 6.0, orig_y + 5.0, 8, 0xFFFFFF)
    } else {
        if (ny == 1.0) {
            ui_card(orig_x, orig_y, orig_w, orig_h, 0x1F2937, 0x58A6FF)
            text(label_str, orig_x + 6.0, orig_y + 5.0, 8, 0xFFFFFF)
        } else {
            ui_card(orig_x, orig_y, orig_w, orig_h, 0x161B22, 0x30363D)
            text(label_str, orig_x + 6.0, orig_y + 5.0, 8, min_w)
        }
    }
    ny
}

// -------------------------------------------------------------------------------
// 3. ÁRBOL JERÁRQUICO REACTIVO CON HOVER Y MENÚ [⋮] INTEGRADO (UI_TREE_NODE)
// -------------------------------------------------------------------------------
// Icono vectorial procedural de Carpeta (nw==1.0) o Archivo (nw==0.0)
ui_file_icon(orig_x, orig_y, nw, nh, min_h) = {
    if (nw == 1.0) {
        if (nh == 1.0) {
            rect(orig_x, orig_y, 5.0, 2.0, 0xF2CC60)
            rect(orig_x, orig_y + 2.0, 11.0, 8.0, 0xF2CC60)
            rect(orig_x + 1.0, orig_y + 4.0, 9.0, 5.0, 0x9E6A03)
        } else {
            rect(orig_x, orig_y, 5.0, 2.0, 0xD29922)
            rect(orig_x, orig_y + 2.0, 11.0, 8.0, 0x9E6A03)
        }
    } else {
        rect(orig_x + 1.0, orig_y, 8.0, 10.0, 0x161B22)
        line(orig_x + 1.0, orig_y, orig_x + 9.0, orig_y, min_h)
        line(orig_x + 1.0, orig_y + 10.0, orig_x + 9.0, orig_y + 10.0, min_h)
        line(orig_x + 1.0, orig_y, orig_x + 1.0, orig_y + 10.0, min_h)
        line(orig_x + 9.0, orig_y, orig_x + 9.0, orig_y + 10.0, min_h)
        rect(orig_x + 3.0, orig_y + 3.0, 4.0, 4.0, min_h)
    }
    1.0
}

// Hit-testing aislado de una fila del árbol (alto 18 px):
// Retorna: 0.0 = fuera, 1.0 = sobre la fila (abrir/expandir), 2.0 = sobre el botón [⋮]
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

// Fila base de árbol (compatibilidad)
ui_tree_row(orig_x, orig_y, orig_w, nw, nh, orig_h, min_w, min_h) = {
    nx = orig_x + (nw * 16.0)
    if (min_w == 1.0) {
        rect(orig_x, orig_y - 3.0, orig_w, 18.0, 0x162234)
        rect(orig_x, orig_y - 3.0, 3.0, 18.0, 0x58A6FF)
    } else { 1.0 }
    if (nw > 0.0) {
        line(nx - 10.0, orig_y - 3.0, nx - 10.0, orig_y + 15.0, 0x21262D)
        line(nx - 10.0, orig_y + 6.0, nx - 3.0, orig_y + 6.0, 0x30363D)
    } else { 1.0 }
    if (nh == 1.0) {
        if (orig_h == 1.0) { text("v", nx, orig_y, 8, 0xF2CC60) } else { text(">", nx, orig_y, 8, 0x8B949E) }
        ui_file_icon(nx + 9.0, orig_y, 1.0, orig_h, min_h)
        nx = nx + 24.0
    } else {
        ui_file_icon(nx + 1.0, orig_y, 0.0, orig_h, min_h)
        nx = nx + 15.0
    }
    ny = (orig_x + orig_w) - 22.0
    if (ny > (nx + 40.0)) {
        if (nh == 0.0) {
            if (orig_h == 1.0) { circle(ny - 6.0, orig_y + 5.0, 3.0, 0xF2CC60) } else { 1.0 }
        } else { 1.0 }
        rect(ny, orig_y - 2.0, 18.0, 14.0, 0x161B22)
        text("⋮", ny + 6.0, orig_y - 1.0, 9, 0x8B949E)
    } else { 1.0 }
    nx
}

// Nodo de Árbol Reactivo Completo en 1 sola línea (`ui_tree_node`):
// - Dibuja Hover en vivo (0x131D2B) cuando el cursor pasa sobre la fila
// - Dibuja Selección activa (0x1A2B42 + barra neón 3px) cuando `min_w == 1.0`
// - Dibuja guía jerárquica `├─`, chevron `v`/`>`, icono vectorial y texto `label_str`
// - Dibuja botón `[⋮]` al frente que se ilumina en azul cian cuando `hit == 2.0`
// - Retorna: 0.0 (fuera), 1.0 (hover/hit en fila), 2.0 (hover/hit en botón [⋮])
ui_tree_node(label_str, orig_x, orig_y, orig_w, nw, nh, orig_h, min_w, min_h, mx, my) = {
    dir = ui_tree_hit(orig_x, orig_y, orig_w, mx, my)
    nx = orig_x + (nw * 16.0)

    // 1. Fondo de Selección o Hover Reactivo en Tiempo Real
    if (min_w == 1.0) {
        rect(orig_x, orig_y - 3.0, orig_w, 18.0, 0x1A2B42)
        rect(orig_x, orig_y - 3.0, 3.0, 18.0, 0x58A6FF)
    } else {
        if (dir > 0.0) {
            rect(orig_x, orig_y - 3.0, orig_w, 18.0, 0x131C2B)
            rect(orig_x, orig_y - 3.0, 2.0, 18.0, 0x30363D)
        } else { 1.0 }
    }

    // 2. Guía de rama en L (├─) para nodos hijos
    if (nw > 0.0) {
        line(nx - 10.0, orig_y - 3.0, nx - 10.0, orig_y + 15.0, 0x21262D)
        line(nx - 10.0, orig_y + 6.0, nx - 3.0, orig_y + 6.0, 0x30363D)
    } else { 1.0 }

    // 3. Chevron + Icono vectorial + Etiqueta de texto
    if (nh == 1.0) {
        if (orig_h == 1.0) {
            text("v", nx, orig_y, 8, 0xF2CC60)
        } else {
            text(">", nx, orig_y, 8, 0x8B949E)
        }
        ui_file_icon(nx + 9.0, orig_y, 1.0, orig_h, min_h)
        nx = nx + 24.0
    } else {
        ui_file_icon(nx + 1.0, orig_y, 0.0, orig_h, min_h)
        nx = nx + 15.0
    }

    if (dir > 0.0) {
        text(label_str, nx, orig_y, 9, 0xFFFFFF)
    } else {
        text(label_str, nx, orig_y, 9, min_h)
    }

    // 4. Indicador de edición en vivo (●) y Botón de Menú Emergente [⋮] con Hover propio
    ny = (orig_x + orig_w) - 22.0
    if (ny > (nx + 36.0)) {
        if (nh == 0.0) {
            if (orig_h == 1.0) {
                circle(ny - 6.0, orig_y + 5.0, 3.0, 0xF2CC60)
            } else { 1.0 }
        } else { 1.0 }

        if (dir == 2.0) {
            ui_card(ny, orig_y - 2.0, 18.0, 14.0, 0x1F6FEB, 0x79C0FF)
            text("⋮", ny + 6.0, orig_y - 1.0, 9, 0xFFFFFF)
        } else {
            if (dir == 1.0) {
                ui_card(ny, orig_y - 2.0, 18.0, 14.0, 0x161B22, 0x58A6FF)
                text("⋮", ny + 6.0, orig_y - 1.0, 9, 0x58A6FF)
            } else {
                if (min_w == 1.0) {
                    ui_card(ny, orig_y - 2.0, 18.0, 14.0, 0x161B22, 0x30363D)
                    text("⋮", ny + 6.0, orig_y - 1.0, 9, 0x58A6FF)
                } else {
                    rect(ny, orig_y - 2.0, 18.0, 14.0, 0x0D1117)
                    text("⋮", ny + 6.0, orig_y - 1.0, 9, 0x484F58)
                }
            }
        }
    } else { 1.0 }

    dir
}

// -------------------------------------------------------------------------------
// 4. MENÚS EMERGENTES / POPOVERS CON HOVER EN VIVO (UI_CONTEXT_MENU, UI_MENU_ITEM)
// -------------------------------------------------------------------------------
// Contenedor base de menú emergente con sombra proyectada y cabecera
ui_context_box(orig_x, orig_y, orig_w, orig_h) = {
    rect(orig_x + 4.0, orig_y + 4.0, orig_w, orig_h, 0x04070B)
    ui_card(orig_x, orig_y, orig_w, orig_h, 0x161B22, 0x58A6FF)
    rect(orig_x + 1.0, orig_y + 1.0, orig_w - 2.0, 19.0, 0x0D1117)
    line(orig_x, orig_y + 20.0, orig_x + orig_w, orig_y + 20.0, 0x30363D)
    1.0
}

// Contenedor de menú emergente con título incluido
ui_context_menu(label_str, orig_x, orig_y, orig_w, orig_h, nh) = {
    ui_context_box(orig_x, orig_y, orig_w, orig_h)
    text(label_str, orig_x + 8.0, orig_y + 5.0, 8, nh)
    1.0
}

// Opción interactiva dentro de un menú emergente (fila `nw` = 0, 1, 2, 3, 4):
// - Ilumina toda la fila en azul brillante (0x1F6FEB) cuando el mouse pasa por encima
// - Dibuja el texto `label_str` y retorna 1.0 si el cursor está sobre esta opción
ui_menu_item(label_str, orig_x, orig_y, orig_w, nw, nh, mx, my) = {
    ny = orig_y + 22.0 + (nw * 18.0)
    nx = ui_hit_box(orig_x + 2.0, ny, orig_w - 4.0, 17.0, mx, my)
    if (nx == 1.0) {
        rect(orig_x + 3.0, ny, orig_w - 6.0, 17.0, 0x1F6FEB)
        text(label_str, orig_x + 10.0, ny + 3.0, 8, 0xFFFFFF)
    } else {
        text(label_str, orig_x + 10.0, ny + 3.0, 8, nh)
    }
    nx
}
