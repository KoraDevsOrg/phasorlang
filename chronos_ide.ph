// ===============================================================================
// CHRONOS IDE — APLICATIVO PRINCIPAL (chronos_ide.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Soberana: 100% Código PhasorLang Puro
// Hito 2: Contenedor de Pantallas Hijas (Scrollbars 2D, Resizing y Minimizado)
// Captura Nativa de Periféricos (Mouse Clicks, Gamepad USB & Teclado R230..R255)
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. IMPORTACIONES MODULARES DE COMPONENTES
// -------------------------------------------------------------------------------
import "lib/ui_spatial_main.ph"
import "lib/ui_window.ph"

// -------------------------------------------------------------------------------
// 2. SEÑALES REACTIVAS GLOBALES (MEMORIA PLANA CONTIGUA)
// -------------------------------------------------------------------------------
signal t_global = 0.0

// Coordenadas mundiales en el espacio toroidal (3600 x 2400)
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
signal drag_offset_x = 0.0
signal drag_offset_y = 0.0
signal resize_orig_w = 0.0
signal resize_orig_h = 0.0
signal resize_orig_mx = 0.0
signal resize_orig_my = 0.0
signal prev_click_down = 0.0     // Edge-trigger para botones de un solo clic

// -------------------------------------------------------------------------------
// 3. CONTENIDO: SCREEN 1 (EDITOR) CON SCROLL 2D CLIPPED
// -------------------------------------------------------------------------------
render_screen_editor_content(hx, hy, hw, hh, is_min, sc_x, sc_y) = {
    if (is_min == 1.0) { 0.0 } else {
        inner_w = hw - 2.0
        inner_h = hh - 30.0

        // Menú superior interno del editor
        rect(hx + 1.0, hy + 29.0, inner_w, 24.0, 0x111620)
        line(hx + 1.0, hy + 53.0, hx + hw - 1.0, hy + 53.0, 0x21262D)
        text("Archivo", hx + 12.0, hy + 35.0, 9, 0x8B949E)
        text("Editar", hx + 64.0, hy + 35.0, 9, 0x8B949E)
        text("Ver", hx + 110.0, hy + 35.0, 9, 0x8B949E)
        text("Compilar HTML", hx + 140.0, hy + 35.0, 9, 0x3FB950)

        // Área de edición de código
        rect(hx + 1.0, hy + 54.0, inner_w, hh - 55.0, 0x090D13)
        
        // Gutter de números de línea (fijo horizontalmente)
        rect(hx + 1.0, hy + 54.0, 34.0, hh - 55.0, 0x0C1017)
        line(hx + 35.0, hy + 54.0, hx + 35.0, hy + hh - 1.0, 0x21262D)
        
        // Renderizado de líneas de código desplazadas por scroll
        base_y = hy + 64.0 - sc_y
        tx = hx + 42.0 - sc_x
        clip_bottom = hy + hh - 12.0

        // Línea 1
        row_y = base_y
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("1", hx + 12.0, row_y, 9, 0x484F58)
            text("// CHRONOS IDE — HITO 2 AUTÓNOMO 100% PHASORLANG", tx, row_y, 9, 0x6E7681)
        } }

        // Línea 2
        row_y = base_y + 18.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("2", hx + 12.0, row_y, 9, 0x484F58)
            text("import \"lib/ui_spatial_main.ph\"", tx, row_y, 9, 0x79C0FF)
        } }

        // Línea 3
        row_y = base_y + 36.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("3", hx + 12.0, row_y, 9, 0x484F58)
            text("import \"lib/ui_window.ph\"", tx, row_y, 9, 0x79C0FF)
        } }

        // Línea 4
        row_y = base_y + 54.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("4", hx + 12.0, row_y, 9, 0x484F58)
            text("signal t = 0.0", tx, row_y, 9, 0x58A6FF)
        } }

        // Línea 5
        row_y = base_y + 72.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("5", hx + 12.0, row_y, 9, 0x484F58)
            text("screen main {", tx, row_y, 9, 0xF2CC60)
        } }

        // Línea 6
        row_y = base_y + 90.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("6", hx + 12.0, row_y, 9, 0x484F58)
            text("    sw = R250; sh = R251; pd = R254", tx + 16.0, row_y, 9, 0x3FB950)
        } }

        // Línea 7
        row_y = base_y + 108.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("7", hx + 12.0, row_y, 9, 0x484F58)
            text("    left = R254; right = R248; mid = R249", tx + 16.0, row_y, 9, 0x3FB950)
        } }

        // Línea 8
        row_y = base_y + 126.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("8", hx + 12.0, row_y, 9, 0x484F58)
            text("    if (R240 > 0.0) { motor_x = R241 }", tx + 16.0, row_y, 9, 0x79C0FF)
        } }

        // Línea 9
        row_y = base_y + 144.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("9", hx + 12.0, row_y, 9, 0x484F58)
            text("    spatial_main_render(sw, sh)", tx + 16.0, row_y, 9, 0x58A6FF)
        } }

        // Línea 10
        row_y = base_y + 162.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("10", hx + 12.0, row_y, 9, 0x484F58)
            text("    render_window_scrollbars(...)", tx + 16.0, row_y, 9, 0x79C0FF)
        } }

        // Línea 11
        row_y = base_y + 180.0
        if (row_y >= (hy + 54.0)) { if (row_y <= clip_bottom) {
            text("11", hx + 12.0, row_y, 9, 0x484F58)
            text("}", tx, row_y, 9, 0xF2CC60)
        } }

        // Scrollbars 2D: Contenido virtual 640 x 480
        render_window_scrollbars(hx, hy, hw, hh, 640.0, 480.0, sc_x, sc_y)
        1.0
    }
}

