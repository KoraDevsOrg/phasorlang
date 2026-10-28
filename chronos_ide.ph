// ===============================================================================
// CHRONOS IDE — APLICATIVO PRINCIPAL (chronos_ide.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Soberana: 100% Código PhasorLang Puro & Modular
// Hito 4: Viewport Aislado, Scissor Clipping Suave PVM y Scroll Inteligente (Thumb Dragging)
// Captura Nativa de Periféricos (Mouse Clicks, Gamepad USB & Teclado R229..R255)
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

// Screen 1: Editor de Código
signal s1_x = 50.0
signal s1_y = 80.0
signal s1_w = 480.0
signal s1_h = 360.0
signal s1_min = 0.0
signal s1_sc_x = 0.0
signal s1_sc_y = 0.0

// Screen 2: Explorador de Archivos
signal s2_x = 560.0
signal s2_y = 80.0
signal s2_w = 320.0
signal s2_h = 360.0
signal s2_min = 0.0
signal s2_sc_x = 0.0
signal s2_sc_y = 0.0

// Screen 3: Live Preview & Visor Científico
signal s3_x = 910.0
signal s3_y = 80.0
signal s3_w = 360.0
signal s3_h = 360.0
signal s3_min = 0.0
signal s3_sc_x = 0.0
signal s3_sc_y = 0.0

// Mutex de Interacción (Arrastre vs Redimensión 8D vs Scrollbar Thumb vs Fondo)
signal drag_target_win = 0.0     // 0=Ninguna, 1=Screen1, 2=Screen2, 3=Screen3
signal resize_target_win = 0.0   // 0=Ninguna, 1=Screen1, 2=Screen2, 3=Screen3
signal resize_target_dir = 0.0   // 0=None, 1=E, 2=S, 3=W, 4=N, 5=SE, 6=SW, 7=NE, 8=NW
signal drag_offset_x = 0.0
signal drag_offset_y = 0.0
signal resize_orig_x = 0.0
signal resize_orig_y = 0.0
signal resize_orig_w = 0.0
signal resize_orig_h = 0.0
signal resize_orig_mx = 0.0
signal resize_orig_my = 0.0
signal prev_click_down = 0.0     // Edge-trigger para botones de un solo clic

// Interacción de Scrollbars 2D (Hito 4)
signal sb_win = 0.0              // Ventana cuyo thumb se arrastra (0=ninguna)
signal sb_axis = 0.0             // 1=vertical, 2=horizontal
signal sb_grab = 0.0             // Offset del puntero dentro del thumb
signal sb_scan_win = 0.0         // Resultado del último escaneo de barras
signal sb_scan_axis = 0.0
signal sb_scan_hit = 0.0         // 0=nada, 1=thumb, 2=pista
signal sb_scan_blocked = 0.0     // Z-order: la ventana superior ya capturó el puntero

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
    res
}

win_y(id) = {
    res = s1_y
    if (id == 2.0) { res = s2_y } else { 1.0 }
    if (id == 3.0) { res = s3_y } else { 1.0 }
    res
}

win_w(id) = {
    res = s1_w
    if (id == 2.0) { res = s2_w } else { 1.0 }
    if (id == 3.0) { res = s3_w } else { 1.0 }
    res
}

win_h(id) = {
    res = s1_h
    if (id == 2.0) { res = s2_h } else { 1.0 }
    if (id == 3.0) { res = s3_h } else { 1.0 }
    res
}

win_min(id) = {
    res = s1_min
    if (id == 2.0) { res = s2_min } else { 1.0 }
    if (id == 3.0) { res = s3_min } else { 1.0 }
    res
}

win_sc_x(id) = {
    res = s1_sc_x
    if (id == 2.0) { res = s2_sc_x } else { 1.0 }
    if (id == 3.0) { res = s3_sc_x } else { 1.0 }
    res
}

win_sc_y(id) = {
    res = s1_sc_y
    if (id == 2.0) { res = s2_sc_y } else { 1.0 }
    if (id == 3.0) { res = s3_sc_y } else { 1.0 }
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
    res
}

win_ch(id) = {
    res = 560.0
    if (id == 2.0) { res = explorer_content_h() } else { 1.0 }
    if (id == 3.0) { res = 340.0 } else { 1.0 }
    res
}

win_hx(id, sw) = {
    wx = win_x(id)
    ww = win_w(id)
    spatial_world_to_screen_x(wx, ww, sw)
}

win_hy(id, sh) = {
    wy = win_y(id)
    wh = win_h(id)
    spatial_world_to_screen_y(wy, wh, sh)
}

set_win_sc(id, dx, dy) = {
    if (id == 1.0) { s1_sc_x = dx; s1_sc_y = dy } else { 1.0 }
    if (id == 2.0) { s2_sc_x = dx; s2_sc_y = dy } else { 1.0 }
    if (id == 3.0) { s3_sc_x = dx; s3_sc_y = dy } else { 1.0 }
    1.0
}

