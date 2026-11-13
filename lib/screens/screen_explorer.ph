// Grado 3: Explorador BOM Modular con Coordenadas Táctiles Corregidas (Móvil y Escritorio)
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"
import "lib/ui/explorer_toolbar.ph"
import "lib/fs/vfs_state.ph"
import "lib/fs/crear.ph"
import "lib/spatial/gesture_lock.ph"

signal exp_popup_open = 0.0
signal exp_popup_target = 0.0
signal exp_popup_x = 0.0
signal exp_popup_y = 0.0

// Fila de carpeta plegable (Átomo Grado 2)
exp_draw_folder(lbl_open, lbl_closed, x, cy, w, is_open, mx, my, click) = {
    prim_box(x + 4.0, cy, w - 8.0, 26.0, 0x11161D)
    if (is_open == 1.0) {
        ui_label(lbl_open, x + 10.0, cy + 17.0, 9.5, 0xE6EDF3)
    } else {
        ui_label(lbl_closed, x + 10.0, cy + 17.0, 9.5, 0x8B949E)
    }
    toggled = is_open
    if (click == 1.0) {
        if (ui_hit_test(mx, my, x, cy, w, 26.0) == 1.0) {
            if (is_open == 1.0) { toggled = 0.0 } else { toggled = 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    toggled
}

// Fila de archivo con botón [⋮] alineado a la derecha
exp_draw_file(lbl, col, x, cy, w, indent, file_id, mx, my, click) = {
    dots_x = (x + w) - 34.0
    if (vfs_selected_id == file_id) {
        prim_box(x + 4.0 + indent, cy + 1.0, (w - 8.0) - indent, 24.0, 0x16283E)
        prim_box(x + 4.0 + indent, cy + 1.0, 3.0, 24.0, 0x58A6FF)
    } else { 1.0 }
    if (indent > 0.0) {
        line(x + 16.0, cy, x + 16.0, cy + 26.0, 0x30363D)
    } else { 1.0 }
    ui_label(lbl, x + 12.0 + indent, cy + 17.0, 9.5, col)
    
    // Dibujar botón [⋮] con área táctil generosa para móvil
    prim_box(dots_x - 4.0, cy + 1.0, 32.0, 24.0, 0x1F2937)
    prim_stroke(dots_x - 4.0, cy + 1.0, 32.0, 24.0, 0x30363D)
    ui_label("⋮", dots_x + 8.0, cy + 16.0, 11.5, 0xFFFFFF)

    if (click == 1.0) {
        if (ui_hit_test(mx, my, x, cy, w, 26.0) == 1.0) {
            if (mx >= (dots_x - 6.0)) {
                exp_popup_open = 1.0
                exp_popup_target = file_id
                exp_popup_x = (x + w) - 188.0
                exp_popup_y = cy + 28.0
            } else {
                vfs_selected_id = file_id
                editor_active_file_id = file_id
            }
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

// Menú contextual flotante persistente (Se cierra al tocar fuera)
exp_draw_popup(x, y, w, h, mx, my, click) = {
    mw = 180.0
    mh = 140.0
    dx = exp_popup_x
    dy = exp_popup_y
    if ((dx + mw) > (x + w - 10.0)) { dx = (x + w - 10.0) - mw } else { 1.0 }
    if ((dy + mh) > (y + h - 10.0)) { dy = (y + h - 10.0) - mh } else { 1.0 }

    prim_box(dx + 3.0, dy + 3.0, mw, mh, 0x010409)
    prim_box(dx, dy, mw, mh, 0x1C2331)
    prim_stroke(dx, dy, mw, mh, 0x58A6FF)

    prim_box(dx + 1.0, dy + 1.0, mw - 2.0, 24.0, 0x0D1117)
    ui_label("Acciones Archivo", dx + 8.0, dy + 16.0, 9.5, 0x79C0FF)
    ui_label("✕", (dx + mw) - 18.0, dy + 16.0, 10.0, 0xF85149)

    iy = dy + 26.0
    ih = 28.0

    // Opción 1: Editar en S1
    ui_label("⚡ Editar en S1", dx + 10.0, iy + 18.0, 10.0, 0xFFFFFF)
    if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
        editor_active_file_id = exp_popup_target
        exp_popup_open = 0.0
        torus_goto(0.0, 0.0, R250, R251)
    } else { 1.0 }
    iy = iy + ih

    // Opción 2: Copiar import
    ui_label("📥 Copiar import", dx + 10.0, iy + 18.0, 10.0, 0x3FB950)
    if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
        vfs_bridge_cmd = 108.0
        exp_popup_open = 0.0
    } else { 1.0 }
    iy = iy + ih

    // Opción 3: Renombrar
    ui_label("✏ Renombrar", dx + 10.0, iy + 18.0, 10.0, 0xD29922)
    if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
        fs_renombrar_activo(exp_popup_target)
        exp_popup_open = 0.0
    } else { 1.0 }
    iy = iy + ih

    // Opción 4: Eliminar
    ui_label("🗑 Eliminar", dx + 10.0, iy + 18.0, 10.0, 0xF85149)
    if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
        fs_eliminar_activo(exp_popup_target)
        exp_popup_open = 0.0
    } else { 1.0 }

    // Cerrar menú al tocar fuera del cuadro de diálogo
    if ((click == 1.0) && (ui_hit_test(mx, my, dx, dy, mw, mh) == 0.0)) {
        exp_popup_open = 0.0
    } else { 1.0 }

    1.0
}

screen_explorer_full(x, y, w, h, mx, my, click) = {
    clip(x, y, w, h)
    prim_box(x, y, w, h, 0x0D1117)
    prim_box(x, y, w, 26.0, 0x14261C)
    prim_stroke(x, y, w, h, 0x30363D)
    ui_label("📁 Screen 2: Explorador (BOM)", x + 10.0, y + 17.0, 11.0, 0xFFFFFF)

    bg_click = click
    if (exp_popup_open == 1.0) {
        bg_click = 0.0
    } else {
        bg_click = click
    }

    tb_y = y + 26.0
    ui_explorer_toolbar(x, tb_y, w, mx, my, bg_click)
    cy = tb_y + 38.0

    // OPEN EDITORS
    prim_box(x + 2.0, cy, w - 4.0, 19.0, 0x161B22)
    ui_label("v OPEN EDITORS", x + 8.0, cy + 13.0, 8.5, 0x8B949E)
    cy = cy + 21.0

    exp_draw_file("⚡ chronos_ide.ph [S1]", 0xFFFFFF, x, cy, w, 0.0, 1.0, mx, my, bg_click)
    cy = cy + 26.0
    exp_draw_file("⚡ screen_explorer.ph", 0xC9D1D9, x, cy, w, 0.0, 6.0, mx, my, bg_click)
    cy = cy + 28.0

    // PROYECTO BOM
    prim_box(x + 2.0, cy, w - 4.0, 19.0, 0x161B22)
    ui_label("v PROYECTO: SKETCHWAREPRO [BOM]", x + 8.0, cy + 13.0, 8.5, 0x58A6FF)
    cy = cy + 21.0

    vfs_dir_core = exp_draw_folder("v 📁 lib/core (Grado 0)", "> 📁 lib/core (Grado 0)", x, cy, w, vfs_dir_core, mx, my, bg_click)
    cy = cy + 26.0
    if (vfs_dir_core == 1.0) {
        exp_draw_file("⚡ primitives.ph", 0x3FB950, x, cy, w, 14.0, 2.0, mx, my, bg_click)
        cy = cy + 26.0
    } else { 1.0 }

    vfs_dir_ui = exp_draw_folder("v 📁 lib/ui (Grado 1 & 2)", "> 📁 lib/ui (Grado 1 & 2)", x, cy, w, vfs_dir_ui, mx, my, bg_click)
    cy = cy + 26.0
    if (vfs_dir_ui == 1.0) {
        exp_draw_file("⚡ tree_node.ph", 0xC9D1D9, x, cy, w, 14.0, 3.0, mx, my, bg_click)
        cy = cy + 26.0
        exp_draw_file("⚡ popup_menu.ph", 0xC9D1D9, x, cy, w, 14.0, 4.0, mx, my, bg_click)
        cy = cy + 26.0
        if (vfs_custom_visible == 1.0) {
            exp_draw_file("⚡ custom_node.ph", 0x3FB950, x, cy, w, 14.0, 7.0, mx, my, bg_click)
            cy = cy + 26.0
        } else { 1.0 }
    } else { 1.0 }

    vfs_dir_screens = exp_draw_folder("v 📁 lib/fs (Abrir/Crear/Git)", "> 📁 lib/fs (Abrir/Crear/Git)", x, cy, w, vfs_dir_screens, mx, my, bg_click)
    cy = cy + 26.0
    if (vfs_dir_screens == 1.0) {
        exp_draw_file("⚡ abrir.ph", 0xC9D1D9, x, cy, w, 14.0, 8.0, mx, my, bg_click)
        cy = cy + 26.0
    } else { 1.0 }

    if (vfs_custom_dir_visible == 1.0) {
        prim_box(x + 4.0, cy, w - 8.0, 26.0, 0x11161D)
        ui_label("v 📁 lib/custom (Nueva)", x + 10.0, cy + 17.0, 9.5, 0xD29922)
        cy = cy + 26.0
    } else { 1.0 }

    prim_box(x + 1.0, (y + h) - 22.0, w - 2.0, 21.0, 0x161B22)
    ui_label("Editor Link ID:", x + 8.0, (y + h) - 7.0, 9.0, 0x8B949E)
    text(editor_active_file_id, x + 114.0, (y + h) - 15.0, 9.5, 0x3FB950)

    if (exp_popup_open == 1.0) {
        exp_draw_popup(x, y, w, h, mx, my, click)
    } else { 1.0 }

    unclip()
}
