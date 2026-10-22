// ===============================================================================
// CHRONOS IDE — APLICATIVO PRINCIPAL (chronos_ide.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Soberana: 100% Código PhasorLang Puro & Modular
// Hito 2: Contenedor de Pantallas Hijas (Scrollbars 2D, Resizing 8D y Minimizado)
// Captura Nativa de Periféricos (Mouse Clicks, Gamepad USB & Teclado R229..R255)
// Invariante Estricto: Zero-GC a 120 FPS Nativos
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. IMPORTACIONES MODULARES
// -------------------------------------------------------------------------------
import "lib/ui_spatial_main.ph"
import "lib/ui_window.ph"

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

// Mutex de Interacción (Arrastre de ventana vs Redimensionamiento vs Fondo)
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

// -------------------------------------------------------------------------------
// 3. FUNCIONES AUXILIARES DE MATEMÁTICA Y CINEMÁTICA (ZERO-GC)
// -------------------------------------------------------------------------------
clamp_val(v, min_v, max_v) = {
    res = v
    if (res < min_v) { res = min_v } else { 1.0 }
    if (res > max_v) { res = max_v } else { 1.0 }
    res
}

clamp_scroll(cur_sc, max_sc) = {
    res = cur_sc
    if (max_sc < 0.0) { res = 0.0 } else {
        if (res > max_sc) { res = max_sc } else { 1.0 }
        if (res < 0.0) { res = 0.0 } else { 1.0 }
    }
    res
}

calc_resize_w(dir, orig_w, delta_w, min_w) = {
    nw = orig_w
    if (dir == 1.0) { nw = orig_w + delta_w } else {
        if (dir == 5.0) { nw = orig_w + delta_w } else {
            if (dir == 7.0) { nw = orig_w + delta_w } else {
                if (dir == 3.0) { nw = orig_w - delta_w } else {
                    if (dir == 6.0) { nw = orig_w - delta_w } else {
                        if (dir == 8.0) { nw = orig_w - delta_w } else { 1.0 }
                    }
                }
            }
        }
    }
    if (nw < min_w) { nw = min_w } else { 1.0 }
    nw
}

calc_resize_x(dir, orig_x, orig_w, new_w) = {
    nx = orig_x
    if (dir == 3.0) { nx = (orig_x + orig_w) - new_w } else {
        if (dir == 6.0) { nx = (orig_x + orig_w) - new_w } else {
            if (dir == 8.0) { nx = (orig_x + orig_w) - new_w } else { 1.0 }
        }
    }
    nx
}

calc_resize_h(dir, orig_h, delta_h, min_h) = {
    nh = orig_h
    if (dir == 2.0) { nh = orig_h + delta_h } else {
        if (dir == 5.0) { nh = orig_h + delta_h } else {
            if (dir == 6.0) { nh = orig_h + delta_h } else {
                if (dir == 4.0) { nh = orig_h - delta_h } else {
                    if (dir == 7.0) { nh = orig_h - delta_h } else {
                        if (dir == 8.0) { nh = orig_h - delta_h } else { 1.0 }
                    }
                }
            }
        }
    }
    if (nh < min_h) { nh = min_h } else { 1.0 }
    nh
}

calc_resize_y(dir, orig_y, orig_h, new_h) = {
    ny = orig_y
    if (dir == 4.0) { ny = (orig_y + orig_h) - new_h } else {
        if (dir == 7.0) { ny = (orig_y + orig_h) - new_h } else {
            if (dir == 8.0) { ny = (orig_y + orig_h) - new_h } else { 1.0 }
        }
    }
    ny
}

// -------------------------------------------------------------------------------
// 4. MÓDULO SCREEN 1: EDITOR DE CÓDIGO (RENDERIZADO Y CONTENIDO)
// -------------------------------------------------------------------------------
render_editor_line(num_str, code_str, tx, gx, row_y, c_top, c_bot, text_col) = {
    if (row_y >= c_top) { if (row_y <= c_bot) {
        text(num_str, gx, row_y, 9, 0x484F58)
        text(code_str, tx, row_y, 9, text_col)
    } } else { 1.0 }
    1.0
}

