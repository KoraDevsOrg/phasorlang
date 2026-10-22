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
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. GEOMETRÍA DEL ÁREA CLIENTE
// -------------------------------------------------------------------------------
vp_client_w(ww) = {
    ww - 2.0
}

vp_client_h(wh, top) = {
    wh - top - 1.0
}

// 1.0 si hace falta barra vertical (considerando el espacio que roba la horizontal)
vp_show_v(cw, ch, clw, clh) = {
    h0 = 0.0
    if (cw > clw) { h0 = 1.0 } else { 1.0 }
    avail_h = clh - (7.0 * h0)
    r = 0.0
    if (ch > avail_h) { r = 1.0 } else { 1.0 }
    r
}

// 1.0 si hace falta barra horizontal (considerando el espacio que roba la vertical)
vp_show_h(cw, ch, clw, clh) = {
    sv = vp_show_v(cw, ch, clw, clh)
    avail_w = clw - (7.0 * sv)
    r = 0.0
    if (cw > avail_w) { r = 1.0 } else { 1.0 }
    r
}

// Área visible real del contenido (descontando las barras visibles)
vp_visible_w(cw, ch, clw, clh) = {
    sv = vp_show_v(cw, ch, clw, clh)
    clw - (7.0 * sv)
}

vp_visible_h(cw, ch, clw, clh) = {
    sh = vp_show_h(cw, ch, clw, clh)
    clh - (7.0 * sh)
}

// Máximo desplazamiento permitido por eje (0.0 si todo el contenido cabe)
vp_max_x(cw, ch, clw, clh) = {
    vis_w = vp_visible_w(cw, ch, clw, clh)
    m = cw - vis_w
    if (m < 0.0) { m = 0.0 } else { 1.0 }
    m
}

vp_max_y(cw, ch, clw, clh) = {
    vis_h = vp_visible_h(cw, ch, clw, clh)
    m = ch - vis_h
    if (m < 0.0) { m = 0.0 } else { 1.0 }
    m
}

// Fuerza el desplazamiento dentro de [0, max]
vp_clamp_scroll(sc, max_sc) = {
    r = sc
    if (r > max_sc) { r = max_sc } else { 1.0 }
    if (r < 0.0) { r = 0.0 } else { 1.0 }
    r
}

// -------------------------------------------------------------------------------
// 2. CLIPPING ESTRICTO DE CONTENIDO (PRUEBA DE CONTENCIÓN TOTAL)
// -------------------------------------------------------------------------------
// 1.0 solo si el rectángulo [x, x+w] x [y, y+h] queda 100% dentro del viewport
// [cl, cr] x [ct, cb]. Nada se dibuja fuera del área cliente.
vp_rect_inside(x, y, w, h, cl, ct, cr, cb) = {
    r = 0.0
    if (x >= cl) { if ((x + w) <= cr) {
        if (y >= ct) { if ((y + h) <= cb) {
            r = 1.0
        } }
    } }
    r
}

// Ancho estimado de una cadena monoespaciada de n caracteres con fuente 'size'
vp_text_w(nchars, size) = {
    nchars * (size * 0.6)
}

// Dibuja texto solo si cabe por completo dentro del viewport (Zero-GC)
vp_text(label, nchars, size, x, y, cl, ct, cr, cb, col) = {
    tw = vp_text_w(nchars, size)
    th = size + 3.0
    fits = vp_rect_inside(x, y, tw, th, cl, ct, cr, cb)
    if (fits == 1.0) {
        text(label, x, y, size, col)
    } else { 1.0 }
    1.0
}

// -------------------------------------------------------------------------------
// 3. GEOMETRÍA DE PISTAS Y THUMBS
// -------------------------------------------------------------------------------
vp_track_v_x(hx, ww) = { hx + ww - 7.0 }
vp_track_v_y(hy, top) = { hy + top + 1.0 }
vp_track_v_len(cw, ch, clw, clh) = {
    vis_h = vp_visible_h(cw, ch, clw, clh)
    vis_h - 1.0
}

vp_track_h_x(hx) = { hx + 1.0 }
vp_track_h_y(hy, wh) = { hy + wh - 7.0 }
vp_track_h_len(cw, ch, clw, clh) = {
    vis_w = vp_visible_w(cw, ch, clw, clh)
    vis_w - 1.0
}

