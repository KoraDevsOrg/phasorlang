// ===============================================================================
// LIB/UI_SCREEN_EXPLORER.PH — PANEL DE EXPLORADOR DE ARCHIVOS REACTIVO (GEN-2)
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// https://github.com/koradevsorg
//
// Arquitectura Moderna Immediate-Mode UI (IMGUI) 100% en PhasorLang:
// - Estética Retro-Cyberpunk KoraDevs + Funcionalidad Moderna Reactiva a 120 FPS
// - Paso Único Unificado (Render + Hover en Vivo + Clic Simple Robusto en 1 línea)
// - Menús Emergentes Reales con Enmascaramiento Modal (Popover "+ Nuevo ▾" y Menú "[⋮]")
// - Confinado estrictamente dentro del Scissor Clipping y Scroll 2D de Screen 2
// ===============================================================================

import "lib/ui_components.ph"

// -------------------------------------------------------------------------------
// 1. SEÑALES DE ESTADO DEL EXPLORADOR (MEMORIA PLANA SOA ZERO-GC)
// -------------------------------------------------------------------------------
signal exp_sel = 12.0            // Nodo seleccionado (1..4=Carpetas, 11..41=Archivos)
signal exp_d1 = 1.0              // Carpeta samples/  (1.0=expandida, 0.0=contraída)
signal exp_d2 = 1.0              // Carpeta lib/      (1.0=expandida, 0.0=contraída)
signal exp_d3 = 1.0              // Carpeta docs/dist (1.0=expandida, 0.0=contraída)
signal exp_d4 = 1.0              // Carpeta modules/  (1.0=expandida, 0.0=contraída)
signal exp_has_new = 0.0         // Archivos creados (0.0, 1.0=nuevo_modulo.ph, 2.0=+custom_panel.ph)
signal exp_menu_open = 0.0       // 1.0 si el menú contextual emergente [⋮] está abierto
signal exp_menu_y = 0.0          // Offset Y relativo de la fila donde emergió el menú [⋮]
signal exp_create_open = 0.0     // 1.0 si el menú emergente "+ Nuevo ▾" de la barra está abierto
signal exp_ed_file = 0.0         // Archivo activo en Screen 1 (0=chronos_ide, 1=main, 2=ui_comp, 3=explorer, 4=nuevo)
signal exp_imp_copied = 0.0      // 1.0 si se copió la directiva import al portapapeles lógico
signal exp_edit_mod = 0.0        // 1.0 si el archivo abierto tiene edición en vivo activa (●)
signal exp_click_pending = 0.0   // Latch de clic primario pendiente de consumir en el frame actual
signal exp_rclick_pending = 0.0  // Latch de clic secundario pendiente de consumir en el frame actual

