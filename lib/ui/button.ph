// Grado 1: Botón interactivo atómico (Hitbox + Borde + Etiqueta)
import "lib/core/primitives.ph"
import "lib/ui/label.ph"

ui_hit_test(px, py, x, y, w, h) = {
    hit = 0.0
    if ((px >= x) && (px <= (x + w)) && (py >= y) && (py <= (y + h))) {
        hit = 1.0
    } else { 1.0 }
    hit
}

ui_button(str_id, x, y, w, h, bg_col, border_col, txt_col, txt_sz) = {
    prim_box(x, y, w, h, bg_col)
    prim_stroke(x, y, w, h, border_col)
    tx = x + (w * 0.22)
    ty = y + (h * 0.66)
    ui_label(str_id, tx, ty, txt_sz, txt_col)
}
