// ===============================================================================
// PLANTILLA ESTÁNDAR DE NUEVO PROYECTO (main.ph)
// PhasorLang v1.0 [Chronos IDE & KoraDevs Autonomous Ecosystem]
// https://github.com/koradevsorg
//
// Estándar por Defecto al Crear "Nuevo Proyecto" en Chronos IDE:
// - Contenedor Principal: Fondo Espacial Toroidal 360° (ui_spatial_main.ph)
// - Screen 1 Inicial: Ventana flotante con Redimensión 8D, Minimizado [-]/[+],
//   Scissor Clipping Suave PVM y Scrollbars 2D Neón activos en blanco lista
//   para desarrollar en su interior, eliminarla o crear más pantallas (Screen 2..N).
// - Invariante Estricto: Zero-GC a 120 FPS Nativos (Registros R229..R255)
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. IMPORTACIONES MODULARES ESTÁNDAR
// -------------------------------------------------------------------------------
import "lib/ui_spatial_main.ph"
import "lib/ui_window_frame.ph"
import "lib/ui_viewport.ph"
import "lib/ui_scrollbar.ph"
import "lib/ui_components.ph"

// -------------------------------------------------------------------------------
// 2. SEÑALES REACTIVAS GLOBALES (SCREEN 1 + GESTOR DE INTERACCIÓN)
// -------------------------------------------------------------------------------
signal t_global = 0.0

// Geometría y Estado de Screen 1 (Posición mundial, tamaño, minimizado y scroll 2D)
signal s1_x = 120.0
signal s1_y = 70.0
signal s1_w = 560.0
signal s1_h = 400.0
signal s1_min = 0.0
signal s1_sc_x = 0.0
signal s1_sc_y = 0.0

// Dimensiones lógicas del lienzo interior de Screen 1 (activan el scroll 2D cuando superan s1_w/s1_h)
signal s1_cw = 800.0
signal s1_ch = 640.0

// Mutex de Interacción (Arrastre vs Redimensión 8D vs Scrollbar Thumb vs Pan Espacial)
signal drag_target_win = 0.0
signal resize_target_win = 0.0
signal resize_target_dir = 0.0
signal drag_offset_x = 0.0
signal drag_offset_y = 0.0
signal resize_orig_x = 0.0
signal resize_orig_y = 0.0
signal resize_orig_w = 0.0
signal resize_orig_h = 0.0
signal resize_orig_mx = 0.0
signal resize_orig_my = 0.0
signal prev_click_down = 0.0

// Estado de Scrollbars 2D
signal sb_win = 0.0
signal sb_axis = 0.0
signal sb_grab = 0.0

// -------------------------------------------------------------------------------
// 3. ÁREA DE DESARROLLO INTERIOR: SCREEN 1 (LIENZO EN BLANCO CON SCROLL ACTIVO)
// -------------------------------------------------------------------------------
// ¡Desarrolla aquí el contenido de tu aplicación!
// Puedes usar las coordenadas desplazadas (tx, ty) dentro del bloque sb_begin_clip / sb_end_clip,
// o borrar Screen 1 / duplicar su estructura para añadir Screen 2, Screen 3, etc.
render_screen_1_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = 28.0
        cw = s1_cw
        ch = s1_ch

        // 1. Lienzo interior limpio de Screen 1
        rect(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0, 0x090D13)

        // 2. Recorte de Hardware PVM (Scissor Clipping Suave)
        sb_begin_clip(hx, hy, w, h, top, cw, ch)

        tx = hx + 20.0 - dx
        ty = hy + 48.0 - dy

        // --- INICIO DEL CONTENIDO DEL DESARROLLADOR ---
        ui_card(tx, ty, 480.0, 96.0, 0x0D1117, 0x21262D)
        ui_badge_box(tx + 14.0, ty + 14.0, 48.0, 0x238636)
        text("READY", tx + 19.0, ty + 17.0, 8, 0xFFFFFF)
        text("Screen 1 — Lienzo en Blanco Activo (Scroll 2D + Resize 8D)", tx + 72.0, ty + 17.0, 9, 0x58A6FF)
        ui_divider(tx + 14.0, ty + 38.0, 452.0, 0x21262D)
        text("Escribe tu codigo PhasorLang dentro de render_screen_1_content()", tx + 14.0, ty + 50.0, 9, 0x8B949E)
        text("o agrega mas ventanas en screen main.", tx + 14.0, ty + 68.0, 9, 0x3FB950)
        // --- FIN DEL CONTENIDO DEL DESARROLLADOR ---

        sb_end_clip()

        // 3. Barras de desplazamiento 2D Neón automáticas
        ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, 1.0)
        1.0
    }
}

