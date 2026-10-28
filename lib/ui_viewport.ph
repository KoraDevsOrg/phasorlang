// ===============================================================================
// LIB/UI_VIEWPORT.PH — HITO 4: VIEWPORT AISLADO Y SCROLL INTELIGENTE
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Geometría única (fuente de verdad) para: área cliente, clipping estricto,
// scrollbars 2D, hit-testing de thumb/pista y arrastre del thumb.
// Invariante Estricto: Zero-GC a 120 FPS Nativos (solo aritmética escalar)
//
// Convenciones:
//   top  = distancia en px desde el borde superior de la ventana hasta el área
//          cliente (28.0 sin menú local, 54.0 con barra de herramientas).
//   cw/ch = tamaño del CONTENIDO lógico. clw/clh = tamaño del ÁREA CLIENTE.
//   Hit: 0.0 = nada, 1.0 = thumb, 2.0 = pista (fuera del thumb).
//
// Disciplina PVM: cada llamada a función se asigna a una variable local antes de
// combinarse con otra operación (evita temporales compartidos entre llamadas).
// Identificadores consolidados para optimización del archivo de registros PVM.
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. GEOMETRÍA DEL ÁREA CLIENTE
// -------------------------------------------------------------------------------
vp_client_w(w) = {
    w - 2.0
}

vp_client_h(h, top) = {
    h - top - 1.0
}

// 1.0 si hace falta barra vertical (considerando el espacio que roba la horizontal)
vp_show_v(cw, ch, clw, clh) = {
    val = 0.0
    if (cw > clw) { val = 1.0 } else { 1.0 }
    delta = clh - (7.0 * val)
    res = 0.0
    if (ch > delta) { res = 1.0 } else { 1.0 }
    res
}

// 1.0 si hace falta barra horizontal (considerando el espacio que roba la vertical)
vp_show_h(cw, ch, clw, clh) = {
    val = vp_show_v(cw, ch, clw, clh)
    delta = clw - (7.0 * val)
    res = 0.0
    if (cw > delta) { res = 1.0 } else { 1.0 }
    res
}

// Área visible real del contenido (descontando las barras visibles)
vp_visible_w(cw, ch, clw, clh) = {
    val = vp_show_v(cw, ch, clw, clh)
    clw - (7.0 * val)
}

vp_visible_h(cw, ch, clw, clh) = {
    val = vp_show_h(cw, ch, clw, clh)
    clh - (7.0 * val)
}

// Máximo desplazamiento permitido por eje (0.0 si todo el contenido cabe)
vp_max_x(cw, ch, clw, clh) = {
    res = vp_visible_w(cw, ch, clw, clh)
    val = cw - res
    if (val < 0.0) { val = 0.0 } else { 1.0 }
    val
}

vp_max_y(cw, ch, clw, clh) = {
    res = vp_visible_h(cw, ch, clw, clh)
    val = ch - res
    if (val < 0.0) { val = 0.0 } else { 1.0 }
    val
}

