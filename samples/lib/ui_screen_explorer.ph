// ===============================================================================
// LIB/UI_SCREEN_EXPLORER.PH — PANEL DE EXPLORADOR DE ARCHIVOS DE PRODUCCIÓN
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// https://github.com/koradevsorg
//
// Diseño Profesional de Explorador de Archivos dentro de Screen 2:
// - Contenedor interior estructurado (ui_card) dentro del Scissor Clipping de Screen 2
// - Aislamiento absoluto de registros: 0 colisiones con (hx, hy, w, h, tx, ty, clw)
// - Cadenas literales directas en text("...", ...) para renderizado nítido (0 NaN / 0 IDs)
// - Visualización por carpetas expandibles/contraíbles (samples, lib, docs, modules)
// - Menú de 3 puntos [⋮] al frente de cada carpeta y archivo + CRUD completo
// ===============================================================================

import "lib/ui_components.ph"

// -------------------------------------------------------------------------------
// 1. SEÑALES DE ESTADO DEL EXPLORADOR (MEMORIA PLANA SOA ZERO-GC)
// -------------------------------------------------------------------------------
signal exp_sel = 12.0          // Nodo activo (1..4=Carpetas, 11..41=Archivos)
signal exp_d1 = 1.0            // Carpeta samples/  (1.0=expandida, 0.0=contraída)
signal exp_d2 = 1.0            // Carpeta lib/      (1.0=expandida, 0.0=contraída)
signal exp_d3 = 1.0            // Carpeta docs/dist (1.0=expandida, 0.0=contraída)
signal exp_d4 = 1.0            // Carpeta modules/  (1.0=expandida, 0.0=contraída)
signal exp_has_new = 0.0       // Contador de archivos creados (0.0, 1.0=nuevo_modulo.ph, 2.0=+custom_panel.ph)
signal exp_menu_open = 0.0     // 1.0 si el menú de 3 puntos [⋮] está abierto
signal exp_menu_x = 0.0        // Posición X relativa del menú [⋮]
signal exp_menu_y = 0.0        // Posición Y relativa del menú [⋮]
signal exp_ed_file = 0.0       // Archivo activo en Screen 1 (0=chronos_ide, 1=main, 2=ui_components, 3=explorer, 4=nuevo)
signal exp_imp_copied = 0.0    // 1.0 si se copió la directiva import
signal exp_edit_mod = 0.0      // 1.0 si el archivo abierto fue editado en vivo (●)

// Calcula dinámicamente la altura lógica del contenedor interior según carpetas abiertas
explorer_content_h() = {
    res = 280.0
    if (exp_d1 == 1.0) { res = res + 60.0 } else { 1.0 }
    if (exp_d1 == 1.0) {
        if (exp_has_new >= 1.0) { res = res + 18.0 } else { 1.0 }
        if (exp_has_new >= 2.0) { res = res + 18.0 } else { 1.0 }
    } else { 1.0 }
    if (exp_d2 == 1.0) { res = res + 114.0 } else { 1.0 }
    if (exp_d3 == 1.0) { res = res + 58.0 } else { 1.0 }
    if (exp_d4 == 1.0) { res = res + 22.0 } else { 1.0 }
    res
}

// Sincroniza el nodo seleccionado con el archivo mostrado en Screen 1 (Editor)
exp_open_selected_in_editor() = {
    if (exp_sel == 11.0) { exp_ed_file = 1.0 } else { 1.0 }
    if (exp_sel == 12.0) { exp_ed_file = 0.0 } else { 1.0 }
    if (exp_sel == 13.0) { exp_ed_file = 1.0 } else { 1.0 }
    if (exp_sel == 14.0) { exp_ed_file = 4.0 } else { 1.0 }
    if (exp_sel == 15.0) { exp_ed_file = 4.0 } else { 1.0 }
    if (exp_sel == 21.0) { exp_ed_file = 2.0 } else { 1.0 }
    if (exp_sel == 26.0) { exp_ed_file = 3.0 } else { 1.0 }
    if (exp_sel == 41.0) { exp_ed_file = 4.0 } else { 1.0 }
    1.0
}

