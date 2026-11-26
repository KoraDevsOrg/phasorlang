// ============================================================================
// PHASORLANG STORE - GRADO 2: CUADRICULA RESPONSIVA ZERO-GC
// Se ajusta al ancho del viewport (sw) con margen de diseño y detección O(1)
// ============================================================================
grid_board_w(sw, pad, max_w) = {
    bw = sw - (pad * 2.0)
    if (bw < 180.0) { bw = 180.0 } else { 0.0 }
    if (bw > max_w) { bw = max_w } else { 0.0 }
    bw
}

grid_origin_x(sw, bw) = {
    ox = (sw - bw) * 0.5
    if (ox < 8.0) { ox = 8.0 } else { 0.0 }
    ox
}

grid_draw(gx, gy, cols, rows, cell, bg_col, line_col, border_col) = {
    bw = cols * cell
    bh = rows * cell
    rect(gx, gy, bw, bh, bg_col)

    // Líneas verticales internas
    i = 1.0
    while (i < cols) {
        lx = gx + (i * cell)
        line(lx, gy, lx, gy + bh, line_col)
        i = i + 1.0
    }

    // Líneas horizontales internas
    j = 1.0
    while (j < rows) {
        ly = gy + (j * cell)
        line(gx, ly, gx + bw, ly, line_col)
        j = j + 1.0
    }

    // Marco exterior del tablero
    line(gx, gy, gx + bw, gy, border_col)
    line(gx, gy + bh, gx + bw, gy + bh, border_col)
    line(gx, gy, gx, gy + bh, border_col)
    line(gx + bw, gy, gx + bw, gy + bh, border_col)
    1.0
}

// Retorna índice 0..(cols*rows - 1) si el toque cae dentro, o -1.0 si está fuera
grid_hit_index(px, py, gx, gy, cols, rows, cell) = {
    idx = 0.0 - 1.0
    bw = cols * cell
    bh = rows * cell
    if (px >= gx) {
        if (px < (gx + bw)) {
            if (py >= gy) {
                if (py < (gy + bh)) {
                    dx = px - gx
                    dy = py - gy
                    c = (dx - (dx % cell)) / cell
                    r = (dy - (dy % cell)) / cell
                    idx = (r * cols) + c
                } else { 0.0 }
            } else { 0.0 }
        } else { 0.0 }
    } else { 0.0 }
    idx
}
