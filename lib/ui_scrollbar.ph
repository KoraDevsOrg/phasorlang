// ===============================================================================
// LIB/UI_SCROLLBAR.PH — COMPONENTE MODULAR DE SCROLLBARS 2D (KORADEVS)
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// https://github.com/koradevsorg
//
// Componente Oficial de Barras de Desplazamiento Estilo Phasor IDE:
// - Estética Neón: Pista #161B22, Borde #21262D, Thumb #58A6FF, Activo #79C0FF
// - Ancho ergonómico de 8 px con radio visual y reserva de esquina (16 px)
// - Hit-testing amplio (14 px) para captura táctil y de ratón infalible
// - Cinemática de arrastre con offset de agarre y salto en pista
// - Soporte bidireccional X/Y para rueda de ratón (R255 / R247)
// - Disciplina PVM: Identificadores consolidados para evitar desbordamiento R229
// - Invariante Estricto Zero-GC a 120 FPS Nativos (Solo aritmética escalar PVM)
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. MÉTRICAS DEL VIEWPORT Y ÁREA CLIENTE (REUTILIZACIÓN ESTRICTA DE REGISTROS)
// -------------------------------------------------------------------------------
sb_client_w(w) = {
    res = w - 2.0
    if (res < 10.0) { res = 10.0 } else { 1.0 }
    res
}

sb_client_h(h, top) = {
    res = h - top - 1.0
    if (res < 10.0) { res = 10.0 } else { 1.0 }
    res
}

sb_needed_v(ch, clh) = {
    res = 0.0
    if (ch > clh) { res = 1.0 } else { 1.0 }
    res
}

sb_needed_h(cw, clw) = {
    res = 0.0
    if (cw > clw) { res = 1.0 } else { 1.0 }
    res
}

sb_max_scroll_x(cw, clw) = {
    delta = cw - clw
    if (delta < 0.0) { delta = 0.0 } else { 1.0 }
    delta
}

sb_max_scroll_y(ch, clh) = {
    delta = ch - clh
    if (delta < 0.0) { delta = 0.0 } else { 1.0 }
    delta
}

