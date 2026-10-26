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
dock_work_h(dk_sh) = {
    dh = dk_sh - 52.0
    if (dh < 100.0) { dh = 100.0 } else { 1.0 }
    dh
}

// -------------------------------------------------------------------------------
// 2. DETECCIÓN DE ZONAS CALIENTES DE DOCKING (DURING DRAG)
// -------------------------------------------------------------------------------
// Retorna la zona detectada según la posición del puntero (mx, my) y el margen umbral
dock_detect_zone(dk_mx, dk_my, dk_sw, dk_sh, dk_margin) = {
    found_zone = 0.0
    if (dk_sw >= 768.0) {
        // Zona superior -> Maximizar
        if (dk_my <= (28.0 + dk_margin)) {
            found_zone = 5.0
        } else {
            // Zona izquierda -> Mitad izquierda
            if (dk_mx <= dk_margin) {
                found_zone = 1.0
            } else {
                // Zona derecha -> Mitad derecha
                if (dk_mx >= (dk_sw - dk_margin)) {
                    found_zone = 2.0
                } else {
                    // Zona inferior -> Mitad inferior
                    if (dk_my >= (dk_sh - 24.0 - dk_margin)) {
                        found_zone = 4.0
                    } else { 1.0 }
                }
            }
        }
    } else { 1.0 }
    found_zone
}

// -------------------------------------------------------------------------------
// 3. GEOMETRÍA PRECISIÓN DE CADA ZONA DE DOCKING (ZERO-GC)
// -------------------------------------------------------------------------------
dock_zone_x(dk_zone, dk_sw) = {
    res_x = 0.0
    if (dk_zone == 2.0) { res_x = dk_sw * 0.5 } else { 1.0 }
    res_x
}

dock_zone_y(dk_zone, dk_sh) = {
    res_y = 28.0
    if (dk_zone == 4.0) {
        h_work = dock_work_h(dk_sh)
        res_y = 28.0 + (h_work * 0.5)
    } else { 1.0 }
    res_y
}

dock_zone_w(dk_zone, dk_sw) = {
    res_w = dk_sw
    if (dk_zone == 1.0) { res_w = dk_sw * 0.5 } else { 1.0 }
    if (dk_zone == 2.0) { res_w = dk_sw * 0.5 } else { 1.0 }
    res_w
}

dock_zone_h(dk_zone, dk_sh) = {
    h_work = dock_work_h(dk_sh)
    res_h = h_work
    if (dk_zone == 3.0) { res_h = h_work * 0.5 } else { 1.0 }
    if (dk_zone == 4.0) { res_h = h_work * 0.5 } else { 1.0 }
    res_h
}

// -------------------------------------------------------------------------------
// 4. SNAP MAGNÉTICO (MAGNETIC EDGE SNAPPING)
// -------------------------------------------------------------------------------
// Imanta un valor a un objetivo si la diferencia absoluta está dentro del umbral
dock_snap_edge(curr_val, target_val, snap_thresh) = {
    diff = curr_val - target_val
    res_snap = curr_val
    if (diff >= (0.0 - snap_thresh)) {
        if (diff <= snap_thresh) {
            res_snap = target_val
        } else { 1.0 }
    } else { 1.0 }
    res_snap
}

// Snap horizontal a bordes del viewport (0.0 o sw - ww)
dock_snap_viewport_x(curr_x, win_w, dk_sw, snap_thresh) = {
    snapped = dock_snap_edge(curr_x, 0.0, snap_thresh)
    if (snapped == curr_x) {
        target_right = dk_sw - win_w
        snapped = dock_snap_edge(curr_x, target_right, snap_thresh)
    } else { 1.0 }
    snapped
}

// Snap vertical a bordes del viewport (28.0 o sh - 24.0 - wh)
dock_snap_viewport_y(curr_y, win_h, dk_sh, snap_thresh) = {
    snapped = dock_snap_edge(curr_y, 28.0, snap_thresh)
    if (snapped == curr_y) {
        target_bottom = (dk_sh - 24.0) - win_h
        snapped = dock_snap_edge(curr_y, target_bottom, snap_thresh)
    } else { 1.0 }
    snapped
}

