// ===============================================================================
// LIB/UI_WINDOW.PH — COMPONENTE MODULAR DE VENTANAS HIJAS EN ESPACIO TOROIDAL
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Hito 2: Contenedor de Pantallas Hijas (Scrollbars 2D, Resizing y Minimizado)
// Zero-GC a 120 FPS | Arquitectura Limpia y Desacoplada
// ===============================================================================

import "lib/ui_spatial_main.ph"

// Dibuja el marco base, barra de título, botón de minimizado y agarre de redimensión
render_window_frame(wx, wy, ww, wh, screen_w, screen_h, is_min) = {
    hx = spatial_world_to_screen_x(wx, ww, screen_w)
    hy = spatial_world_to_screen_y(wy, wh, screen_h)
    hr = hx + ww
    
    // Si está minimizada, el alto visible es solo la barra de título (28px)
    eff_h = wh
    if (is_min == 1.0) {
        eff_h = 28.0
    } else { 1.0 }
    hb = hy + eff_h

    // Culling: Solo dibujar si está dentro o cerca del viewport
    if (hr > -50.0) { if (hx < (screen_w + 50.0)) {
        // Fondo de la ventana
        rect(hx, hy, ww, eff_h, 0x0D1117)
        
        // Barra de título superior
        rect(hx, hy, ww, 28.0, 0x161B22)
        line(hx, hy + 28.0, hr, hy + 28.0, 0x30363D)
        
        // Botón de Minimizar / Restaurar [-] / [+]
        btn_bx = hr - 24.0
        btn_by = hy + 6.0
        if (is_min == 1.0) {
            rect(btn_bx, btn_by, 16.0, 16.0, 0x238636)
            text("+", btn_bx + 5.0, btn_by + 2.0, 10, 0xFFFFFF)
        } else {
            rect(btn_bx, btn_by, 16.0, 16.0, 0x21262D)
            text("-", btn_bx + 5.0, btn_by + 1.0, 10, 0x8B949E)
        }

        // Bordes perimetrales iniciales de la ventana
        line(hx, hy, hr, hy, 0x30363D)
        line(hx, hy, hx, hb, 0x30363D)
        line(hr, hy, hr, hb, 0x30363D)
        line(hx, hb, hr, hb, 0x30363D)

        // Agarre de redimensionamiento en esquina inferior-derecha (Solo escritorio y no minimizada)
        if (is_min == 0.0) { if (screen_w >= 768.0) {
            line(hr - 10.0, hb - 2.0, hr - 2.0, hb - 10.0, 0x8B949E)
            line(hr - 6.0, hb - 2.0, hr - 2.0, hb - 6.0, 0x8B949E)
        } }
    } }
    1.0
}

// Sella los bordes perimetrales por encima del contenido para garantizar oclusión limpia
render_window_borders(hx, hy, ww, wh, is_min) = {
    eff_h = wh
    if (is_min == 1.0) { eff_h = 28.0 } else { 1.0 }
    hr = hx + ww
    hb = hy + eff_h
    line(hx, hy, hr, hy, 0x30363D)
    line(hx, hy, hx, hb, 0x30363D)
    line(hr, hy, hr, hb, 0x30363D)
    line(hx, hb, hr, hb, 0x30363D)
    1.0
}

