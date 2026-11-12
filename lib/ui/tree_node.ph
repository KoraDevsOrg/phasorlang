// Grado 1: Fila de árbol jerárquico con icono por extensión y botón menú (⋮)
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"

// Retorna: 0=Nada, 1=Click en fila (abrir/plegar), 2=Click en menú (⋮)
ui_tree_node(lbl_id, icon_id, icon_col, x, y, w, depth, is_dir, expanded, selected, mx, my, click) = {
    h = 24.0
    hov = ui_hit_test(mx, my, x, y, w, h)

    if (selected == 1.0) {
        prim_box(x, y, w, h, 0x162436)
        prim_box(x, y, 2.5, h, 0x58A6FF)
    } else {
        if (hov == 1.0) { prim_box(x, y, w, h, 0x161B22) } else { 1.0 }
    }

    // Guías verticales de indentación
    ix = x + 8.0 + (depth * 14.0)
    if (depth >= 1.0) { line(x + 14.0, y, x + 14.0, y + h, 0x21262D) } else { 1.0 }
    if (depth >= 2.0) { line(x + 28.0, y, x + 28.0, y + h, 0x21262D) } else { 1.0 }

    if (is_dir == 1.0) {
        if (expanded == 1.0) {
            ui_label("v", ix, y + 16.0, 9.0, 0x8B949E)
        } else {
            ui_label(">", ix, y + 16.0, 9.0, 0x8B949E)
        }
        ui_label("📁", ix + 11.0, y + 16.0, 10.0, 0xD29922)
        ui_label(lbl_id, ix + 27.0, y + 16.0, 10.0, 0xE6EDF3)
    } else {
        ui_label(icon_id, ix + 4.0, y + 16.0, 9.0, icon_col)
        txt_col = 0xC9D1D9
        if (selected == 1.0) { txt_col = 0xFFFFFF } else { 1.0 }
        ui_label(lbl_id, ix + 20.0, y + 16.0, 10.0, txt_col)
    }

    // Botón de acciones por archivo (⋮) alineado a la derecha
    dots_x = (x + w) - 22.0
    dots_hov = ui_hit_test(mx, my, dots_x, y + 2.0, 18.0, h - 4.0)
    if ((dots_hov == 1.0) || (selected == 1.0)) {
        prim_box(dots_x, y + 3.0, 18.0, h - 6.0, 0x21262D)
        ui_label(":", dots_x + 7.0, y + 16.0, 10.0, 0xFFFFFF)
    } else {
        ui_label(":", dots_x + 7.0, y + 16.0, 10.0, 0x6E7681)
    }

    res = 0.0
    if ((hov == 1.0) && (click == 1.0)) {
        if (mx >= dots_x) { res = 2.0 } else { res = 1.0 }
    } else { 1.0 }
    res
}