// Snap magnético entre bordes de dos ventanas vecinas (A y B)
// Imanta el borde derecho de A con el borde izquierdo de B, o viceversa
dock_snap_window_neighbor_x(ax, aw, bx, bw, snap_thresh) = {
    // Caso 1: A se acopla a la izquierda de B (ax + aw = bx -> ax = bx - aw)
    tgt_left = bx - aw
    res_neighbor = dock_snap_edge(ax, tgt_left, snap_thresh)
    // Caso 2: A se acopla a la derecha de B (ax = bx + bw)
    if (res_neighbor == ax) {
        tgt_right = bx + bw
        res_neighbor = dock_snap_edge(ax, tgt_right, snap_thresh)
    } else { 1.0 }
    res_neighbor
}

// -------------------------------------------------------------------------------
// 5. SPLITTERS INTER-VENTANA (DIVISORES ARRASTRABLES)
// -------------------------------------------------------------------------------
// Detecta si el puntero se encuentra en la franja del splitter entre dos ventanas
splitter_hit_v(split_x, split_y, split_h, dk_mx, dk_my, hit_margin) = {
    is_hit = 0.0
    if (dk_mx >= (split_x - hit_margin)) {
        if (dk_mx <= (split_x + hit_margin)) {
            if (dk_my >= split_y) {
                if (dk_my <= (split_y + split_h)) {
                    is_hit = 1.0
                } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    is_hit
}

// Redistribuye los anchos w1 y w2 dado un delta de movimiento del splitter,
// manteniendo constante la suma total (w1 + w2) y respetando límites mínimos.
splitter_calc_w1(delta_x, orig_w1, orig_w2, min_w) = {
    max_w1 = (orig_w1 + orig_w2) - min_w
    nw1 = orig_w1 + delta_x
    if (nw1 < min_w) { nw1 = min_w } else { 1.0 }
    if (nw1 > max_w1) { nw1 = max_w1 } else { 1.0 }
    nw1
}

splitter_calc_w2(new_w1, orig_w1, orig_w2) = {
    total_w = orig_w1 + orig_w2
    nw2 = total_w - new_w1
    nw2
}

// -------------------------------------------------------------------------------
// 6. RENDERIZADO VISUAL DEL GHOST DOCKING PREVIEW Y SPLITTER (ZERO-GC)
// -------------------------------------------------------------------------------
render_dock_ghost_preview(dk_zone, dk_sw, dk_sh) = {
    if (dk_zone > 0.0) {
        gx = dock_zone_x(dk_zone, dk_sw)
        gy = dock_zone_y(dk_zone, dk_sh)
        gw = dock_zone_w(dk_zone, dk_sw)
        gh = dock_zone_h(dk_zone, dk_sh)

        // Silueta translúcida de previsualización magnética
        rect(gx + 4.0, gy + 4.0, gw - 8.0, gh - 8.0, 0x0D223A)
        // Borde cian brillante punteado/delimitado
        line(gx + 4.0, gy + 4.0, (gx + gw) - 4.0, gy + 4.0, 0x58A6FF)
        line(gx + 4.0, (gy + gh) - 4.0, (gx + gw) - 4.0, (gy + gh) - 4.0, 0x58A6FF)
        line(gx + 4.0, gy + 4.0, gx + 4.0, (gy + gh) - 4.0, 0x58A6FF)
        line((gx + gw) - 4.0, gy + 4.0, (gx + gw) - 4.0, (gy + gh) - 4.0, 0x58A6FF)
    } else { 1.0 }
    1.0
}

render_splitter_bar(split_x, split_y, split_h, is_active) = {
    col = 0x21262D
    if (is_active == 1.0) { col = 0x58A6FF } else { 1.0 }
    rect(split_x - 2.0, split_y, 4.0, split_h, col)
    1.0
}
