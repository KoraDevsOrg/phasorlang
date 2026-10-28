// ===============================================================================
// LIB/UI_SCREEN_EDITOR.PH — MÓDULO AISLADO: SCREEN 1 (EDITOR DE CÓDIGO)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Encapsulación completa: Viewport aislado, Toolbar, Gutter y Líneas de Código
// Invariante Estricto: Zero-GC a 120 FPS Nativos (cero asignación en heap)
// ===============================================================================

render_editor_toolbar(hx, hy, w) = {
    rect(hx + 1.0, hy + 28.0, w, 26.0, 0x161B22)
    line(hx + 1.0, hy + 54.0, hx + w + 1.0, hy + 54.0, 0x30363D)
    text("Archivo", hx + 12.0, hy + 35.0, 9, 0x8B949E)
    text("Editar", hx + 65.0, hy + 35.0, 9, 0x8B949E)
    text("Ver", hx + 110.0, hy + 35.0, 9, 0x8B949E)
    text("Compilar HTML", hx + 140.0, hy + 35.0, 9, 0x3FB950)
    1.0
}

render_screen_editor_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(1.0)
        cw = win_cw(1.0)
        ch = win_ch(1.0)

        // 1. Fondo del área cliente
        rect(hx + 1.0, hy + 54.0, w - 2.0, h - 55.0, 0x090D13)

        // 2. Límites estrictos del área de clipping
        ct = hy + 54.0
        cb = (hy + h) - 10.0
        cr = (hx + w) - 8.0
        ty = hy + 66.0 - dy
        tx = hx + 42.0 - dx
        gx = hx + 12.0

        // 3. Renderizado de líneas de código fuente (literales para emisión segura de string tokens)
        if (vp_line_visible(ty, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("// CHRONOS IDE — HITO 5 AUTONOMO 100% PHASORLANG", tx, ty, 9, 0x6E7681) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 18.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("import \"lib/ui_spatial_main.ph\"", tx, ty + 18.0, 9, 0x79C0FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 36.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("import \"lib/ui_window_frame.ph\"", tx, ty + 36.0, 9, 0x79C0FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 54.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("import \"lib/ui_viewport.ph\"", tx, ty + 54.0, 9, 0x79C0FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 72.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("import \"lib/ui_docking.ph\"", tx, ty + 72.0, 9, 0x79C0FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 90.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("signal t = 0.0", tx, ty + 90.0, 9, 0xF2CC60) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 108.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("screen main {", tx, ty + 108.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 126.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    sw = R250; sh = R251; pd = R254", tx, ty + 126.0, 9, 0x3FB950) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 144.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    left = R254; right = R248; mid = R249", tx, ty + 144.0, 9, 0x3FB950) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 162.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    spatial_main_render(sw, sh)", tx, ty + 162.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 180.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("    render_dock_ghost_preview(...)", tx, ty + 180.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }
        if (vp_line_visible(ty + 198.0, ct, cb) == 1.0) {
            if (tx >= (hx + 2.0)) { if (tx < cr) { text("}", tx, ty + 198.0, 9, 0x58A6FF) } else { 1.0 } } else { 1.0 }
        } else { 1.0 }

        // 4. Gutter opaco y números de línea (dibujados después para enmascarar texto scrolled a la izquierda)
        rect(hx + 1.0, hy + 54.0, 36.0, h - 55.0, 0x0C1017)
        line(hx + 37.0, hy + 54.0, hx + 37.0, hy + h - 1.0, 0x21262D)

        if (vp_line_visible(ty, ct, cb) == 1.0) { text("1", gx, ty, 9, 0x484F58) } else { 1.0 }
        if (vp_line_visible(ty + 18.0, ct, cb) == 1.0) { text("2", gx, ty + 18.0, 9, 0x484F58) } else { 1.0 }
        if (vp_line_visible(ty + 36.0, ct, cb) == 1.0) { text("3", gx, ty + 36.0, 9, 0x484F58) } else { 1.0 }
        if (vp_line_visible(ty + 54.0, ct, cb) == 1.0) { text("4", gx, ty + 54.0, 9, 0x484F58) } else { 1.0 }
        if (vp_line_visible(ty + 72.0, ct, cb) == 1.0) { text("5", gx, ty + 72.0, 9, 0xF2CC60) } else { 1.0 }
        if (vp_line_visible(ty + 90.0, ct, cb) == 1.0) { text("6", gx, ty + 90.0, 9, 0x58A6FF) } else { 1.0 }
        if (vp_line_visible(ty + 108.0, ct, cb) == 1.0) { text("7", gx, ty + 108.0, 9, 0x3FB950) } else { 1.0 }
        if (vp_line_visible(ty + 126.0, ct, cb) == 1.0) { text("8", gx, ty + 126.0, 9, 0x3FB950) } else { 1.0 }
        if (vp_line_visible(ty + 144.0, ct, cb) == 1.0) { text("9", gx, ty + 144.0, 9, 0x79C0FF) } else { 1.0 }
        if (vp_line_visible(ty + 162.0, ct, cb) == 1.0) { text("10", gx - 5.0, ty + 162.0, 9, 0x58A6FF) } else { 1.0 }
        if (vp_line_visible(ty + 180.0, ct, cb) == 1.0) { text("11", gx - 5.0, ty + 180.0, 9, 0x58A6FF) } else { 1.0 }
        if (vp_line_visible(ty + 198.0, ct, cb) == 1.0) { text("12", gx - 5.0, ty + 198.0, 9, 0x58A6FF) } else { 1.0 }

        // 5. Barra de herramientas superior
        render_editor_toolbar(hx, hy, w - 2.0)

        // 6. Barras de scroll 2D
        render_viewport_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act)
        1.0
    }
}
