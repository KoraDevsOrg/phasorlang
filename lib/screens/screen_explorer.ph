// Grado 3: Explorador Completo BOM + Open Editors + Feedback Interactivo + Señal Editor S1
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/tree_node.ph"
import "lib/ui/explorer_toolbar.ph"
import "lib/ui/popup_menu.ph"
import "lib/spatial/gesture_lock.ph"

signal exp_dir_core = 1.0
signal exp_dir_ui = 1.0
signal exp_dir_screens = 1.0
signal exp_selected_id = 1.0
signal exp_popup_open = 0.0
signal exp_popup_target = 0.0
signal exp_popup_x = 0.0
signal exp_popup_y = 0.0
signal exp_toolbar_msg = 0.0
signal exp_extra_file = 0.0

// Señal puente desacoplada hacia Screen 1 (Editor)
signal editor_active_file_id = 1.0

screen_explorer_full(x, y, w, h, mx, my, click) = {
    clip(x, y, w, h)
    prim_box(x, y, w, h, 0x0D1117)
    prim_box(x, y, w, 26.0, 0x14261C)
    prim_stroke(x, y, w, h, 0x30363D)
    ui_label("📁 Screen 2: Explorador (BOM)", x + 10.0, y + 17.0, 11.0, 0xFFFFFF)

    // Si el popup está abierto, bloquear clics en el fondo para que el popup capture primero
    bg_click = click
    if (exp_popup_open == 1.0) { bg_click = 0.0 } else { 1.0 }

    // 1. Menú Superior Estilo VS Code
    tb_y = y + 26.0
    tb_act = ui_explorer_toolbar(x, tb_y, w, mx, my, bg_click)
    if (tb_act > 0.0) {
        exp_toolbar_msg = tb_act
        if (tb_act == 3.0) { exp_extra_file = 1.0 } else { 1.0 }
    } else { 1.0 }

    cy = tb_y + 38.0

    // Banner de respuesta inmediata al tocar botones del menú superior o acciones de archivo
    if (exp_toolbar_msg > 0.0) {
        prim_box(x + 4.0, cy, w - 8.0, 22.0, 0x16283E)
        prim_stroke(x + 4.0, cy, w - 8.0, 22.0, 0x3FB950)
        if (exp_toolbar_msg == 1.0) { ui_label("📄 Selector de archivos listo", x + 12.0, cy + 15.0, 9.0, 0x79C0FF) } else { 1.0 }
        if (exp_toolbar_msg == 2.0) { ui_label("📂 Proyecto activo: SketchWarePro", x + 12.0, cy + 15.0, 9.0, 0x79C0FF) } else { 1.0 }
        if (exp_toolbar_msg == 3.0) { ui_label("➕ Nuevo módulo: custom_node.ph", x + 12.0, cy + 15.0, 9.0, 0x3FB950) } else { 1.0 }
        if (exp_toolbar_msg == 4.0) { ui_label("📁 Carpeta creada en árbol BOM", x + 12.0, cy + 15.0, 9.0, 0xD29922) } else { 1.0 }
        if (exp_toolbar_msg == 5.0) { ui_label("🌐 Sync GitHub koradevsorg OK", x + 12.0, cy + 15.0, 9.0, 0x58A6FF) } else { 1.0 }
        if (exp_toolbar_msg == 12.0) { ui_label("📥 Directiva import copiada", x + 12.0, cy + 15.0, 9.0, 0x3FB950) } else { 1.0 }
        if (exp_toolbar_msg == 13.0) { ui_label("✏ Modo renombrar activado", x + 12.0, cy + 15.0, 9.0, 0xD29922) } else { 1.0 }
        if (exp_toolbar_msg == 14.0) { ui_label("🗑 Archivo ocultado del árbol", x + 12.0, cy + 15.0, 9.0, 0xF85149) } else { 1.0 }
        cy = cy + 25.0
    } else { 1.0 }

    // 2. Sección OPEN EDITORS
    prim_box(x + 1.0, cy, w - 2.0, 20.0, 0x161B22)
    ui_label("v OPEN EDITORS", x + 8.0, cy + 14.0, 9.0, 0x8B949E)
    cy = cy + 22.0

    r_oe1 = ui_tree_node("chronos_ide.ph [S1]", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 0.0, 0.0, 0.0, (exp_selected_id == 1.0), mx, my, bg_click)
    if (r_oe1 == 1.0) { exp_selected_id = 1.0; editor_active_file_id = 1.0 } else { 1.0 }
    if (r_oe1 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 1.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
    cy = cy + 28.0

    r_oe2 = ui_tree_node("screen_explorer.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 0.0, 0.0, 0.0, (exp_selected_id == 6.0), mx, my, bg_click)
    if (r_oe2 == 1.0) { exp_selected_id = 6.0; editor_active_file_id = 6.0 } else { 1.0 }
    if (r_oe2 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 6.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
    cy = cy + 30.0

    // 3. Sección PROYECTO: SKETCHWAREPRO [BOM]
    prim_box(x + 1.0, cy, w - 2.0, 20.0, 0x161B22)
    ui_label("v PROYECTO: SKETCHWAREPRO [BOM]", x + 8.0, cy + 14.0, 9.0, 0x58A6FF)
    cy = cy + 22.0

    // Carpeta Grado 0: lib/core
    r_d0 = ui_tree_node("lib/core (Grado 0)", "", 0xD29922, x + 2.0, cy, w - 4.0, 0.0, 1.0, exp_dir_core, 0.0, mx, my, bg_click)
    if (r_d0 == 1.0) { if (exp_dir_core == 1.0) { exp_dir_core = 0.0 } else { exp_dir_core = 1.0 } } else { 1.0 }
    cy = cy + 28.0

    if (exp_dir_core == 1.0) {
        r_f2 = ui_tree_node("primitives.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 2.0), mx, my, bg_click)
        if (r_f2 == 1.0) { exp_selected_id = 2.0; editor_active_file_id = 2.0 } else { 1.0 }
        if (r_f2 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 2.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
        cy = cy + 28.0
    } else { 1.0 }

    // Carpeta Grado 1 & 2: lib/ui
    r_d1 = ui_tree_node("lib/ui (Grado 1 & 2)", "", 0xD29922, x + 2.0, cy, w - 4.0, 0.0, 1.0, exp_dir_ui, 0.0, mx, my, bg_click)
    if (r_d1 == 1.0) { if (exp_dir_ui == 1.0) { exp_dir_ui = 0.0 } else { exp_dir_ui = 1.0 } } else { 1.0 }
    cy = cy + 28.0

    if (exp_dir_ui == 1.0) {
        r_f3 = ui_tree_node("tree_node.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 3.0), mx, my, bg_click)
        if (r_f3 == 1.0) { exp_selected_id = 3.0; editor_active_file_id = 3.0 } else { 1.0 }
        if (r_f3 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 3.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
        cy = cy + 28.0

        r_f4 = ui_tree_node("popup_menu.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 4.0), mx, my, bg_click)
        if (r_f4 == 1.0) { exp_selected_id = 4.0; editor_active_file_id = 4.0 } else { 1.0 }
        if (r_f4 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 4.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
        cy = cy + 28.0

        if (exp_extra_file == 1.0) {
            r_f7 = ui_tree_node("custom_node.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 7.0), mx, my, bg_click)
            if (r_f7 == 1.0) { exp_selected_id = 7.0; editor_active_file_id = 7.0 } else { 1.0 }
            if (r_f7 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 7.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
            cy = cy + 28.0
        } else { 1.0 }
    } else { 1.0 }

    // Carpeta Grado 3: lib/screens
    r_d2 = ui_tree_node("lib/screens (Grado 3)", "", 0xD29922, x + 2.0, cy, w - 4.0, 0.0, 1.0, exp_dir_screens, 0.0, mx, my, bg_click)
    if (r_d2 == 1.0) { if (exp_dir_screens == 1.0) { exp_dir_screens = 0.0 } else { exp_dir_screens = 1.0 } } else { 1.0 }
    cy = cy + 28.0

    if (exp_dir_screens == 1.0) {
        r_f6 = ui_tree_node("screen_explorer.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 6.0), mx, my, bg_click)
        if (r_f6 == 1.0) { exp_selected_id = 6.0; editor_active_file_id = 6.0 } else { 1.0 }
        if (r_f6 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 6.0; exp_popup_x = mx - 165.0; exp_popup_y = cy + 14.0 } else { 1.0 }
        cy = cy + 28.0
    } else { 1.0 }

    // 4. Barra de estado inferior con enlace activo al Editor S1
    prim_box(x + 1.0, (y + h) - 22.0, w - 2.0, 21.0, 0x161B22)
    ui_label("Editor Link ID:", x + 8.0, (y + h) - 7.0, 9.0, 0x8B949E)
    text(editor_active_file_id, x + 114.0, (y + h) - 15.0, 9.5, 0x3FB950)

    // 5. Menú Contextual Popup por Archivo (Z-Index Máximo)
    if (exp_popup_open == 1.0) {
        p_res = ui_popup_menu("Acciones Archivo", exp_popup_x, exp_popup_y, x, y + 26.0, x + w, y + h, mx, my, click)
        if (p_res == 1.0) {
            editor_active_file_id = exp_popup_target
            exp_popup_open = 0.0
            torus_goto(0.0, 0.0, R250, R251)
        } else { 1.0 }
        if ((p_res == 2.0) || (p_res == 3.0) || (p_res == 4.0)) {
            exp_toolbar_msg = p_res + 10.0
            if (p_res == 4.0) { exp_extra_file = 0.0 } else { 1.0 }
            exp_popup_open = 0.0
        } else { 1.0 }
        if (p_res == 9.0) {
            exp_popup_open = 0.0
        } else { 1.0 }
    } else { 1.0 }

    unclip()
}