render_editor_toolbar(hx, hy, inner_w) = {
    rect(hx + 1.0, hy + 28.0, inner_w, 26.0, 0x161B22)
    line(hx + 1.0, hy + 54.0, hx + inner_w + 1.0, hy + 54.0, 0x30363D)
    text("Archivo", hx + 12.0, hy + 35.0, 9, 0x8B949E)
    text("Editar", hx + 65.0, hy + 35.0, 9, 0x8B949E)
    text("Ver", hx + 110.0, hy + 35.0, 9, 0x8B949E)
    text("Compilar HTML", hx + 140.0, hy + 35.0, 9, 0x3FB950)
    1.0
}

render_screen_editor_content(hx, hy, hw, hh, is_min, sc_x, sc_y) = {
    if (is_min == 1.0) { 0.0 } else {
        inner_w = hw - 2.0
        rect(hx + 1.0, hy + 54.0, inner_w, hh - 55.0, 0x090D13)

        c_top = hy + 54.0
        c_bot = hy + hh - 16.0
        base_y = hy + 64.0 - sc_y
        tx = hx + 42.0 - sc_x
        gx = hx + 12.0

        // Líneas de código con gutter sincronizado y oclusión Zero-GC
        render_editor_line("1", "// CHRONOS IDE — HITO 2 AUTONOMO 100% PHASORLANG", tx, gx, base_y, c_top, c_bot, 0x6E7681)
        render_editor_line("2", "import \"lib/ui_spatial_main.ph\"", tx, gx, base_y + 18.0, c_top, c_bot, 0x79C0FF)
        render_editor_line("3", "import \"lib/ui_window.ph\"", tx, gx, base_y + 36.0, c_top, c_bot, 0x79C0FF)
        render_editor_line("4", "signal t = 0.0", tx, gx, base_y + 54.0, c_top, c_bot, 0xF2CC60)
        render_editor_line("5", "screen main {", tx, gx, base_y + 72.0, c_top, c_bot, 0x58A6FF)
        render_editor_line("6", "    sw = R250; sh = R251; pd = R254", tx, gx, base_y + 90.0, c_top, c_bot, 0x3FB950)
        render_editor_line("7", "    left = R254; right = R248; mid = R249", tx, gx, base_y + 108.0, c_top, c_bot, 0x3FB950)
        render_editor_line("8", "    if (R240 > 0.0) { motor_x = R241 }", tx, gx, base_y + 126.0, c_top, c_bot, 0x79C0FF)
        render_editor_line("9", "    spatial_main_render(sw, sh)", tx, gx, base_y + 144.0, c_top, c_bot, 0x58A6FF)
        render_editor_line("10", "    render_window_scrollbars(...)", tx, gx - 5.0, base_y + 162.0, c_top, c_bot, 0x58A6FF)
        render_editor_line("11", "}", tx, gx - 5.0, base_y + 180.0, c_top, c_bot, 0x58A6FF)

        // Gutter opaco lateral
        rect(hx + 1.0, hy + 54.0, 36.0, hh - 55.0, 0x0C1017)
        line(hx + 37.0, hy + 54.0, hx + 37.0, hy + hh - 1.0, 0x21262D)

        // Barra de herramientas local
        render_editor_toolbar(hx, hy, inner_w)

        // Scrollbars 2D nativas
        render_window_scrollbars(hx, hy, hw, hh, 380.0, 260.0, sc_x, sc_y, is_min)
        1.0
    }
}