// -------------------------------------------------------------------------------
// 4. CONTENIDO: SCREEN 2 (EXPLORADOR) CON SCROLL 2D CLIPPED
// -------------------------------------------------------------------------------
render_screen_explorer_content(hx, hy, hw, hh, is_min, sc_x, sc_y) = {
    if (is_min == 1.0) { 0.0 } else {
        inner_w = hw - 2.0
        inner_h = hh - 30.0
        rect(hx + 1.0, hy + 29.0, inner_w, inner_h, 0x0A0E15)

        base_y = hy + 38.0 - sc_y
        tx = hx + 14.0 - sc_x
        clip_bottom = hy + hh - 12.0

        if (base_y >= (hy + 29.0)) { if (base_y <= clip_bottom) {
            text("📁 PROYECTO: SketchWarePro", tx, base_y, 9, 0x58A6FF)
        } }

        row_y = base_y + 20.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("v 📁 samples/", tx + 6.0, row_y, 9, 0x8B949E)
        } }

        row_y = base_y + 38.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("    ⚡ chronos_ide.ph (Hito 2 Activo)", tx + 6.0, row_y, 9, 0x3FB950)
        } }

        row_y = base_y + 56.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("    ⚡ fractal_ui.ph", tx + 6.0, row_y, 9, 0x79C0FF)
        } }

        row_y = base_y + 74.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("v 📁 lib/", tx + 6.0, row_y, 9, 0x8B949E)
        } }

        row_y = base_y + 92.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("    ⚡ ui_spatial_main.ph", tx + 6.0, row_y, 9, 0x79C0FF)
        } }

        row_y = base_y + 110.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("    ⚡ ui_window.ph (Scroll & Resize)", tx + 6.0, row_y, 9, 0x79C0FF)
        } }

        row_y = base_y + 128.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("v 📁 docs/", tx + 6.0, row_y, 9, 0x8B949E)
        } }

        row_y = base_y + 146.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("    📚 syntax_dictionary.md", tx + 6.0, row_y, 9, 0xF2CC60)
        } }

        row_y = base_y + 164.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("v 📁 dist/", tx + 6.0, row_y, 9, 0x8B949E)
        } }

        row_y = base_y + 182.0
        if (row_y >= (hy + 29.0)) { if (row_y <= clip_bottom) {
            text("    🌐 chronos_ide.html (Standalone)", tx + 6.0, row_y, 9, 0x58A6FF)
        } }

        // Scrollbars 2D: Contenido virtual 360 x 380
        render_window_scrollbars(hx, hy, hw, hh, 360.0, 380.0, sc_x, sc_y)
        1.0
    }
}

