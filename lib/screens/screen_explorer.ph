// Grado 3: Explorador Completo BOM + Open Editors + Señal puente hacia Editor S1
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

// Señal puente desacoplada para conectar con el Editor futuro (Screen 1)
signal editor_active_file_id = 1.0

screen_explorer_full(x, y, w, h, mx, my, click) = {
    prim_box(x, y, w, h, 0x0D1117)
    prim_box(x, y, w, 26.0, 0x14261C)
    prim_stroke(x, y, w, h, 0x30363D)
    ui_label("📁 Screen 2: Explorador (BOM)", x + 10.0, y + 17.0, 11.0, 0xFFFFFF)

    // 1. Menú Superior Estilo VS Code
    tb_y = y + 26.0
    tb_act = ui_explorer_toolbar(x, tb_y, w, mx, my, click)
    if (tb_act > 0.0) { exp_toolbar_msg = tb_act } else { 1.0 }

    cy = tb_y + 34.0

    // 2. Sección OPEN EDITORS (Archivos abiertos listos para editar en S1)
    prim_box(x + 1.0, cy, w - 2.0, 18.0, 0x161B22)
    ui_label("v OPEN EDITORS", x + 8.0, cy + 12.0, 8.5, 0x8B949E)
    cy = cy + 20.0

    r_oe1 = ui_tree_node("chronos_ide.ph [S1]", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 0.0, 0.0, 0.0, (exp_selected_id == 1.0), mx, my, click)
    if (r_oe1 == 1.0) { exp_selected_id = 1.0; editor_active_file_id = 1.0 } else { 1.0 }
    if (r_oe1 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 1.0; exp_popup_x = mx - 135.0; exp_popup_y = cy + 10.0 } else { 1.0 }
    cy = cy + 24.0

    r_oe2 = ui_tree_node("screen_explorer.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 0.0, 0.0, 0.0, (exp_selected_id == 6.0), mx, my, click)
    if (r_oe2 == 1.0) { exp_selected_id = 6.0; editor_active_file_id = 6.0 } else { 1.0 }
    if (r_oe2 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 6.0; exp_popup_x = mx - 135.0; exp_popup_y = cy + 10.0 } else { 1.0 }
    cy = cy + 26.0

    // 3. Sección PROYECTO: SKETCHWAREPRO [BOM]
    prim_box(x + 1.0, cy, w - 2.0, 18.0, 0x161B22)
    ui_label("v PROYECTO: SKETCHWAREPRO [BOM]", x + 8.0, cy + 12.0, 8.5, 0x58A6FF)
    cy = cy + 20.0

    // Carpeta Grado 0: lib/core/
    r_d0 = ui_tree_node("lib/core (Grado 0)", "", 0xD29922, x + 2.0, cy, w - 4.0, 0.0, 1.0, exp_dir_core, 0.0, mx, my, click)
    if (r_d0 == 1.0) { if (exp_dir_core == 1.0) { exp_dir_core = 0.0 } else { exp_dir_core = 1.0 } } else { 1.0 }
    cy = cy + 24.0

    if (exp_dir_core == 1.0) {
        r_f2 = ui_tree_node("primitives.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 2.0), mx, my, click)
        if (r_f2 == 1.0) { exp_selected_id = 2.0; editor_active_file_id = 2.0 } else { 1.0 }
        if (r_f2 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 2.0; exp_popup_x = mx - 135.0; exp_popup_y = cy + 10.0 } else { 1.0 }
        cy = cy + 24.0
    } else { 1.0 }

    // Carpeta Grado 1 & 2: lib/ui/
    r_d1 = ui_tree_node("lib/ui (Grado 1 & 2)", "", 0xD29922, x + 2.0, cy, w - 4.0, 0.0, 1.0, exp_dir_ui, 0.0, mx, my, click)
    if (r_d1 == 1.0) { if (exp_dir_ui == 1.0) { exp_dir_ui = 0.0 } else { exp_dir_ui = 1.0 } } else { 1.0 }
    cy = cy + 24.0

    if (exp_dir_ui == 1.0) {
        r_f3 = ui_tree_node("tree_node.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 3.0), mx, my, click)
        if (r_f3 == 1.0) { exp_selected_id = 3.0; editor_active_file_id = 3.0 } else { 1.0 }
        if (r_f3 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 3.0; exp_popup_x = mx - 135.0; exp_popup_y = cy + 10.0 } else { 1.0 }
        cy = cy + 24.0

        r_f4 = ui_tree_node("popup_menu.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 4.0), mx, my, click)
        if (r_f4 == 1.0) { exp_selected_id = 4.0; editor_active_file_id = 4.0 } else { 1.0 }
        if (r_f4 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 4.0; exp_popup_x = mx - 135.0; exp_popup_y = cy + 10.0 } else { 1.0 }
        cy = cy + 24.0
    } else { 1.0 }

    // Carpeta Grado 3: lib/screens/
    r_d2 = ui_tree_node("lib/screens (Grado 3)", "", 0xD29922, x + 2.0, cy, w - 4.0, 0.0, 1.0, exp_dir_screens, 0.0, mx, my, click)
    if (r_d2 == 1.0) { if (exp_dir_screens == 1.0) { exp_dir_screens = 0.0 } else { exp_dir_screens = 1.0 } } else { 1.0 }
    cy = cy + 24.0

    if (exp_dir_screens == 1.0) {
        r_f6 = ui_tree_node("screen_explorer.ph", "⚡", 0x3FB950, x + 2.0, cy, w - 4.0, 1.0, 0.0, 0.0, (exp_selected_id == 6.0), mx, my, click)
        if (r_f6 == 1.0) { exp_selected_id = 6.0; editor_active_file_id = 6.0 } else { 1.0 }
        if (r_f6 == 2.0) { exp_popup_open = 1.0; exp_popup_target = 6.0; exp_popup_x = mx - 135.0; exp_popup_y = cy + 10.0 } else { 1.0 }
        cy = cy + 24.0
    } else { 1.0 }

    // 4. Barra de estado con enlace activo al Editor S1
    prim_box(x + 1.0, (y + h) - 21.0, w - 2.0, 20.0, 0x161B22)
    ui_label("Editor Link ID:", x + 8.0, (y + h) - 7.0, 8.5, 0x8B949E)
    text(editor_active_file_id, x + 108.0, (y + h) - 14.0, 9, 0x3FB950)

    // 5. Menú Contextual Popup por Archivo (Z-Index Máximo)
    if (exp_popup_open == 1.0) {
        p_res = ui_popup_menu("Acciones Archivo", exp_popup_x, exp_popup_y, x + w, y + h, mx, my, click)
        if (p_res == 1.0) {
            editor_active_file_id = exp_popup_target
            exp_popup_open = 0.0
            torus_goto(0.0, 0.0, R250, R251)
        } else { 1.0 }
        if ((p_res == 2.0) || (p_res == 3.0) || (p_res == 4.0)) {
            exp_toolbar_msg = p_res + 10.0
            exp_popup_open = 0.0
        } else { 1.0 }
        if (p_res == 9.0) {
            exp_popup_open = 0.0
        } else { 1.0 }
    } else { 1.0 }
}
