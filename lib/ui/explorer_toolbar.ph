// Grado 2: Menú superior estilo VS Code conectado a lib/fs/*
import "lib/core/primitives.ph"
import "lib/ui/button.ph"
import "lib/fs/abrir.ph"
import "lib/fs/crear.ph"
import "lib/fs/github.ph"

ui_explorer_toolbar(ox, oy, ow, mx, my, click) = {
    prim_box(ox, oy, ow, 34.0, 0x161B22)
    line(ox, oy + 34.0, ox + ow, oy + 34.0, 0x30363D)

    gap = 4.0
    bw = (ow - (gap * 6.0)) * 0.2
    if (bw < 46.0) { bw = 46.0 } else { 1.0 }
    by = oy + 4.0
    bh = 26.0

    cx = ox + gap
    ui_button("📄 Abrir", cx, by, bw, bh, 0x21262D, 0x58A6FF, 0xFFFFFF, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, bh) == 1.0) && (click == 1.0)) {
        fs_abrir_archivo()
    } else { 1.0 }

    cx = cx + bw + gap
    ui_button("📂 Proy", cx, by, bw, bh, 0x21262D, 0x58A6FF, 0xFFFFFF, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, bh) == 1.0) && (click == 1.0)) {
        fs_abrir_proyecto()
    } else { 1.0 }

    cx = cx + bw + gap
    ui_button("➕ .ph", cx, by, bw, bh, 0x238636, 0x3FB950, 0xFFFFFF, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, bh) == 1.0) && (click == 1.0)) {
        fs_nuevo_archivo()
    } else { 1.0 }

    cx = cx + bw + gap
    ui_button("📁 +Dir", cx, by, bw, bh, 0x21262D, 0xD29922, 0xFFFFFF, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, bh) == 1.0) && (click == 1.0)) {
        fs_nueva_carpeta()
    } else { 1.0 }

    cx = cx + bw + gap
    ui_button("🌐 Git", cx, by, bw, bh, 0x1F6FEB, 0x79C0FF, 0xFFFFFF, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, bh) == 1.0) && (click == 1.0)) {
        fs_sincronizar_github()
    } else { 1.0 }

    1.0
}