add_win_sc(id, dx, dy) = {
    tx = win_sc_x(id) + dx
    ty = win_sc_y(id) + dy
    set_win_sc(id, tx, ty)
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
    tx = win_sc_x(id)
    ty = win_sc_y(id)
    dx = sb_clamp(tx, val)
    dy = sb_clamp(ty, delta)
    set_win_sc(id, dx, dy)
}

clamp_all_scrolls() = {
    clamp_win_scroll(1.0)
    clamp_win_scroll(2.0)
    clamp_win_scroll(3.0)
    1.0
}

top_win_at(mx, my, sw, sh) = {
    target = 0.0
    hit = window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my)
    if (hit == 1.0) { target = 1.0 } else { 1.0 }
    hit = window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my)
    if (hit == 1.0) { target = 2.0 } else { 1.0 }
    hit = window_hit_body(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my)
    if (hit == 1.0) { target = 3.0 } else { 1.0 }
    target
}

sb_axis_for(id) = {
    delta = 0.0
    if (sb_win == id) { delta = sb_axis } else { 1.0 }
    delta
}

// -------------------------------------------------------------------------------
// 4. INTERACCIÓN DE SCROLLBARS: ESCANEO Y ARRASTRE DE THUMB (UI_SCROLLBAR.PH)
// -------------------------------------------------------------------------------
sb_scan_one(id, mx, my, sw, sh) = {
    if (sb_scan_blocked == 0.0) {
        wx = win_x(id)
        wy = win_y(id)
        w = win_w(id)
        h = win_h(id)
        is_min = win_min(id)
        if (window_hit_body(wx, wy, w, h, sw, sh, is_min, mx, my) == 1.0) {
            sb_scan_blocked = 1.0
            if (is_min == 0.0) {
                hx = win_hx(id, sw)
                hy = win_hy(id, sh)
                top = win_top(id)
                cw = win_cw(id)
                ch = win_ch(id)
                sc_y = win_sc_y(id)
                hit = sb_hit_test_v(hx, hy, w, h, top, cw, ch, sc_y, mx, my)
                if (hit > 0.0) {
                    sb_scan_win = id
                    sb_scan_axis = 1.0
                    sb_scan_hit = hit
                } else {
                    sc_x = win_sc_x(id)
                    hit = sb_hit_test_h(hx, hy, w, h, top, cw, ch, sc_x, mx, my)
                    if (hit > 0.0) {
                        sb_scan_win = id
                        sb_scan_axis = 2.0
                        sb_scan_hit = hit
                    } else { 1.0 }
                }
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

sb_scan(mx, my, sw, sh) = {
    sb_scan_win = 0.0
    sb_scan_axis = 0.0
    sb_scan_hit = 0.0
    sb_scan_blocked = 0.0
    sb_scan_one(3.0, mx, my, sw, sh)
    sb_scan_one(2.0, mx, my, sw, sh)
    sb_scan_one(1.0, mx, my, sw, sh)
    1.0
}

sb_apply_drag(mx, my, sw, sh) = {
    id = sb_win
    hx = win_hx(id, sw)
    hy = win_hy(id, sh)
    w = win_w(id)
    h = win_h(id)
    top = win_top(id)
    cw = win_cw(id)
    ch = win_ch(id)
    if (sb_axis == 1.0) {
        cur_x = win_sc_x(id)
        val = sb_apply_drag_v(hx, hy, w, h, top, cw, ch, sb_grab, my)
        set_win_sc(id, cur_x, val)
    } else {
        cur_y = win_sc_y(id)
        val = sb_apply_drag_h(hx, hy, w, h, top, cw, ch, sb_grab, mx)
        set_win_sc(id, val, cur_y)
    }
    1.0
}

sb_try_start(mx, my, sw, sh) = {
    handled = 0.0
    sb_scan(mx, my, sw, sh)
    if (sb_scan_hit > 0.0) {
        id = sb_scan_win
        hx = win_hx(id, sw)
        hy = win_hy(id, sh)
        w = win_w(id)
        h = win_h(id)
        top = win_top(id)
        cw = win_cw(id)
        ch = win_ch(id)
        hit_type = sb_scan_hit
        if (sb_scan_axis == 1.0) {
            sc_y = win_sc_y(id)
            sb_grab = sb_calc_grab_v(hx, hy, w, h, top, cw, ch, sc_y, hit_type, my)
        } else {
            sc_x = win_sc_x(id)
            sb_grab = sb_calc_grab_h(hx, hy, w, h, top, cw, ch, sc_x, hit_type, mx)
        }
        sb_win = id
        sb_axis = sb_scan_axis
        sb_apply_drag(mx, my, sw, sh)
        handled = 1.0
    } else { 1.0 }
    handled
}

// -------------------------------------------------------------------------------
// 5. MÓDULO SCREEN 1: EDITOR DE CÓDIGO (VIEWPORT CON SCISSOR CLIPPING SUAVE)
// -------------------------------------------------------------------------------
render_editor_toolbar(hx, hy, w) = {
    rect(hx + 1.0, hy + 28.0, w - 2.0, 26.0, 0x161B22)
    line(hx + 1.0, hy + 54.0, hx + w - 1.0, hy + 54.0, 0x30363D)
    text("Archivo", hx + 12.0, hy + 35.0, 9, 0x8B949E)
    text("Editar", hx + 65.0, hy + 35.0, 9, 0x8B949E)
    text("Ver", hx + 110.0, hy + 35.0, 9, 0x8B949E)
    text("Compilar HTML", hx + 140.0, hy + 35.0, 9, 0x3FB950)
    if (exp_edit_mod == 1.0) {
        ui_badge_box(hx + 236.0, hy + 33.0, 48.0, 0x1F6FEB)
        text("MOD ●", hx + 242.0, hy + 36.0, 8, 0xF2CC60)
    } else { 1.0 }
    1.0
}

render_screen_editor_content(hx, hy, w, h, is_min, dx, dy, act) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(1.0)
        cw = win_cw(1.0)
        ch = win_ch(1.0)

        // Fondo del viewport del editor
        rect(hx + 1.0, hy + 54.0, w - 2.0, h - 55.0, 0x090D13)

        // Coordenadas de inicio del código y del gutter
        ty = hy + 66.0 - dy
        tx = hx + 42.0 - dx
        gx = hx + 12.0

        // 1. DIBUJAR CÓDIGO CON SCISSOR CLIPPING SUAVE (PÍXEL A PÍXEL DETRÁS DEL GUTTER Y MARCO)
        clip(hx + 38.0, hy + 54.0, w - 50.0, h - 66.0)
        if (exp_ed_file == 1.0) {
            text("// PLANTILLA ESTANDAR: NUEVO PROYECTO (main.ph)", tx, ty, 9, 0x6E7681)
            text("import \"lib/ui_spatial_main.ph\"", tx, ty + 18.0, 9, 0x79C0FF)
            text("import \"lib/ui_window_frame.ph\"", tx, ty + 36.0, 9, 0x79C0FF)
            text("import \"lib/ui_scrollbar.ph\"", tx, ty + 54.0, 9, 0x79C0FF)
            text("signal s1_x = 120.0; signal s1_y = 70.0", tx, ty + 72.0, 9, 0xF2CC60)
            text("render_screen_1_content(hx, hy, w, h, ...) = {", tx, ty + 90.0, 9, 0x58A6FF)
            text("    sb_begin_clip(hx, hy, w, h, top, cw, ch)", tx, ty + 108.0, 9, 0x3FB950)
            text("    // Screen 1 en blanco listo para desarrollar", tx, ty + 126.0, 9, 0x6E7681)
            text("    sb_end_clip()", tx, ty + 144.0, 9, 0x3FB950)
            text("    ui_subscreen_scrollbars(hx, hy, w, h, ..., 1.0)", tx, ty + 162.0, 9, 0x58A6FF)
            text("}", tx, ty + 180.0, 9, 0x58A6FF)
            text("screen main { spatial_main_render(R250, R251) }", tx, ty + 198.0, 9, 0xF2CC60)
        } else { 1.0 }

        if (exp_ed_file == 2.0) {
            text("// LIB/UI_COMPONENTS.PH — COMPONENTES GENERICOS", tx, ty, 9, 0x6E7681)
            text("ui_card(orig_x, orig_y, orig_w, orig_h, bg, border)", tx, ty + 18.0, 9, 0x3FB950)
            text("ui_divider(orig_x, orig_y, orig_w, col)", tx, ty + 36.0, 9, 0x3FB950)
            text("ui_badge_box(orig_x, orig_y, orig_w, bg_col)", tx, ty + 54.0, 9, 0x58A6FF)
            text("ui_button_box(orig_x, orig_y, orig_w, orig_h, act, bg)", tx, ty + 72.0, 9, 0x58A6FF)
            text("ui_icon_box(orig_x, orig_y, orig_w, act)", tx, ty + 90.0, 9, 0x58A6FF)
            text("ui_file_icon(orig_x, orig_y, is_folder, is_open, col)", tx, ty + 108.0, 9, 0xF2CC60)
            text("ui_tree_row(orig_x, orig_y, orig_w, depth, ...)", tx, ty + 126.0, 9, 0x79C0FF)
            text("ui_tree_hit(orig_x, orig_y, orig_w, mx, my)", tx, ty + 144.0, 9, 0x79C0FF)
            text("ui_context_box(orig_x, orig_y, orig_w, orig_h)", tx, ty + 162.0, 9, 0x3FB950)
            text("ui_hit_box(orig_x, orig_y, orig_w, orig_h, mx, my)", tx, ty + 180.0, 9, 0x3FB950)
            text("// Registros aislados Zero-GC sin colision con hx/hy", tx, ty + 198.0, 9, 0x58A6FF)
        } else { 1.0 }

        if (exp_ed_file == 3.0) {
            text("// LIB/UI_SCREEN_EXPLORER.PH — EXPLORADOR IDE", tx, ty, 9, 0x6E7681)
            text("import \"lib/ui_components.ph\"", tx, ty + 18.0, 9, 0x79C0FF)
            text("signal exp_sel = 12.0; signal exp_d1 = 1.0", tx, ty + 36.0, 9, 0xF2CC60)
            text("render_explorer_toolbar(hx, hy, w) = { ... }", tx, ty + 54.0, 9, 0x58A6FF)
            text("handle_explorer_click(hx, hy, w, h, ...) = {", tx, ty + 72.0, 9, 0x58A6FF)
            text("    handle_explorer_menu_click(hx, hy, h, mx, my)", tx, ty + 90.0, 9, 0x3FB950)
            text("    handle_explorer_toolbar_click(hx, hy, mx, my)", tx, ty + 108.0, 9, 0x3FB950)
            text("    handle_explorer_tree_click(hx, hy, w, ...)", tx, ty + 126.0, 9, 0x3FB950)
            text("}", tx, ty + 144.0, 9, 0x58A6FF)
            text("render_screen_explorer_content(...) = {", tx, ty + 162.0, 9, 0x58A6FF)
            text("    ui_card(hx + 6.0 - dx, hy + 58.0 - dy, ...)", tx, ty + 180.0, 9, 0xF2CC60)
            text("}", tx, ty + 198.0, 9, 0x58A6FF)
        } else { 1.0 }

        if (exp_ed_file == 4.0) {
            text("// NUEVO MODULO CREADO DESDE EL EXPLORADOR (.ph)", tx, ty, 9, 0x6E7681)
            text("import \"lib/ui_components.ph\"", tx, ty + 18.0, 9, 0x79C0FF)
            text("import \"lib/ui_scrollbar.ph\"", tx, ty + 36.0, 9, 0x79C0FF)
            text("signal mod_state = 1.0", tx, ty + 54.0, 9, 0xF2CC60)
            text("render_custom_module(hx, hy, w, h) = {", tx, ty + 72.0, 9, 0x58A6FF)
            text("    ui_card(hx + 12.0, hy + 12.0, w - 24.0, 80.0, 0x0D1117, 0x58A6FF)", tx, ty + 90.0, 9, 0x3FB950)
            text("    ui_badge_box(hx + 20.0, hy + 20.0, 96.0, 0x238636)", tx, ty + 108.0, 9, 0x3FB950)
            text("    ui_button_box(hx + 20.0, hy + 46.0, 84.0, 22.0, 1.0, 0x1F6FEB)", tx, ty + 126.0, 9, 0x58A6FF)
            text("    1.0", tx, ty + 144.0, 9, 0xF2CC60)
            text("}", tx, ty + 162.0, 9, 0x58A6FF)
            text("// Listo para importar con: import \"samples/nuevo_modulo.ph\"", tx, ty + 180.0, 9, 0x6E7681)
            text("screen main { render_custom_module(20.0, 20.0, 400.0, 240.0) }", tx, ty + 198.0, 9, 0xF2CC60)
        } else { 1.0 }

        if (exp_ed_file == 0.0) {
            text("// CHRONOS IDE — AUTONOMO 100% PHASORLANG", tx, ty, 9, 0x6E7681)
            text("import \"lib/ui_spatial_main.ph\"", tx, ty + 18.0, 9, 0x79C0FF)
            text("import \"lib/ui_window_frame.ph\"", tx, ty + 36.0, 9, 0x79C0FF)
            text("import \"lib/ui_screen_explorer.ph\"", tx, ty + 54.0, 9, 0x79C0FF)
            text("signal t = 0.0", tx, ty + 72.0, 9, 0xF2CC60)
            text("screen main {", tx, ty + 90.0, 9, 0x58A6FF)
            text("    sw = R250; sh = R251; pd = R254", tx, ty + 108.0, 9, 0x3FB950)
            text("    left = R254; right = R248; mid = R249", tx, ty + 126.0, 9, 0x3FB950)
            text("    if (R240 > 0.0) { motor_x = R241 }", tx, ty + 144.0, 9, 0x79C0FF)
            text("    spatial_main_render(sw, sh)", tx, ty + 162.0, 9, 0x58A6FF)
            text("    ui_subscreen_scrollbars(...)", tx, ty + 180.0, 9, 0x58A6FF)
            text("}", tx, ty + 198.0, 9, 0x58A6FF)
        } else { 1.0 }

        // Bloque dinámico inyectado cuando el usuario activa Modo Edición (✎Edit)
        if (exp_edit_mod == 1.0) {
            text("// [EDICION EN VIVO ●] Bloque insertado desde el Explorador:", tx, ty + 216.0, 9, 0xF2CC60)
            text("ui_card(tx, ty + 120.0, 320.0, 48.0, 0x162234, 0x58A6FF)", tx, ty + 234.0, 9, 0x3FB950)
        } else { 1.0 }
        unclip()

        // 2. GUTTER OPACO Y NÚMEROS DE LÍNEA CON CLIPPING VERTICAL SUAVE
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
        text("11", gx - 5.0, ty + 180.0, 9, 0x58A6FF)
        text("12", gx - 5.0, ty + 198.0, 9, 0x58A6FF)
        if (exp_edit_mod == 1.0) {
            text("13", gx - 5.0, ty + 216.0, 9, 0xF2CC60)
            text("14", gx - 5.0, ty + 234.0, 9, 0x3FB950)
        } else { 1.0 }
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
    text("📝 Screen 1: Editor de Código", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    act = sb_axis_for(1.0)
    render_screen_editor_content(hx, hy, s1_w, s1_h, s1_min, s1_sc_x, s1_sc_y, act)
    render_window_borders(hx, hy, s1_w, s1_h, s1_min)
}

// -------------------------------------------------------------------------------
// 6. MÓDULO SCREEN 2: EXPLORADOR DE ARCHIVOS (IMPORTADO DE LIB/UI_SCREEN_EXPLORER.PH)
// -------------------------------------------------------------------------------
render_screen_2(sw, sh) = {
    render_window_frame(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min)
    hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
    hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
    text("📁 Screen 2: Explorador de Archivos", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    act = sb_axis_for(2.0)
    render_screen_explorer_content(hx, hy, s2_w, s2_h, s2_min, s2_sc_x, s2_sc_y, act)
    render_window_borders(hx, hy, s2_w, s2_h, s2_min)
}

// -------------------------------------------------------------------------------
// 7. MÓDULO SCREEN 3: LIVE PREVIEW PVM (VIEWPORT CON SCISSOR CLIPPING)
// -------------------------------------------------------------------------------
render_screen_preview_content(hx, hy, w, h, is_min, dx, dy, act, t_frame, gp_conn, right_click) = {
    if (is_min == 1.0) { 0.0 } else {
        top = win_top(3.0)
        cw = win_cw(3.0)
        ch = win_ch(3.0)
        rect(hx + 1.0, hy + 28.0, w - 2.0, h - 29.0, 0x070A0E)

        ct = hy + 28.0
        cb = (hy + h) - 12.0

        sb_begin_clip(hx, hy, w, h, top, cw, ch)

        // Fasor Circular Reactivo (recorte suave píxel a píxel detrás del marco)
        tx = hx + 125.0 - dx
        ty = hy + 80.0 - dy
        if ((ty + 36.0) >= ct) {
            if ((ty - 36.0) <= cb) {
                circle(tx, ty, 32.0, 0x1F6FEB)
                circle(tx, ty, 24.0, 0x238636)
                ang = t_frame * 0.05
                fx = tx + (cos(ang) * 24.0)
                fy = ty + (sin(ang) * 24.0)
                line(tx, ty, fx, fy, 0x58A6FF)
                circle(fx, fy, 3.5, 0x3FB950)
            } else { 1.0 }
        } else { 1.0 }

        // Telemetría Directa PVM (aislada estrictamente dentro de Screen 3)
        tx = hx + 16.0 - dx
        ty = hy + 138.0 - dy
        if (vp_line_visible(ty, ct, cb) == 1.0) {
            text("MONITOR HARDWARE DIRECTO (PVM)", tx, ty, 9, 0x58A6FF)
        } else { 1.0 }
        if (vp_line_visible(ty + 18.0, ct, cb) == 1.0) {
            if (gp_conn > 0.0) {
                text("Gamepad USB: CONECTADO [R240=1.0]", tx, ty + 18.0, 8, 0x3FB950)
            } else {
                text("Gamepad USB: Desconectado [R240=0.0]", tx, ty + 18.0, 8, 0x8B949E)
            }
        } else { 1.0 }
        if (vp_line_visible(ty + 36.0, ct, cb) == 1.0) {
            if (right_click > 0.0) {
                text("Clic Secundario (Der): ACTIVO [R248]", tx, ty + 36.0, 8, 0xF2CC60)
            } else {
                text("Mouse: Izq=R254 | Der=R248 | Med=R249", tx, ty + 36.0, 8, 0x8B949E)
            }
        } else { 1.0 }
        if (vp_line_visible(ty + 54.0, ct, cb) == 1.0) {
            text("Rueda Scroll 2D: R255 (Y) / R247 (X)", tx, ty + 54.0, 8, 0x58A6FF)
        } else { 1.0 }
        if (vp_line_visible(ty + 72.0, ct, cb) == 1.0) {
            text("Zero-GC: 0 pausas | 120 FPS Nativos", tx, ty + 72.0, 8, 0x3FB950)
        } else { 1.0 }

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
    act = sb_axis_for(3.0)
    render_screen_preview_content(hx, hy, s3_w, s3_h, s3_min, s3_sc_x, s3_sc_y, act, val, gp_conn, right_click)
    render_window_borders(hx, hy, s3_w, s3_h, s3_min)
}

// -------------------------------------------------------------------------------
// 8. BARRAS FIJAS DEL SISTEMA (MENUBAR Y STATUSBAR)
// -------------------------------------------------------------------------------
render_system_bars(sw, sh) = {
    // Barra de menús superior
    rect(0.0, 0.0, sw, 28.0, 0x090D13)
    line(0.0, 28.0, sw, 28.0, 0x21262D)
    text("⚡ CHRONOS IDE — KORADEVS ECOSYSTEM", 16.0, 8.0, 10, 0x58A6FF)
    text("HITO 4: VIEWPORT AISLADO | CLIPPING ESTRICTO | THUMB DRAGGING", sw - 480.0, 9.0, 8, 0x8B949E)

    // Barra de estado inferior
    ty = sh - 24.0
    rect(0.0, ty, sw, 24.0, 0x090D13)
    line(0.0, ty, sw, ty, 0x21262D)
    text("Hito 4 Listo | Scroll 2D: Rueda y Arrastre de Scrollbar | Resize 8D | Scissor Clipping Zero-GC", 16.0, ty + 6.0, 8, 0x3FB950)
    1.0
}

// -------------------------------------------------------------------------------
// 9. DISPATCHERS MODULARES DE ENTRADA E INTERACCIÓN
// -------------------------------------------------------------------------------
handle_responsive_layout(sw, sh) = {
    if (sw < 768.0) {
        s1_w = sw - 16.0; s1_h = sh - 80.0
        s2_w = sw - 16.0; s2_h = sh - 80.0
        s3_w = sw - 16.0; s3_h = sh - 80.0
    } else { 1.0 }
    1.0
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
        if (id > 0.0) {
            add_win_sc(id, 0.0, val)
            clamp_win_scroll(id)
        } else { 1.0 }
    } else { 1.0 }

    if (wh_x != 0.0) {
        val = clamp_val(wh_x * 0.25, -24.0, 24.0)
        id = top_win_at(mx, my, sw, sh)
        if (id > 0.0) {
            add_win_sc(id, val, 0.0)
            clamp_win_scroll(id)
        } else { 1.0 }
    } else { 1.0 }
    1.0
}

apply_active_resize(mx, my) = {
    dx = mx - resize_orig_mx
    dy = my - resize_orig_my
    val = 220.0
    delta = 160.0
    if (resize_target_win == 1.0) { val = 280.0; delta = 180.0 } else { 1.0 }

    w = calc_resize_w(resize_target_dir, resize_orig_w, dx, val)
    hx = calc_resize_x(resize_target_dir, resize_orig_x, resize_orig_w, w)
    h = calc_resize_h(resize_target_dir, resize_orig_h, dy, delta)
    hy = calc_resize_y(resize_target_dir, resize_orig_y, resize_orig_h, h)

    if (resize_target_win == 1.0) { s1_x = hx; s1_y = hy; s1_w = w; s1_h = h } else { 1.0 }
    if (resize_target_win == 2.0) { s2_x = hx; s2_y = hy; s2_w = w; s2_h = h } else { 1.0 }
    if (resize_target_win == 3.0) { s3_x = hx; s3_y = hy; s3_w = w; s3_h = h } else { 1.0 }
    clamp_win_scroll(resize_target_win)
    1.0
}

apply_active_drag(mx, my, pan_x, pan_y) = {
    tx = (mx - drag_offset_x) - pan_x
    ty = (my - drag_offset_y) - pan_y
    if (drag_target_win == 1.0) { s1_x = tx; s1_y = ty } else { 1.0 }
    if (drag_target_win == 2.0) { s2_x = tx; s2_y = ty } else { 1.0 }
    if (drag_target_win == 3.0) { s3_x = tx; s3_y = ty } else { 1.0 }
    1.0
}

check_minimize_buttons(mx, my, sw, sh) = {
    handled = 0.0
    if (window_hit_min_btn(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) { s1_min = 1.0 - s1_min; handled = 1.0 } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_min_btn(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) { s2_min = 1.0 - s2_min; handled = 1.0 } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_min_btn(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) { s3_min = 1.0 - s3_min; handled = 1.0 } else { 1.0 }
    } else { 1.0 }
    handled
}

check_resize_start(mx, my, sw, sh) = {
    handled = 0.0
    if (s1_min == 0.0) {
        dir = window_hit_edge_8d(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my)
        if (dir > 0.0) {
            resize_target_win = 1.0; resize_target_dir = dir
            resize_orig_x = s1_x; resize_orig_y = s1_y
            resize_orig_w = s1_w; resize_orig_h = s1_h
            resize_orig_mx = mx; resize_orig_my = my
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s2_min == 0.0) {
            dir = window_hit_edge_8d(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my)
            if (dir > 0.0) {
                resize_target_win = 2.0; resize_target_dir = dir
                resize_orig_x = s2_x; resize_orig_y = s2_y
                resize_orig_w = s2_w; resize_orig_h = s2_h
                resize_orig_mx = mx; resize_orig_my = my
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s3_min == 0.0) {
            dir = window_hit_edge_8d(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my)
            if (dir > 0.0) {
                resize_target_win = 3.0; resize_target_dir = dir
                resize_orig_x = s3_x; resize_orig_y = s3_y
                resize_orig_w = s3_w; resize_orig_h = s3_h
                resize_orig_mx = mx; resize_orig_my = my
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    handled
}

check_drag_start(mx, my, sw, sh) = {
    handled = 0.0
    if (window_hit_title(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
        drag_target_win = 1.0
        hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
        hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
        drag_offset_x = mx - hx; drag_offset_y = my - hy
        handled = 1.0
    } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_title(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) {
            drag_target_win = 2.0
            hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
            hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
            drag_offset_x = mx - hx; drag_offset_y = my - hy
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (window_hit_title(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) {
            drag_target_win = 3.0
            hx = spatial_world_to_screen_x(s3_x, s3_w, sw)
            hy = spatial_world_to_screen_y(s3_y, s3_h, sh)
            drag_offset_x = mx - hx; drag_offset_y = my - hy
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    handled
}

handle_workspace_interactions(mx, my, sw, sh, pd, pan_x, pan_y) = {
    if (pd == 1.0) {
        handled = 0.0
        // 1. Arrastre activo de scrollbar thumb (prioridad máxima)
        if (sb_win > 0.0) {
            sb_apply_drag(mx, my, sw, sh)
            handled = 1.0
        } else { 1.0 }

        // 2. Redimensionamiento activo 8D
        if (handled == 0.0) {
            if (resize_target_win > 0.0) {
                apply_active_resize(mx, my)
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }

        // 3. Arrastre activo de ventana
        if (handled == 0.0) {
            if (drag_target_win > 0.0) {
                apply_active_drag(mx, my, pan_x, pan_y)
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }

        // 4. Inicio de nuevas interacciones con clic fresco
        if (handled == 0.0) {
            if (my > 28.0) { if (my < (sh - 24.0)) {
                if (prev_click_down == 0.0) {
                    handled = check_minimize_buttons(mx, my, sw, sh)
                } else { 1.0 }

                // Hit testing de scrollbar (thumb o pista) tiene prioridad sobre el borde
                if (handled == 0.0) {
                    handled = sb_try_start(mx, my, sw, sh)
                } else { 1.0 }

                if (handled == 0.0) {
                    handled = check_resize_start(mx, my, sw, sh)
                } else { 1.0 }

                if (handled == 0.0) {
                    handled = check_drag_start(mx, my, sw, sh)
                } else { 1.0 }

                // Interacción interna de componentes en Screen 1 (Editor) y Screen 2 (Explorador)
                if (handled == 0.0) {
                    if (prev_click_down == 0.0) {
                        id = top_win_at(mx, my, sw, sh)
                        if (id == 1.0) {
                            if (s1_min == 0.0) {
                                hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
                                hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
                                hit = ui_hit_box(hx + 8.0, hy + 28.0, 52.0, 26.0, mx, my)
                                if (hit == 1.0) { exp_ed_file = 1.0; exp_sel = 11.0; handled = 1.0 } else { 1.0 }
                                hit = ui_hit_box(hx + 62.0, hy + 28.0, 44.0, 26.0, mx, my)
                                if (hit == 1.0) { exp_edit_mod = 1.0 - exp_edit_mod; handled = 1.0 } else { 1.0 }
                            } else { 1.0 }
                        } else { 1.0 }
                        if (id == 2.0) {
                            if (s2_min == 0.0) {
                                hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
                                hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
                                handled = handle_explorer_click(hx, hy, s2_w, s2_h, s2_sc_x, s2_sc_y, mx, my)
                                clamp_win_scroll(2.0)
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }
                } else { 1.0 }

                // Arrastre del fondo espacial si no tocó ventana
                if (handled == 0.0) {
                    if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 0.0) {
                        if (window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my) == 0.0) {
                            if (window_hit_body(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my) == 0.0) {
                                spatial_main_handle_input(mx, my, pd, 1.0)
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }
                } else { 1.0 }
            } } else { 1.0 }
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
// 10. RESOLUCIÓN DE FORMA DEL CURSOR REACTIVO (R229 & R256)
// -------------------------------------------------------------------------------
resolve_window_cursor(wx, wy, ww, wh, sw, sh, is_min, mx, my, id) = {
    shape = -1.0
    // 1. Botón de minimizado
    if (window_hit_min_btn(wx, wy, ww, wh, sw, sh, mx, my) == 1.0) {
        shape = 1.0 // pointer
    } else {
        hx = spatial_world_to_screen_x(wx, ww, sw)
        hy = spatial_world_to_screen_y(wy, wh, sh)
        top = win_top(id)
        cw = win_cw(id)
        ch = win_ch(id)

        // 2. Scrollbars tienen prioridad visual y de cursor (pointer)
        if (is_min == 0.0) {
            hit_v = sb_hit_test_v(hx, hy, ww, wh, top, cw, ch, win_sc_y(id), mx, my)
            if (hit_v > 0.0) {
                shape = 1.0 // pointer sobre scrollbar vertical
            } else {
                hit_h = sb_hit_test_h(hx, hy, ww, wh, top, cw, ch, win_sc_x(id), mx, my)
                if (hit_h > 0.0) {
                    shape = 1.0 // pointer sobre scrollbar horizontal
                } else { 1.0 }
            }
        } else { 1.0 }

        if (shape < 0.0) {
            // 3. Bordes y esquinas de redimensionamiento 8D
            dir = window_hit_edge_8d(wx, wy, ww, wh, sw, sh, is_min, mx, my)
            if (dir > 0.0) {
                shape = window_cursor_from_dir(dir)
            } else {
                // 4. Barra de título para arrastre
                if (window_hit_title(wx, wy, ww, wh, sw, sh, mx, my) == 1.0) {
                    shape = 3.0 // move
                } else {
                    // 5. Cuerpo de la ventana
                    if (window_hit_body(wx, wy, ww, wh, sw, sh, is_min, mx, my) == 1.0) {
                        if (is_min == 0.0) {
                            if (id == 1.0) {
                                if (my >= (hy + 28.0)) {
                                    if (my < (hy + 54.0)) {
                                        shape = 1.0 // pointer en menú toolbar
                                    } else {
                                        shape = 2.0 // text I-Beam en editor
                                    }
                                } else {
                                    shape = 0.0
                                }
                            } else {
                                if (id == 2.0) {
                                    shape = 1.0 // pointer en explorador
                                } else {
                                    shape = 0.0 // default en preview
                                }
                            }
                        } else {
                            shape = 0.0
                        }
                    } else { 1.0 }
                }
            }
        } else { 1.0 }
    }
    shape
}

compute_pointer_cursor(mx, my, sw, sh, pd) = {
    shape = 0.0
    if (pd == 1.0) {
        if (sb_win > 0.0) {
            shape = 1.0 // pointer durante arrastre de scrollbar
        } else {
            if (resize_target_win > 0.0) {
                shape = window_cursor_from_dir(resize_target_dir)
            } else {
                if (drag_target_win > 0.0) {
                    shape = 3.0 // move
                } else {
                    if (spatial_is_panning == 1.0) {
                        shape = 8.0 // grabbing
                    } else { 1.0 }
                }
            }
        }
    } else {
        if (my < 28.0) {
            shape = 1.0 // Barra superior
        } else {
            if (my > (sh - 24.0)) {
                shape = 0.0 // Barra inferior
            } else {
                // Prioridad Z-order: Screen 3 -> Screen 2 -> Screen 1
                shape = resolve_window_cursor(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my, 3.0)
                if (shape < 0.0) {
                    shape = resolve_window_cursor(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my, 2.0)
                    if (shape < 0.0) {
                        shape = resolve_window_cursor(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my, 1.0)
                        if (shape < 0.0) {
                            shape = 0.0
                        } else { 1.0 }
                    } else { 1.0 }
                } else { 1.0 }
            }
        }
    }
    shape
}

// -------------------------------------------------------------------------------
// 11. ORQUESTADOR PRINCIPAL (SCREEN MAIN)
// -------------------------------------------------------------------------------
screen main {
    // 1. Inicialización y tiempo fasorial
    t_global = t_global + 1.0
    if (t_global <= 1.0) { spatial_main_init(3600.0, 2400.0, 80.0) } else { 1.0 }

    // 2. Lectura directa de registros de hardware (PVM ISA)
    sw = R250; sh = R251; mx = R252; my = R253; pd = R254
    wh_y = R255; wh_x = R247; right_click = R248; mid_click = R249
    gp_conn = R240; dx = R241; dy = R242

    if (sw < 240.0) { sw = 800.0 } else { 1.0 }
    if (sh < 240.0) { sh = 600.0 } else { 1.0 }
    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()

    // 3. Layout responsive para móvil
    handle_responsive_layout(sw, sh)

    // 4. Navegación por Gamepad USB
    handle_gamepad_navigation(gp_conn, dx, dy)

    // 5. Scroll 2D con auto-ajuste inteligente por rueda
    handle_scroll_input(mx, my, sw, sh, wh_y, wh_x)

    // 6. Mutex de interacción (Thumb Drag vs Arrastre de Ventana vs Redimensión 8D vs Fondo)
    handle_workspace_interactions(mx, my, sw, sh, pd, pan_x, pan_y)
    if (right_click > 0.0) {
        id = top_win_at(mx, my, sw, sh)
        if (id == 2.0) {
            if (s2_min == 0.0) {
                hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
                hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
                handle_explorer_tree_click(hx, hy, s2_w, s2_h, s2_sc_x, s2_sc_y, mx, my)
                exp_menu_open = 1.0
                exp_menu_x = 18.0
                exp_menu_y = clamp_val(my - hy, 56.0, s2_h - 140.0)
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }

    // 7. Registro de forma de cursor nativo (R229 canonical 8-bit)
    shape = compute_pointer_cursor(mx, my, sw, sh, pd)
    R229 = shape

    // 8. Canalización de renderizado a 120 FPS Zero-GC
    spatial_main_render(sw, sh)
    render_screen_1(sw, sh)
    render_screen_2(sw, sh)
    render_screen_3(sw, sh, t_global, gp_conn, right_click, mid_click)

    // Feedback visual y cinemático de redimensionamiento activo 8D (borde cian brillante)
    if (resize_target_win == 1.0) { render_window_active_resize_outline(s1_x, s1_y, s1_w, s1_h, sw, sh) } else { 1.0 }
    if (resize_target_win == 2.0) { render_window_active_resize_outline(s2_x, s2_y, s2_w, s2_h, sw, sh) } else { 1.0 }
    if (resize_target_win == 3.0) { render_window_active_resize_outline(s3_x, s3_y, s3_w, s3_h, sw, sh) } else { 1.0 }

    render_system_bars(sw, sh)
}
