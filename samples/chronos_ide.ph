// ===============================================================================
// CHRONOS IDE — APLICATIVO PRINCIPAL (chronos_ide.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Soberana: 100% Código PhasorLang Puro
// Hito 1: Fondo Espacial Toroidal + Ventanas Hijas (Screens) Modulares
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
signal s1_w = 460.0
signal s1_h = 360.0

// Screen 2: Explorador de Archivos
signal s2_x = 540.0
signal s2_y = 80.0
signal s2_w = 320.0
signal s2_h = 360.0

// Screen 3: Live Preview & Visor Científico
signal s3_x = 890.0
signal s3_y = 80.0
signal s3_w = 360.0
signal s3_h = 360.0

// Mutex de Interacción (Arrastre de ventana vs Desplazamiento de fondo)
signal drag_target_win = 0.0   // 0=Ninguna, 1=Screen1, 2=Screen2, 3=Screen3
signal drag_offset_x = 0.0
signal drag_offset_y = 0.0

// -------------------------------------------------------------------------------
// 3. CONTENIDO: SCREEN 1 (EDITOR)
// -------------------------------------------------------------------------------
render_screen_editor_content(hx, hy, hw, hh) = {
    // Menú superior de la ventana del editor
    rect(hx + 1.0, hy + 29.0, hw - 2.0, 24.0, 0x111620)
    line(hx + 1.0, hy + 53.0, hx + hw - 1.0, hy + 53.0, 0x21262D)
    text("Archivo", hx + 12.0, hy + 35.0, 9, 0x8B949E)
    text("Editar", hx + 64.0, hy + 35.0, 9, 0x8B949E)
    text("Ver", hx + 110.0, hy + 35.0, 9, 0x8B949E)
    text("Compilar HTML", hx + 140.0, hy + 35.0, 9, 0x3FB950)

    // Área de código
    rect(hx + 1.0, hy + 54.0, 32.0, hh - 55.0, 0x090D13)
    line(hx + 33.0, hy + 54.0, hx + 33.0, hy + hh - 1.0, 0x21262D)
    
    // Números de línea
    text("1", hx + 12.0, hy + 64.0, 9, 0x484F58)
    text("2", hx + 12.0, hy + 82.0, 9, 0x484F58)
    text("3", hx + 12.0, hy + 100.0, 9, 0x484F58)
    text("4", hx + 12.0, hy + 118.0, 9, 0x484F58)
    text("5", hx + 12.0, hy + 136.0, 9, 0x484F58)
    text("6", hx + 12.0, hy + 154.0, 9, 0x484F58)

    // Código fuente de muestra en el editor
    text("import \"lib/ui_spatial_main.ph\"", hx + 42.0, hy + 64.0, 9, 0x79C0FF)
    text("import \"lib/ui_window.ph\"", hx + 42.0, hy + 82.0, 9, 0x79C0FF)
    text("signal t = 0.0", hx + 42.0, hy + 100.0, 9, 0x58A6FF)
    text("screen main {", hx + 42.0, hy + 118.0, 9, 0xF2CC60)
    text("    spatial_main_render(R250, R251)", hx + 58.0, hy + 136.0, 9, 0x3FB950)
    text("}", hx + 42.0, hy + 154.0, 9, 0xF2CC60)
    1.0
}