// Alterna expandir/contraer una carpeta según su ID (1..4)
exp_toggle_folder(id) = {
    if (id == 1.0) { exp_d1 = 1.0 - exp_d1 } else { 1.0 }
    if (id == 2.0) { exp_d2 = 1.0 - exp_d2 } else { 1.0 }
    if (id == 3.0) { exp_d3 = 1.0 - exp_d3 } else { 1.0 }
    if (id == 4.0) { exp_d4 = 1.0 - exp_d4 } else { 1.0 }
    1.0
}

// -------------------------------------------------------------------------------
// 2. BARRA DE HERRAMIENTAS INTERNA DEL EXPLORADOR (ALTO 26 PX)
// -------------------------------------------------------------------------------
render_explorer_toolbar(hx, hy, w) = {
    rect(hx + 1.0, hy + 28.0, w - 2.0, 26.0, 0x161B22)
    line(hx + 1.0, hy + 54.0, hx + w - 1.0, hy + 54.0, 0x30363D)

    clip(hx + 1.0, hy + 28.0, w - 2.0, 26.0)

    // Botón 1: +Proy (Plantilla Nuevo Proyecto main.ph)
    val = 0.0
    if (exp_ed_file == 1.0) { val = 1.0 } else { 1.0 }
    ui_button_box(hx + 6.0, hy + 31.0, 48.0, 20.0, val, 0x1F6FEB)
    text("+Proy", hx + 12.0, hy + 36.0, 8, 0x58A6FF)

    // Botón 2: +Arch (Crear nuevo archivo .ph)
    val = 0.0
    if (exp_has_new > 0.0) { val = 1.0 } else { 1.0 }
    ui_button_box(hx + 58.0, hy + 31.0, 48.0, 20.0, val, 0x238636)
    text("+Arch", hx + 64.0, hy + 36.0, 8, 0x3FB950)

    // Botón 3: +Carp (Expandir/Activar carpeta modules/)
    ui_button_box(hx + 110.0, hy + 31.0, 48.0, 20.0, exp_d4, 0x1F6FEB)
    text("+Carp", hx + 116.0, hy + 36.0, 8, 0xF2CC60)

    // Botón 4: Editar (Modo edición en vivo ●)
    ui_button_box(hx + 162.0, hy + 31.0, 48.0, 20.0, exp_edit_mod, 0x1F6FEB)
    text("Editar", hx + 168.0, hy + 36.0, 8, 0x79C0FF)

    // Botón 5: v/> (Expandir / Contraer todas las carpetas)
    val = 0.0
    if (exp_d1 == 1.0) { val = exp_d2 } else { 1.0 }
    ui_icon_box(hx + 214.0, hy + 31.0, 28.0, val)
    text("v/>", hx + 218.0, hy + 36.0, 8, 0xFFFFFF)

    unclip()
    1.0
}