render_screen_1(sw, sh) = {
    render_window_frame(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min)
    hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
    hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
    text("📝 Screen 1: Editor de Código", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    render_screen_editor_content(hx, hy, s1_w, s1_h, s1_min, s1_sc_x, s1_sc_y)
    render_window_borders(hx, hy, s1_w, s1_h, s1_min)
}

// -------------------------------------------------------------------------------
// 5. MÓDULO SCREEN 2: EXPLORADOR DE ARCHIVOS (RENDERIZADO Y CONTENIDO)
// -------------------------------------------------------------------------------
render_tree_item(label, tx, y, c_top, c_bot, col) = {
    if (y >= c_top) { if (y <= c_bot) {
        text(label, tx, y, 9, col)
    } } else { 1.0 }
    1.0
}

render_screen_explorer_content(hx, hy, hw, hh, is_min, sc_x, sc_y) = {
    if (is_min == 1.0) { 0.0 } else {
        inner_w = hw - 2.0
        rect(hx + 1.0, hy + 28.0, inner_w, hh - 29.0, 0x090D13)

        c_top = hy + 28.0
        c_bot = hy + hh - 16.0
        base_y = hy + 38.0 - sc_y
        tx = hx + 12.0 - sc_x

        render_tree_item("📁 PROYECTO: SketchWarePro", tx, base_y, c_top, c_bot, 0xF2CC60)
        render_tree_item("v 📁 samples/", tx + 10.0, base_y + 20.0, c_top, c_bot, 0xF2CC60)
        render_tree_item("    ⚡ chronos_ide.ph (Hito 2)", tx + 10.0, base_y + 38.0, c_top, c_bot, 0x3FB950)
        render_tree_item("    ⚡ fractal_ui.ph", tx + 10.0, base_y + 56.0, c_top, c_bot, 0xF2CC60)
        render_tree_item("v 📁 lib/", tx + 10.0, base_y + 74.0, c_top, c_bot, 0xF2CC60)
        render_tree_item("    ⚡ ui_spatial_main.ph", tx + 10.0, base_y + 92.0, c_top, c_bot, 0x58A6FF)
        render_tree_item("    ⚡ ui_window.ph", tx + 10.0, base_y + 110.0, c_top, c_bot, 0x58A6FF)
        render_tree_item("v 📁 docs/", tx + 10.0, base_y + 128.0, c_top, c_bot, 0xF2CC60)
        render_tree_item("    📚 syntax_dictionary.md", tx + 10.0, base_y + 146.0, c_top, c_bot, 0xFA7970)
        render_tree_item("    🌐 chronos_ide.html", tx + 10.0, base_y + 164.0, c_top, c_bot, 0x79C0FF)

        render_window_scrollbars(hx, hy, hw, hh, 240.0, 240.0, sc_x, sc_y, is_min)
        1.0
    }
}

render_screen_2(sw, sh) = {
    render_window_frame(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min)
    hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
    hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
    text("📁 Screen 2: Explorador de Archivos", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    render_screen_explorer_content(hx, hy, s2_w, s2_h, s2_min, s2_sc_x, s2_sc_y)
    render_window_borders(hx, hy, s2_w, s2_h, s2_min)
}

// -------------------------------------------------------------------------------
// 6. MÓDULO SCREEN 3: LIVE PREVIEW PVM (RENDERIZADO Y TELEMETRÍA)
// -------------------------------------------------------------------------------
render_screen_preview_content(hx, hy, hw, hh, is_min, t_glob, gp_conn, right_click, mid_click) = {
    if (is_min == 1.0) { 0.0 } else {
        inner_w = hw - 2.0
        rect(hx + 1.0, hy + 28.0, inner_w, hh - 29.0, 0x070A0E)

        // Fasor Circular Reactivo
        cx = hx + (hw * 0.5)
        cy = hy + 80.0
        circle(cx, cy, 32.0, 0x1F6FEB)
        circle(cx, cy, 24.0, 0x238636)

        ang = t_glob * 0.05
        fx = cx + (cos(ang) * 24.0)
        fy = cy + (sin(ang) * 24.0)
        line(cx, cy, fx, fy, 0x58A6FF)
        circle(fx, fy, 3.5, 0x3FB950)

        // Telemetría Directa PVM (Sin dependencias externas)
        base_ty = hy + 138.0
        text("MONITOR HARDWARE DIRECTO (PVM)", hx + 16.0, base_ty, 9, 0x58A6FF)
        if (gp_conn > 0.0) {
            text("Gamepad USB: CONECTADO [R240=1.0]", hx + 16.0, base_ty + 18.0, 8, 0x3FB950)
        } else {
            text("Gamepad USB: Desconectado [R240=0.0]", hx + 16.0, base_ty + 18.0, 8, 0x8B949E)
        }
        if (right_click > 0.0) {
            text("Clic Secundario (Der): ACTIVO [R248]", hx + 16.0, base_ty + 36.0, 8, 0xF2CC60)
        } else {
            text("Mouse: Izq=R254 | Der=R248 | Med=R249", hx + 16.0, base_ty + 36.0, 8, 0x8B949E)
        }
        text("Rueda Scroll 2D: R255 (Y) / R247 (X)", hx + 16.0, base_ty + 54.0, 8, 0x58A6FF)
        text("Zero-GC: 0 pausas | 120 FPS Nativos", hx + 16.0, base_ty + 72.0, 8, 0x3FB950)
        1.0
    }
}

render_screen_3(sw, sh, t_glob, gp_conn, right_click, mid_click) = {
    render_window_frame(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min)
    hx = spatial_world_to_screen_x(s3_x, s3_w, sw)
    hy = spatial_world_to_screen_y(s3_y, s3_h, sh)
    text("🔬 Screen 3: Live Preview PVM", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
    render_screen_preview_content(hx, hy, s3_w, s3_h, s3_min, t_glob, gp_conn, right_click, mid_click)
    render_window_borders(hx, hy, s3_w, s3_h, s3_min)
}

// -------------------------------------------------------------------------------
// 7. BARRAS FIJAS DEL SISTEMA (MENUBAR Y STATUSBAR)
// -------------------------------------------------------------------------------
render_system_bars(sw, sh) = {
    // Barra de menús superior
    rect(0.0, 0.0, sw, 28.0, 0x090D13)
    line(0.0, 28.0, sw, 28.0, 0x21262D)
    text("⚡ CHRONOS IDE — KORADEVS ECOSYSTEM", 16.0, 8.0, 10, 0x58A6FF)
    text("HITO 2: SCROLL 2D | RESIZE CORNER | PERIFÉRICOS R229..R255", sw - 480.0, 9.0, 8, 0x8B949E)

    // Barra de estado inferior
    by = sh - 24.0
    rect(0.0, by, sw, 24.0, 0x090D13)
    line(0.0, by, sw, by, 0x21262D)
    text("Hito 2 Listo | Scroll 2D: Rueda Mouse | Resize: Esquinas y Bordes 8D | Min/Max: [-]/[+]", 16.0, by + 6.0, 8, 0x3FB950)
    1.0
}

// -------------------------------------------------------------------------------
// 8. DISPATCHERS MODULARES DE ENTRADA E INTERACCIÓN
// -------------------------------------------------------------------------------
handle_responsive_layout(sw, sh) = {
    if (sw < 768.0) {
        s1_w = sw - 16.0; s1_h = sh - 80.0
        s2_w = sw - 16.0; s2_h = sh - 80.0
        s3_w = sw - 16.0; s3_h = sh - 80.0
    } else { 1.0 }
    1.0
}

handle_gamepad_navigation(gp_conn, gp_lx, gp_ly) = {
    if (gp_conn > 0.0) {
        if (abs(gp_lx) > 0.15) { spatial_main_pan(gp_lx * -8.0, 0.0) } else { 1.0 }
        if (abs(gp_ly) > 0.15) { spatial_main_pan(0.0, gp_ly * -8.0) } else { 1.0 }
    } else { 1.0 }
    1.0
}

handle_scroll_input(mx, my, sw, sh, wh, wheel_x) = {
    if (wh != 0.0) {
        delta = clamp_val(wh * 0.25, -24.0, 24.0)
        if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 1.0) {
            s1_sc_y = s1_sc_y + delta
        } else {
            if (window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my) == 1.0) {
                s2_sc_y = s2_sc_y + delta
            } else { 1.0 }
        }
    } else { 1.0 }

    if (wheel_x != 0.0) {
        delta = clamp_val(wheel_x * 0.25, -24.0, 24.0)
        if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 1.0) {
            s1_sc_x = s1_sc_x + delta
        } else { 1.0 }
    } else { 1.0 }

    s1_sc_y = clamp_scroll(s1_sc_y, 260.0 - (s1_h - 56.0))
    s1_sc_x = clamp_scroll(s1_sc_x, clamp_val(380.0 - (s1_w - 2.0), 0.0, 36.0))
    s2_sc_y = clamp_scroll(s2_sc_y, 240.0 - (s2_h - 30.0))
    1.0
}

