// ===============================================================================
// CHRONOS IDE — APLICATIVO PRINCIPAL TOROIDAL (chronos_ide.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Soberana: 100% Código PhasorLang Puro & Modular
// Mundo Toroidal 2D (T^2) + Modo Celular Focus Viewport + Modo Escritorio Stark HUD
// Invariante Estricto: Zero-GC a 120 FPS Nativos
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. IMPORTACIONES MODULARES
// -------------------------------------------------------------------------------
import "lib/ui_spatial_main.ph"
import "lib/ui_window_frame.ph"
import "lib/ui_viewport.ph"
import "lib/ui_scrollbar.ph"
import "lib/ui_screen_explorer.ph"

// -------------------------------------------------------------------------------
// 2. ESTADO GLOBAL REACTIVO (MEMORIA CONTIGUA SOA)
// -------------------------------------------------------------------------------
signal t_global = 0.0

// Screen 1: Editor de Código (Cuadrante Toroidal 0,0)
signal s1_x = 24.0
signal s1_y = 48.0
signal s1_w = 480.0
signal s1_h = 360.0
signal s1_min = 0.0
signal s1_sc_x = 0.0
signal s1_sc_y = 0.0

// Screen 2: Explorador de Archivos (Cuadrante Toroidal 0,1)
signal s2_x = 24.0
signal s2_y = 440.0
signal s2_w = 360.0
signal s2_h = 340.0
signal s2_min = 0.0
signal s2_sc_x = 0.0
signal s2_sc_y = 0.0

// Screen 3: Live Preview & Visor Científico (Cuadrante Toroidal 1,0)
signal s3_x = 530.0
signal s3_y = 48.0
signal s3_w = 380.0
signal s3_h = 360.0
signal s3_min = 0.0
signal s3_sc_x = 0.0
signal s3_sc_y = 0.0

// Screen 4: Inspector SoA & Consola PVM (Cuadrante Toroidal 1,1)
signal s4_x = 410.0
signal s4_y = 440.0
signal s4_w = 500.0
signal s4_h = 340.0
signal s4_min = 0.0
signal s4_sc_x = 0.0
signal s4_sc_y = 0.0

// Mutex de Interacción
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
signal dpad_collapsed = 0.0

// Interacción de Scrollbars 2D
signal sb_win = 0.0
signal sb_axis = 0.0
signal sb_grab = 0.0
signal sb_scan_win = 0.0
signal sb_scan_axis = 0.0
signal sb_scan_hit = 0.0
signal sb_scan_blocked = 0.0

// -------------------------------------------------------------------------------
// 3. FUNCIONES AUXILIARES DE CLAMPING Y ACCESO A ESTADO (ZERO-GC)
// -------------------------------------------------------------------------------
clamp_val(val, min_v, max_v) = {
    res = val
    if (res < min_v) { res = min_v } else { 1.0 }
    if (res > max_v) { res = max_v } else { 1.0 }
    res
}

win_x(id) = {
    res = s1_x
    if (id == 2.0) { res = s2_x } else { 1.0 }
    if (id == 3.0) { res = s3_x } else { 1.0 }
    if (id == 4.0) { res = s4_x } else { 1.0 }
    res
}

win_y(id) = {
    res = s1_y
    if (id == 2.0) { res = s2_y } else { 1.0 }
    if (id == 3.0) { res = s3_y } else { 1.0 }
    if (id == 4.0) { res = s4_y } else { 1.0 }
    res
}

win_w(id) = {
    res = s1_w
    if (id == 2.0) { res = s2_w } else { 1.0 }
    if (id == 3.0) { res = s3_w } else { 1.0 }
    if (id == 4.0) { res = s4_w } else { 1.0 }
    res
}

win_h(id) = {
    res = s1_h
    if (id == 2.0) { res = s2_h } else { 1.0 }
    if (id == 3.0) { res = s3_h } else { 1.0 }
    if (id == 4.0) { res = s4_h } else { 1.0 }
    res
}

win_min(id) = {
    res = s1_min
    if (id == 2.0) { res = s2_min } else { 1.0 }
    if (id == 3.0) { res = s3_min } else { 1.0 }
    if (id == 4.0) { res = s4_min } else { 1.0 }
    res
}

win_sc_x(id) = {
    res = s1_sc_x
    if (id == 2.0) { res = s2_sc_x } else { 1.0 }
    if (id == 3.0) { res = s3_sc_x } else { 1.0 }
    if (id == 4.0) { res = s4_sc_x } else { 1.0 }
    res
}

win_sc_y(id) = {
    res = s1_sc_y
    if (id == 2.0) { res = s2_sc_y } else { 1.0 }
    if (id == 3.0) { res = s3_sc_y } else { 1.0 }
    if (id == 4.0) { res = s4_sc_y } else { 1.0 }
    res
}

win_top(id) = {
    res = 28.0
    if (id == 1.0) { res = 54.0 } else { 1.0 }
    if (id == 2.0) { res = 54.0 } else { 1.0 }
    res
}

win_cw(id) = {
    res = 640.0
    if (id == 2.0) { res = 360.0 } else { 1.0 }
    if (id == 3.0) { res = 380.0 } else { 1.0 }
    if (id == 4.0) { res = 440.0 } else { 1.0 }
    res
}

win_ch(id) = {
    res = 560.0
    if (id == 2.0) { res = explorer_content_h() } else { 1.0 }
    if (id == 3.0) { res = 340.0 } else { 1.0 }
    if (id == 4.0) { res = 300.0 } else { 1.0 }
    res
}

win_hx(id, sw) = {
    spatial_world_to_screen_x(win_x(id), win_w(id), sw)
}

