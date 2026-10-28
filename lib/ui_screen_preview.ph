// ===============================================================================
// LIB/UI_SCREEN_PREVIEW.PH — MÓDULO AISLADO: SCREEN 3 (LIVE PREVIEW PVM)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Encapsulación completa: Viewport aislado, Fasor Circular Reactivo y Monitor de Hardware
// Invariante Estricto: Zero-GC a 120 FPS Nativos (cero asignación en heap)
// ===============================================================================

render_screen_preview_content(hx, hy, w, h, is_min, dx, dy, act, val, gp_conn, right_click) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(3.0)
        cw = win_cw(3.0)
        ch = win_ch(3.0)

        // 1. Fondo del área cliente
        rect(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0, 0x070A0E)

        // 2. Límites estrictos del área de clipping
        ct = hy + 28.0
        cb = (hy + h) - 10.0
        cl = hx + 4.0
        cr = (hx + w) - 8.0

        // 3. Fasor Circular Reactivo (120 FPS Nativos)
        tx = hx + 125.0 - dx
        ty = hy + 80.0 - dy
        if (vp_line_visible(ty - 32.0, ct, cb) == 1.0) {
            if (vp_line_visible(ty + 32.0, ct, cb) == 1.0) {
                if ((tx - 32.0) >= (hx + 2.0)) { if ((tx + 32.0) <= cr) {
                    circle(tx, ty, 32.0, 0x1F6FEB)
                    circle(tx, ty, 24.0, 0x238636)
                    ang = val * 0.05
                    fx = tx + (cos(ang) * 24.0)
                    fy = ty + (sin(ang) * 24.0)
                    line(tx, ty, fx, fy, 0x58A6FF)
                    circle(fx, fy, 3.5, 0x3FB950)
                } else { 1.0 } } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }

        // 4. Telemetría de hardware directo PVM (sin dependencias externas)
        tx = hx + 16.0 - dx
        ty = hy + 138.0 - dy
        if (vp_line_visible(ty, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("MONITOR HARDWARE DIRECTO (PVM)", tx, ty, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 18.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) {
                if (gp_conn > 0.0) {
                    text("Gamepad USB: CONECTADO [R240=1.0]", tx, ty + 18.0, 8, 0x3FB950)
                } else {
                    text("Gamepad USB: Desconectado [R240=0.0]", tx, ty + 18.0, 8, 0x8B949E)
                }
            } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 36.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) {
                if (right_click > 0.0) {
                    text("Clic Secundario (Der): ACTIVO [R248]", tx, ty + 36.0, 8, 0xF2CC60)
                } else {
                    text("Mouse: Izq=R254 | Der=R248 | Med=R249", tx, ty + 36.0, 8, 0x8B949E)
                }
            } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 54.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("Rueda Scroll 2D: R255 (Y) / R247 (X)", tx, ty + 54.0, 8, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 72.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("Zero-GC: 0 pausas | 120 FPS Nativos", tx, ty + 72.0, 8, 0x3FB950) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }

        // 5. Barras de scroll 2D
        render_viewport_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act)
        1.0
    }
}
