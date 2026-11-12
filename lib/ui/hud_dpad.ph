// Grado 2: D-Pad toroidal flotante con minimapa 2x2
import "lib/core/primitives.ph"
import "lib/ui/button.ph"
import "lib/spatial/gesture_lock.ph"

dpad_handle_click(mx, my, sw, sh) = {
    cx = sw - 64.0
    cy = sh - 68.0
    hit = 0.0
    if (ui_hit_test(mx, my, cx - 50.0, cy - 50.0, 100.0, 100.0) == 1.0) {
        hit = 1.0
        // Arriba
        if (ui_hit_test(mx, my, cx - 16.0, cy - 48.0, 32.0, 28.0) == 1.0) {
            torus_goto(tor_col, tor_row - 1.0, sw, sh)
        } else { 1.0 }
        // Abajo
        if (ui_hit_test(mx, my, cx - 16.0, cy + 20.0, 32.0, 28.0) == 1.0) {
            torus_goto(tor_col, tor_row + 1.0, sw, sh)
        } else { 1.0 }
        // Izquierda
        if (ui_hit_test(mx, my, cx - 48.0, cy - 16.0, 28.0, 32.0) == 1.0) {
            torus_goto(tor_col - 1.0, tor_row, sw, sh)
        } else { 1.0 }
        // Derecha
        if (ui_hit_test(mx, my, cx + 20.0, cy - 16.0, 28.0, 32.0) == 1.0) {
            torus_goto(tor_col + 1.0, tor_row, sw, sh)
        } else { 1.0 }
    } else { 1.0 }
    hit
}

dpad_render(sw, sh) = {
    cx = sw - 64.0
    cy = sh - 68.0
    circle(cx, cy, 50.0, 0x162234)

    ui_button("^", cx - 16.0, cy - 48.0, 32.0, 28.0, 0x1F2937, 0x58A6FF, 0xFFFFFF, 11.0)
    ui_button("v", cx - 16.0, cy + 20.0, 32.0, 28.0, 0x1F2937, 0x58A6FF, 0xFFFFFF, 11.0)
    ui_button("<", cx - 48.0, cy - 16.0, 28.0, 32.0, 0x1F2937, 0x58A6FF, 0xFFFFFF, 11.0)
    ui_button(">", cx + 20.0, cy - 16.0, 28.0, 32.0, 0x1F2937, 0x58A6FF, 0xFFFFFF, 11.0)

    // Minimapa central 2x2
    prim_box(cx - 14.0, cy - 14.0, 28.0, 28.0, 0x0D1117)
    prim_stroke(cx - 14.0, cy - 14.0, 28.0, 28.0, 0x3FB950)

    m00 = 0x30363D; if ((tor_col == 0.0) && (tor_row == 0.0)) { m00 = 0x3FB950 } else { 1.0 }
    m10 = 0x30363D; if ((tor_col == 1.0) && (tor_row == 0.0)) { m10 = 0x3FB950 } else { 1.0 }
    m01 = 0x30363D; if ((tor_col == 0.0) && (tor_row == 1.0)) { m01 = 0x3FB950 } else { 1.0 }
    m11 = 0x30363D; if ((tor_col == 1.0) && (tor_row == 1.0)) { m11 = 0x3FB950 } else { 1.0 }

    prim_box(cx - 11.0, cy - 11.0, 9.0, 9.0, m00)
    prim_box(cx + 2.0,  cy - 11.0, 9.0, 9.0, m10)
    prim_box(cx - 11.0, cy + 2.0,  9.0, 9.0, m01)
    prim_box(cx + 2.0,  cy + 2.0,  9.0, 9.0, m11)
}