// Tamaño proporcional del thumb (mínimo 16 px, máximo la pista)
vp_thumb_size(track_len, visible, content) = {
    ratio = 1.0
    if (content > 1.0) { ratio = visible / content } else { 1.0 }
    sz = track_len * ratio
    if (sz < 16.0) { sz = 16.0 } else { 1.0 }
    if (sz > track_len) { sz = track_len } else { 1.0 }
    sz
}

// Offset del thumb desde el inicio de la pista según el scroll actual
vp_thumb_offset(track_len, thumb_sz, sc, max_sc) = {
    travel = track_len - thumb_sz
    off = 0.0
    if (max_sc >= 1.0) { if (travel > 0.0) {
        cs = sc
        if (cs < 0.0) { cs = 0.0 } else { 1.0 }
        if (cs > max_sc) { cs = max_sc } else { 1.0 }
        off = (cs / max_sc) * travel
    } }
    off
}

// Desplazamiento resultante de colocar el inicio del thumb en 'thumb_start'
vp_scroll_from_thumb(thumb_start, track_start, track_len, thumb_sz, max_sc) = {
    travel = track_len - thumb_sz
    sc = 0.0
    if (travel >= 1.0) {
        ratio = (thumb_start - track_start) / travel
        if (ratio < 0.0) { ratio = 0.0 } else { 1.0 }
        if (ratio > 1.0) { ratio = 1.0 } else { 1.0 }
        sc = ratio * max_sc
    } else { 1.0 }
    sc
}

// -------------------------------------------------------------------------------
// 4. HIT-TESTING DE BARRAS (0=nada, 1=thumb, 2=pista)
// -------------------------------------------------------------------------------
vp_hit_v(hx, hy, ww, wh, top, cw, ch, sc_y, mx, my) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)
    sv = vp_show_v(cw, ch, clw, clh)
    hit = 0.0
    if (sv == 1.0) {
        tx = vp_track_v_x(hx, ww)
        ty = vp_track_v_y(hy, top)
        tl = vp_track_v_len(cw, ch, clw, clh)
        if (tl >= 16.0) { if (mx >= (tx - 3.0)) { if (mx <= (tx + 6.0)) {
            if (my >= ty) { if (my <= (ty + tl)) {
                vis_h = vp_visible_h(cw, ch, clw, clh)
                mxs = vp_max_y(cw, ch, clw, clh)
                tsz = vp_thumb_size(tl, vis_h, ch)
                off = vp_thumb_offset(tl, tsz, sc_y, mxs)
                tpos = ty + off
                hit = 2.0
                if (my >= tpos) { if (my <= (tpos + tsz)) { hit = 1.0 } else { 1.0 } } else { 1.0 }
            } }
        } } }
    } else { 1.0 }
    hit
}

vp_hit_h(hx, hy, ww, wh, top, cw, ch, sc_x, mx, my) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)
    sh = vp_show_h(cw, ch, clw, clh)
    hit = 0.0
    if (sh == 1.0) {
        tx = vp_track_h_x(hx)
        ty = vp_track_h_y(hy, wh)
        tl = vp_track_h_len(cw, ch, clw, clh)
        if (tl >= 16.0) { if (my >= (ty - 3.0)) { if (my <= (ty + 6.0)) {
            if (mx >= tx) { if (mx <= (tx + tl)) {
                vis_w = vp_visible_w(cw, ch, clw, clh)
                mxs = vp_max_x(cw, ch, clw, clh)
                tsz = vp_thumb_size(tl, vis_w, cw)
                off = vp_thumb_offset(tl, tsz, sc_x, mxs)
                tpos = tx + off
                hit = 2.0
                if (mx >= tpos) { if (mx <= (tpos + tsz)) { hit = 1.0 } else { 1.0 } } else { 1.0 }
            } }
        } } }
    } else { 1.0 }
    hit
}

// -------------------------------------------------------------------------------
// 5. ARRASTRE DEL THUMB (AGARRE Y CINEMÁTICA)
// -------------------------------------------------------------------------------
// Offset del puntero dentro del thumb al iniciar el arrastre. Si se hizo clic en
// la pista, el thumb se centra bajo el puntero (grab = mitad del thumb).
vp_grab_v(hx, hy, ww, wh, top, cw, ch, sc_y, hit, my) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)
    tl = vp_track_v_len(cw, ch, clw, clh)
    vis_h = vp_visible_h(cw, ch, clw, clh)
    mxs = vp_max_y(cw, ch, clw, clh)
    tsz = vp_thumb_size(tl, vis_h, ch)
    g = tsz * 0.5
    if (hit == 1.0) {
        ty = vp_track_v_y(hy, top)
        off = vp_thumb_offset(tl, tsz, sc_y, mxs)
        tpos = ty + off
        g = my - tpos
    } else { 1.0 }
    g
}