render_screen_1(sw, sh) = {
    render_window_frame(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min)
    hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
    hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
    text("⚡ Screen 1: Mi Aplicacion Phasor", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    act = 0.0
    if (sb_win == 1.0) { act = sb_axis } else { 1.0 }
    render_screen_1_content(hx, hy, s1_w, s1_h, s1_min, s1_sc_x, s1_sc_y, act)
    render_window_borders(hx, hy, s1_w, s1_h, s1_min)
}

// -------------------------------------------------------------------------------
// 4. GESTIÓN AUTOMÁTICA DE INTERACCIÓN, SCROLL 2D, RESIZE 8D Y CURSOR
// -------------------------------------------------------------------------------
clamp_s1_scroll() = {
    clw = sb_client_w(s1_w)
    clh = sb_client_h(s1_h, 28.0)
    max_sc = sb_max_scroll_x(s1_cw, clw)
    s1_sc_x = sb_clamp(s1_sc_x, max_sc)
    max_sc = sb_max_scroll_y(s1_ch, clh)
    s1_sc_y = sb_clamp(s1_sc_y, max_sc)
    1.0
}

handle_s1_interactions(mx, my, sw, sh, pd, pan_x, pan_y) = {
    if (pd == 1.0) {
        handled = 0.0
        hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
        hy = spatial_world_to_screen_y(s1_y, s1_h, sh)

        // 1. Arrastre activo de scrollbar
        if (sb_win == 1.0) {
            if (sb_axis == 1.0) {
                s1_sc_y = sb_apply_drag_v(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, sb_grab, my)
            } else {
                s1_sc_x = sb_apply_drag_h(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, sb_grab, mx)
            }
            handled = 1.0
        } else { 1.0 }

        // 2. Redimensionamiento 8D activo
        if (handled == 0.0) {
            if (resize_target_win == 1.0) {
                dx = mx - resize_orig_mx
                dy = my - resize_orig_my
                w = calc_resize_w(resize_target_dir, resize_orig_w, dx, 240.0)
                s1_x = calc_resize_x(resize_target_dir, resize_orig_x, resize_orig_w, w)
                h = calc_resize_h(resize_target_dir, resize_orig_h, dy, 160.0)
                s1_y = calc_resize_y(resize_target_dir, resize_orig_y, resize_orig_h, h)
                s1_w = w
                s1_h = h
                clamp_s1_scroll()
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }

        // 3. Arrastre de barra de título activo
        if (handled == 0.0) {
            if (drag_target_win == 1.0) {
                s1_x = (mx - drag_offset_x) - pan_x
                s1_y = (my - drag_offset_y) - pan_y
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }

        // 4. Inicio de clic fresco
        if (handled == 0.0) {
            if (prev_click_down == 0.0) {
                if (window_hit_min_btn(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
                    s1_min = 1.0 - s1_min
                    handled = 1.0
                } else { 1.0 }
            } else { 1.0 }

            // Scrollbar hit-test
            if (handled == 0.0) { if (s1_min == 0.0) {
                hit = sb_hit_test_v(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, s1_sc_y, mx, my)
                if (hit > 0.0) {
                    sb_win = 1.0; sb_axis = 1.0
                    sb_grab = sb_calc_grab_v(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, s1_sc_y, hit, my)
                    s1_sc_y = sb_apply_drag_v(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, sb_grab, my)
                    handled = 1.0
                } else {
                    hit = sb_hit_test_h(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, s1_sc_x, mx, my)
                    if (hit > 0.0) {
                        sb_win = 1.0; sb_axis = 2.0
                        sb_grab = sb_calc_grab_h(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, s1_sc_x, hit, mx)
                        s1_sc_x = sb_apply_drag_h(hx, hy, s1_w, s1_h, 28.0, s1_cw, s1_ch, sb_grab, mx)
                        handled = 1.0
                    } else { 1.0 }
                }
            } else { 1.0 } } else { 1.0 }

            // Redimensión 8D en bordes y esquinas
            if (handled == 0.0) { if (s1_min == 0.0) {
                dir = window_hit_edge_8d(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my)
                if (dir > 0.0) {
                    resize_target_win = 1.0; resize_target_dir = dir
                    resize_orig_x = s1_x; resize_orig_y = s1_y
                    resize_orig_w = s1_w; resize_orig_h = s1_h
                    resize_orig_mx = mx; resize_orig_my = my
                    handled = 1.0
                } else { 1.0 }
            } else { 1.0 } } else { 1.0 }

            // Arrastre desde la barra de título
            if (handled == 0.0) {
                if (window_hit_title(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
                    drag_target_win = 1.0
                    drag_offset_x = mx - hx; drag_offset_y = my - hy
                    handled = 1.0
                } else { 1.0 }
            } else { 1.0 }

            // Arrastre del fondo espacial toroidal si el clic fue en el espacio vacío
            if (handled == 0.0) {
                if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 0.0) {
                    spatial_main_handle_input(mx, my, pd, 1.0)
                } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }
        prev_click_down = 1.0
    } else {
        sb_win = 0.0
        sb_axis = 0.0
        drag_target_win = 0.0
        resize_target_win = 0.0
        resize_target_dir = 0.0
        prev_click_down = 0.0
        spatial_main_handle_input(mx, my, 0.0, 0.0)
    }
    1.0
}

// -------------------------------------------------------------------------------
// 5. PANTALLA PRINCIPAL (SCREEN MAIN)
// -------------------------------------------------------------------------------
screen main {
    t_global = t_global + 1.0
    if (t_global <= 1.0) { spatial_main_init(3600.0, 2400.0, 80.0) } else { 1.0 }

    sw = R250; sh = R251; mx = R252; my = R253; pd = R254
    wh_y = R255; wh_x = R247
    if (sw < 240.0) { sw = 800.0 } else { 1.0 }
    if (sh < 240.0) { sh = 600.0 } else { 1.0 }

    // Scroll con rueda de ratón cuando el puntero está sobre Screen 1
    if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 1.0) {
        if (wh_y != 0.0) { s1_sc_y = s1_sc_y + (wh_y * 0.25); clamp_s1_scroll() } else { 1.0 }
        if (wh_x != 0.0) { s1_sc_x = s1_sc_x + (wh_x * 0.25); clamp_s1_scroll() } else { 1.0 }
    } else { 1.0 }

    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()
    handle_s1_interactions(mx, my, sw, sh, pd, pan_x, pan_y)

    // Renderizado a 120 FPS Zero-GC
    spatial_main_render(sw, sh)
    render_screen_1(sw, sh)
    if (resize_target_win == 1.0) {
        render_window_active_resize_outline(s1_x, s1_y, s1_w, s1_h, sw, sh)
    } else { 1.0 }
}