// Fuerza el desplazamiento dentro de [0, max]
vp_clamp_scroll(sc, max_sc) = {
    res = sc
    if (res > max_sc) { res = max_sc } else { 1.0 }
    if (res < 0.0) { res = 0.0 } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 2. CLIPPING ESTRICTO DE CONTENIDO (PRUEBA DE CONTENCIÓN TOTAL)
// -------------------------------------------------------------------------------
// 1.0 solo si el rectángulo [x, x+w] x [y, y+h] queda 100% dentro del viewport
// [cl, cr] x [ct, cb]. Nada se dibuja fuera del área cliente.
vp_rect_inside(x, y, w, h, x_min, y_min, x_max, y_max) = {
    fits = 0.0
    if (x >= x_min) { if ((x + w) <= x_max) {
        if (y >= y_min) { if ((y + h) <= y_max) {
            fits = 1.0
        } }
    } }
    fits
}

// Ancho estimado de una cadena monoespaciada de n caracteres con fuente 'font_sz'
vp_text_w(text_len, font_sz) = {
    text_len * (font_sz * 0.6)
}

// Dibuja texto si intersecta el viewport; el recorte fino lo ejecuta clip() (Zero-GC)
vp_text(text_str, text_len, font_sz, text_x, text_y, x_min, y_min, x_max, y_max, text_col) = {
    fits = 0.0
    if (text_x <= x_max) { if ((text_y + font_sz) >= y_min) { if (text_y <= y_max) {
        fits = 1.0
    } } }
    if (fits == 1.0) {
        text(text_str, text_x, text_y, font_sz, text_col)
    } else { 1.0 }
    1.0
}

// 1.0 si una fila en 'y' con altura ~14px intersecta verticalmente [ct, cb]
// Permite que el contenido se oculte suavemente píxel a píxel detrás del marco con clip()
vp_line_visible(y, ct, cb) = {
    fits = 0.0
    if ((y + 14.0) >= ct) { if (y <= cb) {
        fits = 1.0
    } }
    fits
}

// -------------------------------------------------------------------------------
// 3. GEOMETRÍA DE PISTAS Y THUMBS
// -------------------------------------------------------------------------------
vp_track_v_x(hx, w) = { hx + w - 7.0 }
vp_track_v_y(hy, top) = { hy + top + 1.0 }
vp_track_v_len(cw, ch, clw, clh) = {
    res = vp_visible_h(cw, ch, clw, clh)
    res - 1.0
}

vp_track_h_x(hx) = { hx + 1.0 }
vp_track_h_y(hy, h) = { hy + h - 7.0 }
vp_track_h_len(cw, ch, clw, clh) = {
    res = vp_visible_w(cw, ch, clw, clh)
    res - 1.0
}

// Tamaño proporcional del thumb (mínimo 16 px, máximo la pista)
vp_thumb_size(tl, val, ch) = {
    delta = 1.0
    if (ch > 1.0) { delta = val / ch } else { 1.0 }
    sz = tl * delta
    if (sz < 16.0) { sz = 16.0 } else { 1.0 }
    if (sz > tl) { sz = tl } else { 1.0 }
    sz
}

// Offset del thumb desde el inicio de la pista según el scroll actual
vp_thumb_offset(tl, sz, sc, max_sc) = {
    delta = tl - sz
    off = 0.0
    if (max_sc >= 1.0) { if (delta > 0.0) {
        val = sc
        if (val < 0.0) { val = 0.0 } else { 1.0 }
        if (val > max_sc) { val = max_sc } else { 1.0 }
        off = (val / max_sc) * delta
    } }
    off
}

// Desplazamiento resultante de colocar el inicio del thumb en 'val'
vp_scroll_from_thumb(val, ty, tl, sz, max_sc) = {
    delta = tl - sz
    res = 0.0
    if (delta >= 1.0) {
        sc = (val - ty) / delta
        if (sc < 0.0) { sc = 0.0 } else { 1.0 }
        if (sc > 1.0) { sc = 1.0 } else { 1.0 }
        res = sc * max_sc
    } else { 1.0 }
    res
}

// -------------------------------------------------------------------------------
// 4. HIT-TESTING DE BARRAS (0=nada, 1=thumb, 2=pista)
// -------------------------------------------------------------------------------
vp_hit_v(hx, hy, w, h, top, cw, ch, sc, mx, my) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)
    val = vp_show_v(cw, ch, clw, clh)
    hit = 0.0
    if (val == 1.0) {
        tx = vp_track_v_x(hx, w)
        ty = vp_track_v_y(hy, top)
        tl = vp_track_v_len(cw, ch, clw, clh)
        if (tl >= 16.0) { if (mx >= (tx - 4.0)) { if (mx <= (tx + 7.0)) {
            if (my >= ty) { if (my <= (ty + tl)) {
                vh = vp_visible_h(cw, ch, clw, clh)
                max_sc = vp_max_y(cw, ch, clw, clh)
                sz = vp_thumb_size(tl, vh, ch)
                off = vp_thumb_offset(tl, sz, sc, max_sc)
                delta = ty + off
                hit = 2.0
                if (my >= delta) { if (my <= (delta + sz)) { hit = 1.0 } else { 1.0 } } else { 1.0 }
            } }
        } } }
    } else { 1.0 }
    hit
}

vp_hit_h(hx, hy, w, h, top, cw, ch, sc, mx, my) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)
    val = vp_show_h(cw, ch, clw, clh)
    hit = 0.0
    if (val == 1.0) {
        tx = vp_track_h_x(hx)
        ty = vp_track_h_y(hy, h)
        tl = vp_track_h_len(cw, ch, clw, clh)
        if (tl >= 16.0) { if (my >= (ty - 4.0)) { if (my <= (ty + 7.0)) {
            if (mx >= tx) { if (mx <= (tx + tl)) {
                vw = vp_visible_w(cw, ch, clw, clh)
                max_sc = vp_max_x(cw, ch, clw, clh)
                sz = vp_thumb_size(tl, vw, cw)
                off = vp_thumb_offset(tl, sz, sc, max_sc)
                delta = tx + off
                hit = 2.0
                if (mx >= delta) { if (mx <= (delta + sz)) { hit = 1.0 } else { 1.0 } } else { 1.0 }
            } }
        } } }
    } else { 1.0 }
    hit
}

