// Grado 2: Menú superior estilo VS Code (Abrir archivo, Proyecto, Nuevo, GitHub)
import "lib/core/primitives.ph"
import "lib/ui/button.ph"

// Retorna: 0=Nada, 1=Abrir Archivo, 2=Abrir Proyecto, 3=+Archivo, 4=+Carpeta, 5=GitHub
ui_explorer_toolbar(ox, oy, ow, mx, my, click) = {
    prim_box(ox, oy, ow, 32.0, 0x161B22)
    line(ox, oy + 32.0, ox + ow, oy + 32.0, 0x30363D)

    act = 0.0
    bw = 58.0
    gap = 4.0
    cx = ox + 6.0
    by = oy + 4.0

    ui_button("📄 Abrir", cx, by, bw, 24.0, 0x21262D, 0x30363D, 0xE6EDF3, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, 24.0) == 1.0) && (click == 1.0)) { act = 1.0 } else { 1.0 }
    cx = cx + bw + gap

    ui_button("📂 Proy", cx, by, bw, 24.0, 0x21262D, 0x30363D, 0xE6EDF3, 9.0)
    if ((ui_hit_test(mx, my, cx, by, bw, 24.0) == 1.0) && (click == 1.0)) { act = 2.0 } else { 1.0 }
    cx = cx + bw + gap

    ui_button("➕ .ph", cx, by, 52.0, 24.0, 0x238636, 0x3FB950, 0xFFFFFF, 9.0)
    if ((ui_hit_test(mx, my, cx, by, 52.0, 24.0) == 1.0) && (click == 1.0)) { act = 3.0 } else { 1.0 }
    cx = cx + 52.0 + gap

    ui_button("📁 +Dir", cx, by, 56.0, 24.0, 0x21262D, 0x30363D, 0xE6EDF3, 9.0)
    if ((ui_hit_test(mx, my, cx, by, 56.0, 24.0) == 1.0) && (click == 1.0)) { act = 4.0 } else { 1.0 }
    cx = cx + 56.0 + gap

    if (ow >= 320.0) {
        ui_button("🌐 Git", cx, by, 50.0, 24.0, 0x1F6FEB, 0x58A6FF, 0xFFFFFF, 9.0)
        if ((ui_hit_test(mx, my, cx, by, 50.0, 24.0) == 1.0) && (click == 1.0)) { act = 5.0 } else { 1.0 }
    } else { 1.0 }

    act
}