// -------------------------------------------------------------------------------
// 5. CONTENIDO: SCREEN 3 (LIVE PREVIEW & MONITOR DE PERIFÉRICOS)
// -------------------------------------------------------------------------------
render_screen_preview_content(hx, hy, hw, hh, is_min, t, gp_conn, right_click, mid_click) = {
    if (is_min == 1.0) { 0.0 } else {
        inner_w = hw - 2.0
        inner_h = hh - 30.0
        rect(hx + 1.0, hy + 29.0, inner_w, inner_h, 0x070B12)

        cx = hx + (hw * 0.5)
        cy = hy + 76.0 + 29.0
        
        // Fasor animado
        circle(cx, cy, 44.0, 0x1F6FEB)
        circle(cx, cy, 22.0, 0x238636)
        ang = t * 0.05
        fx = cx + (38.0 * cos(ang))
        fy = cy - (38.0 * sin(ang))
        line(cx, cy, fx, fy, 0x00E5FF)
        circle(fx, fy, 3.5, 0x3FB950)

        // Telemetría de Periféricos Nativos
        text("MONITOR HARDWARE DIRECTO (PVM)", hx + 14.0, hy + 164.0, 9, 0x58A6FF)
        
        // Estado Gamepad USB
        if (gp_conn > 0.0) {
            text("Gamepad USB: CONECTADO [R240=1.0]", hx + 14.0, hy + 180.0, 9, 0x3FB950)
        } else {
            text("Gamepad USB: Desconectado [R240=0.0]", hx + 14.0, hy + 180.0, 9, 0x8B949E)
        }

        // Estado Ratón
        if (right_click > 0.0) {
            text("Clic Secundario (Der): ACTIVO [R248]", hx + 14.0, hy + 196.0, 9, 0xF2CC60)
        } else {
            text("Mouse: Izq=R254 | Der=R248 | Med=R249", hx + 14.0, hy + 196.0, 9, 0x8B949E)
        }

        text("Rueda Scroll 2D: R255 (Y) / R247 (X)", hx + 14.0, hy + 212.0, 9, 0x79C0FF)
        text("Zero-GC: 0 pausas | 120 FPS Nativos", hx + 14.0, hy + 228.0, 9, 0x3FB950)
        1.0
    }
}

// -------------------------------------------------------------------------------
// 6. BARRAS PERSISTENTES SUPERIOR E INFERIOR (DESKTOP DOCK)
// -------------------------------------------------------------------------------
render_top_menubar(sw, sh) = {
    rect(0.0, 0.0, sw, 48.0, 0x0D1117)
    line(0.0, 48.0, sw, 48.0, 0x30363D)
    text("⚡ CHRONOS IDE — KORADEVS ECOSYSTEM", 16.0, 16.0, 12, 0x58A6FF)
    text("HITO 2: SCROLL 2D | RESIZE CORNER | PERIFÉRICOS R230..R255", 360.0, 18.0, 9, 0x8B949E)
    1.0
}

render_bottom_statusbar(sw, sh) = {
    by = sh - 24.0
    rect(0.0, by, sw, 24.0, 0x0B0E14)
    line(0.0, by, sw, by, 0x21262D)
    text("Hito 2 Listo | Scroll 2D: Rueda Mouse | Resize: Esquina inferior-derecha | Min/Max: Botón [-]/[+]", 16.0, by + 6.0, 9, 0x3FB950)
    1.0
}