// -------------------------------------------------------------------------------
// 5. ARRASTRE DEL THUMB (AGARRE Y CINEMÁTICA)
// -------------------------------------------------------------------------------
vp_grab_v(hx, hy, w, h, top, cw, ch, sc, hit, my) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)
    tl = vp_track_v_len(cw, ch, clw, clh)
    vh = vp_visible_h(cw, ch, clw, clh)
    max_sc = vp_max_y(cw, ch, clw, clh)
    sz = vp_thumb_size(tl, vh, ch)
    val = sz * 0.5
    if (hit == 1.0) {
        ty = vp_track_v_y(hy, top)
        off = vp_thumb_offset(tl, sz, sc, max_sc)
        delta = ty + off
        val = my - delta
    } else { 1.0 }
    val
}

vp_grab_h(hx, hy, w, h, top, cw, ch, sc, hit, mx) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)
    tl = vp_track_h_len(cw, ch, clw, clh)
    vw = vp_visible_w(cw, ch, clw, clh)
    max_sc = vp_max_x(cw, ch, clw, clh)
    sz = vp_thumb_size(tl, vw, cw)
    val = sz * 0.5
    if (hit == 1.0) {
        tx = vp_track_h_x(hx)
        off = vp_thumb_offset(tl, sz, sc, max_sc)
        delta = tx + off
        val = mx - delta
    } else { 1.0 }
    val
}

vp_drag_scroll_v(hx, hy, w, h, top, cw, ch, grab, my) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)
    tl = vp_track_v_len(cw, ch, clw, clh)
    vh = vp_visible_h(cw, ch, clw, clh)
    max_sc = vp_max_y(cw, ch, clw, clh)
    ty = vp_track_v_y(hy, top)
    sz = vp_thumb_size(tl, vh, ch)
    val = my - grab
    sc_val = vp_scroll_from_thumb(val, ty, tl, sz, max_sc)
    sc_val
}

vp_drag_scroll_h(hx, hy, w, h, top, cw, ch, grab, mx) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)
    tl = vp_track_h_len(cw, ch, clw, clh)
    vw = vp_visible_w(cw, ch, clw, clh)
    max_sc = vp_max_x(cw, ch, clw, clh)
    tx = vp_track_h_x(hx)
    sz = vp_thumb_size(tl, vw, cw)
    val = mx - grab
    sc_val = vp_scroll_from_thumb(val, tx, tl, sz, max_sc)
    sc_val
}

// -------------------------------------------------------------------------------
// 6. RENDERIZADO DE BARRAS 2D (active_axis: 0=ninguno, 1=V arrastrando, 2=H arrastrando)
// -------------------------------------------------------------------------------
render_viewport_scrollbars(hx, hy, w, h, top, cw, ch, sc, val, active_axis) = {
    clw = vp_client_w(w)
    clh = vp_client_h(h, top)

    delta = vp_show_v(cw, ch, clw, clh)
    if (delta == 1.0) {
        tx = vp_track_v_x(hx, w)
        ty = vp_track_v_y(hy, top)
        tl = vp_track_v_len(cw, ch, clw, clh)
        if (tl >= 16.0) {
            res = vp_visible_h(cw, ch, clw, clh)
            max_sc = vp_max_y(cw, ch, clw, clh)
            sz = vp_thumb_size(tl, res, ch)
            off = vp_thumb_offset(tl, sz, val, max_sc)
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

    delta = vp_show_h(cw, ch, clw, clh)
    if (delta == 1.0) {
        tx = vp_track_h_x(hx)
        ty = vp_track_h_y(hy, h)
        tl = vp_track_h_len(cw, ch, clw, clh)
        if (tl >= 16.0) {
            res = vp_visible_w(cw, ch, clw, clh)
            max_sc = vp_max_x(cw, ch, clw, clh)
            sz = vp_thumb_size(tl, res, cw)
            off = vp_thumb_offset(tl, sz, sc, max_sc)
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
    1.0
}