win_hy(id, sh) = {
    spatial_world_to_screen_y(win_y(id), win_h(id), sh)
}

set_win_sc(id, dx, dy) = {
    if (id == 1.0) { s1_sc_x = dx; s1_sc_y = dy } else { 1.0 }
    if (id == 2.0) { s2_sc_x = dx; s2_sc_y = dy } else { 1.0 }
    if (id == 3.0) { s3_sc_x = dx; s3_sc_y = dy } else { 1.0 }
    if (id == 4.0) { s4_sc_x = dx; s4_sc_y = dy } else { 1.0 }
    1.0
}

add_win_sc(id, dx, dy) = {
    set_win_sc(id, win_sc_x(id) + dx, win_sc_y(id) + dy)
}

clamp_win_scroll(id) = {
    w = win_w(id)
    h = win_h(id)
    top = win_top(id)
    cw = win_cw(id)
    ch = win_ch(id)
    clw = sb_client_w(w)
    clh = sb_client_h(h, top)
    val = sb_max_scroll_x(cw, clw)
    delta = sb_max_scroll_y(ch, clh)
    set_win_sc(id, sb_clamp(win_sc_x(id), val), sb_clamp(win_sc_y(id), delta))
}

clamp_all_scrolls() = {
    clamp_win_scroll(1.0)
    clamp_win_scroll(2.0)
    clamp_win_scroll(3.0)
    clamp_win_scroll(4.0)
    1.0
}

top_win_at(mx, my, sw, sh) = {
    target = 0.0
    if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 1.0) { target = 1.0 } else { 1.0 }
    if (window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my) == 1.0) { target = 2.0 } else { 1.0 }
    if (window_hit_body(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my) == 1.0) { target = 3.0 } else { 1.0 }
    if (window_hit_body(s4_x, s4_y, s4_w, s4_h, sw, sh, s4_min, mx, my) == 1.0) { target = 4.0 } else { 1.0 }
    target
}

sb_axis_for(id) = {
    delta = 0.0
    if (sb_win == id) { delta = sb_axis } else { 1.0 }
    delta
}

