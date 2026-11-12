// Grado 1: Fila de árbol jerárquico alineada con hitbox táctil (28px alto) y botón (⋮)
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"

// Retorna: 0=Nada, 1=Click en fila (abrir/plegar), 2=Click en menú (⋮)
ui_tree_node(lbl_id, icon_id, icon_col, x, y, w, depth, is_dir, expanded, selected, mx, my, click) = {
    h = 28.0
    hov = ui_hit_test(mx, my, x, y, w, h)

    if (selected == 1.0) {
        prim_box(x + 2.0, y + 1.0, w - 4.0, h - 2.0, 0x16283E)
        prim_box(x + 2.0, y + 1.0, 3.0, h - 2.0, 0x58A6FF)
    } else {
        if (hov == 1.0) {
            prim_box(x + 2.0, y + 1.0, w - 4.0, h - 2.0, 0x161B22)
        } else { 1.0 }
    }

    // Guías verticales de indentación limpias
    ix = x + 10.0 + (depth * 16.0)
    if (depth >= 1.0) { line(x + 16.0, y, x + 16.0, y + h, 0x21262D) } else { 1.0 }
    if (depth >= 2.0) { line(x + 32.0, y, x + 32.0, y + h, 0x21262D) } else { 1.0 }

    if (is_dir == 1.0) {
        if (expanded == 1.0) {
            ui_label("v", ix, y + 18.0, 10.0, 0x8B949E)
        } else {
            ui_label(">", ix, y + 18.0, 10.0, 0x8B949E)
        }
        ui_label("📁", ix + 12.0, y + 18.0, 11.0, 0xD29922)
        ui_label(lbl_id, ix + 30.0, y + 18.0, 10.5, 0xE6EDF3)
    } else {
        ui_label(icon_id, ix + 2.0, y + 18.0, 10.0, icon_col)
        txt_col = 0xC9D1D9
        if (selected == 1.0) { txt_col = 0xFFFFFF } else { 1.0 }
        ui_label(lbl_id, ix + 18.0, y + 18.0, 10.5, txt_col)
    }

    // Botón táctil de 3 puntos (⋮) de 34px de ancho a la derecha para fácil toque en celular
    dots_w = 34.0
    dots_x = (x + w) - dots_w - 4.0
    dots_hov = ui_hit_test(mx, my, dots_x, y + 2.0, dots_w, h - 4.0)
    btn_bg = 0x161B22
    if ((dots_hov == 1.0) || (selected == 1.0)) { btn_bg = 0x21262D } else { 1.0 }
    prim_box(dots_x, y + 3.0, dots_w, h - 6.0, btn_bg)
    prim_stroke(dots_x, y + 3.0, dots_w, h - 6.0, 0x30363D)
    ui_label("⋮", dots_x + 13.0, y + 18.0, 11.0, 0xFFFFFF)

    res = 0.0
    if ((hov == 1.0) && (click == 1.0)) {
        if (mx >= dots_x) { res = 2.0 } else { res = 1.0 }
    } else { 1.0 }
    res
}
