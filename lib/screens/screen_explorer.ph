// Grado 3: Explorador Completo BOM + Open Editors + Acciones VFS Reales
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

screen_explorer_full(x, y, w, h, mx, my, click) = {
    clip(x, y, w, h)
    prim_box(x, y, w, h, 0x0D1117)
    prim_box(x, y, w, 26.0, 0x14261C)
    prim_stroke(x, y, w, h, 0x30363D)
    ui_label("📁 Screen 2: Explorador (BOM)", x + 10.0, y + 17.0, 11.0, 0xFFFFFF)

    bg_click = click
    if (exp_popup_open == 1.0) { bg_click = 0.0 } else { 1.0 }

    // 1. Menú Superior VS Code (delega en lib/fs/*)
    tb_y = y + 26.0
    ui_explorer_toolbar(x, tb_y, w, mx, my, bg_click)
    cy = tb_y + 38.0
    rh = 26.0
    dots_x = (x + w) - 34.0

    // 2. Sección OPEN EDITORS
    prim_box(x + 2.0, cy, w - 4.0, 19.0, 0x161B22)
    ui_label("v OPEN EDITORS", x + 8.0, cy + 13.0, 8.5, 0x8B949E)
    cy = cy + 21.0

    // OE-1: chronos_ide.ph [S1]
    if (vfs_selected_id == 1.0) {
        prim_box(x + 4.0, cy + 1.0, w - 8.0, rh - 2.0, 0x16283E)
        prim_box(x + 4.0, cy + 1.0, 3.0, rh - 2.0, 0x58A6FF)
    } else { 1.0 }
    ui_label("⚡ chronos_ide.ph [S1]", x + 12.0, cy + 17.0, 9.5, 0xFFFFFF)
    prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
    prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
    ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
    if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
        if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 1.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
        else { vfs_selected_id = 1.0; editor_active_file_id = 1.0 }
    } else { 1.0 }
    cy = cy + rh

    // OE-2: screen_explorer.ph
    if (vfs_selected_id == 6.0) {
        prim_box(x + 4.0, cy + 1.0, w - 8.0, rh - 2.0, 0x16283E)
        prim_box(x + 4.0, cy + 1.0, 3.0, rh - 2.0, 0x58A6FF)
    } else { 1.0 }
    ui_label("⚡ screen_explorer.ph", x + 12.0, cy + 17.0, 9.5, 0xC9D1D9)
    prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
    prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
    ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
    if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
        if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 6.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
        else { vfs_selected_id = 6.0; editor_active_file_id = 6.0 }
    } else { 1.0 }
    cy = cy + rh + 2.0

    // 3. Sección PROYECTO: SKETCHWAREPRO [BOM]
    prim_box(x + 2.0, cy, w - 4.0, 19.0, 0x161B22)
    ui_label("v PROYECTO: SKETCHWAREPRO [BOM]", x + 8.0, cy + 13.0, 8.5, 0x58A6FF)
    cy = cy + 21.0

    // --- Carpeta Grado 0: lib/core ---
    prim_box(x + 4.0, cy, w - 8.0, rh, 0x11161D)
    if (vfs_dir_core == 1.0) {
        ui_label("v 📁 lib/core (Grado 0)", x + 10.0, cy + 17.0, 9.5, 0xE6EDF3)
    } else {
        ui_label("> 📁 lib/core (Grado 0)", x + 10.0, cy + 17.0, 9.5, 0x8B949E)
    }
    if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
        if (vfs_dir_core == 1.0) { vfs_dir_core = 0.0 } else { vfs_dir_core = 1.0 }
    } else { 1.0 }
    cy = cy + rh

    if (vfs_dir_core == 1.0) {
        if (vfs_selected_id == 2.0) { prim_box(x + 20.0, cy + 1.0, w - 24.0, rh - 2.0, 0x16283E) } else { 1.0 }
        line(x + 16.0, cy, x + 16.0, cy + rh, 0x30363D)
        ui_label("⚡ primitives.ph", x + 26.0, cy + 17.0, 9.5, 0x3FB950)
        prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
        prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
        ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
        if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
            if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 2.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
            else { vfs_selected_id = 2.0; editor_active_file_id = 2.0 }
        } else { 1.0 }
        cy = cy + rh
    } else { 1.0 }

    // --- Carpeta Grado 1 & 2: lib/ui ---
    prim_box(x + 4.0, cy, w - 8.0, rh, 0x11161D)
    if (vfs_dir_ui == 1.0) {
        ui_label("v 📁 lib/ui (Grado 1 & 2)", x + 10.0, cy + 17.0, 9.5, 0xE6EDF3)
    } else {
        ui_label("> 📁 lib/ui (Grado 1 & 2)", x + 10.0, cy + 17.0, 9.5, 0x8B949E)
    }
    if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
        if (vfs_dir_ui == 1.0) { vfs_dir_ui = 0.0 } else { vfs_dir_ui = 1.0 }
    } else { 1.0 }
    cy = cy + rh

    if (vfs_dir_ui == 1.0) {
        if (vfs_selected_id == 3.0) { prim_box(x + 20.0, cy + 1.0, w - 24.0, rh - 2.0, 0x16283E) } else { 1.0 }
        line(x + 16.0, cy, x + 16.0, cy + rh, 0x30363D)
        ui_label("⚡ tree_node.ph", x + 26.0, cy + 17.0, 9.5, 0xC9D1D9)
        prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
        prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
        ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
        if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
            if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 3.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
            else { vfs_selected_id = 3.0; editor_active_file_id = 3.0 }
        } else { 1.0 }
        cy = cy + rh

        if (vfs_selected_id == 4.0) { prim_box(x + 20.0, cy + 1.0, w - 24.0, rh - 2.0, 0x16283E) } else { 1.0 }
        line(x + 16.0, cy, x + 16.0, cy + rh, 0x30363D)
        ui_label("⚡ popup_menu.ph", x + 26.0, cy + 17.0, 9.5, 0xC9D1D9)
        prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
        prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
        ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
        if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
            if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 4.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
            else { vfs_selected_id = 4.0; editor_active_file_id = 4.0 }
        } else { 1.0 }
        cy = cy + rh

        if (vfs_custom_visible == 1.0) {
            if (vfs_selected_id == 7.0) { prim_box(x + 20.0, cy + 1.0, w - 24.0, rh - 2.0, 0x16283E) } else { 1.0 }
            line(x + 16.0, cy, x + 16.0, cy + rh, 0x30363D)
            ui_label("⚡ custom_node.ph", x + 26.0, cy + 17.0, 9.5, 0x3FB950)
            prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
            prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
            ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
            if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
                if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 7.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
                else { vfs_selected_id = 7.0; editor_active_file_id = 7.0 }
            } else { 1.0 }
            cy = cy + rh
        } else { 1.0 }
    } else { 1.0 }

    // --- Carpeta Grado 2 FS: lib/fs ---
    prim_box(x + 4.0, cy, w - 8.0, rh, 0x11161D)
    if (vfs_dir_screens == 1.0) {
        ui_label("v 📁 lib/fs (Abrir/Crear/Git)", x + 10.0, cy + 17.0, 9.5, 0xE6EDF3)
    } else {
        ui_label("> 📁 lib/fs (Abrir/Crear/Git)", x + 10.0, cy + 17.0, 9.5, 0x8B949E)
    }
    if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
        if (vfs_dir_screens == 1.0) { vfs_dir_screens = 0.0 } else { vfs_dir_screens = 1.0 }
    } else { 1.0 }
    cy = cy + rh

    if (vfs_dir_screens == 1.0) {
        if (vfs_selected_id == 8.0) { prim_box(x + 20.0, cy + 1.0, w - 24.0, rh - 2.0, 0x16283E) } else { 1.0 }
        line(x + 16.0, cy, x + 16.0, cy + rh, 0x30363D)
        ui_label("⚡ abrir.ph", x + 26.0, cy + 17.0, 9.5, 0xC9D1D9)
        prim_box(dots_x, cy + 2.0, 26.0, 21.0, 0x1F2937)
        prim_stroke(dots_x, cy + 2.0, 26.0, 21.0, 0x30363D)
        ui_label("⋮", dots_x + 10.0, cy + 16.0, 10.5, 0xFFFFFF)
        if ((bg_click == 1.0) && (ui_hit_test(mx, my, x, cy, w, rh) == 1.0)) {
            if (mx >= dots_x) { exp_popup_open = 1.0; exp_popup_target = 8.0; exp_popup_x = (x + w) - 184.0; exp_popup_y = cy + 24.0 }
            else { vfs_selected_id = 8.0; editor_active_file_id = 8.0 }
        } else { 1.0 }
        cy = cy + rh
    } else { 1.0 }

    if (vfs_custom_dir_visible == 1.0) {
        prim_box(x + 4.0, cy, w - 8.0, rh, 0x11161D)
        ui_label("v 📁 lib/custom (Nueva)", x + 10.0, cy + 17.0, 9.5, 0xD29922)
        cy = cy + rh
    } else { 1.0 }

    // 4. Barra de estado inferior con enlace activo al Editor S1
    prim_box(x + 1.0, (y + h) - 22.0, w - 2.0, 21.0, 0x161B22)
    ui_label("Editor Link ID:", x + 8.0, (y + h) - 7.0, 9.0, 0x8B949E)
    text(editor_active_file_id, x + 114.0, (y + h) - 15.0, 9.5, 0x3FB950)

    // 5. Menú Contextual Popup por Archivo (Z-Index Máximo)
    if (exp_popup_open == 1.0) {
        mw = 176.0
        mh = 136.0
        dx = exp_popup_x
        dy = exp_popup_y
        if ((dy + mh) > ((y + h) - 24.0)) { dy = ((y + h) - 24.0) - mh } else { 1.0 }

        prim_box(dx + 3.0, dy + 3.0, mw, mh, 0x010409)
        prim_box(dx, dy, mw, mh, 0x1C2331)
        prim_stroke(dx, dy, mw, mh, 0x58A6FF)

        prim_box(dx + 1.0, dy + 1.0, mw - 2.0, 22.0, 0x0D1117)
        ui_label("Acciones Archivo", dx + 8.0, dy + 15.0, 9.0, 0x79C0FF)
        ui_label("✕", (dx + mw) - 18.0, dy + 15.0, 9.5, 0xF85149)

        iy = dy + 24.0
        ih = 27.0

        ui_label("⚡ Editar en S1", dx + 10.0, iy + 17.0, 9.5, 0xFFFFFF)
        if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
            editor_active_file_id = exp_popup_target
            exp_popup_open = 0.0
            torus_goto(0.0, 0.0, R250, R251)
        } else { 1.0 }
        iy = iy + ih

        ui_label("📥 Copiar import", dx + 10.0, iy + 17.0, 9.5, 0x3FB950)
        if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
            vfs_bridge_cmd = 108.0
            exp_popup_open = 0.0
        } else { 1.0 }
        iy = iy + ih

        ui_label("✏ Renombrar", dx + 10.0, iy + 17.0, 9.5, 0xD29922)
        if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
            fs_renombrar_activo(exp_popup_target)
            exp_popup_open = 0.0
        } else { 1.0 }
        iy = iy + ih

        ui_label("🗑 Eliminar", dx + 10.0, iy + 17.0, 9.5, 0xF85149)
        if ((click == 1.0) && (ui_hit_test(mx, my, dx, iy, mw, ih) == 1.0)) {
            fs_eliminar_activo(exp_popup_target)
            exp_popup_open = 0.0
        } else { 1.0 }

        if ((click == 1.0) && (ui_hit_test(mx, my, dx, dy + 23.0, mw, mh - 23.0) == 0.0)) {
            exp_popup_open = 0.0
        } else { 1.0 }
    } else { 1.0 }

    unclip()
}