// -------------------------------------------------------------------------------
// 3. INTERACCIÓN PLANA DEL EXPLORADOR (100% AISLADA DE HX, HY, W, H)
// -------------------------------------------------------------------------------
// Evalúa clic sobre una carpeta usando registros hoja (orig_x, orig_y, orig_w)
exp_test_folder_node(orig_x, orig_y, orig_w, mx, my, id) = {
    if (handled == 0.0) {
        hit = ui_tree_hit(orig_x, orig_y, orig_w, mx, my)
        if (hit > 0.0) {
            exp_sel = id
            if (hit == 2.0) {
                exp_menu_open = 1.0
                exp_menu_x = 20.0
                exp_menu_y = my - hy
            } else {
                exp_toggle_folder(id)
            }
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

// Evalúa clic sobre un archivo usando registros hoja (orig_x, orig_y, orig_w)
exp_test_file_node(orig_x, orig_y, orig_w, mx, my, id, delta) = {
    if (handled == 0.0) {
        hit = ui_tree_hit(orig_x, orig_y, orig_w, mx, my)
        if (hit > 0.0) {
            exp_sel = id
            if (delta >= 0.0) { exp_ed_file = delta } else { 1.0 }
            exp_imp_copied = 0.0
            if (hit == 2.0) {
                exp_menu_open = 1.0
                exp_menu_x = 20.0
                exp_menu_y = my - hy
            } else { 1.0 }
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

// Procesa clic en las 5 opciones del menú de 3 puntos [⋮]
handle_explorer_menu_click(mx, my) = {
    tl = hy + exp_menu_y
    if (tl > ((hy + h) - 130.0)) { tl = (hy + h) - 130.0 } else { 1.0 }
    if (tl < (hy + 56.0)) { tl = hy + 56.0 } else { 1.0 }

    hit = ui_hit_box(hx + 20.0, tl, 172.0, 114.0, mx, my)
    if (hit == 1.0) {
        val = my - (tl + 22.0)
        // Opción 0 (0..18): Abrir en Editor / Expandir-Contraer carpeta
        if (val >= 0.0) {
            if (val < 18.0) {
                if (exp_sel < 10.0) {
                    exp_toggle_folder(exp_sel)
                } else {
                    exp_open_selected_in_editor()
                }
            } else { 1.0 }
        } else { 1.0 }

        // Opción 1 (18..36): Editar archivo activo en vivo (●)
        if (val >= 18.0) {
            if (val < 36.0) {
                exp_open_selected_in_editor()
                exp_edit_mod = 1.0 - exp_edit_mod
            } else { 1.0 }
        } else { 1.0 }

        // Opción 2 (36..54): Crear / Duplicar + Archivo (.ph)
        if (val >= 36.0) {
            if (val < 54.0) {
                if (exp_has_new < 1.0) {
                    exp_has_new = 1.0; exp_sel = 14.0
                } else {
                    exp_has_new = 2.0; exp_sel = 15.0
                }
                exp_d1 = 1.0
                exp_ed_file = 4.0
            } else { 1.0 }
        } else { 1.0 }

        // Opción 3 (54..72): Copiar import / Abrir carpeta modules/
        if (val >= 54.0) {
            if (val < 72.0) {
                if (exp_sel < 10.0) {
                    exp_d4 = 1.0; exp_sel = 4.0
                } else {
                    exp_imp_copied = 1.0
                }
            } else { 1.0 }
        } else { 1.0 }

        // Opción 4 (72..90): Eliminar nodo creado / Restaurar edición
        if (val >= 72.0) {
            if (val < 90.0) {
                if (exp_sel == 15.0) { exp_has_new = 1.0; exp_sel = 14.0 } else { 1.0 }
                if (exp_sel == 14.0) { exp_has_new = 0.0; exp_sel = 12.0; exp_ed_file = 0.0 } else { 1.0 }
                exp_edit_mod = 0.0
                exp_imp_copied = 0.0
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    exp_menu_open = 0.0
    1.0
}

// Procesa clic en la barra de herramientas superior del Explorador
handle_explorer_toolbar_click(mx, my) = {
    hit = ui_hit_box(hx + 6.0, hy + 31.0, 48.0, 20.0, mx, my)
    if (hit == 1.0) {
        exp_ed_file = 1.0; exp_sel = 11.0; exp_d1 = 1.0
    } else { 1.0 }

    hit = ui_hit_box(hx + 58.0, hy + 31.0, 48.0, 20.0, mx, my)
    if (hit == 1.0) {
        if (exp_has_new < 1.0) {
            exp_has_new = 1.0; exp_sel = 14.0
        } else {
            exp_has_new = 2.0; exp_sel = 15.0
        }
        exp_d1 = 1.0
        exp_ed_file = 4.0
    } else { 1.0 }

    hit = ui_hit_box(hx + 110.0, hy + 31.0, 48.0, 20.0, mx, my)
    if (hit == 1.0) {
        exp_d4 = 1.0 - exp_d4
        exp_sel = 4.0
    } else { 1.0 }

    hit = ui_hit_box(hx + 162.0, hy + 31.0, 48.0, 20.0, mx, my)
    if (hit == 1.0) {
        exp_edit_mod = 1.0 - exp_edit_mod
    } else { 1.0 }

    hit = ui_hit_box(hx + 214.0, hy + 31.0, 28.0, 20.0, mx, my)
    if (hit == 1.0) {
        if (exp_d1 == 1.0) {
            exp_d1 = 0.0; exp_d2 = 0.0; exp_d3 = 0.0; exp_d4 = 0.0
        } else {
            exp_d1 = 1.0; exp_d2 = 1.0; exp_d3 = 1.0; exp_d4 = 1.0
        }
    } else { 1.0 }
    1.0
}

// Procesa clic dentro del contenedor de árbol y tarjeta inspectora
handle_explorer_tree_click(dx, dy, mx, my) = {
    tx = hx + 12.0 - dx
    ty = hy + 90.0 - dy
    clw = w - 30.0
    if (clw < 220.0) { clw = 220.0 } else { 1.0 }

    // --- RAMA 1: Carpeta samples/ ---
    exp_test_folder_node(tx, ty, clw, mx, my, 1.0)
    ty = ty + 20.0

    if (exp_d1 == 1.0) {
        exp_test_file_node(tx, ty, clw, mx, my, 11.0, 1.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 12.0, 0.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 13.0, 1.0)
        ty = ty + 18.0
    } else { 1.0 }

    if (exp_d1 == 1.0) {
        if (exp_has_new >= 1.0) {
            exp_test_file_node(tx, ty, clw, mx, my, 14.0, 4.0)
            ty = ty + 18.0
        } else { 1.0 }
        if (exp_has_new >= 2.0) {
            exp_test_file_node(tx, ty, clw, mx, my, 15.0, 4.0)
            ty = ty + 18.0
        } else { 1.0 }
    } else { 1.0 }

    // --- RAMA 2: Carpeta lib/ ---
    exp_test_folder_node(tx, ty, clw, mx, my, 2.0)
    ty = ty + 20.0

    if (exp_d2 == 1.0) {
        exp_test_file_node(tx, ty, clw, mx, my, 21.0, 2.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 26.0, 3.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 22.0, 0.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 23.0, 0.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 24.0, 0.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 25.0, 0.0)
        ty = ty + 18.0
    } else { 1.0 }

    // --- RAMA 3: Carpeta docs/ & dist/ ---
    exp_test_folder_node(tx, ty, clw, mx, my, 3.0)
    ty = ty + 20.0

    if (exp_d3 == 1.0) {
        exp_test_file_node(tx, ty, clw, mx, my, 31.0, -1.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 32.0, -1.0)
        ty = ty + 18.0
        exp_test_file_node(tx, ty, clw, mx, my, 33.0, 1.0)
        ty = ty + 18.0
    } else { 1.0 }

    // --- RAMA 4: Carpeta modules/ ---
    exp_test_folder_node(tx, ty, clw, mx, my, 4.0)
    ty = ty + 20.0

    if (exp_d4 == 1.0) {
        exp_test_file_node(tx, ty, clw, mx, my, 41.0, 4.0)
        ty = ty + 18.0
    } else { 1.0 }

    // --- BOTONES DE LA TARJETA INSPECTOR (ABRIR / EDITAR / IMPORT) ---
    ty = ty + 6.0
    if (handled == 0.0) {
        hit = ui_hit_box(tx + 8.0, ty + 42.0, 56.0, 18.0, mx, my)
        if (hit == 1.0) {
            exp_open_selected_in_editor()
            handled = 1.0
        } else { 1.0 }

        hit = ui_hit_box(tx + 68.0, ty + 42.0, 60.0, 18.0, mx, my)
        if (hit == 1.0) {
            exp_open_selected_in_editor()
            exp_edit_mod = 1.0 - exp_edit_mod
            handled = 1.0
        } else { 1.0 }

        hit = ui_hit_box(tx + 132.0, ty + 42.0, 60.0, 18.0, mx, my)
        if (hit == 1.0) {
            exp_imp_copied = 1.0
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

handle_explorer_click(hx, hy, w, h, dx, dy, mx, my) = {
    handled = 0.0

    // A. Si el menú de 3 puntos [⋮] está abierto, procesar selección
    if (exp_menu_open == 1.0) {
        handle_explorer_menu_click(mx, my)
        handled = 1.0
    } else { 1.0 }

    // B. Clic en la barra de herramientas superior (hy + 28 .. hy + 54)
    hit = ui_hit_box(hx, hy + 28.0, w, 26.0, mx, my)
    if (handled == 0.0) {
        if (hit == 1.0) {
            handle_explorer_toolbar_click(mx, my)
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }

    // C. Clic en el contenedor del árbol de archivos y carpetas
    hit = ui_hit_box(hx, hy + 54.0, w - 12.0, h - 66.0, mx, my)
    if (handled == 0.0) {
        if (hit == 1.0) {
            handle_explorer_tree_click(dx, dy, mx, my)
        } else { 1.0 }
    } else { 1.0 }

    handled
}

// -------------------------------------------------------------------------------
// 4. RENDERIZADO DEL CONTENEDOR INTERIOR DEL EXPLORADOR (SCREEN 2)
// -------------------------------------------------------------------------------
render_screen_explorer_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = 54.0
        cw = 360.0
        ch = explorer_content_h()

        // 1. Fondo del área cliente de Screen 2
        rect(hx + 1.0, hy + 54.0, w - 2.0, h - 55.0, 0x090D13)

        // 2. Recorte de Hardware PVM (Scissor Clipping Suave del Contenedor)
        sb_begin_clip(hx, hy, w, h, top, cw, ch)

        ct = hy + 54.0
        cb = (hy + h) - 12.0
        tx = hx + 12.0 - dx
        ty = hy + 66.0 - dy
        clw = w - 30.0
        if (clw < 220.0) { clw = 220.0 } else { 1.0 }

        // Contenedor Padre Interior del Explorador (Card Marco Principal)
        ui_card(hx + 6.0 - dx, hy + 58.0 - dy, clw + 12.0, ch - 12.0, 0x0D1117, 0x21262D)

        // Cabecera del Proyecto Raíz
        hit = vp_line_visible(ty, ct, cb)
        if (hit == 1.0) {
            ui_badge_box(tx, ty - 2.0, 56.0, 0x1F6FEB)
            text("PROYECTO", tx + 5.0, ty + 1.0, 8, 0xFFFFFF)
            text("SketchWarePro [Phasor]", tx + 64.0, ty + 1.0, 9, 0x58A6FF)
            ui_divider(tx, ty + 18.0, clw, 0x21262D)
        } else { 1.0 }
        ty = ty + 24.0

        // --- RAMA 1: Carpeta samples/ ---
        hit = vp_line_visible(ty, ct, cb)
        if (hit == 1.0) {
            val = 0.0; if (exp_sel == 1.0) { val = 1.0 } else { 1.0 }
            nx = ui_tree_row(tx, ty, clw, 0.0, 1.0, exp_d1, val, 0xF2CC60)
            text("samples/ (Aplicativos)", nx, ty, 9, 0xF2CC60)
        } else { 1.0 }
        ty = ty + 20.0

        if (exp_d1 == 1.0) {
            // 11: main.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 11.0) { val = 1.0 } else { 1.0 }
                delta = 0.0; if (exp_ed_file == 1.0) { delta = exp_edit_mod } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, delta, val, 0x58A6FF)
                text("main.ph (Plantilla Base)", nx, ty, 9, 0x58A6FF)
            } else { 1.0 }
            ty = ty + 18.0

            // 12: chronos_ide.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 12.0) { val = 1.0 } else { 1.0 }
                delta = 0.0; if (exp_ed_file == 0.0) { delta = exp_edit_mod } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, delta, val, 0x3FB950)
                text("chronos_ide.ph (Activo)", nx, ty, 9, 0x3FB950)
            } else { 1.0 }
            ty = ty + 18.0

            // 13: fractal_ui.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 13.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x58A6FF)
                text("fractal_ui.ph", nx, ty, 9, 0xC9D1D9)
            } else { 1.0 }
            ty = ty + 18.0
        } else { 1.0 }

        if (exp_d1 == 1.0) {
            if (exp_has_new >= 1.0) {
                hit = vp_line_visible(ty, ct, cb)
                if (hit == 1.0) {
                    val = 0.0; if (exp_sel == 14.0) { val = 1.0 } else { 1.0 }
                    nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 1.0, val, 0x3FB950)
                    text("nuevo_modulo.ph (Nuevo)", nx, ty, 9, 0x3FB950)
                } else { 1.0 }
                ty = ty + 18.0
            } else { 1.0 }

            if (exp_has_new >= 2.0) {
                hit = vp_line_visible(ty, ct, cb)
                if (hit == 1.0) {
                    val = 0.0; if (exp_sel == 15.0) { val = 1.0 } else { 1.0 }
                    nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 1.0, val, 0x3FB950)
                    text("custom_panel.ph (Clon)", nx, ty, 9, 0x3FB950)
                } else { 1.0 }
                ty = ty + 18.0
            } else { 1.0 }
        } else { 1.0 }

        // --- RAMA 2: Carpeta lib/ ---
        hit = vp_line_visible(ty, ct, cb)
        if (hit == 1.0) {
            val = 0.0; if (exp_sel == 2.0) { val = 1.0 } else { 1.0 }
            nx = ui_tree_row(tx, ty, clw, 0.0, 1.0, exp_d2, val, 0xF2CC60)
            text("lib/ (Componentes UI)", nx, ty, 9, 0xF2CC60)
        } else { 1.0 }
        ty = ty + 20.0

        if (exp_d2 == 1.0) {
            // 21: ui_components.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 21.0) { val = 1.0 } else { 1.0 }
                delta = 0.0; if (exp_ed_file == 2.0) { delta = exp_edit_mod } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, delta, val, 0x3FB950)
                text("ui_components.ph", nx, ty, 9, 0x3FB950)
            } else { 1.0 }
            ty = ty + 18.0

            // 26: ui_screen_explorer.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 26.0) { val = 1.0 } else { 1.0 }
                delta = 0.0; if (exp_ed_file == 3.0) { delta = exp_edit_mod } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, delta, val, 0x3FB950)
                text("ui_screen_explorer.ph", nx, ty, 9, 0x3FB950)
            } else { 1.0 }
            ty = ty + 18.0

            // 22: ui_spatial_main.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 22.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x58A6FF)
                text("ui_spatial_main.ph", nx, ty, 9, 0xC9D1D9)
            } else { 1.0 }
            ty = ty + 18.0

            // 23: ui_window_frame.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 23.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x58A6FF)
                text("ui_window_frame.ph", nx, ty, 9, 0xC9D1D9)
            } else { 1.0 }
            ty = ty + 18.0

            // 24: ui_viewport.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 24.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x58A6FF)
                text("ui_viewport.ph", nx, ty, 9, 0xC9D1D9)
            } else { 1.0 }
            ty = ty + 18.0

            // 25: ui_scrollbar.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 25.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x58A6FF)
                text("ui_scrollbar.ph", nx, ty, 9, 0xC9D1D9)
            } else { 1.0 }
            ty = ty + 18.0
        } else { 1.0 }

        // --- RAMA 3: Carpeta docs/ & dist/ ---
        hit = vp_line_visible(ty, ct, cb)
        if (hit == 1.0) {
            val = 0.0; if (exp_sel == 3.0) { val = 1.0 } else { 1.0 }
            nx = ui_tree_row(tx, ty, clw, 0.0, 1.0, exp_d3, val, 0xF2CC60)
            text("docs/ & dist/ (Salidas)", nx, ty, 9, 0xF2CC60)
        } else { 1.0 }
        ty = ty + 20.0

        if (exp_d3 == 1.0) {
            // 31: syntax_dictionary.md
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 31.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0xFA7970)
                text("syntax_dictionary.md", nx, ty, 9, 0xFA7970)
            } else { 1.0 }
            ty = ty + 18.0

            // 32: chronos_ide.html
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 32.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x79C0FF)
                text("chronos_ide.html", nx, ty, 9, 0x79C0FF)
            } else { 1.0 }
            ty = ty + 18.0

            // 33: template_new_project.html
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 33.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, 0.0, val, 0x79C0FF)
                text("template_new_project.html", nx, ty, 9, 0x79C0FF)
            } else { 1.0 }
            ty = ty + 18.0
        } else { 1.0 }

        // --- RAMA 4: Carpeta modules/ ---
        hit = vp_line_visible(ty, ct, cb)
        if (hit == 1.0) {
            val = 0.0; if (exp_sel == 4.0) { val = 1.0 } else { 1.0 }
            nx = ui_tree_row(tx, ty, clw, 0.0, 1.0, exp_d4, val, 0xF2CC60)
            text("modules/ (Submodulos)", nx, ty, 9, 0xF2CC60)
        } else { 1.0 }
        ty = ty + 20.0

        if (exp_d4 == 1.0) {
            // 41: sub_panel_ai.ph
            hit = vp_line_visible(ty, ct, cb)
            if (hit == 1.0) {
                val = 0.0; if (exp_sel == 41.0) { val = 1.0 } else { 1.0 }
                nx = ui_tree_row(tx, ty, clw, 1.0, 0.0, exp_edit_mod, val, 0x3FB950)
                text("sub_panel_ai.ph", nx, ty, 9, 0x3FB950)
            } else { 1.0 }
            ty = ty + 18.0
        } else { 1.0 }

        // --- TARJETA INSPECTOR Y ACCIONES RÁPIDAS DENTRO DEL CONTENEDOR ---
        ty = ty + 6.0
        ui_card(tx, ty, clw, 66.0, 0x161B22, 0x30363D)
        text("ARCHIVO SELECCIONADO & ACCIONES:", tx + 8.0, ty + 6.0, 8, 0x8B949E)

        if (exp_sel == 11.0) {
            text("samples/template_new_project/main.ph", tx + 8.0, ty + 22.0, 8, 0x58A6FF)
        } else { 1.0 }
        if (exp_sel == 21.0) {
            text("import \"lib/ui_components.ph\"", tx + 8.0, ty + 22.0, 8, 0x3FB950)
        } else { 1.0 }
        if (exp_sel == 26.0) {
            text("import \"lib/ui_screen_explorer.ph\"", tx + 8.0, ty + 22.0, 8, 0x3FB950)
        } else { 1.0 }
        if (exp_sel != 11.0) {
            if (exp_sel != 21.0) {
                if (exp_sel != 26.0) {
                    text("chronos_ide.ph -> Screen 1 Editor", tx + 8.0, ty + 22.0, 8, 0x79C0FF)
                } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }

        if (exp_edit_mod == 1.0) {
            ui_badge_box(tx + clw - 50.0, ty + 4.0, 44.0, 0x1F6FEB)
            text("MOD ●", tx + clw - 45.0, ty + 7.0, 8, 0xF2CC60)
        } else {
            if (exp_imp_copied == 1.0) {
                ui_badge_box(tx + clw - 56.0, ty + 4.0, 50.0, 0x238636)
                text("COPIADO", tx + clw - 51.0, ty + 7.0, 8, 0xFFFFFF)
            } else { 1.0 }
        }

        // 3 Botones de acción directa con etiquetas literales nítidas
        ui_button_box(tx + 8.0, ty + 42.0, 56.0, 18.0, 0.0, 0x1F6FEB)
        text("Abrir", tx + 18.0, ty + 46.0, 8, 0x58A6FF)

        ui_button_box(tx + 68.0, ty + 42.0, 60.0, 18.0, exp_edit_mod, 0x1F6FEB)
        text("Editar", tx + 78.0, ty + 46.0, 8, 0xF2CC60)

        ui_button_box(tx + 132.0, ty + 42.0, 60.0, 18.0, exp_imp_copied, 0x238636)
        text("Import", tx + 142.0, ty + 46.0, 8, 0x3FB950)

        // --- MENÚ FLOTANTE DE 3 PUNTOS [⋮] CONFINADO DENTRO DE SCREEN 2 ---
        if (exp_menu_open == 1.0) {
            tl = hy + exp_menu_y
            if (tl > ((hy + h) - 130.0)) { tl = (hy + h) - 130.0 } else { 1.0 }
            if (tl < (hy + 56.0)) { tl = hy + 56.0 } else { 1.0 }

            ui_context_box(hx + 20.0, tl, 172.0, 114.0)
            if (exp_sel < 10.0) {
                text("MENU DE CARPETA (⋮)", hx + 28.0, tl + 4.0, 8, 0xF2CC60)
                text("▸ Expandir / Contraer", hx + 28.0, tl + 25.0, 8, 0xFFFFFF)
                text("✎ Modo Edicion Activo", hx + 28.0, tl + 43.0, 8, 0x58A6FF)
                text("+ Nuevo Archivo .ph Aqui", hx + 28.0, tl + 61.0, 8, 0x3FB950)
                text("📁 Abrir Subcarpeta modules", hx + 28.0, tl + 79.0, 8, 0x79C0FF)
                text("x Cerrar Menu (⋮)", hx + 28.0, tl + 97.0, 8, 0xFA7970)
            } else {
                text("MENU DE ARCHIVO (⋮)", hx + 28.0, tl + 4.0, 8, 0x58A6FF)
                text("⚡ Abrir en Editor (Screen 1)", hx + 28.0, tl + 25.0, 8, 0xFFFFFF)
                text("✎ Editar Codigo en Vivo (●)", hx + 28.0, tl + 43.0, 8, 0xF2CC60)
                text("+ Duplicar / Crear Archivo", hx + 28.0, tl + 61.0, 8, 0x3FB950)
                text("📥 Copiar import \"...\"", hx + 28.0, tl + 79.0, 8, 0x79C0FF)
                text("x Eliminar / Restaurar", hx + 28.0, tl + 97.0, 8, 0xFA7970)
            }
        } else { 1.0 }

        sb_end_clip()

        // 3. Barra de herramientas superior y scrollbars 2D Neón (con hx, hy, w, h intactos)
        render_explorer_toolbar(hx, hy, w)
        ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, 1.0)
        1.0
    }
}
