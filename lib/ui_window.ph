// ===============================================================================
// LIB/UI_WINDOW.PH — COMPONENTE MODULAR DE VENTANAS HIJAS EN ESPACIO TOROIDAL
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Hito 2: Contenedor de Pantallas Hijas (Scrollbars 2D, Resizing y Minimizado)
// Zero-GC a 120 FPS | Arquitectura Limpia y Desacoplada
// ===============================================================================

import "lib/ui_spatial_main.ph"

// Dibuja el marco, barra de título, botón de minimizado y agarre de redimensión
render_window_frame(wx, wy, ww, wh, screen_w, screen_h, is_min, title_str) = {
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
    if (hr > -50.0) { if (hx < screen_w + 50.0) {
        // Fondo de la ventana
        rect(hx, hy, ww, eff_h, 0x0D1117)
        
        // Barra de título superior
        rect(hx, hy, ww, 28.0, 0x161B22)
        line(hx, hy + 28.0, hr, hy + 28.0, 0x30363D)
        
        // Título de la ventana
        text(title_str, hx + 12.0, hy + 8.0, 10, 0x58A6FF)
        
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

        // Bordes perimetrales de la ventana
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

// Renderiza barras de scroll 2D (Vertical y Horizontal) si el contenido excede el contenedor
render_window_scrollbars(hx, hy, ww, wh, content_w, content_h, sc_x, sc_y) = {
    inner_h = wh - 29.0
    inner_w = ww - 2.0
    
    // 1. Scrollbar Vertical (lado derecho)
    if (content_h > inner_h) {
        sb_x = hx + ww - 7.0
        sb_y = hy + 29.0
        sb_len = inner_h - 1.0
        
        // Fondo de la pista vertical
        rect(sb_x, sb_y, 6.0, sb_len, 0x161B22)
        
        // Cálculo proporcional del thumb
        ratio = inner_h / content_h
        thumb_sz = sb_len * ratio
        if (thumb_sz < 16.0) { thumb_sz = 16.0 } else { 1.0 }
        
        max_sc = content_h - inner_h
        travel = sb_len - thumb_sz
        thumb_pos = sb_y + ((sc_y / max_sc) * travel)
        
        rect(sb_x + 1.0, thumb_pos, 4.0, thumb_sz, 0x484F58)
    } else { 1.0 }

    // 2. Scrollbar Horizontal (lado inferior)
    if (content_w > inner_w) {
        sb_x = hx + 1.0
        sb_y = hy + wh - 7.0
        sb_len = inner_w - 7.0
        
        // Fondo de la pista horizontal
        rect(sb_x, sb_y, sb_len, 6.0, 0x161B22)
        
        // Cálculo proporcional del thumb
        ratio = inner_w / content_w
        thumb_sz = sb_len * ratio
        if (thumb_sz < 16.0) { thumb_sz = 16.0 } else { 1.0 }
        
        max_sc = content_w - inner_w
        travel = sb_len - thumb_sz
        thumb_pos = sb_x + ((sc_x / max_sc) * travel)
        
        rect(thumb_pos, sb_y + 1.0, thumb_sz, 4.0, 0x484F58)
    } else { 1.0 }
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

// Verifica si el puntero está sobre la esquina inferior derecha para redimensionar
window_hit_resize_corner(wx, wy, ww, wh, screen_w, screen_h, mx, my) = {
    hx = spatial_world_to_screen_x(wx, ww, screen_w)
    hy = spatial_world_to_screen_y(wy, wh, screen_h)
    hr = hx + ww
    hb = hy + wh
    hit = 0.0
    if (screen_w >= 768.0) {
        if (mx >= (hr - 18.0)) { if (mx <= hr) {
            if (my >= (hb - 18.0)) { if (my <= hb) {
                hit = 1.0
            } }
        } }
    } else { 0.0 }
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