vp_grab_h(hx, hy, ww, wh, top, cw, ch, sc_x, hit, mx) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)
    tl = vp_track_h_len(cw, ch, clw, clh)
    vis_w = vp_visible_w(cw, ch, clw, clh)
    mxs = vp_max_x(cw, ch, clw, clh)
    tsz = vp_thumb_size(tl, vis_w, cw)
    g = tsz * 0.5
    if (hit == 1.0) {
        tx = vp_track_h_x(hx)
        off = vp_thumb_offset(tl, tsz, sc_x, mxs)
        tpos = tx + off
        g = mx - tpos
    } else { 1.0 }
    g
}

// Nuevo scroll vertical/horizontal mientras se arrastra el thumb con 'grab'
vp_drag_scroll_v(hx, hy, ww, wh, top, cw, ch, grab, my) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)
    tl = vp_track_v_len(cw, ch, clw, clh)
    vis_h = vp_visible_h(cw, ch, clw, clh)
    mxs = vp_max_y(cw, ch, clw, clh)
    ty = vp_track_v_y(hy, top)
    tsz = vp_thumb_size(tl, vis_h, ch)
    thumb_start = my - grab
    r = vp_scroll_from_thumb(thumb_start, ty, tl, tsz, mxs)
    r
}

vp_drag_scroll_h(hx, hy, ww, wh, top, cw, ch, grab, mx) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)
    tl = vp_track_h_len(cw, ch, clw, clh)
    vis_w = vp_visible_w(cw, ch, clw, clh)
    mxs = vp_max_x(cw, ch, clw, clh)
    tx = vp_track_h_x(hx)
    tsz = vp_thumb_size(tl, vis_w, cw)
    thumb_start = mx - grab
    r = vp_scroll_from_thumb(thumb_start, tx, tl, tsz, mxs)
    r
}

// -------------------------------------------------------------------------------
// 6. RENDERIZADO DE BARRAS 2D (active_axis: 0=ninguno, 1=V arrastrando, 2=H arrastrando)
// -------------------------------------------------------------------------------
render_viewport_scrollbars(hx, hy, ww, wh, top, cw, ch, sc_x, sc_y, active_axis) = {
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)

    sv = vp_show_v(cw, ch, clw, clh)
    if (sv == 1.0) {
        tx = vp_track_v_x(hx, ww)
        ty = vp_track_v_y(hy, top)
        tl = vp_track_v_len(cw, ch, clw, clh)
        if (tl >= 16.0) {
            vis_h = vp_visible_h(cw, ch, clw, clh)
            mxs = vp_max_y(cw, ch, clw, clh)
            tsz = vp_thumb_size(tl, vis_h, ch)
            off = vp_thumb_offset(tl, tsz, sc_y, mxs)
            col = 0x484F58
            if (active_axis == 1.0) { col = 0x8B949E } else { 1.0 }
            rect(tx, ty, 6.0, tl, 0x161B22)
            rect(tx + 1.0, ty + off, 4.0, tsz, col)
        } else { 1.0 }
    } else { 1.0 }

    sh = vp_show_h(cw, ch, clw, clh)
    if (sh == 1.0) {
        tx = vp_track_h_x(hx)
        ty = vp_track_h_y(hy, wh)
        tl = vp_track_h_len(cw, ch, clw, clh)
        if (tl >= 16.0) {
            vis_w = vp_visible_w(cw, ch, clw, clh)
            mxs = vp_max_x(cw, ch, clw, clh)
            tsz = vp_thumb_size(tl, vis_w, cw)
            off = vp_thumb_offset(tl, tsz, sc_x, mxs)
            col = 0x484F58
            if (active_axis == 2.0) { col = 0x8B949E } else { 1.0 }
            rect(tx, ty, tl, 6.0, 0x161B22)
            rect(tx + off, ty + 1.0, tsz, 4.0, col)
        } else { 1.0 }
    } else { 1.0 }
    1.0
}
