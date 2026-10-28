// ===============================================================================
// LIB/UI_DOCKING.PH — HITO 5: DOCKING, SNAP MAGNÉTICO Y SPLITTERS
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Modular de Acoplamiento Dinámico Multi-Ventana a 120 FPS Nativos
// Invariante Estricto: Zero-GC (0 bytes en Heap, solo aritmética escalar PVM)
//
// Zonas de Docking:
//   0.0 = DOCK_NONE     (Flotante libre)
//   1.0 = DOCK_LEFT     (Mitad izquierda: x=0, y=28, w=sw/2, h=sh-52)
//   2.0 = DOCK_RIGHT    (Mitad derecha:   x=sw/2, y=28, w=sw/2, h=sh-52)
//   3.0 = DOCK_TOP      (Mitad superior:  x=0, y=28, w=sw, h=(sh-52)/2)
//   4.0 = DOCK_BOTTOM   (Mitad inferior:  x=0, y=28+(sh-52)/2, w=sw, h=(sh-52)/2)
//   5.0 = DOCK_MAXIMIZE (Pantalla completa en área de trabajo: x=0, y=28, w=sw, h=sh-52)
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. CONSTANTES Y ÁREA DE TRABAJO (USABLE WORKSPACE)
// -------------------------------------------------------------------------------
dock_work_y() = { 28.0 }

dock_work_h(sh) = {
    res = sh - 52.0
    if (res < 100.0) { res = 100.0 } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 2. DETECCIÓN DE ZONAS CALIENTES DE DOCKING (DURING DRAG)
// -------------------------------------------------------------------------------
dock_detect_zone(mx, my, sw, sh, delta) = {
    res = 0.0
    if (sw >= 768.0) {
        if (my <= (28.0 + delta)) {
            res = 5.0
        } else {
            if (mx <= delta) {
                res = 1.0
            } else {
                if (mx >= (sw - delta)) {
                    res = 2.0
                } else {
                    if (my >= (sh - 24.0 - delta)) {
                        res = 4.0
                    } else { 1.0 }
                }
            }
        }
    } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 3. GEOMETRÍA PRECISIÓN DE CADA ZONA DE DOCKING (ZERO-GC)
// -------------------------------------------------------------------------------
dock_zone_x(dir, sw) = {
    res = 0.0
    if (dir == 2.0) { res = sw * 0.5 } else { 1.0 }
    res
}

dock_zone_y(dir, sh) = {
    res = 28.0
    if (dir == 4.0) {
        res = 28.0 + (dock_work_h(sh) * 0.5)
    } else { 1.0 }
    res
}

dock_zone_w(dir, sw) = {
    res = sw
    if (dir == 1.0) { res = sw * 0.5 } else { 1.0 }
    if (dir == 2.0) { res = sw * 0.5 } else { 1.0 }
    res
}

dock_zone_h(dir, sh) = {
    res = dock_work_h(sh)
    if (dir == 3.0) { res = res * 0.5 } else { 1.0 }
    if (dir == 4.0) { res = res * 0.5 } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 4. SNAP MAGNÉTICO (MAGNETIC EDGE SNAPPING)
// -------------------------------------------------------------------------------
dock_snap_edge(val, target, delta) = {
    res = val
    if (abs(val - target) <= delta) {
        res = target
    } else { 1.0 }
    res
}

dock_snap_viewport_x(x, w, sw, delta) = {
    target = sw - w
    res = x
    if (abs(x) <= delta) {
        res = 0.0
    } else {
        if (abs(x - target) <= delta) {
            res = target
        } else { 1.0 }
    }
    res
}

dock_snap_viewport_y(y, h, sh, delta) = {
    target = (sh - 24.0) - h
    res = y
    if (abs(y - 28.0) <= delta) {
        res = 28.0
    } else {
        if (abs(y - target) <= delta) {
            res = target
        } else { 1.0 }
    }
    res
}

dock_snap_window_neighbor_x(wx, ww, hx, w, delta) = {
    target = hx - ww
    res = dock_snap_edge(wx, target, delta)
    if (res == wx) {
        target = hx + w
        res = dock_snap_edge(wx, target, delta)
    } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 5. SPLITTERS INTER-VENTANA (DIVISORES ARRASTRABLES)
// -------------------------------------------------------------------------------
splitter_hit_v(x, y, h, mx, my, delta) = {
    res = 0.0
    if (mx >= (x - delta)) {
        if (mx <= (x + delta)) {
            if (my >= y) {
                if (my <= (y + h)) {
                    res = 1.0
                } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    res
}

splitter_calc_w1(val, w, target, delta) = {
    m = (w + target) - delta
    res = w + val
    if (res < delta) { res = delta } else { 1.0 }
    if (res > m) { res = m } else { 1.0 }
    res
}

splitter_calc_w2(w, target) = {
    target - w
}

// -------------------------------------------------------------------------------
// 6. RENDERIZADO VISUAL DEL GHOST DOCKING PREVIEW Y SPLITTER (ZERO-GC)
// -------------------------------------------------------------------------------
render_dock_ghost_preview(dir, sw, sh) = {
    if (dir > 0.0) {
        hx = dock_zone_x(dir, sw)
        hy = dock_zone_y(dir, sh)
        w = dock_zone_w(dir, sw)
        h = dock_zone_h(dir, sh)

        rect(hx + 4.0, hy + 4.0, w - 8.0, h - 8.0, 0x0D223A)
        line(hx + 4.0, hy + 4.0, (hx + w) - 4.0, hy + 4.0, 0x58A6FF)
        line(hx + 4.0, (hy + h) - 4.0, (hx + w) - 4.0, (hy + h) - 4.0, 0x58A6FF)
        line(hx + 4.0, hy + 4.0, hx + 4.0, (hy + h) - 4.0, 0x58A6FF)
        line((hx + w) - 4.0, hy + 4.0, (hx + w) - 4.0, (hy + h) - 4.0, 0x58A6FF)
    } else { 1.0 }
    1.0
}

render_splitter_bar(x, y, h, val) = {
    res = 0x21262D
    if (val == 1.0) { res = 0x58A6FF } else { 1.0 }
    rect(x - 2.0, y, 4.0, h, res)
    1.0
}
