// Grado 2: Menú flotante contextual por archivo (Editar, Importar, Renombrar, Eliminar)
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"

// Retorna: 0=Nada, 1=Editar en S1, 2=Copiar import, 3=Renombrar, 4=Eliminar, 9=Cerrar
ui_popup_menu(title_id, px, py, min_x, min_y, max_w, max_h, mx, my, click) = {
    mw = 184.0
    mh = 144.0
    dx = px
    dy = py
    if ((dx + mw) > (max_w - 8.0)) { dx = max_w - mw - 8.0 } else { 1.0 }
    if ((dy + mh) > (max_h - 8.0)) { dy = max_h - mh - 8.0 } else { 1.0 }
    if (dx < (min_x + 8.0)) { dx = min_x + 8.0 } else { 1.0 }
    if (dy < (min_y + 8.0)) { dy = min_y + 8.0 } else { 1.0 }

    prim_box(dx + 4.0, dy + 4.0, mw, mh, 0x010409)
    prim_box(dx, dy, mw, mh, 0x1C2331)
    prim_stroke(dx, dy, mw, mh, 0x58A6FF)

    prim_box(dx + 2.0, dy + 2.0, mw - 4.0, 24.0, 0x0D1117)
    ui_label(title_id, dx + 10.0, dy + 17.0, 9.5, 0x79C0FF)
    ui_label("✕", (dx + mw) - 20.0, dy + 17.0, 10.0, 0xF85149)

    res = 0.0
    if ((click == 1.0) && (ui_hit_test(mx, my, (dx + mw) - 28.0, dy, 28.0, 26.0) == 1.0)) {
        res = 9.0
    } else { 1.0 }

    iy = dy + 28.0
    ih = 27.0

    if (ui_hit_test(mx, my, dx + 3.0, iy, mw - 6.0, ih) == 1.0) {
        prim_box(dx + 3.0, iy, mw - 6.0, ih, 0x1F6FEB)
        if (click == 1.0) { res = 1.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("⚡ Editar en S1", dx + 12.0, iy + 18.0, 10.0, 0xFFFFFF)
    iy = iy + ih

    if (ui_hit_test(mx, my, dx + 3.0, iy, mw - 6.0, ih) == 1.0) {
        prim_box(dx + 3.0, iy, mw - 6.0, ih, 0x1F6FEB)
        if (click == 1.0) { res = 2.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("📥 Copiar import", dx + 12.0, iy + 18.0, 10.0, 0x3FB950)
    iy = iy + ih

    if (ui_hit_test(mx, my, dx + 3.0, iy, mw - 6.0, ih) == 1.0) {
        prim_box(dx + 3.0, iy, mw - 6.0, ih, 0x1F6FEB)
        if (click == 1.0) { res = 3.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("✏ Renombrar", dx + 12.0, iy + 18.0, 10.0, 0xD29922)
    iy = iy + ih

    if (ui_hit_test(mx, my, dx + 3.0, iy, mw - 6.0, ih) == 1.0) {
        prim_box(dx + 3.0, iy, mw - 6.0, ih, 0xDA3633)
        if (click == 1.0) { res = 4.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("🗑 Eliminar", dx + 12.0, iy + 18.0, 10.0, 0xF85149)

    if ((click == 1.0) && (res == 0.0) && (ui_hit_test(mx, my, dx, dy, mw, mh) == 0.0)) {
        res = 9.0
    } else { 1.0 }

    res
}