// Renderiza barras de scroll 2D (Vertical y Horizontal) con clamping geométrico estricto
render_window_scrollbars(hx, hy, ww, wh, content_w, content_h, sc_x, sc_y) = {
    inner_h = wh - 30.0
    inner_w = ww - 2.0
    
    // 1. Scrollbar Vertical (lado derecho)
    if (content_h > inner_h) { if (inner_h >= 40.0) {
        sb_x = hx + ww - 7.0
        sb_y = hy + 29.0
        sb_len = inner_h - 1.0
        if (content_w > inner_w) { sb_len = inner_h - 7.0 } else { 1.0 }
        
        if (sb_len >= 16.0) {
            // Fondo de la pista vertical
            rect(sb_x, sb_y, 6.0, sb_len, 0x161B22)
            
            // Cálculo proporcional del thumb
            ratio = inner_h / content_h
            thumb_sz = sb_len * ratio
            if (thumb_sz < 16.0) { thumb_sz = 16.0 } else { 1.0 }
            if (thumb_sz > sb_len) { thumb_sz = sb_len } else { 1.0 }
            
            max_sc = content_h - inner_h
            if (max_sc < 1.0) { max_sc = 1.0 } else { 1.0 }
            travel = sb_len - thumb_sz
            if (travel < 0.0) { travel = 0.0 } else { 1.0 }

            cur_sc = sc_y
            if (cur_sc < 0.0) { cur_sc = 0.0 } else { 1.0 }
            if (cur_sc > max_sc) { cur_sc = max_sc } else { 1.0 }
            
            thumb_pos = sb_y + ((cur_sc / max_sc) * travel)
            if (thumb_pos < sb_y) { thumb_pos = sb_y } else { 1.0 }
            if (thumb_pos > (sb_y + travel)) { thumb_pos = sb_y + travel } else { 1.0 }
            
            rect(sb_x + 1.0, thumb_pos, 4.0, thumb_sz, 0x484F58)
        }
    } }

    // 2. Scrollbar Horizontal (lado inferior)
    if (content_w > inner_w) { if (inner_w >= 40.0) {
        sb_x = hx + 1.0
        sb_y = hy + wh - 7.0
        sb_len = inner_w - 1.0
        if (content_h > inner_h) { sb_len = inner_w - 7.0 } else { 1.0 }
        
        if (sb_len >= 16.0) {
            // Fondo de la pista horizontal
            rect(sb_x, sb_y, sb_len, 6.0, 0x161B22)
            
            // Cálculo proporcional del thumb
            ratio = inner_w / content_w
            thumb_sz = sb_len * ratio
            if (thumb_sz < 16.0) { thumb_sz = 16.0 } else { 1.0 }
            if (thumb_sz > sb_len) { thumb_sz = sb_len } else { 1.0 }
            
            max_sc = content_w - inner_w
            if (max_sc < 1.0) { max_sc = 1.0 } else { 1.0 }
            travel = sb_len - thumb_sz
            if (travel < 0.0) { travel = 0.0 } else { 1.0 }

            cur_sc = sc_x
            if (cur_sc < 0.0) { cur_sc = 0.0 } else { 1.0 }
            if (cur_sc > max_sc) { cur_sc = max_sc } else { 1.0 }
            
            thumb_pos = sb_x + ((cur_sc / max_sc) * travel)
            if (thumb_pos < sb_x) { thumb_pos = sb_x } else { 1.0 }
            if (thumb_pos > (sb_x + travel)) { thumb_pos = sb_x + travel } else { 1.0 }
            
            rect(thumb_pos, sb_y + 1.0, thumb_sz, 4.0, 0x484F58)
        }
    } }
    1.0
}

// Verifica si el puntero está sobre el botón de minimizar [-] / [+]
window_hit_min_btn(wx, wy, ww, wh, screen_w, screen_h, mx, my) = {
    hx = spatial_world_to_screen_x(wx, ww, screen_w)
    hy = spatial_world_to_screen_y(wy, wh, screen_h)
    hr = hx + ww
    hit = 0.0
    btn_bx = hr - 26.0
    btn_by = hy + 4.0
    if (mx >= btn_bx) { if (mx <= btn_bx + 20.0) {
        if (my >= btn_by) { if (my <= btn_by + 20.0) {
            hit = 1.0
        } }
    } }
    hit
}