apply_active_resize(mx, my) = {
    dw = mx - resize_orig_mx
    dh = my - resize_orig_my
    min_w = 220.0
    min_h = 160.0
    if (resize_target_win == 1.0) { min_w = 280.0; min_h = 180.0 } else { 1.0 }

    cand_w = calc_resize_w(resize_target_dir, resize_orig_w, dw, min_w)
    cand_x = calc_resize_x(resize_target_dir, resize_orig_x, resize_orig_w, cand_w)
    cand_h = calc_resize_h(resize_target_dir, resize_orig_h, dh, min_h)
    cand_y = calc_resize_y(resize_target_dir, resize_orig_y, resize_orig_h, cand_h)

    if (resize_target_win == 1.0) { s1_x = cand_x; s1_y = cand_y; s1_w = cand_w; s1_h = cand_h } else { 1.0 }
    if (resize_target_win == 2.0) { s2_x = cand_x; s2_y = cand_y; s2_w = cand_w; s2_h = cand_h } else { 1.0 }
    if (resize_target_win == 3.0) { s3_x = cand_x; s3_y = cand_y; s3_w = cand_w; s3_h = cand_h } else { 1.0 }
    1.0
}

apply_active_drag(mx, my, pan_x, pan_y) = {
    tgt_x = (mx - drag_offset_x) - pan_x
    tgt_y = (my - drag_offset_y) - pan_y
    if (drag_target_win == 1.0) { s1_x = tgt_x; s1_y = tgt_y } else { 1.0 }
    if (drag_target_win == 2.0) { s2_x = tgt_x; s2_y = tgt_y } else { 1.0 }
    if (drag_target_win == 3.0) { s3_x = tgt_x; s3_y = tgt_y } else { 1.0 }
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
        dir1 = window_hit_edge_8d(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my)
        if (dir1 > 0.0) {
            resize_target_win = 1.0; resize_target_dir = dir1
            resize_orig_x = s1_x; resize_orig_y = s1_y
            resize_orig_w = s1_w; resize_orig_h = s1_h
            resize_orig_mx = mx; resize_orig_my = my
            handled = 1.0
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s2_min == 0.0) {
            dir2 = window_hit_edge_8d(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my)
            if (dir2 > 0.0) {
                resize_target_win = 2.0; resize_target_dir = dir2
                resize_orig_x = s2_x; resize_orig_y = s2_y
                resize_orig_w = s2_w; resize_orig_h = s2_h
                resize_orig_mx = mx; resize_orig_my = my
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }
    if (handled == 0.0) {
        if (s3_min == 0.0) {
            dir3 = window_hit_edge_8d(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my)
            if (dir3 > 0.0) {
                resize_target_win = 3.0; resize_target_dir = dir3
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
        if (resize_target_win > 0.0) {
            apply_active_resize(mx, my)
            handled = 1.0
        } else { 1.0 }

        if (handled == 0.0) {
            if (drag_target_win > 0.0) {
                apply_active_drag(mx, my, pan_x, pan_y)
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }

        if (handled == 0.0) {
            if (my > 28.0) { if (my < (sh - 24.0)) {
                if (prev_click_down == 0.0) {
                    handled = check_minimize_buttons(mx, my, sw, sh)
                } else { 1.0 }

                if (handled == 0.0) {
                    handled = check_resize_start(mx, my, sw, sh)
                } else { 1.0 }

                if (handled == 0.0) {
                    handled = check_drag_start(mx, my, sw, sh)
                } else { 1.0 }

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
        drag_target_win = 0.0
        resize_target_win = 0.0
        resize_target_dir = 0.0
        prev_click_down = 0.0
        spatial_main_handle_input(mx, my, 0.0, 0.0)
    }
    1.0
}

// -------------------------------------------------------------------------------
// 9. RESOLUCIÓN DE FORMA DEL CURSOR REACTIVO (R229 & R256)
// -------------------------------------------------------------------------------
resolve_window_cursor(wx, wy, ww, wh, sw, sh, is_min, mx, my, is_editor) = {
    shape = -1.0
    if (window_hit_min_btn(wx, wy, ww, wh, sw, sh, mx, my) == 1.0) {
        shape = 1.0 // pointer
    } else {
        dir = window_hit_edge_8d(wx, wy, ww, wh, sw, sh, is_min, mx, my)
        if (dir > 0.0) {
            shape = window_cursor_from_dir(dir)
        } else {
            if (window_hit_title(wx, wy, ww, wh, sw, sh, mx, my) == 1.0) {
                shape = 3.0 // move
            } else {
                if (window_hit_body(wx, wy, ww, wh, sw, sh, is_min, mx, my) == 1.0) {
                    if (is_editor == 1.0) {
                        hy = spatial_world_to_screen_y(wy, wh, sh)
                        if (my >= (hy + 28.0)) {
                            if (my < (hy + 54.0)) {
                                shape = 1.0 // pointer en menú local
                            } else {
                                shape = 2.0 // text I-Beam en código
                            }
                        } else {
                            shape = 0.0
                        }
                    } else {
                        if (is_editor == 2.0) {
                            shape = 1.0 // pointer en explorador
                        } else {
                            shape = 0.0 // default en preview
                        }
                    }
                } else { 1.0 }
            }
        }
    }
    shape
}

compute_pointer_cursor(mx, my, sw, sh, pd) = {
    shape = 0.0
    if (pd == 1.0) {
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
    } else {
        if (my < 28.0) {
            shape = 1.0 // Barra superior
        } else {
            if (my > (sh - 24.0)) {
                shape = 0.0 // Barra inferior
            } else {
                // Prioridad Z-order: Screen 3 -> Screen 2 -> Screen 1
                c3 = resolve_window_cursor(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my, 0.0)
                if (c3 >= 0.0) {
                    shape = c3
                } else {
                    c2 = resolve_window_cursor(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my, 2.0)
                    if (c2 >= 0.0) {
                        shape = c2
                    } else {
                        c1 = resolve_window_cursor(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my, 1.0)
                        if (c1 >= 0.0) {
                            shape = c1
                        } else {
                            shape = 0.0
                        }
                    }
                }
            }
        }
    }
    shape
}

// -------------------------------------------------------------------------------
// 10. ORQUESTADOR PRINCIPAL (SCREEN MAIN)
// -------------------------------------------------------------------------------
screen main {
    // 1. Inicialización y tiempo fasorial
    t_global = t_global + 1.0
    if (t_global <= 1.0) { spatial_main_init(3600.0, 2400.0, 80.0) } else { 1.0 }

    // 2. Lectura directa de registros de hardware (PVM ISA)
    sw = R250; sh = R251; mx = R252; my = R253; pd = R254
    wh = R255; wheel_x = R247; right_click = R248; mid_click = R249
    gp_conn = R240; gp_lx = R241; gp_ly = R242

    if (sw < 240.0) { sw = 800.0 } else { 1.0 }
    if (sh < 240.0) { sh = 600.0 } else { 1.0 }
    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()

    // 3. Layout responsive para móvil
    handle_responsive_layout(sw, sh)

    // 4. Navegación por Gamepad USB
    handle_gamepad_navigation(gp_conn, gp_lx, gp_ly)

    // 5. Scroll 2D con auto-ajuste
    handle_scroll_input(mx, my, sw, sh, wh, wheel_x)

    // 6. Mutex de interacción (Arrastre vs Redimensión vs Fondo)
    handle_workspace_interactions(mx, my, sw, sh, pd, pan_x, pan_y)

    // 7. Registro de forma de cursor nativo (R229 canonical 8-bit & R256)
    cur_shape = compute_pointer_cursor(mx, my, sw, sh, pd)
    R229 = cur_shape
    R256 = cur_shape

    // 8. Canalización de renderizado a 120 FPS Zero-GC
    spatial_main_render(sw, sh)
    render_screen_1(sw, sh)
    render_screen_2(sw, sh)
    render_screen_3(sw, sh, t_global, gp_conn, right_click, mid_click)
    render_system_bars(sw, sh)
}
