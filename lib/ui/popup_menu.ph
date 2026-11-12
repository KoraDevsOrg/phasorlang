// Grado 2: Menú flotante contextual por archivo con clamping de bordes
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"

// Retorna: 0=Sin acción, 1=Editar en S1, 2=Copiar import, 3=Renombrar, 4=Eliminar, 9=Cerrar
ui_popup_menu(title_id, px, py, max_w, max_h, mx, my, click) = {
    mw = 154.0
    mh = 114.0
    dx = px
    dy = py
    if ((dx + mw) > (max_w - 6.0)) { dx = max_w - mw - 6.0 } else { 1.0 }
    if ((dy + mh) > (max_h - 6.0)) { dy = max_h - mh - 6.0 } else { 1.0 }
    if (dx < 6.0) { dx = 6.0 } else { 1.0 }

    prim_box(dx + 3.0, dy + 3.0, mw, mh, 0x05070A)
    prim_box(dx, dy, mw, mh, 0x161B22)
    prim_stroke(dx, dy, mw, mh, 0x58A6FF)

    prim_box(dx + 1.0, dy + 1.0, mw - 2.0, 20.0, 0x1F2937)
    ui_label(title_id, dx + 8.0, dy + 14.0, 8.0, 0x79C0FF)

    res = 0.0
    iy = dy + 23.0
    ih = 21.0

    // 1. Editar en Editor (S1)
    if (ui_hit_test(mx, my, dx + 2.0, iy, mw - 4.0, ih) == 1.0) {
        prim_box(dx + 2.0, iy, mw - 4.0, ih, 0x1F6FEB)
        if (click == 1.0) { res = 1.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("⚡ Editar en S1", dx + 10.0, iy + 14.0, 9.0, 0xFFFFFF)
    iy = iy + ih

    // 2. Copiar directiva import
    if (ui_hit_test(mx, my, dx + 2.0, iy, mw - 4.0, ih) == 1.0) {
        prim_box(dx + 2.0, iy, mw - 4.0, ih, 0x1F6FEB)
        if (click == 1.0) { res = 2.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("📥 Copiar import", dx + 10.0, iy + 14.0, 9.0, 0x3FB950)
    iy = iy + ih

    // 3. Renombrar
    if (ui_hit_test(mx, my, dx + 2.0, iy, mw - 4.0, ih) == 1.0) {
        prim_box(dx + 2.0, iy, mw - 4.0, ih, 0x1F6FEB)
        if (click == 1.0) { res = 3.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("✏ Renombrar", dx + 10.0, iy + 14.0, 9.0, 0xD29922)
    iy = iy + ih

    // 4. Eliminar
    if (ui_hit_test(mx, my, dx + 2.0, iy, mw - 4.0, ih) == 1.0) {
        prim_box(dx + 2.0, iy, mw - 4.0, ih, 0xDA3633)
        if (click == 1.0) { res = 4.0 } else { 1.0 }
    } else { 1.0 }
    ui_label("🗑 Eliminar", dx + 10.0, iy + 14.0, 9.0, 0xF85149)

    // Clic fuera cierra el menú
    if ((click == 1.0) && (res == 0.0) && (ui_hit_test(mx, my, dx, dy, mw, mh) == 0.0)) {
        res = 9.0
    } else { 1.0 }

    res
}