// -------------------------------------------------------------------------------
// 7. PANTALLA PRINCIPAL: FONDO TOROIDAL + CONTENEDOR DE SCREENS HIJAS
// -------------------------------------------------------------------------------
screen main {
    t_global = t_global + 1.0
    if (t_global <= 1.0) {
        spatial_main_init(3600.0, 2400.0, 80.0)
    } else { 1.0 }

    // LECTURA DIRECTA DE REGISTROS DE HARDWARE VIRTUAL (100% ENSAMBLADOR PVM)
    sw = R250
    sh = R251
    mx = R252
    my = R253
    pd = R254
    wh = R255
    wheel_x = R247
    right_click = R248
    mid_click = R249
    gp_conn = R240
    gp_lx = R241
    gp_ly = R242

    if (sw < 240.0) { sw = 800.0 } else { 1.0 }
    if (sh < 240.0) { sh = 600.0 } else { 1.0 }

    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()

    // Adaptación responsive para móvil (Snap 100% al viewport)
    is_mobile = 0.0
    if (sw < 768.0) {
        is_mobile = 1.0
        s1_w = sw - 16.0
        s1_h = sh - 80.0
        s2_w = sw - 16.0
        s2_h = sh - 80.0
        s3_w = sw - 16.0
        s3_h = sh - 80.0
    } else { 1.0 }

    // Navegación fluida por Gamepad USB si está conectado
    if (gp_conn > 0.0) {
        if (abs(gp_lx) > 0.15) { spatial_main_pan(gp_lx * -8.0, 0.0) } else { 1.0 }
        if (abs(gp_ly) > 0.15) { spatial_main_pan(0.0, gp_ly * -8.0) } else { 1.0 }
    } else { 1.0 }

    // ===========================================================================
    // SCROLL 2D: RUEDA VERTICAL (R255) Y HORIZONTAL (R247)
    // ===========================================================================
    if (wh != 0.0) {
        // Scroll vertical en Screen 1
        if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 1.0) {
            max_sc = 480.0 - (s1_h - 29.0)
            if (max_sc > 0.0) {
                s1_sc_y = s1_sc_y + (wh * 0.35)
                if (s1_sc_y < 0.0) { s1_sc_y = 0.0 } else { 1.0 }
                if (s1_sc_y > max_sc) { s1_sc_y = max_sc } else { 1.0 }
            } else { 1.0 }
        } else {
            // Scroll vertical en Screen 2
            if (window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my) == 1.0) {
                max_sc = 380.0 - (s2_h - 29.0)
                if (max_sc > 0.0) {
                    s2_sc_y = s2_sc_y + (wh * 0.35)
                    if (s2_sc_y < 0.0) { s2_sc_y = 0.0 } else { 1.0 }
                    if (s2_sc_y > max_sc) { s2_sc_y = max_sc } else { 1.0 }
                } else { 1.0 }
            } else { 1.0 }
        }
    } else { 1.0 }

    if (wheel_x != 0.0) {
        // Scroll horizontal en Screen 1
        if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 1.0) {
            max_sc = 640.0 - (s1_w - 2.0)
            if (max_sc > 0.0) {
                s1_sc_x = s1_sc_x + (wheel_x * 0.35)
                if (s1_sc_x < 0.0) { s1_sc_x = 0.0 } else { 1.0 }
                if (s1_sc_x > max_sc) { s1_sc_x = max_sc } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }
    } else { 1.0 }

    // ===========================================================================
    // GESTIÓN DE ENTRADA EXCLUSIVA (MUTEX: REDIMENSIONAMIENTO VS ARRASTRE VS FONDO)
    // ===========================================================================
    if (pd == 1.0) {
        handled = 0.0

        // 1. Redimensionamiento activo continuo desde esquina
        if (resize_target_win > 0.0) {
            delta_w = mx - resize_orig_mx
            delta_h = my - resize_orig_my
            if (resize_target_win == 1.0) {
                nw = resize_orig_w + delta_w
                nh = resize_orig_h + delta_h
                if (nw < 220.0) { nw = 220.0 } else { 1.0 }
                if (nh < 160.0) { nh = 160.0 } else { 1.0 }
                s1_w = nw
                s1_h = nh
            } else { 1.0 }
            if (resize_target_win == 2.0) {
                nw = resize_orig_w + delta_w
                nh = resize_orig_h + delta_h
                if (nw < 200.0) { nw = 200.0 } else { 1.0 }
                if (nh < 160.0) { nh = 160.0 } else { 1.0 }
                s2_w = nw
                s2_h = nh
            } else { 1.0 }
            if (resize_target_win == 3.0) {
                nw = resize_orig_w + delta_w
                nh = resize_orig_h + delta_h
                if (nw < 200.0) { nw = 200.0 } else { 1.0 }
                if (nh < 160.0) { nh = 160.0 } else { 1.0 }
                s3_w = nw
                s3_h = nh
            } else { 1.0 }
            handled = 1.0
        } else { 1.0 }

        // 2. Arrastre activo continuo por barra de título
        if (handled == 0.0) {
            if (drag_target_win > 0.0) {
                target_scr_x = mx - drag_offset_x
                target_scr_y = my - drag_offset_y
                if (drag_target_win == 1.0) {
                    s1_x = target_scr_x - pan_x
                    s1_y = target_scr_y - pan_y
                } else { 1.0 }
                if (drag_target_win == 2.0) {
                    s2_x = target_scr_x - pan_x
                    s2_y = target_scr_y - pan_y
                } else { 1.0 }
                if (drag_target_win == 3.0) {
                    s3_x = target_scr_x - pan_x
                    s3_y = target_scr_y - pan_y
                } else { 1.0 }
                handled = 1.0
            } else { 1.0 }
        } else { 1.0 }

        // 3. Nuevo clic: Solo dentro del área de trabajo (entre menubar y statusbar)
        if (handled == 0.0) {
            if (my > 48.0) {
                if (my < (sh - 24.0)) {
                    // A. Botón de Minimizar [-] / [+]
                    if (prev_click_down == 0.0) {
                        if (window_hit_min_btn(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
                            s1_min = 1.0 - s1_min
                            handled = 1.0
                        } else { 1.0 }
                        if (handled == 0.0) {
                            if (window_hit_min_btn(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) {
                                s2_min = 1.0 - s2_min
                                handled = 1.0
                            } else { 1.0 }
                        } else { 1.0 }
                        if (handled == 0.0) {
                            if (window_hit_min_btn(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) {
                                s3_min = 1.0 - s3_min
                                handled = 1.0
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }

                    // B. Esquinas de redimensionamiento (Solo escritorio)
                    if (handled == 0.0) {
                        if (s1_min == 0.0) {
                            if (window_hit_resize_corner(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
                                resize_target_win = 1.0
                                resize_orig_w = s1_w
                                resize_orig_h = s1_h
                                resize_orig_mx = mx
                                resize_orig_my = my
                                handled = 1.0
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }
                    if (handled == 0.0) {
                        if (s2_min == 0.0) {
                            if (window_hit_resize_corner(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) {
                                resize_target_win = 2.0
                                resize_orig_w = s2_w
                                resize_orig_h = s2_h
                                resize_orig_mx = mx
                                resize_orig_my = my
                                handled = 1.0
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }
                    if (handled == 0.0) {
                        if (s3_min == 0.0) {
                            if (window_hit_resize_corner(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) {
                                resize_target_win = 3.0
                                resize_orig_w = s3_w
                                resize_orig_h = s3_h
                                resize_orig_mx = mx
                                resize_orig_my = my
                                handled = 1.0
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }

                    // C. Barra de título para arrastre
                    if (handled == 0.0) {
                        if (window_hit_title(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my) == 1.0) {
                            drag_target_win = 1.0
                            hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
                            hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
                            drag_offset_x = mx - hx
                            drag_offset_y = my - hy
                            handled = 1.0
                        } else { 1.0 }
                    } else { 1.0 }
                    if (handled == 0.0) {
                        if (window_hit_title(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my) == 1.0) {
                            drag_target_win = 2.0
                            hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
                            hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
                            drag_offset_x = mx - hx
                            drag_offset_y = my - hy
                            handled = 1.0
                        } else { 1.0 }
                    } else { 1.0 }
                    if (handled == 0.0) {
                        if (window_hit_title(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my) == 1.0) {
                            drag_target_win = 3.0
                            hx = spatial_world_to_screen_x(s3_x, s3_w, sw)
                            hy = spatial_world_to_screen_y(s3_y, s3_h, sh)
                            drag_offset_x = mx - hx
                            drag_offset_y = my - hy
                            handled = 1.0
                        } else { 1.0 }
                    } else { 1.0 }

                    // D. Puntero en el fondo espacial toroidal (ninguna ventana tocada)
                    if (handled == 0.0) {
                        if (window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, mx, my) == 0.0) {
                            if (window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, mx, my) == 0.0) {
                                if (window_hit_body(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, mx, my) == 0.0) {
                                    spatial_main_handle_input(mx, my, pd, 1.0)
                                } else { 1.0 }
                            } else { 1.0 }
                        } else { 1.0 }
                    } else { 1.0 }
                } else { 1.0 }
            } else { 1.0 }
        } else { 1.0 }
        prev_click_down = 1.0
    } else {
        drag_target_win = 0.0
        resize_target_win = 0.0
        prev_click_down = 0.0
        spatial_main_handle_input(mx, my, 0.0, 0.0)
    }

    // ===========================================================================
    // RENDERIZADO DEL ENTORNO
    // ===========================================================================
    // 1. Fondo Espacial Toroidal (Cuadrícula ortogonal infinita y estrellas)
    spatial_main_render(sw, sh)

    // 2. Screen 1: Editor de Código
    render_window_frame(s1_x, s1_y, s1_w, s1_h, sw, sh, s1_min, "📝 Screen 1: Editor de Código")
    hx = spatial_world_to_screen_x(s1_x, s1_w, sw)
    hy = spatial_world_to_screen_y(s1_y, s1_h, sh)
    render_screen_editor_content(hx, hy, s1_w, s1_h, s1_min, s1_sc_x, s1_sc_y)

    // 3. Screen 2: Explorador de Archivos
    render_window_frame(s2_x, s2_y, s2_w, s2_h, sw, sh, s2_min, "📁 Screen 2: Explorador de Archivos")
    hx = spatial_world_to_screen_x(s2_x, s2_w, sw)
    hy = spatial_world_to_screen_y(s2_y, s2_h, sh)
    render_screen_explorer_content(hx, hy, s2_w, s2_h, s2_min, s2_sc_x, s2_sc_y)

    // 4. Screen 3: Live Preview PVM
    render_window_frame(s3_x, s3_y, s3_w, s3_h, sw, sh, s3_min, "🔬 Screen 3: Live Preview PVM")
    hx = spatial_world_to_screen_x(s3_x, s3_w, sw)
    hy = spatial_world_to_screen_y(s3_y, s3_h, sh)
    render_screen_preview_content(hx, hy, s3_w, s3_h, s3_min, t_global, gp_conn, right_click, mid_click)

    // 5. Barras fijas del sistema
    render_top_menubar(sw, sh)
    render_bottom_statusbar(sw, sh)
}