// Evalúa la proximidad del puntero a los 4 bordes y 4 esquinas de la ventana
// Retorna: 0.0=Ninguno, 1.0=E, 2.0=S, 3.0=W, 4.0=N, 5.0=SE, 6.0=SW, 7.0=NE, 8.0=NW
window_hit_edge_8d(wx, wy, ww, wh, screen_w, screen_h, is_min, mx, my) = {
    dir = 0.0
    if (screen_w >= 768.0) { if (is_min == 0.0) {
        hx = spatial_world_to_screen_x(wx, ww, screen_w)
        hy = spatial_world_to_screen_y(wy, wh, screen_h)
        hr = hx + ww
        hb = hy + wh
        bm = 7.0

        // Bounding box expandido por el margen de agarre
        if (mx >= (hx - bm)) { if (mx <= (hr + bm)) {
            if (my >= (hy - bm)) { if (my <= (hb + bm)) {
                on_l = 0.0
                on_r = 0.0
                on_t = 0.0
                on_b = 0.0
                if (mx <= (hx + bm)) { on_l = 1.0 } else { 1.0 }
                if (mx >= (hr - bm)) { on_r = 1.0 } else { 1.0 }
                if (my <= (hy + 4.0)) { on_t = 1.0 } else { 1.0 }
                if (my >= (hb - bm)) { on_b = 1.0 } else { 1.0 }

                // 1. Esquinas (Tienen máxima prioridad)
                if (on_l == 1.0) {
                    if (on_t == 1.0) { dir = 8.0 } else { 1.0 }
                    if (on_b == 1.0) { dir = 6.0 } else { 1.0 }
                } else { 1.0 }
                if (on_r == 1.0) {
                    if (on_t == 1.0) { dir = 7.0 } else { 1.0 }
                    if (on_b == 1.0) { dir = 5.0 } else { 1.0 }
                } else { 1.0 }

                // 2. Bordes rectos (si no fue esquina)
                if (dir == 0.0) {
                    if (on_r == 1.0) { dir = 1.0 } else { 1.0 }
                    if (on_b == 1.0) { dir = 2.0 } else { 1.0 }
                    if (on_l == 1.0) { dir = 3.0 } else { 1.0 }
                    if (on_t == 1.0) { dir = 4.0 } else { 1.0 }
                } else { 1.0 }
            } }
        } }
    } } else { 0.0 }
    dir
}

// Retorna el código de cursor R256 adecuado para una dirección 8D
window_cursor_from_dir(dir) = {
    cur = 0.0
    // E (1) o W (3) -> ew-resize (4.0)
    if (dir == 1.0) { cur = 4.0 } else { 1.0 }
    if (dir == 3.0) { cur = 4.0 } else { 1.0 }
    // S (2) o N (4) -> ns-resize (5.0)
    if (dir == 2.0) { cur = 5.0 } else { 1.0 }
    if (dir == 4.0) { cur = 5.0 } else { 1.0 }
    // SE (5) o NW (8) -> nwse-resize (6.0)
    if (dir == 5.0) { cur = 6.0 } else { 1.0 }
    if (dir == 8.0) { cur = 6.0 } else { 1.0 }
    // SW (6) o NE (7) -> nesw-resize (7.0)
    if (dir == 6.0) { cur = 7.0 } else { 1.0 }
    if (dir == 7.0) { cur = 7.0 } else { 1.0 }
    cur
}

// Verifica si el puntero está sobre la esquina inferior derecha para redimensionar
window_hit_resize_corner(wx, wy, ww, wh, screen_w, screen_h, mx, my) = {
    d = window_hit_edge_8d(wx, wy, ww, wh, screen_w, screen_h, 0.0, mx, my)
    hit = 0.0
    if (d == 5.0) { hit = 1.0 } else { 1.0 }
    hit
}

// Verifica si el puntero se encuentra sobre la barra de título de la ventana
window_hit_title(wx, wy, ww, wh, screen_w, screen_h, mx, my) = {
    hx = spatial_world_to_screen_x(wx, ww, screen_w)
    hy = spatial_world_to_screen_y(wy, wh, screen_h)
    hit = 0.0
    if (mx >= hx) { if (mx <= (hx + ww - 28.0)) {
        if (my >= hy) { if (my <= hy + 28.0) {
            hit = 1.0
        } }
    } }
    hit
}

// Verifica si el puntero se encuentra sobre el cuerpo de la ventana
window_hit_body(wx, wy, ww, wh, screen_w, screen_h, is_min, mx, my) = {
    hx = spatial_world_to_screen_x(wx, ww, screen_w)
    hy = spatial_world_to_screen_y(wy, wh, screen_h)
    eff_h = wh
    if (is_min == 1.0) { eff_h = 28.0 } else { 1.0 }
    hit = 0.0
    if (mx >= hx) { if (mx <= hx + ww) {
        if (my >= hy) { if (my <= hy + eff_h) {
            hit = 1.0
        } }
    } }
    hit
}
