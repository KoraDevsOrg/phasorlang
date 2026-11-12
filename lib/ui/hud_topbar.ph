// Grado 2: Barra superior fija compuesta por botones atómicos
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"
import "lib/spatial/gesture_lock.ph"

topbar_handle_click(mx, my, sw, sh) = {
    hit = 0.0
    if (my <= 34.0) {
        hit = 1.0
        cw = sw
        ch = sh
        if (ui_hit_test(mx, my, 96.0, 4.0, 32.0, 26.0) == 1.0) {
            torus_goto(0.0, 0.0, cw, ch)
        } else { 1.0 }
        if (ui_hit_test(mx, my, 132.0, 4.0, 32.0, 26.0) == 1.0) {
            torus_goto(0.0, 1.0, cw, ch)
        } else { 1.0 }
        if (ui_hit_test(mx, my, 168.0, 4.0, 32.0, 26.0) == 1.0) {
            torus_goto(1.0, 0.0, cw, ch)
        } else { 1.0 }
        if (ui_hit_test(mx, my, 204.0, 4.0, 32.0, 26.0) == 1.0) {
            torus_goto(1.0, 1.0, cw, ch)
        } else { 1.0 }
        if (ui_hit_test(mx, my, sw - 76.0, 4.0, 70.0, 26.0) == 1.0) {
            if (force_mobile == 1.0) { force_mobile = 0.0 } else { force_mobile = 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    hit
}

topbar_render(sw) = {
    prim_box(0.0, 0.0, sw, 34.0, 0x0D1117)
    line(0.0, 34.0, sw, 34.0, 0x30363D)
    ui_label("⚡ CHRONOS", 10.0, 22.0, 11.0, 0x58A6FF)

    c1 = 0x161B22; if ((tor_col == 0.0) && (tor_row == 0.0)) { c1 = 0x1F6FEB } else { 1.0 }
    c2 = 0x161B22; if ((tor_col == 0.0) && (tor_row == 1.0)) { c2 = 0x1F6FEB } else { 1.0 }
    c3 = 0x161B22; if ((tor_col == 1.0) && (tor_row == 0.0)) { c3 = 0x1F6FEB } else { 1.0 }
    c4 = 0x161B22; if ((tor_col == 1.0) && (tor_row == 1.0)) { c4 = 0x1F6FEB } else { 1.0 }

    ui_button("S1", 96.0, 4.0, 32.0, 26.0, c1, 0x30363D, 0xFFFFFF, 10.0)
    ui_button("S2", 132.0, 4.0, 32.0, 26.0, c2, 0x30363D, 0xFFFFFF, 10.0)
    ui_button("S3", 168.0, 4.0, 32.0, 26.0, c3, 0x30363D, 0xFFFFFF, 10.0)
    ui_button("S4", 204.0, 4.0, 32.0, 26.0, c4, 0x30363D, 0xFFFFFF, 10.0)

    if (force_mobile == 1.0) {
        ui_button("📱 MÓVIL", sw - 76.0, 4.0, 70.0, 26.0, 0x238636, 0x3FB950, 0xFFFFFF, 9.0)
    } else {
        ui_button("🖥️ DESK", sw - 76.0, 4.0, 70.0, 26.0, 0x1F6FEB, 0x58A6FF, 0xFFFFFF, 9.0)
    }
}
