// ===============================================================================
// LIB/UI_SCREEN_EXPLORER.PH — MÓDULO AISLADO: SCREEN 2 (EXPLORADOR DE ARCHIVOS)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Encapsulación completa: Viewport aislado, Árbol de Directorios y Archivos
// Invariante Estricto: Zero-GC a 120 FPS Nativos (cero asignación en heap)
// ===============================================================================

render_screen_explorer_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(2.0)
        cw = win_cw(2.0)
        ch = win_ch(2.0)

        // 1. Fondo del área cliente
        rect(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0, 0x090D13)

        // 2. Límites estrictos del área de clipping
        ct = hy + 28.0
        cb = (hy + h) - 10.0
        cl = hx + 4.0
        cr = (hx + w) - 8.0
        ty = hy + 40.0 - dy
        tx = hx + 12.0 - dx

        // 3. Renderizado de elementos del árbol (literales para emisión segura de string tokens)
        if (vp_line_visible(ty, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("📁 PROYECTO: SketchWarePro", tx, ty, 9, 0xF2CC60) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 20.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("v 📁 samples/", tx + 10.0, ty + 20.0, 9, 0xF2CC60) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 38.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    ⚡ chronos_ide.ph (Hito 5)", tx + 10.0, ty + 38.0, 9, 0x3FB950) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 56.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    ⚡ fractal_ui.ph", tx + 10.0, ty + 56.0, 9, 0xF2CC60) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 74.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("v 📁 lib/", tx + 10.0, ty + 74.0, 9, 0xF2CC60) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 92.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    ⚡ ui_spatial_main.ph", tx + 10.0, ty + 92.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 110.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    ⚡ ui_window_frame.ph", tx + 10.0, ty + 110.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 128.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    ⚡ ui_viewport.ph", tx + 10.0, ty + 128.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 146.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    ⚡ ui_docking.ph", tx + 10.0, ty + 146.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 164.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("v 📁 docs/", tx + 10.0, ty + 164.0, 9, 0xF2CC60) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 182.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    📚 architecture_guidelines.md", tx + 10.0, ty + 182.0, 9, 0xFA7970) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 200.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    🌐 chronos_ide.html", tx + 10.0, ty + 200.0, 9, 0x79C0FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }

        // 4. Barras de scroll 2D
        render_viewport_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act)
        1.0
    }
}