// Calcula dinámicamente la altura lógica del contenedor interior según carpetas abiertas
explorer_content_h() = {
    res = 285.0
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

// Sincroniza el nodo seleccionado con el código mostrado en Screen 1 (Editor)
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

// Acción reutilizable para crear un nuevo archivo .ph en el árbol
exp_action_create_file() = {
    if (exp_has_new < 1.0) {
        exp_has_new = 1.0
        exp_sel = 14.0
    } else {
        exp_has_new = 2.0
        exp_sel = 15.0
    }
    exp_d1 = 1.0
    exp_ed_file = 4.0
    exp_imp_copied = 0.0
    1.0
}

// -------------------------------------------------------------------------------
// 2. COMPONENTE DECLARATIVO DE NODO (1 LÍNEA = RENDER + HOVER + CLIC + MENÚ [⋮])
// -------------------------------------------------------------------------------
exp_node(label_str, depth, is_dir, dir, id, val, nw, tmx, tmy) = {
    if (vp_line_visible(ty, ct, cb) == 1.0) {
        shape = 0.0
        if (exp_sel == id) { shape = 1.0 } else { 1.0 }
        hit = ui_tree_node(label_str, tx, ty, clw, depth, is_dir, dir, shape, nw, tmx, tmy)
        if (hit > 0.0) {
            if (exp_click_pending == 1.0) {
                exp_sel = id
                if (hit == 2.0) {
                    exp_menu_open = 1.0
                    exp_create_open = 0.0
                    exp_menu_y = ty - hy
                } else {
                    if (is_dir == 1.0) {
                        exp_toggle_folder(id)
                    } else {
                        if (val >= 0.0) { exp_ed_file = val } else { 1.0 }
                        exp_imp_copied = 0.0
                    }
                }
                exp_click_pending = 0.0
            } else { 1.0 }

            if (exp_rclick_pending == 1.0) {
                exp_sel = id
                if (val >= 0.0) { exp_ed_file = val } else { 1.0 }
                exp_menu_open = 1.0
                exp_create_open = 0.0
                exp_menu_y = ty - hy
                exp_rclick_pending = 0.0
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    if (is_dir == 1.0) { ty = ty + 20.0 } else { ty = ty + 18.0 }
    1.0
}

// -------------------------------------------------------------------------------
// 3. BARRA DE HERRAMIENTAS INTERNA REACTIVA (CON HOVER Y CLIC SIMPLE)
// -------------------------------------------------------------------------------
render_explorer_toolbar(hx, hy, w, bmx, bmy) = {
    rect(hx + 1.0, hy + 28.0, w - 2.0, 26.0, 0x161B22)
    line(hx + 1.0, hy + 54.0, hx + w - 1.0, hy + 54.0, 0x30363D)

    clip(hx + 1.0, hy + 28.0, w - 2.0, 26.0)

    // Botón 1: "+ Nuevo ▾" (Abre el Menú Emergente de Creación)
    hit = ui_button("+ Nuevo v", hx + 6.0, hy + 31.0, 58.0, 20.0, exp_create_open, 0x238636, bmx, bmy)
    if (hit == 1.0) {
        if (exp_click_pending == 1.0) {
            exp_create_open = 1.0 - exp_create_open
            exp_menu_open = 0.0
            exp_click_pending = 0.0
        } else { 1.0 }
    } else { 1.0 }

    // Botón 2: "+ Arch" (Creación instantánea de 1 clic)
    val = 0.0
    if (exp_has_new > 0.0) { val = 1.0 } else { 1.0 }
    hit = ui_button("+ Arch", hx + 68.0, hy + 31.0, 46.0, 20.0, val, 0x1F6FEB, bmx, bmy)
    if (hit == 1.0) {
        if (exp_click_pending == 1.0) {
            exp_action_create_file()
            exp_click_pending = 0.0
        } else { 1.0 }
    } else { 1.0 }

    // Botón 3: "Editar ●" (Alterna edición en vivo en Screen 1)
    hit = ui_button("Editar", hx + 118.0, hy + 31.0, 48.0, 20.0, exp_edit_mod, 0x1F6FEB, bmx, bmy)
    if (hit == 1.0) {
        if (exp_click_pending == 1.0) {
            exp_open_selected_in_editor()
            exp_edit_mod = 1.0 - exp_edit_mod
            exp_click_pending = 0.0
        } else { 1.0 }
    } else { 1.0 }

    // Botón 4: "Import" (Copia directiva import del módulo seleccionado)
    hit = ui_button("Import", hx + 170.0, hy + 31.0, 46.0, 20.0, exp_imp_copied, 0x238636, bmx, bmy)
    if (hit == 1.0) {
        if (exp_click_pending == 1.0) {
            exp_imp_copied = 1.0
            exp_click_pending = 0.0
        } else { 1.0 }
    } else { 1.0 }

    // Botón 5: "v/>" (Expandir / Contraer todas las ramas del árbol)
    val = 0.0
    if (exp_d1 == 1.0) { val = exp_d2 } else { 1.0 }
    hit = ui_button("v/>", hx + 220.0, hy + 31.0, 28.0, 20.0, val, 0x1F6FEB, bmx, bmy)
    if (hit == 1.0) {
        if (exp_click_pending == 1.0) {
            if (exp_d1 == 1.0) {
                exp_d1 = 0.0; exp_d2 = 0.0; exp_d3 = 0.0; exp_d4 = 0.0
            } else {
                exp_d1 = 1.0; exp_d2 = 1.0; exp_d3 = 1.0; exp_d4 = 1.0
            }
            exp_click_pending = 0.0
        } else { 1.0 }
    } else { 1.0 }

    unclip()
    1.0
}

// -------------------------------------------------------------------------------
// 4. DISPATCHERS DE ENTRADA DESDE CHRONOS_IDE.PH (PUENTE REACTIVO)
// -------------------------------------------------------------------------------
handle_explorer_click(hx, hy, w, h, dx, dy, mx, my) = {
    handled = 0.0
    if (my >= (hy + 28.0)) {
        if (my <= (hy + h)) {
            exp_click_pending = 1.0
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    handled
}

handle_explorer_tree_click(dx, dy, mx, my) = {
    exp_rclick_pending = 1.0
    1.0
}

// -------------------------------------------------------------------------------
// 5. RENDERIZADO E INTERACCIÓN UNIFICADA DEL EXPLORADOR (SCREEN 2)
// -------------------------------------------------------------------------------
render_screen_explorer_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = 54.0
        cw = 360.0
        ch = explorer_content_h()

        // Coordenadas en tiempo real del cursor desde registros PVM
        mx = R252
        my = R253

        // Enmascaramiento Modal: si un menú emergente está abierto, bloquea hover de fondo
        bmx = mx
        bmy = my
        if (exp_menu_open == 1.0) { bmx = -1000.0; bmy = -1000.0 } else { 1.0 }
        if (exp_create_open == 1.0) { bmx = -1000.0; bmy = -1000.0 } else { 1.0 }

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

        // Coordenadas de hover restringidas al área visible del árbol (respeta clipping)
        tmx = bmx
        if (bmy < ct) { tmx = -1000.0 } else { 1.0 }
        if (bmy > cb) { tmx = -1000.0 } else { 1.0 }
        if (bmx > (hx + w - 12.0)) { tmx = -1000.0 } else { 1.0 }

        // Contenedor Padre Interior del Explorador (Card Marco Principal)
        ui_card(hx + 6.0 - dx, hy + 58.0 - dy, clw + 12.0, ch - 12.0, 0x0D1117, 0x21262D)

        // Cabecera del Proyecto Raíz con ui_badge de 1 línea
        if (vp_line_visible(ty, ct, cb) == 1.0) {
            ui_badge("PROYECTO", tx, ty - 2.0, 56.0, 0x1F6FEB, 0xFFFFFF)
            text("SketchWarePro [Phasor]", tx + 64.0, ty + 1.0, 9, 0x58A6FF)
            ui_divider(tx, ty + 18.0, clw, 0x21262D)
        } else { 1.0 }
        ty = ty + 24.0

        // --- RAMA 1: Carpeta samples/ ---
        exp_node("samples/ (Aplicativos)", 0.0, 1.0, exp_d1, 1.0, -1.0, 0xF2CC60, tmx, bmy)
        if (exp_d1 == 1.0) {
            val = 0.0; if (exp_ed_file == 1.0) { val = exp_edit_mod } else { 1.0 }
            exp_node("main.ph (Plantilla Base)", 1.0, 0.0, val, 11.0, 1.0, 0x58A6FF, tmx, bmy)

            val = 0.0; if (exp_ed_file == 0.0) { val = exp_edit_mod } else { 1.0 }
            exp_node("chronos_ide.ph (Activo)", 1.0, 0.0, val, 12.0, 0.0, 0x3FB950, tmx, bmy)

            exp_node("fractal_ui.ph", 1.0, 0.0, 0.0, 13.0, 1.0, 0x58A6FF, tmx, bmy)

            if (exp_has_new >= 1.0) {
                exp_node("nuevo_modulo.ph (Nuevo)", 1.0, 0.0, 1.0, 14.0, 4.0, 0x3FB950, tmx, bmy)
            } else { 1.0 }

            if (exp_has_new >= 2.0) {
                exp_node("custom_panel.ph (Clon)", 1.0, 0.0, 1.0, 15.0, 4.0, 0x3FB950, tmx, bmy)
            } else { 1.0 }
        } else { 1.0 }

        // --- RAMA 2: Carpeta lib/ ---
        exp_node("lib/ (Componentes UI)", 0.0, 1.0, exp_d2, 2.0, -1.0, 0xF2CC60, tmx, bmy)
        if (exp_d2 == 1.0) {
            val = 0.0; if (exp_ed_file == 2.0) { val = exp_edit_mod } else { 1.0 }
            exp_node("ui_components.ph", 1.0, 0.0, val, 21.0, 2.0, 0x3FB950, tmx, bmy)

            val = 0.0; if (exp_ed_file == 3.0) { val = exp_edit_mod } else { 1.0 }
            exp_node("ui_screen_explorer.ph", 1.0, 0.0, val, 26.0, 3.0, 0x3FB950, tmx, bmy)

            exp_node("ui_spatial_main.ph", 1.0, 0.0, 0.0, 22.0, 0.0, 0x58A6FF, tmx, bmy)
            exp_node("ui_window_frame.ph", 1.0, 0.0, 0.0, 23.0, 0.0, 0x58A6FF, tmx, bmy)
            exp_node("ui_viewport.ph", 1.0, 0.0, 0.0, 24.0, 0.0, 0x58A6FF, tmx, bmy)
            exp_node("ui_scrollbar.ph", 1.0, 0.0, 0.0, 25.0, 0.0, 0x58A6FF, tmx, bmy)
        } else { 1.0 }

        // --- RAMA 3: Carpeta docs/ & dist/ ---
        exp_node("docs/ & dist/ (Salidas)", 0.0, 1.0, exp_d3, 3.0, -1.0, 0xF2CC60, tmx, bmy)
        if (exp_d3 == 1.0) {
            exp_node("syntax_dictionary.md", 1.0, 0.0, 0.0, 31.0, -1.0, 0xFA7970, tmx, bmy)
            exp_node("chronos_ide.html", 1.0, 0.0, 0.0, 32.0, -1.0, 0x79C0FF, tmx, bmy)
            exp_node("template_new_project.html", 1.0, 0.0, 0.0, 33.0, 1.0, 0x79C0FF, tmx, bmy)
        } else { 1.0 }

        // --- RAMA 4: Carpeta modules/ ---
        exp_node("modules/ (Submodulos)", 0.0, 1.0, exp_d4, 4.0, -1.0, 0xF2CC60, tmx, bmy)
        if (exp_d4 == 1.0) {
            exp_node("sub_panel_ai.ph", 1.0, 0.0, exp_edit_mod, 41.0, 4.0, 0x3FB950, tmx, bmy)
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
            ui_badge("MOD ●", tx + clw - 50.0, ty + 4.0, 44.0, 0x1F6FEB, 0xF2CC60)
        } else {
            if (exp_imp_copied == 1.0) {
                ui_badge("COPIADO", tx + clw - 56.0, ty + 4.0, 50.0, 0x238636, 0xFFFFFF)
            } else { 1.0 }
        }

        // 4 Botones Reactivos en el Inspector (con Hover en Vivo y Clic Simple)
        if (ui_button("Abrir", tx + 8.0, ty + 42.0, 48.0, 18.0, 0.0, 0x1F6FEB, tmx, bmy) == 1.0) {
            if (exp_click_pending == 1.0) {
                exp_open_selected_in_editor()
                exp_click_pending = 0.0
            } else { 1.0 }
        } else { 1.0 }

        if (ui_button("Editar", tx + 60.0, ty + 42.0, 52.0, 18.0, exp_edit_mod, 0x1F6FEB, tmx, bmy) == 1.0) {
            if (exp_click_pending == 1.0) {
                exp_open_selected_in_editor()
                exp_edit_mod = 1.0 - exp_edit_mod
                exp_click_pending = 0.0
            } else { 1.0 }
        } else { 1.0 }

        if (ui_button("Import", tx + 116.0, ty + 42.0, 52.0, 18.0, exp_imp_copied, 0x238636, tmx, bmy) == 1.0) {
            if (exp_click_pending == 1.0) {
                exp_imp_copied = 1.0
                exp_click_pending = 0.0
            } else { 1.0 }
        } else { 1.0 }

        if (ui_button("Menu ⋮", tx + 172.0, ty + 42.0, 52.0, 18.0, exp_menu_open, 0x1F6FEB, tmx, bmy) == 1.0) {
            if (exp_click_pending == 1.0) {
                exp_menu_open = 1.0 - exp_menu_open
                exp_create_open = 0.0
                exp_menu_y = (ty - hy) - 60.0
                exp_click_pending = 0.0
            } else { 1.0 }
        } else { 1.0 }

        sb_end_clip()

        // 3. Barra de herramientas superior y scrollbars 2D Neón
        render_explorer_toolbar(hx, hy, w, bmx, bmy)
        ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, 1.0)

        // 4. MENÚ EMERGENTE 1: POPOVER "+ NUEVO ▾" DESDE LA BARRA DE HERRAMIENTAS
        if (exp_create_open == 1.0) {
            clip(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0)
            tl = hy + 53.0
            ui_context_menu("CREAR EN PROYECTO (+)", hx + 6.0, tl, 184.0, 96.0)

            if (ui_menu_item("+ Nuevo Script .ph", hx + 6.0, tl + 22.0, 184.0, 0x3FB950, mx, my) == 1.0) {
                if (exp_click_pending == 1.0) {
                    exp_action_create_file()
                    exp_create_open = 0.0
                    exp_click_pending = 0.0
                } else { 1.0 }
            } else { 1.0 }

            if (ui_menu_item("▸ Submodulo en modules/", hx + 6.0, tl + 40.0, 184.0, 0xF2CC60, mx, my) == 1.0) {
                if (exp_click_pending == 1.0) {
                    exp_d4 = 1.0
                    exp_sel = 41.0
                    exp_ed_file = 4.0
                    exp_create_open = 0.0
                    exp_click_pending = 0.0
                } else { 1.0 }
            } else { 1.0 }

            if (ui_menu_item("⚡ Plantilla Base main.ph", hx + 6.0, tl + 58.0, 184.0, 0x58A6FF, mx, my) == 1.0) {
                if (exp_click_pending == 1.0) {
                    exp_d1 = 1.0
                    exp_sel = 11.0
                    exp_ed_file = 1.0
                    exp_create_open = 0.0
                    exp_click_pending = 0.0
                } else { 1.0 }
            } else { 1.0 }

            if (ui_menu_item("x Cerrar Menu Emergente", hx + 6.0, tl + 76.0, 184.0, 0xFA7970, mx, my) == 1.0) {
                if (exp_click_pending == 1.0) {
                    exp_create_open = 0.0
                    exp_click_pending = 0.0
                } else { 1.0 }
            } else { 1.0 }

            // Si hizo clic fuera del popover, cerrarlo limpiamente
            if (exp_click_pending == 1.0) {
                exp_create_open = 0.0
                exp_click_pending = 0.0
            } else { 1.0 }
            unclip()
        } else { 1.0 }

        // 5. MENÚ EMERGENTE 2: CONTEXTUAL DE FILA [⋮] ANCLADO AL NODO
        if (exp_menu_open == 1.0) {
            clip(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0)
            tl = hy + exp_menu_y
            if (tl > ((hy + h) - 130.0)) { tl = (hy + h) - 130.0 } else { 1.0 }
            if (tl < (hy + 56.0)) { tl = hy + 56.0 } else { 1.0 }

            // Anclado cerca del botón [⋮] a la derecha de la ventana
            gx = (hx + w) - 196.0
            if (gx < (hx + 10.0)) { gx = hx + 10.0 } else { 1.0 }

            if (exp_sel < 10.0) {
                ui_context_menu("ACCIONES DE CARPETA (⋮)", gx, tl, 180.0, 114.0)

                if (ui_menu_item("▸ Expandir / Contraer Rama", gx, tl + 22.0, 180.0, 0xFFFFFF, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_toggle_folder(exp_sel)
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("+ Nuevo Archivo .ph Aqui", gx, tl + 40.0, 180.0, 0x3FB950, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_action_create_file()
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("v Expandir Todo el Arbol", gx, tl + 58.0, 180.0, 0x58A6FF, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_d1 = 1.0; exp_d2 = 1.0; exp_d3 = 1.0; exp_d4 = 1.0
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("> Contraer Todo el Arbol", gx, tl + 76.0, 180.0, 0xF2CC60, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_d1 = 0.0; exp_d2 = 0.0; exp_d3 = 0.0; exp_d4 = 0.0
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("x Cerrar Menu (⋮)", gx, tl + 94.0, 180.0, 0xFA7970, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }
            } else {
                ui_context_menu("ACCIONES DE ARCHIVO (⋮)", gx, tl, 180.0, 114.0)

                if (ui_menu_item("⚡ Abrir en Editor (Screen 1)", gx, tl + 22.0, 180.0, 0xFFFFFF, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_open_selected_in_editor()
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("✎ Editar Codigo en Vivo (●)", gx, tl + 40.0, 180.0, 0xF2CC60, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_open_selected_in_editor()
                        exp_edit_mod = 1.0 - exp_edit_mod
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("+ Duplicar / Crear Script .ph", gx, tl + 58.0, 180.0, 0x3FB950, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_action_create_file()
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("📥 Copiar Directiva import", gx, tl + 76.0, 180.0, 0x79C0FF, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        exp_imp_copied = 1.0
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }

                if (ui_menu_item("x Eliminar / Restaurar Nodo", gx, tl + 94.0, 180.0, 0xFA7970, mx, my) == 1.0) {
                    if (exp_click_pending == 1.0) {
                        if (exp_sel == 15.0) { exp_has_new = 1.0; exp_sel = 14.0 } else { 1.0 }
                        if (exp_sel == 14.0) { exp_has_new = 0.0; exp_sel = 12.0; exp_ed_file = 0.0 } else { 1.0 }
                        exp_edit_mod = 0.0
                        exp_imp_copied = 0.0
                        exp_menu_open = 0.0
                        exp_click_pending = 0.0
                    } else { 1.0 }
                } else { 1.0 }
            }

            // Si hizo clic fuera del menú contextual, cerrarlo limpiamente
            if (exp_click_pending == 1.0) {
                exp_menu_open = 0.0
                exp_click_pending = 0.0
            } else { 1.0 }
            unclip()
        } else { 1.0 }

        // Limpieza determinista de latches al finalizar el frame
        exp_click_pending = 0.0
        exp_rclick_pending = 0.0
        1.0
    }
}