// -------------------------------------------------------------------------------
// 4. INTERACCIÓN DE SCROLLBARS 2D
// -------------------------------------------------------------------------------
sb_scan_one(id, mx, my, sw, sh) = {
    if (sb_scan_blocked == 0.0) {
        wx = win_x(id); wy = win_y(id); w = win_w(id); h = win_h(id); is_min = win_min(id)
        if (window_hit_body(wx, wy, w, h, sw, sh, is_min, mx, my) == 1.0) {
            sb_scan_blocked = 1.0
            if (is_min == 0.0) {
                hx = win_hx(id, sw); hy = win_hy(id, sh)
                top = win_top(id); cw = win_cw(id); ch = win_ch(id)
                hit = sb_hit_test_v(hx, hy, w, h, top, cw, ch, win_sc_y(id), mx, my)
                if (hit > 0.0) {
                    sb_scan_win = id; sb_scan_axis = 1.0; sb_scan_hit = hit
                } else {
                    hit = sb_hit_test_h(hx, hy, w, h, top, cw, ch, win_sc_x(id), mx, my)
                    if (hit > 0.0) {
                        sb_scan_win = id; sb_scan_axis = 2.0; sb_scan_hit = hit
                    } else { 1.0 }
                }
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

sb_scan(mx, my, sw, sh) = {
    sb_scan_win = 0.0; sb_scan_axis = 0.0; sb_scan_hit = 0.0; sb_scan_blocked = 0.0
    sb_scan_one(4.0, mx, my, sw, sh)
    sb_scan_one(3.0, mx, my, sw, sh)
    sb_scan_one(2.0, mx, my, sw, sh)
    sb_scan_one(1.0, mx, my, sw, sh)
    1.0
}

sb_apply_drag(mx, my, sw, sh) = {
    id = sb_win
    hx = win_hx(id, sw); hy = win_hy(id, sh)
    w = win_w(id); h = win_h(id); top = win_top(id); cw = win_cw(id); ch = win_ch(id)
    if (sb_axis == 1.0) {
        val = sb_apply_drag_v(hx, hy, w, h, top, cw, ch, sb_grab, my)
        set_win_sc(id, win_sc_x(id), val)
    } else {
        val = sb_apply_drag_h(hx, hy, w, h, top, cw, ch, sb_grab, mx)
        set_win_sc(id, val, win_sc_y(id))
    }
    1.0
}

sb_try_start(mx, my, sw, sh) = {
    handled = 0.0
    sb_scan(mx, my, sw, sh)
    if (sb_scan_hit > 0.0) {
        id = sb_scan_win
        hx = win_hx(id, sw); hy = win_hy(id, sh)
        w = win_w(id); h = win_h(id); top = win_top(id); cw = win_cw(id); ch = win_ch(id)
        if (sb_scan_axis == 1.0) {
            sb_grab = sb_calc_grab_v(hx, hy, w, h, top, cw, ch, win_sc_y(id), sb_scan_hit, my)
        } else {
            sb_grab = sb_calc_grab_h(hx, hy, w, h, top, cw, ch, win_sc_x(id), sb_scan_hit, mx)
        }
        sb_win = id; sb_axis = sb_scan_axis
        sb_apply_drag(mx, my, sw, sh)
        handled = 1.0
    } else { 1.0 }
    handled
}

// -------------------------------------------------------------------------------
// 5. MÓDULO SCREEN 1: EDITOR DE CÓDIGO (CUADRANTE TOROIDAL 0,0)
// -------------------------------------------------------------------------------
render_editor_toolbar(hx, hy, w) = {
    rect(hx + 1.0, hy + 28.0, w - 2.0, 26.0, 0x161B22)
    line(hx + 1.0, hy + 54.0, hx + w - 1.0, hy + 54.0, 0x30363D)
    text("Plantilla", hx + 10.0, hy + 35.0, 9, 0x8B949E)
    text("Editar", hx + 68.0, hy + 35.0, 9, 0x8B949E)
    text("Compilar", hx + 118.0, hy + 35.0, 9, 0x3FB950)
    if (exp_edit_mod == 1.0) {
        ui_badge_box(hx + w - 62.0, hy + 33.0, 50.0, 0x1F6FEB)
        text("MOD ●", hx + w - 56.0, hy + 36.0, 8, 0xF2CC60)
    } else { 1.0 }
    1.0
}

render_screen_editor_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(1.0); cw = win_cw(1.0); ch = win_ch(1.0)
        rect(hx + 1.0, hy + 54.0, w - 2.0, h - 55.0, 0x090D13)

        ty = hy + 66.0 - dy
        tx = hx + 42.0 - dx
        gx = hx + 12.0

        clip(hx + 38.0, hy + 54.0, w - 50.0, h - 66.0)
        if (exp_ed_file == 1.0) {
            text("// PLANTILLA ESTANDAR: NUEVO PROYECTO (main.ph)", tx, ty, 9, 0x6E7681)
            text("import \"lib/ui_spatial_main.ph\"", tx, ty + 18.0, 9, 0x79C0FF)
            text("import \"lib/ui_window_frame.ph\"", tx, ty + 36.0, 9, 0x79C0FF)
            text("import \"lib/ui_scrollbar.ph\"", tx, ty + 54.0, 9, 0x79C0FF)
            text("signal s1_x = 120.0; signal s1_y = 70.0", tx, ty + 72.0, 9, 0xF2CC60)
            text("screen main { spatial_main_render(R250, R251) }", tx, ty + 90.0, 9, 0x3FB950)
        } else {
            text("// CHRONOS IDE — UNIVERSO TOROIDAL T^2", tx, ty, 9, 0x6E7681)
            text("import \"lib/ui_spatial_main.ph\"", tx, ty + 18.0, 9, 0x79C0FF)
            text("import \"lib/ui_window_frame.ph\"", tx, ty + 36.0, 9, 0x79C0FF)
            text("import \"lib/ui_screen_explorer.ph\"", tx, ty + 54.0, 9, 0x79C0FF)
            text("signal t = 0.0", tx, ty + 72.0, 9, 0xF2CC60)
            text("screen main {", tx, ty + 90.0, 9, 0x58A6FF)
            text("    spatial_sync_topology(R250, R251)", tx, ty + 108.0, 9, 0x3FB950)
            text("    spatial_main_render(R250, R251)", tx, ty + 126.0, 9, 0x3FB950)
            text("    // Desliza o usa HUD D-Pad para viajar en T^2", tx, ty + 144.0, 9, 0x79C0FF)
            text("}", tx, ty + 162.0, 9, 0x58A6FF)
        }
        if (exp_edit_mod == 1.0) {
            text("// [EDICION EN VIVO ●] Bloque insertado:", tx, ty + 186.0, 9, 0xF2CC60)
            text("ui_card(tx, ty + 120.0, 320.0, 48.0, 0x162234, 0x58A6FF)", tx, ty + 204.0, 9, 0x3FB950)
        } else { 1.0 }
        unclip()

        rect(hx + 1.0, hy + 54.0, 36.0, h - 55.0, 0x0C1017)
        line(hx + 37.0, hy + 54.0, hx + 37.0, hy + h - 1.0, 0x21262D)
        clip(hx + 1.0, hy + 54.0, 36.0, h - 66.0)
        text("1", gx, ty, 9, 0x484F58)
        text("2", gx, ty + 18.0, 9, 0x484F58)
        text("3", gx, ty + 36.0, 9, 0x484F58)
        text("4", gx, ty + 54.0, 9, 0x484F58)
        text("5", gx, ty + 72.0, 9, 0xF2CC60)
        text("6", gx, ty + 90.0, 9, 0x58A6FF)
        text("7", gx, ty + 108.0, 9, 0x3FB950)
        text("8", gx, ty + 126.0, 9, 0x3FB950)
        text("9", gx, ty + 144.0, 9, 0x79C0FF)
        text("10", gx - 5.0, ty + 162.0, 9, 0x58A6FF)
        unclip()

        render_editor_toolbar(hx, hy, w)
        ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, 1.0)
        1.0
    }
}

render_screen_1(sw, sh) = {
    render_window_frame(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min)
    hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
    hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
    text("📝 Screen 1: Editor (.ph)", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    render_screen_editor_content(hx, hy, s1_w, s1_h, s1_min, s1_sc_x, s1_sc_y, sb_axis_for(1.0))
    render_window_borders(hx, hy, s1_w, s1_h, s1_min)
}

// -------------------------------------------------------------------------------
// 6. MÓDULO SCREEN 2: EXPLORADOR DE ARCHIVOS (CUADRANTE TOROIDAL 0,1)
// -------------------------------------------------------------------------------
render_screen_2(sw, sh) = {
    render_window_frame(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min)
    hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
    hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
    text("📁 Screen 2: Explorador", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    render_screen_explorer_content(hx, hy, s2_w, s2_h, s2_min, s2_sc_x, s2_sc_y, sb_axis_for(2.0))
    render_window_borders(hx, hy, s2_w, s2_h, s2_min)
}

// -------------------------------------------------------------------------------
// 7. MÓDULO SCREEN 3: LIVE PREVIEW PVM / SMITH CHART (CUADRANTE TOROIDAL 1,0)
// -------------------------------------------------------------------------------
render_screen_preview_content(hx, hy, w, h, is_min, dx, dy, act, t_frame, gp_conn, right_click) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(3.0); cw = win_cw(3.0); ch = win_ch(3.0)
        rect(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0, 0x070A0E)
        sb_begin_clip(hx, hy, w, h, top, cw, ch)

        cx = hx + (w * 0.5) - dx
        cy = hy + 96.0 - dy
        circle(cx, cy, 46.0, 0x1F6FEB)
        circle(cx, cy, 32.0, 0x238636)
        circle(cx + 16.0, cy, 16.0, 0x30363D)
        line(cx - 46.0, cy, cx + 46.0, cy, 0x21262D)
        ang = t_frame * 0.05
        fx = cx + (cos(ang) * 34.0)
        fy = cy + (sin(ang) * 34.0)
        line(cx, cy, fx, fy, 0x58A6FF)
        circle(fx, fy, 4.0, 0x3FB950)

        tx = hx + 16.0 - dx
        ty = hy + 162.0 - dy
        text("MONITOR HARDWARE DIRECTO (PVM)", tx, ty, 9, 0x58A6FF)
        if (gp_conn > 0.0) {
            text("Gamepad USB: CONECTADO [R240=1.0]", tx, ty + 18.0, 8, 0x3FB950)
        } else {
            text("Gamepad USB: Desconectado [R240=0.0]", tx, ty + 18.0, 8, 0x8B949E)
        }
        text("Toroide T^2: Wrap-Around Activo", tx, ty + 36.0, 8, 0x79C0FF)
        text("Zero-GC: 0 pausas | 120 FPS Nativos", tx, ty + 54.0, 8, 0x3FB950)

        sb_end_clip()
        ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, 1.0)
        1.0
    }
}

