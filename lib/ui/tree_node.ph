// Grado 1: Fila de árbol jerárquico alineada (sin recuadros residuales)
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"

// Retorna: 0=Nada, 1=Click en fila, 2=Click en menú (⋮)
ui_tree_node(lbl_id, icon_id, icon_col, x, y, w, depth, is_dir, expanded, selected, mx, my, click) = {
    h = 26.0
    hov = ui_hit_test(mx, my, x, y, w, h)

    if (selected == 1.0) {
        prim_box(x + 4.0, y + 1.0, w - 8.0, h - 2.0, 0x16283E)
        prim_box(x + 4.0, y + 1.0, 3.0, h - 2.0, 0x58A6FF)
    } else { 1.0 }

    // Guías verticales de indentación
    if (depth >= 1.0) {
        line(x + 16.0, y, x + 16.0, y + h, 0x21262D)
    } else { 1.0 }

    ix = x + 12.0 + (depth * 16.0)

    if (is_dir == 1.0) {
        if (expanded == 1.0) {
            ui_label("v", ix, y + 17.0, 9.5, 0x8B949E)
        } else {
            ui_label(">", ix, y + 17.0, 9.5, 0x8B949E)
        }
        ui_label("📁", ix + 12.0, y + 17.0, 10.5, 0xD29922)
        ui_label(lbl_id, ix + 28.0, y + 17.0, 10.0, 0xE6EDF3)
    } else {
        ui_label(icon_id, ix + 2.0, y + 17.0, 9.5, icon_col)
        t_col = 0xC9D1D9
        if (selected == 1.0) { t_col = 0xFFFFFF } else { 1.0 }
        ui_label(lbl_id, ix + 18.0, y + 17.0, 10.0, t_col)
    }

    // Botón táctil (⋮) a la derecha con hitbox amplio (32px)
    dots_w = 32.0
    dots_x = (x + w) - dots_w - 6.0
    prim_box(dots_x, y + 3.0, dots_w, h - 6.0, 0x161B22)
    prim_stroke(dots_x, y + 3.0, dots_w, h - 6.0, 0x30363D)
    ui_label("⋮", dots_x + 12.0, y + 17.0, 10.5, 0xE6EDF3)

    res = 0.0
    if ((hov == 1.0) && (click == 1.0)) {
        if (mx >= dots_x) {
            res = 2.0
        } else {
            res = 1.0
        }
    } else { 1.0 }
    res
}