sb_clamp(val, max_sc) = {
    res = val
    if (res > max_sc) { res = max_sc } else { 1.0 }
    if (res < 0.0) { res = 0.0 } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 2. GEOMETRÍA DE PISTAS Y PULGARES (ANCHO CANÓNICO 8.0 PX, ESQUINA 16.0 PX)
// -------------------------------------------------------------------------------
sb_track_v_x(hx, w) = {
    (hx + w) - 11.0
}

sb_track_v_y(hy, top) = {
    hy + top + 2.0
}

sb_track_v_h(h, top) = {
    val = h - top - 20.0
    if (val < 18.0) { val = 18.0 } else { 1.0 }
    val
}

sb_track_h_x(hx) = {
    hx + 4.0
}

sb_track_h_y(hy, h) = {
    (hy + h) - 11.0
}

sb_track_h_w(w) = {
    val = w - 24.0
    if (val < 18.0) { val = 18.0 } else { 1.0 }
    val
}

// Tamaño proporcional del pulgar (mínimo 18.0 px)
sb_thumb_size(tl, clh, ch) = {
    sz = tl
    if (ch > clh) {
        if (ch > 0.0) {
            sz = tl * (clh / ch)
        } else { 1.0 }
    } else { 1.0 }
    if (sz < 18.0) { sz = 18.0 } else { 1.0 }
    if (sz > tl) { sz = tl } else { 1.0 }
    sz
}

// Desplazamiento del thumb en la pista
sb_thumb_offset(tl, sz, sc, max_sc) = {
    off = 0.0
    delta = tl - sz
    if (max_sc >= 1.0) {
        if (delta > 0.0) {
            val = sc / max_sc
            if (val < 0.0) { val = 0.0 } else { 1.0 }
            if (val > 1.0) { val = 1.0 } else { 1.0 }
            off = val * delta
        } else { 1.0 }
    } else { 1.0 }
    off
}

sb_scroll_from_pos(my, ty, tl, sz, max_sc) = {
    delta = tl - sz
    res = 0.0
    if (delta >= 1.0) {
        val = (my - ty) / delta
        if (val < 0.0) { val = 0.0 } else { 1.0 }
        if (val > 1.0) { val = 1.0 } else { 1.0 }
        res = val * max_sc
    } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 3. HIT TESTING (CAPTURA DE RATÓN Y TOUCH CON TOLERANCIA DE 14 PX)
// -------------------------------------------------------------------------------
sb_hit_test_v(hx, hy, w, h, top, cw, ch, sc_y, mx, my) = {
    clh = sb_client_h(h, top)
    val = sb_needed_v(ch, clh)
    hit = 0.0
    if (val == 1.0) {
        tx = sb_track_v_x(hx, w)
        ty = sb_track_v_y(hy, top)
        tl = sb_track_v_h(h, top)
        if (mx >= (tx - 3.0)) { if (mx <= (tx + 11.0)) {
            if (my >= ty) { if (my <= (ty + tl)) {
                max_sc = sb_max_scroll_y(ch, clh)
                sz = sb_thumb_size(tl, clh, ch)
                off = sb_thumb_offset(tl, sz, sc_y, max_sc)
                delta = ty + off
                hit = 2.0
                if (my >= delta) { if (my <= (delta + sz)) {
                    hit = 1.0
                } else { 1.0 } } else { 1.0 }
            } }
        } }
    } else { 1.0 }
    hit
}

sb_hit_test_h(hx, hy, w, h, top, cw, ch, sc_x, mx, my) = {
    clw = sb_client_w(w)
    val = sb_needed_h(cw, clw)
    hit = 0.0
    if (val == 1.0) {
        tx = sb_track_h_x(hx)
        ty = sb_track_h_y(hy, h)
        tl = sb_track_h_w(w)
        if (my >= (ty - 3.0)) { if (my <= (ty + 11.0)) {
            if (mx >= tx) { if (mx <= (tx + tl)) {
                max_sc = sb_max_scroll_x(cw, clw)
                sz = sb_thumb_size(tl, clw, cw)
                off = sb_thumb_offset(tl, sz, sc_x, max_sc)
                delta = tx + off
                hit = 2.0
                if (mx >= delta) { if (mx <= (delta + sz)) {
                    hit = 1.0
                } else { 1.0 } } else { 1.0 }
            } }
        } }
    } else { 1.0 }
    hit
}

// -------------------------------------------------------------------------------
// 4. CINEMÁTICA DE AGARRE Y ARRASTRE
// -------------------------------------------------------------------------------
sb_calc_grab_v(hx, hy, w, h, top, cw, ch, sc_y, hit_type, my) = {
    clh = sb_client_h(h, top)
    tl = sb_track_v_h(h, top)
    sz = sb_thumb_size(tl, clh, ch)
    val = sz * 0.5
    if (hit_type == 1.0) {
        ty = sb_track_v_y(hy, top)
        max_sc = sb_max_scroll_y(ch, clh)
        off = sb_thumb_offset(tl, sz, sc_y, max_sc)
        val = my - (ty + off)
    } else { 1.0 }
    val
}

sb_calc_grab_h(hx, hy, w, h, top, cw, ch, sc_x, hit_type, mx) = {
    clw = sb_client_w(w)
    tl = sb_track_h_w(w)
    sz = sb_thumb_size(tl, clw, cw)
    val = sz * 0.5
    if (hit_type == 1.0) {
        tx = sb_track_h_x(hx)
        max_sc = sb_max_scroll_x(cw, clw)
        off = sb_thumb_offset(tl, sz, sc_x, max_sc)
        val = mx - (tx + off)
    } else { 1.0 }
    val
}

sb_apply_drag_v(hx, hy, w, h, top, cw, ch, grab, my) = {
    clh = sb_client_h(h, top)
    tl = sb_track_v_h(h, top)
    ty = sb_track_v_y(hy, top)
    sz = sb_thumb_size(tl, clh, ch)
    max_sc = sb_max_scroll_y(ch, clh)
    val = my - grab
    res = sb_scroll_from_pos(val, ty, tl, sz, max_sc)
    res
}

sb_apply_drag_h(hx, hy, w, h, top, cw, ch, grab, mx) = {
    clw = sb_client_w(w)
    tl = sb_track_h_w(w)
    tx = sb_track_h_x(hx)
    sz = sb_thumb_size(tl, clw, cw)
    max_sc = sb_max_scroll_x(cw, clw)
    val = mx - grab
    res = sb_scroll_from_pos(val, tx, tl, sz, max_sc)
    res
}

// -------------------------------------------------------------------------------
// 5. RECORTADO DE HARDWARE (SCISSOR CLIPPING PVM) Y RENDERIZADO VISUAL NEÓN
// active_axis: 0.0=Inactivo, 1.0=Vertical activo, 2.0=Horizontal activo
// -------------------------------------------------------------------------------
sb_begin_clip(hx, hy, w, h, top, cw, ch) = {
    clw = sb_client_w(w)
    clh = sb_client_h(h, top)
    val = sb_needed_v(ch, clh)
    delta = sb_needed_h(cw, clw)
    tx = clw - (11.0 * val)
    ty = clh - (11.0 * delta)
    if (tx < 1.0) { tx = 1.0 } else { 1.0 }
    if (ty < 1.0) { ty = 1.0 } else { 1.0 }
    clip(hx + 1.0, hy + top, tx, ty)
    1.0
}

sb_end_clip() = {
    unclip()
    1.0
}

render_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, sc_x, sc_y, active_axis) = {
    clw = sb_client_w(w)
    clh = sb_client_h(h, top)

    // 1. Barra Vertical Neón (#58A6FF / #79C0FF) estrictamente dentro de la ventana
    val = sb_needed_v(ch, clh)
    if (val == 1.0) {
        rect(hx + w - 12.0, hy + top, 11.0, h - top - 1.0, 0x161B22)
        tx = sb_track_v_x(hx, w)
        ty = sb_track_v_y(hy, top)
        tl = sb_track_v_h(h, top)

        if (tl >= 18.0) {
            max_sc = sb_max_scroll_y(ch, clh)
            sz = sb_thumb_size(tl, clh, ch)
            off = sb_thumb_offset(tl, sz, sc_y, max_sc)

            // Pista oscura (#161B22 con bordes #21262D)
            rect(tx, ty, 8.0, tl, 0x161B22)
            line(tx, ty, tx, ty + tl, 0x21262D)
            line(tx + 8.0, ty, tx + 8.0, ty + tl, 0x21262D)

            if (active_axis == 1.0) {
                rect(tx + 1.0, ty + off, 6.0, sz, 0x79C0FF)
            } else {
                rect(tx + 1.0, ty + off, 6.0, sz, 0x58A6FF)
            }
        } else { 1.0 }
    } else { 1.0 }

    // 2. Barra Horizontal Neón (#58A6FF / #79C0FF) estrictamente dentro de la ventana
    delta = sb_needed_h(cw, clw)
    if (delta == 1.0) {
        rect(hx + 1.0, hy + h - 12.0, w - 2.0, 11.0, 0x161B22)
        tx = sb_track_h_x(hx)
        ty = sb_track_h_y(hy, h)
        tl = sb_track_h_w(w)

        if (tl >= 18.0) {
            max_sc = sb_max_scroll_x(cw, clw)
            sz = sb_thumb_size(tl, clw, cw)
            off = sb_thumb_offset(tl, sz, sc_x, max_sc)

            rect(tx, ty, tl, 8.0, 0x161B22)
            line(tx, ty, tx + tl, ty, 0x21262D)
            line(tx, ty + 8.0, tx + tl, ty + 8.0, 0x21262D)

            if (active_axis == 2.0) {
                rect(tx + off, ty + 1.0, sz, 6.0, 0x79C0FF)
            } else {
                rect(tx + off, ty + 1.0, sz, 6.0, 0x58A6FF)
            }
        } else { 1.0 }
    } else { 1.0 }

    // 3. Re-sellado de bordes perimetrales propios de la ventana
    line(hx, hy, hx + w, hy, 0x30363D)
    line(hx, hy, hx, hy + h, 0x30363D)
    line(hx + w, hy, hx + w, hy + h, 0x30363D)
    line(hx, hy + h, hx + w, hy + h, 0x30363D)
    line(hx, hy + top, hx + w, hy + top, 0x30363D)

    1.0
}

// -------------------------------------------------------------------------------
// 6. ENCAPSULADOR DECLARATIVO SUBSCREEN (OPCIÓN B)
// -------------------------------------------------------------------------------
ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, sc_x, sc_y, active_axis, scroll_flag) = {
    if (scroll_flag > 0.0) {
        render_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, sc_x, sc_y, active_axis)
    } else { 1.0 }
    1.0
}
