// ============================================================================
// PHASORLANG STORE - GRADO 1: UI BASE REUTILIZABLE (ZERO-GC)
// ============================================================================
draw_btn(x, y, w, h, fill_col, border_col, lbl, tx, ty, txt_col) = {
    rect(x, y, w, h, fill_col)
    line(x, y, x + w, y, border_col)
    line(x, y + h, x + w, y + h, border_col)
    line(x, y, x, y + h, border_col)
    line(x + w, y, x + w, y + h, border_col)
    text(lbl, tx, ty, 10.0, txt_col)
    1.0
}

hit_rect(px, py, rx, ry, rw, rh) = {
    res = 0.0
    if (px >= rx) {
        if (px <= (rx + rw)) {
            if (py >= ry) {
                if (py <= (ry + rh)) {
                    res = 1.0
                } else { 0.0 }
            } else { 0.0 }
        } else { 0.0 }
    } else { 0.0 }
    res
}