// -------------------------------------------------------------------------------
// 4. CONTENIDO: SCREEN 2 (EXPLORADOR)
// -------------------------------------------------------------------------------
render_screen_explorer_content(hx, hy, hw, hh) = {
    rect(hx + 1.0, hy + 29.0, hw - 2.0, hh - 30.0, 0x0A0E15)
    text("📁 PROYECTO: SketchWarePro", hx + 14.0, hy + 38.0, 9, 0x58A6FF)
    text("v 📁 samples/", hx + 20.0, hy + 58.0, 9, 0x8B949E)
    text("    ⚡ chronos_ide.ph (Activo)", hx + 24.0, hy + 76.0, 9, 0x3FB950)
    text("    ⚡ fractal_ui.ph", hx + 24.0, hy + 94.0, 9, 0x79C0FF)
    text("v 📁 lib/", hx + 20.0, hy + 114.0, 9, 0x8B949E)
    text("    ⚡ ui_spatial_main.ph", hx + 24.0, hy + 132.0, 9, 0x79C0FF)
    text("    ⚡ ui_window.ph", hx + 24.0, hy + 150.0, 9, 0x79C0FF)
    text("v 📁 dist/", hx + 20.0, hy + 170.0, 9, 0x8B949E)
    text("    🌐 chronos_ide.html", hx + 24.0, hy + 188.0, 9, 0xF2CC60)
    1.0
}

// -------------------------------------------------------------------------------
// 5. CONTENIDO: SCREEN 3 (LIVE PREVIEW)
// -------------------------------------------------------------------------------
render_screen_preview_content(hx, hy, hw, hh, t) = {
    rect(hx + 1.0, hy + 29.0, hw - 2.0, hh - 30.0, 0x070B12)
    cx = hx + (hw * 0.5)
    cy = hy + 80.0 + 29.0
    // Círculos y fasor dinámico
    circle(cx, cy, 48.0, 0x1F6FEB)
    circle(cx, cy, 24.0, 0x238636)
    ang = t * 0.05
    fx = cx + (42.0 * cos(ang))
    fy = cy - (42.0 * sin(ang))
    line(cx, cy, fx, fy, 0x00E5FF)
    circle(fx, fy, 3.5, 0x3FB950)

    // Telemetría SoA Zero-GC
    text("ESCENARIO FASORIAL 120 FPS", hx + 14.0, hy + 180.0, 9, 0x58A6FF)
    text("Hardware Regs: R250..R255", hx + 14.0, hy + 198.0, 9, 0x3FB950)
    text("Zero-GC: 0 bytes en heap", hx + 14.0, hy + 216.0, 9, 0x8B949E)
    1.0
}

// -------------------------------------------------------------------------------
// 6. BARRAS PERSISTENTES SUPERIOR E INFERIOR (DESKTOP DOCK)
// -------------------------------------------------------------------------------
render_top_menubar(sw, sh) = {
    rect(0.0, 0.0, sw, 48.0, 0x0D1117)
    line(0.0, 48.0, sw, 48.0, 0x30363D)
    text("⚡ CHRONOS IDE — KORADEVS ECOSYSTEM", 16.0, 16.0, 12, 0x58A6FF)
    text("100% PHASORLANG AUTÓNOMO | 120 FPS ZERO-GC | REGISTROS R250..R255", 360.0, 18.0, 9, 0x8B949E)
    1.0
}