render_screen_3(sw, sh, val, gp_conn, right_click, mid_click) = {
    render_window_frame(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min)
    hx = spatial_world_to_screen_x(s3_x, s3_w, sw)
    hy = spatial_world_to_screen_y(s3_y, s3_h, sh)
    text("🔬 Screen 3: Live Preview PVM", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    render_screen_preview_content(hx, hy, s3_w, s3_h, s3_min, s3_sc_x, s3_sc_y, sb_axis_for(3.0), val, gp_conn, right_click)
    render_window_borders(hx, hy, s3_w, s3_h, s3_min)
}

// -------------------------------------------------------------------------------
// 8. MÓDULO SCREEN 4: INSPECTOR SOA & CONSOLA PVM (CUADRANTE TOROIDAL 1,1)
// -------------------------------------------------------------------------------
render_screen_4(sw, sh) = {
    render_window_frame(s4_x, s4_y, s4_w, s4_h, sw, sh, s4_min)
    hx = spatial_world_to_screen_x(s4_x, s4_w, sw)
    hy = spatial_world_to_screen_y(s4_y, s4_h, sh)
    text("🧠 Screen 4: Memoria SoA & Terminal", hx + 12.0, hy + 8.0, 10, 0x58A6FF)

    if (s4_min == 0.0) {
        top = win_top(4.0); cw = win_cw(4.0); ch = win_ch(4.0)
        rect(hx + 1.0, hy + 28.0, s4_w - 2.0, s4_h - 29.0, 0x080C12)
        sb_begin_clip(hx, hy, s4_w, s4_h, top, cw, ch)
        tx = hx + 14.0 - s4_sc_x
        ty = hy + 42.0 - s4_sc_y
        text("> [PVM] Universo Toroidal T^2 = S^1 x S^1 activo", tx, ty, 9, 0x3FB950)
        text("> [SoA] 64 KB Linear Memory | Zero-Allocation", tx, ty + 20.0, 9, 0x79C0FF)
        text("> [WASM/JS] Renderizador Determinista 120 FPS", tx, ty + 40.0, 9, 0x8B949E)
        text("> Usa el HUD D-Pad o desliza para viajar entre pantallas", tx, ty + 64.0, 9, 0xF2CC60)
        sb_end_clip()
        ui_subscreen_scrollbars(hx, hy, s4_w, s4_h, top, cw, ch, s4_sc_x, s4_sc_y, sb_axis_for(4.0), 1.0)
    } else { 1.0 }

    render_window_borders(hx, hy, s4_w, s4_h, s4_min)
}

// -------------------------------------------------------------------------------
// 9. BARRA SUPERIOR LIMPIA (ESTILO PHASOR_IDE) + D-PAD FLOTANTE TOROIDAL
// -------------------------------------------------------------------------------
render_system_bars(sw, sh) = {
    mob = spatial_is_mobile_view(sw)

    // Barra superior limpia de 32px sin textos superpuestos
    rect(0.0, 0.0, sw, 32.0, 0x0D1117)
    line(0.0, 32.0, sw, 32.0, 0x21262D)

    // Logo compacto a la izquierda
    text("⚡ CHRONOS", 10.0, 10.0, 10, 0x58A6FF)

    // Selector rápido de cuadrantes toroidales [S1] [S2] [S3] [S4]
    bx = 96.0
    c1 = 0x161B22; if ((spatial_sector_col == 0.0) && (spatial_sector_row == 0.0)) { c1 = 0x1F6FEB } else { 1.0 }
    rect(bx, 5.0, 28.0, 22.0, c1); text("S1", bx + 7.0, 10.0, 9, 0xFFFFFF)

    c2 = 0x161B22; if ((spatial_sector_col == 0.0) && (spatial_sector_row == 1.0)) { c2 = 0x1F6FEB } else { 1.0 }
    rect(bx + 32.0, 5.0, 28.0, 22.0, c2); text("S2", bx + 39.0, 10.0, 9, 0xFFFFFF)

    c3 = 0x161B22; if ((spatial_sector_col == 1.0) && (spatial_sector_row == 0.0)) { c3 = 0x1F6FEB } else { 1.0 }
    rect(bx + 64.0, 5.0, 28.0, 22.0, c3); text("S3", bx + 71.0, 10.0, 9, 0xFFFFFF)

    c4 = 0x161B22; if ((spatial_sector_col == 1.0) && (spatial_sector_row == 1.0)) { c4 = 0x1F6FEB } else { 1.0 }
    rect(bx + 96.0, 5.0, 28.0, 22.0, c4); text("S4", bx + 103.0, 10.0, 9, 0xFFFFFF)

    // Botón conmutador de vista Móvil / Escritorio a la derecha
    mx_btn = sw - 74.0
    rect(mx_btn, 5.0, 66.0, 22.0, 0x238636)
    if (mob == 1.0) {
        text("📱 MÓVIL", mx_btn + 8.0, 10.0, 8, 0xFFFFFF)
    } else {
        text("🖥️ DESK", mx_btn + 10.0, 10.0, 8, 0xFFFFFF)
    }

    // Barra de estado inferior compacta
    ty = sh - 24.0
    rect(0.0, ty, sw, 24.0, 0x0D1117)
    line(0.0, ty, sw, ty, 0x21262D)
    text("T^2 Torus | 120 FPS Zero-GC | Swipe o HUD ◄▲▼►", 10.0, ty + 6.0, 8, 0x3FB950)
    1.0
}

// Controlador Flotante Direccional (HUD D-Pad Translúcido + Minimapa Toroidal)
render_toroidal_dpad(sw, sh) = {
    cx = sw - 68.0
    cy = sh - 92.0

    if (dpad_collapsed == 1.0) {
        ui_card(sw - 44.0, sh - 66.0, 34.0, 34.0, 0x161B22, 0x58A6FF)
        text("+", sw - 31.0, sh - 54.0, 12, 0x58A6FF)
    } else {
        circle(cx, cy, 52.0, 0x30363D)
        circle(cx, cy, 48.0, 0x1F6FEB)

        ui_card(cx - 16.0, cy - 48.0, 32.0, 26.0, 0x1F2937, 0x58A6FF)
        text("^", cx - 4.0, cy - 41.0, 10, 0x79C0FF)

        ui_card(cx - 16.0, cy + 22.0, 32.0, 26.0, 0x1F2937, 0x58A6FF)
        text("v", cx - 4.0, cy + 29.0, 10, 0x79C0FF)

        ui_card(cx - 50.0, cy - 13.0, 28.0, 26.0, 0x1F2937, 0x58A6FF)
        text("<", cx - 40.0, cy - 6.0, 10, 0x79C0FF)

        ui_card(cx + 22.0, cy - 13.0, 28.0, 26.0, 0x1F2937, 0x58A6FF)
        text(">", cx + 32.0, cy - 6.0, 10, 0x79C0FF)

        ui_card(cx - 14.0, cy - 13.0, 28.0, 26.0, 0x090D13, 0x3FB950)

        m00 = 0x30363D; if ((spatial_sector_col == 0.0) && (spatial_sector_row == 0.0)) { m00 = 0x3FB950 } else { 1.0 }
        m10 = 0x30363D; if ((spatial_sector_col == 1.0) && (spatial_sector_row == 0.0)) { m10 = 0x3FB950 } else { 1.0 }
        m01 = 0x30363D; if ((spatial_sector_col == 0.0) && (spatial_sector_row == 1.0)) { m01 = 0x3FB950 } else { 1.0 }
        m11 = 0x30363D; if ((spatial_sector_col == 1.0) && (spatial_sector_row == 1.0)) { m11 = 0x3FB950 } else { 1.0 }

        rect(cx - 10.0, cy - 9.0, 8.0, 7.0, m00)
        rect(cx + 2.0, cy - 9.0, 8.0, 7.0, m10)
        rect(cx - 10.0, cy + 2.0, 8.0, 7.0, m01)
        rect(cx + 2.0, cy + 2.0, 8.0, 7.0, m11)
    }
    1.0
}

// -------------------------------------------------------------------------------
// 10. DISPATCHERS DE LAYOUT RESPONSIVO Y ENTRADA TÁCTIL / ESCRITORIO
// -------------------------------------------------------------------------------
handle_responsive_layout(sw, sh) = {
    spatial_sync_topology(sw, sh)
    mob = spatial_is_mobile_view(sw)

    if (mob == 1.0) {
        // Modo Celular: Ventana enfocada al viewport manteniendo proporciones planas 1:1 (sin deformar contenido)
        cw = sw - 12.0
        ch = sh - 64.0
        if (ch < 220.0) { ch = 220.0 } else { 1.0 }

        s1_x = 6.0;                 s1_y = 36.0;                 s1_w = cw; s1_h = ch; s1_min = 0.0
        s3_x = sw + 6.0;            s3_y = 36.0;                 s3_w = cw; s3_h = ch; s3_min = 0.0
        s2_x = 6.0;                 s2_y = (sh - 56.0) + 36.0;   s2_w = cw; s2_h = ch; s2_min = 0.0
        s4_x = sw + 6.0;            s4_y = (sh - 56.0) + 36.0;   s4_w = cw; s4_h = ch; s4_min = 0.0
        clamp_all_scrolls()
    } else {
        // Modo Escritorio: Subpantallas planas a escala natural flotando simultáneamente
        if (s1_w > (sw * 0.85)) {
            s1_x = 20.0;  s1_y = 44.0;  s1_w = 460.0; s1_h = 330.0
            s3_x = 500.0; s3_y = 44.0;  s3_w = 360.0; s3_h = 330.0
            s2_x = 20.0;  s2_y = 390.0; s2_w = 340.0; s2_h = 310.0
            s4_x = 380.0; s4_y = 390.0; s4_w = 480.0; s4_h = 310.0
            clamp_all_scrolls()
        } else { 1.0 }
    }
    1.0
}

check_hud_clicks(mx, my, sw, sh) = {
    handled = 0.0

    // 1. Clics en la barra superior (S1, S2, S3, S4 y botón Móvil/Escritorio)
    if (my <= 32.0) {
        bx = 96.0
        if (ui_hit_box(bx, 2.0, 30.0, 28.0, mx, my) == 1.0) { spatial_go_sector(0.0, 0.0); handled = 1.0 } else { 1.0 }
        if (ui_hit_box(bx + 32.0, 2.0, 30.0, 28.0, mx, my) == 1.0) { spatial_go_sector(0.0, 1.0); handled = 1.0 } else { 1.0 }
        if (ui_hit_box(bx + 64.0, 2.0, 30.0, 28.0, mx, my) == 1.0) { spatial_go_sector(1.0, 0.0); handled = 1.0 } else { 1.0 }
        if (ui_hit_box(bx + 96.0, 2.0, 30.0, 28.0, mx, my) == 1.0) { spatial_go_sector(1.0, 1.0); handled = 1.0 } else { 1.0 }

        mx_btn = sw - 74.0
        if (ui_hit_box(mx_btn, 2.0, 68.0, 28.0, mx, my) == 1.0) {
            mob = spatial_is_mobile_view(sw)
            if (mob == 1.0) { spatial_view_mode = 2.0 } else { spatial_view_mode = 1.0 }
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }

    // 2. Clics en el D-Pad flotante toroidal (esquina inferior derecha)
    if (handled == 0.0) {
        cx = sw - 68.0
        cy = sh - 92.0
        if (dpad_collapsed == 1.0) {
            if (ui_hit_box(sw - 46.0, sh - 68.0, 38.0, 38.0, mx, my) == 1.0) {
                dpad_collapsed = 0.0
                handled = 1.0
            } else { 1.0 }
        } else {
            // Arriba (▲) -> mueve cámara hacia arriba en el toroide
            if (ui_hit_box(cx - 18.0, cy - 50.0, 36.0, 28.0, mx, my) == 1.0) {
                spatial_step_sector(0.0, -1.0); handled = 1.0
            } else { 1.0 }
            // Abajo (▼) -> mueve cámara hacia abajo en el toroide
            if (ui_hit_box(cx - 18.0, cy + 20.0, 36.0, 28.0, mx, my) == 1.0) {
                spatial_step_sector(0.0, 1.0); handled = 1.0
            } else { 1.0 }
            // Izquierda (◀) -> mueve cámara hacia la izquierda en el toroide
            if (ui_hit_box(cx - 52.0, cy - 15.0, 30.0, 30.0, mx, my) == 1.0) {
                spatial_step_sector(-1.0, 0.0); handled = 1.0
            } else { 1.0 }
            // Derecha (▶) -> mueve cámara hacia la derecha en el toroide
            if (ui_hit_box(cx + 20.0, cy - 15.0, 30.0, 30.0, mx, my) == 1.0) {
                spatial_step_sector(1.0, 0.0); handled = 1.0
            } else { 1.0 }
            // Centro (minimapa) -> colapsar/expandir HUD
            if (ui_hit_box(cx - 14.0, cy - 13.0, 28.0, 26.0, mx, my) == 1.0) {
                dpad_collapsed = 1.0; handled = 1.0
            } else { 1.0 }
        }
    } else { 1.0 }

    handled
}

handle_gamepad_navigation(gp_conn, dx, dy) = {
    if (gp_conn > 0.0) {
        if (abs(dx) > 0.15) { spatial_main_pan(dx * -8.0, 0.0) } else { 1.0 }
        if (abs(dy) > 0.15) { spatial_main_pan(0.0, dy * -8.0) } else { 1.0 }
    } else { 1.0 }
    1.0
}

handle_scroll_input(mx, my, sw, sh, wh_y, wh_x) = {
    if (wh_y != 0.0) {
        val = clamp_val(wh_y * 0.25, -24.0, 24.0)
        id = top_win_at(mx, my, sw, sh)
        if (id > 0.0) { add_win_sc(id, 0.0, val); clamp_win_scroll(id) } else { 1.0 }
    } else { 1.0 }
    if (wh_x != 0.0) {
        val = clamp_val(wh_x * 0.25, -24.0, 24.0)
        id = top_win_at(mx, my, sw, sh)
        if (id > 0.0) { add_win_sc(id, val, 0.0); clamp_win_scroll(id) } else { 1.0 }
    } else { 1.0 }
    1.0
}

apply_active_resize(mx, my) = {
    dx = mx - resize_orig_mx
    dy = my - resize_orig_my
    val = 220.0; delta = 160.0
    if (resize_target_win == 1.0) { val = 280.0; delta = 180.0 } else { 1.0 }

    w = calc_resize_w(resize_target_dir, resize_orig_w, dx, val)
    hx = calc_resize_x(resize_target_dir, resize_orig_x, resize_orig_w, w)
    h = calc_resize_h(resize_target_dir, resize_orig_h, dy, delta)
    hy = calc_resize_y(resize_target_dir, resize_orig_y, resize_orig_h, h)

    if (resize_target_win == 1.0) { s1_x = hx; s1_y = hy; s1_w = w; s1_h = h } else { 1.0 }
    if (resize_target_win == 2.0) { s2_x = hx; s2_y = hy; s2_w = w; s2_h = h } else { 1.0 }
    if (resize_target_win == 3.0) { s3_x = hx; s3_y = hy; s3_w = w; s3_h = h } else { 1.0 }
    if (resize_target_win == 4.0) { s4_x = hx; s4_y = hy; s4_w = w; s4_h = h } else { 1.0 }
    clamp_win_scroll(resize_target_win)
    1.0
}

apply_active_drag(mx, my, pan_x, pan_y) = {
    tx = (mx - drag_offset_x) - pan_x
    ty = (my - drag_offset_y) - pan_y
    if (drag_target_win == 1.0) { s1_x = tx; s1_y = ty } else { 1.0 }
    if (drag_target_win == 2.0) { s2_x = tx; s2_y = ty } else { 1.0 }
    if (drag_target_win == 3.0) { s3_x = tx; s3_y = ty } else { 1.0 }
    if (drag_target_win == 4.0) { s4_x = tx; s4_y = ty } else { 1.0 }
    1.0
}

check_minimize_buttons(mx, my, sw, sh) = {
    handled = 0.0
    if (window_hit_min_btn(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) { s1_min = 1.0 - s1_min; handled = 1.0 } else { 1.0 }
    if (handled == 0.0) { if (window_hit_min_btn(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) { s2_min = 1.0 - s2_min; handled = 1.0 } else { 1.0 } } else { 1.0 }
    if (handled == 0.0) { if (window_hit_min_btn(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) { s3_min = 1.0 - s3_min; handled = 1.0 } else { 1.0 } } else { 1.0 }
    if (handled == 0.0) { if (window_hit_min_btn(s4_x, s4_y, s4_w, s4_h, sw, sh, mx, my) == 1.0) { s4_min = 1.0 - s4_min; handled = 1.0 } else { 1.0 } } else { 1.0 }
    handled
}

check_resize_start(mx, my, sw, sh) = {
    handled = 0.0
    if (s1_min == 0.0) {
        dir = window_hit_edge_8d(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my)
        if (dir > 0.0) { resize_target_win = 1.0; resize_target_dir = dir; resize_orig_x = s1_x; resize_orig_y = s1_y; resize_orig_w = s1_w; resize_orig_h = s1_h; resize_orig_mx = mx; resize_orig_my = my; handled = 1.0 } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s2_min == 0.0) {
            dir = window_hit_edge_8d(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my)
            if (dir > 0.0) { resize_target_win = 2.0; resize_target_dir = dir; resize_orig_x = s2_x; resize_orig_y = s2_y; resize_orig_w = s2_w; resize_orig_h = s2_h; resize_orig_mx = mx; resize_orig_my = my; handled = 1.0 } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s3_min == 0.0) {
            dir = window_hit_edge_8d(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my)
            if (dir > 0.0) { resize_target_win = 3.0; resize_target_dir = dir; resize_orig_x = s3_x; resize_orig_y = s3_y; resize_orig_w = s3_w; resize_orig_h = s3_h; resize_orig_mx = mx; resize_orig_my = my; handled = 1.0 } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s4_min == 0.0) {
            dir = window_hit_edge_8d(s4_x, s4_y, s4_w, s4_h, sw, sh, s4_min, mx, my)
            if (dir > 0.0) { resize_target_win = 4.0; resize_target_dir = dir; resize_orig_x = s4_x; resize_orig_y = s4_y; resize_orig_w = s4_w; resize_orig_h = s4_h; resize_orig_mx = mx; resize_orig_my = my; handled = 1.0 } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    handled
}

check_drag_start(mx, my, sw, sh) = {
    handled = 0.0
    if (window_hit_title(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
        drag_target_win = 1.0; drag_offset_x = mx - win_hx(1.0, sw); drag_offset_y = my - win_hy(1.0, sh); handled = 1.0
    } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_title(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) {
            drag_target_win = 2.0; drag_offset_x = mx - win_hx(2.0, sw); drag_offset_y = my - win_hy(2.0, sh); handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_title(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) {
            drag_target_win = 3.0; drag_offset_x = mx - win_hx(3.0, sw); drag_offset_y = my - win_hy(3.0, sh); handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_title(s4_x, s4_y, s4_w, s4_h, sw, sh, mx, my) == 1.0) {
            drag_target_win = 4.0; drag_offset_x = mx - win_hx(4.0, sw); drag_offset_y = my - win_hy(4.0, sh); handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    handled
}

handle_workspace_interactions(mx, my, sw, sh, pd, pan_x, pan_y) = {
    mob = spatial_is_mobile_view(sw)
    if (pd == 1.0) {
        handled = 0.0

        // 0. Clics en HUD (Barra superior y D-Pad flotante) con edge-trigger
        if (prev_click_down == 0.0) {
            handled = check_hud_clicks(mx, my, sw, sh)
        } else { 1.0 }

        // 1. Arrastre activo de scrollbar thumb
        if (handled == 0.0) {
            if (sb_win > 0.0) { sb_apply_drag(mx, my, sw, sh); handled = 1.0 } else { 1.0 }
        } else { 1.0 }

        // 2. Redimensionamiento y arrastre libre de ventana (solo en Modo Escritorio)
        if (mob == 0.0) {
            if (handled == 0.0) {
                if (resize_target_win > 0.0) { apply_active_resize(mx, my); handled = 1.0 } else { 1.0 }
            } else { 1.0 }
            if (handled == 0.0) {
                if (drag_target_win > 0.0) { apply_active_drag(mx, my, pan_x, pan_y); handled = 1.0 } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }

        // 3. Nuevas interacciones dentro del área de trabajo
        if (handled == 0.0) {
            if (my > 32.0) { if (my < (sh - 24.0)) {
                if (mob == 0.0) {
                    if (prev_click_down == 0.0) { handled = check_minimize_buttons(mx, my, sw, sh) } else { 1.0 }
                } else { 1.0 }

                if (handled == 0.0) { handled = sb_try_start(mx, my, sw, sh) } else { 1.0 }

                if (mob == 0.0) {
                    if (handled == 0.0) { handled = check_resize_start(mx, my, sw, sh) } else { 1.0 }
                    if (handled == 0.0) { handled = check_drag_start(mx, my, sw, sh) } else { 1.0 }
                } else { 1.0 }

                // Interacción interna de botones en Screen 1 (Editor) y Screen 2 (Explorador)
                if (handled == 0.0) {
                    if (prev_click_down == 0.0) {
                        id = top_win_at(mx, my, sw, sh)
                        if (id == 1.0) {
                            hx = win_hx(1.0, sw); hy = win_hy(1.0, sh)
                            if (ui_hit_box(hx + 8.0, hy + 28.0, 56.0, 26.0, mx, my) == 1.0) { exp_ed_file = 1.0 - exp_ed_file; handled = 1.0 } else { 1.0 }
                            if (ui_hit_box(hx + 66.0, hy + 28.0, 48.0, 26.0, mx, my) == 1.0) { exp_edit_mod = 1.0 - exp_edit_mod; handled = 1.0 } else { 1.0 }
                        } else { 1.0 }
                        if (id == 2.0) {
                            hx = win_hx(2.0, sw); hy = win_hy(2.0, sh)
                            handled = handle_explorer_click(hx, hy, s2_w, s2_h, s2_sc_x, s2_sc_y, mx, my)
                            clamp_win_scroll(2.0)
                        } else { 1.0 }
                    } else { 1.0 }
                } else { 1.0 }

                // En modo Celular, arrastrar cualquier área no capturada mueve el toroide (Swipe)
                // En modo Escritorio, arrastrar el fondo espacial mueve el toroide
                if (handled == 0.0) {
                    if (mob == 1.0) {
                        spatial_main_handle_input(mx, my, pd, 1.0, sw)
                    } else {
                        if (top_win_at(mx, my, sw, sh) == 0.0) {
                            spatial_main_handle_input(mx, my, pd, 1.0, sw)
                        } else { 1.0 }
                    }
                } else { 1.0 }
            } } else { 1.0 }
        } else { 1.0 }
        prev_click_down = 1.0
    } else {
        sb_win = 0.0; sb_axis = 0.0
        drag_target_win = 0.0; resize_target_win = 0.0; resize_target_dir = 0.0
        prev_click_down = 0.0
        spatial_main_handle_input(mx, my, 0.0, 0.0, sw)
    }
    1.0
}

// -------------------------------------------------------------------------------
// 11. ORQUESTADOR PRINCIPAL (SCREEN MAIN)
// -------------------------------------------------------------------------------
screen main {
    t_global = t_global + 1.0
    if (t_global <= 1.0) { spatial_main_init(1680.0, 1040.0, 64.0) } else { 1.0 }

    sw = R250; sh = R251; mx = R252; my = R253; pd = R254
    wh_y = R255; wh_x = R247; right_click = R248; mid_click = R249
    gp_conn = R240; dx = R241; dy = R242

    if (sw < 240.0) { sw = 360.0 } else { 1.0 }
    if (sh < 240.0) { sh = 640.0 } else { 1.0 }

    handle_responsive_layout(sw, sh)
    spatial_main_tick(sw)

    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()

    handle_gamepad_navigation(gp_conn, dx, dy)
    handle_scroll_input(mx, my, sw, sh, wh_y, wh_x)
    handle_workspace_interactions(mx, my, sw, sh, pd, pan_x, pan_y)

    if (right_click > 0.0) {
        if (top_win_at(mx, my, sw, sh) == 2.0) {
            handle_explorer_tree_click(s2_sc_x, s2_sc_y, mx, my)
        } else { 1.0 }
    } else { 1.0 }

    // Renderizado del Universo Toroidal y las 4 Ventanas
    spatial_main_render(sw, sh)
    render_screen_1(sw, sh)
    render_screen_2(sw, sh)
    render_screen_3(sw, sh, t_global, gp_conn, right_click, mid_click)
    render_screen_4(sw, sh)

    if (resize_target_win == 1.0) { render_window_active_resize_outline(s1_x, s1_y, s1_w, s1_h, sw, sh) } else { 1.0 }
    if (resize_target_win == 2.0) { render_window_active_resize_outline(s2_x, s2_y, s2_w, s2_h, sw, sh) } else { 1.0 }
    if (resize_target_win == 3.0) { render_window_active_resize_outline(s3_x, s3_y, s3_w, s3_h, sw, sh) } else { 1.0 }
    if (resize_target_win == 4.0) { render_window_active_resize_outline(s4_x, s4_y, s4_w, s4_h, sw, sh) } else { 1.0 }

    render_system_bars(sw, sh)
    render_toroidal_dpad(sw, sh)
}