render_bottom_statusbar(sw, sh) = {
    by = sh - 24.0
    rect(0.0, by, sw, 24.0, 0x0B0E14)
    line(0.0, by, sw, by, 0x21262D)
    text("Listo | Espacio Toroidal Continuo SoA | Clic en fondo: Pan 360° | Clic en barra de título: Arrastrar ventana", 16.0, by + 6.0, 9, 0x3FB950)
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

    if (sw < 240.0) { sw = 800.0 } else { 1.0 }
    if (sh < 240.0) { sh = 600.0 } else { 1.0 }

    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()

    // ===========================================================================
    // GESTIÓN DE ENTRADA EXCLUSIVA (MUTEX: ARRASTRE DE VENTANA VS ARRASTRE DE FONDO)
    // ===========================================================================
    if (pd == 1.0) {
        if (drag_target_win > 0.0) {
            // Arrastre continuo de la ventana activa
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
        } else {
            // Nuevo clic: Verificar que no caiga en las barras fijas del viewport
            if (my > 48.0) { if (my < (sh - 24.0)) {
                // Verificar hit en barra de título de Screen 1
                hit1 = window_hit_title(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my)
                if (hit1 == 1.0) {
                    drag_target_win = 1.0
                    hx1 = spatial_world_to_screen_x(s1_x, s1_w, sw)
                    hy1 = spatial_world_to_screen_y(s1_y, s1_h, sh)
                    drag_offset_x = mx - hx1
                    drag_offset_y = my - hy1
                } else {
                    // Verificar hit en barra de título de Screen 2
                    hit2 = window_hit_title(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my)
                    if (hit2 == 1.0) {
                        drag_target_win = 2.0
                        hx2 = spatial_world_to_screen_x(s2_x, s2_w, sw)
                        hy2 = spatial_world_to_screen_y(s2_y, s2_h, sh)
                        drag_offset_x = mx - hx2
                        drag_offset_y = my - hy2
                    } else {
                        // Verificar hit en barra de título de Screen 3
                        hit3 = window_hit_title(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my)
                        if (hit3 == 1.0) {
                            drag_target_win = 3.0
                            hx3 = spatial_world_to_screen_x(s3_x, s3_w, sw)
                            hy3 = spatial_world_to_screen_y(s3_y, s3_h, sh)
                            drag_offset_x = mx - hx3
                            drag_offset_y = my - hy3
                        } else {
                            // Verificar si cayó en el cuerpo de alguna ventana
                            body1 = window_hit_body(s1_x, s1_y, s1_w, s1_h, sw, sh, mx, my)
                            body2 = window_hit_body(s2_x, s2_y, s2_w, s2_h, sw, sh, mx, my)
                            body3 = window_hit_body(s3_x, s3_y, s3_w, s3_h, sw, sh, mx, my)
                            if (body1 == 0.0) { if (body2 == 0.0) { if (body3 == 0.0) {
                                // Clic en espacio vacío del fondo -> Pan del fondo toroidal
                                spatial_main_handle_input(mx, my, pd, 1.0)
                            } } }
                        }
                    }
                }
            } }
        }
    } else {
        drag_target_win = 0.0
        spatial_main_handle_input(mx, my, 0.0, 0.0)
    }

    // ===========================================================================
    // RENDERIZADO DEL ENTORNO
    // ===========================================================================
    // 1. Fondo Espacial Toroidal (Cuadrícula ortogonal infinita y estrellas)
    spatial_main_render(sw, sh)

    // 2. Screen 1: Editor de Código
    render_window_frame(s1_x, s1_y, s1_w, s1_h, sw, sh)
    hx1 = spatial_world_to_screen_x(s1_x, s1_w, sw)
    hy1 = spatial_world_to_screen_y(s1_y, s1_h, sh)
    text("📝 Screen 1: Editor de Código", hx1 + 12.0, hy1 + 8.0, 10, 0x58A6FF)
    render_screen_editor_content(hx1, hy1, s1_w, s1_h)

    // 3. Screen 2: Explorador de Archivos
    render_window_frame(s2_x, s2_y, s2_w, s2_h, sw, sh)
    hx2 = spatial_world_to_screen_x(s2_x, s2_w, sw)
    hy2 = spatial_world_to_screen_y(s2_y, s2_h, sh)
    text("📁 Screen 2: Explorador de Archivos", hx2 + 12.0, hy2 + 8.0, 10, 0x58A6FF)
    render_screen_explorer_content(hx2, hy2, s2_w, s2_h)

    // 4. Screen 3: Live Preview PVM
    render_window_frame(s3_x, s3_y, s3_w, s3_h, sw, sh)
    hx3 = spatial_world_to_screen_x(s3_x, s3_w, sw)
    hy3 = spatial_world_to_screen_y(s3_y, s3_h, sh)
    text("🔬 Screen 3: Live Preview PVM", hx3 + 12.0, hy3 + 8.0, 10, 0x58A6FF)
    render_screen_preview_content(hx3, hy3, s3_w, s3_h, t_global)

    // 5. Barras fijas del sistema
    render_top_menubar(sw, sh)
    render_bottom_statusbar(sw, sh)
}
