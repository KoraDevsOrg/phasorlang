// ===============================================================================
// CHRONOS IDE — MÓDULO NATIVO DE MENÚS, CONTENEDORES Y CONEXIÓN DE IA (lib/ui_ide_menu.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Unificada Multi-Ventana: 6 Ventanas Ortogonales SoA a 120 FPS
// - Ventanas Móviles Libres por Toda la Pantalla (Drag & Drop en PhasorLang)
// - Minimizables a Barrita de Título (28px) con Botones [-]/[+]
// - Scroll Coherente Multidireccional & Diagonal (Arrastre + Rueda)
// - Mundo Virtual Giratorio/Desplazable en 360° con Pantalla Visible Siempre Plana
// ===============================================================================
import "lib/color.ph"
import "lib/ui.ph"
import "lib/view.ph"
import "lib/barge_in_assistant.ph"
import "lib/tts_speech.ph"
import "lib/procedural_video.ph"

// 1. ESTADOS GLOBALES DE LA INTERFAZ DEL IDE (MEMORIA CONTIGUA SOA)
signal ide_panel_activo = 1.0     // 1=Editor, 2=Explorador, 3=Escenario PVM, 4=Depurador, 5=Terminal/Disasm, 6=IA Avatar
signal ide_modo_escritorio = 1.0  // Detectado dinámicamente por R250 >= 768px
signal ide_ia_status = 1.0        // 1.0 = Gemini Cloud Pro (Profesor), 2.0 = Local SLM (Estudiante)
signal ide_ia_talking = 0.0       // Nivel de energía de voz para el avatar reactivo
signal ide_ia_emotion = 1.0       // 1=Normal, 2=Feliz, 3=Pensando, 4=Alerta
signal ide_dbg_paused = 0.0       // 1.0 = Pausado en breakpoint, 0.0 = Ejecutando
signal ide_dbg_line = 4.0         // Línea de código activa en depurador
signal ide_sec_modal = 0.0        // 1.0 = Diálogo modal de seguridad de red abierto
signal ide_build_count = 1.0      // Conteo de ciclos de auto-recompilación
signal ide_editor_subtab = 1.0    // 1.0 = Editor de Código, 2.0 = Documentación Interactiva

// 2. CÁMARA DEL MUNDO VIRTUAL 360° (PAN Y NAVEGACIÓN EN TODAS DIRECCIONES)
signal world_cam_x = 0.0
signal world_cam_y = 0.0
signal world_prev_mx = 0.0
signal world_prev_my = 0.0
signal world_dragging = 0.0

// 3. GESTOR DE VENTANAS MÓVILES LIBRES, MINIMIZABLES Y SCROLL MULTIDIRECCIONAL
signal drag_win_id = 0.0
signal drag_win_ox = 0.0
signal drag_win_oy = 0.0
signal scroll_win_id = 0.0

// Posiciones mundiales (wx, wy), dimensiones (ww, wh), minimizado (w_min), scroll (sc_x, sc_y)
signal w1_x = 40.0
signal w1_y = 60.0
signal w1_w = 440.0
signal w1_h = 540.0
signal w1_min = 0.0
signal w1_sc_x = 0.0
signal w1_sc_y = 0.0

signal w2_x = 510.0
signal w2_y = 60.0
signal w2_w = 640.0
signal w2_h = 540.0
signal w2_min = 0.0
signal w2_sc_x = 0.0
signal w2_sc_y = 0.0

signal w3_x = 1180.0
signal w3_y = 60.0
signal w3_w = 540.0
signal w3_h = 540.0
signal w3_min = 0.0
signal w3_sc_x = 0.0
signal w3_sc_y = 0.0

signal w4_x = 1750.0
signal w4_y = 60.0
signal w4_w = 520.0
signal w4_h = 540.0
signal w4_min = 0.0
signal w4_sc_x = 0.0
signal w4_sc_y = 0.0

signal w5_x = 2300.0
signal w5_y = 60.0
signal w5_w = 520.0
signal w5_h = 540.0
signal w5_min = 0.0
signal w5_sc_x = 0.0
signal w5_sc_y = 0.0

signal w6_x = 2850.0
signal w6_y = 60.0
signal w6_w = 520.0
signal w6_h = 540.0
signal w6_min = 0.0
signal w6_sc_x = 0.0
signal w6_sc_y = 0.0

// 4. ACCIONES DE MINIMIZADO Y RESTAURACIÓN DE CADA VENTANA
action act_toggle_min_w1 { w1_min = 1.0 - w1_min }
action act_toggle_min_w2 { w2_min = 1.0 - w2_min }
action act_toggle_min_w3 { w3_min = 1.0 - w3_min }
action act_toggle_min_w4 { w4_min = 1.0 - w4_min }
action act_toggle_min_w5 { w5_min = 1.0 - w5_min }
action act_toggle_min_w6 { w6_min = 1.0 - w6_min }

// 5. ACCIONES DE MENÚ Y NAVEGACIÓN (CENTRAN LA VENTANA EN EL ÁREA PLANA VISIBLE)
action act_subtab_code { ide_editor_subtab = 1.0 }
action act_subtab_docs { ide_editor_subtab = 2.0 }
action act_tab_files  { ide_panel_activo = 2.0; world_cam_x = 0.0 - w1_x + 60.0; world_cam_y = 0.0 }
action act_tab_editor { ide_panel_activo = 1.0; world_cam_x = 0.0 - w2_x + 60.0; world_cam_y = 0.0 }
action act_tab_stage  { ide_panel_activo = 3.0; world_cam_x = 0.0 - w3_x + 60.0; world_cam_y = 0.0 }
action act_tab_debug  { ide_panel_activo = 4.0; world_cam_x = 0.0 - w4_x + 60.0; world_cam_y = 0.0 }
action act_tab_disasm { ide_panel_activo = 5.0; world_cam_x = 0.0 - w5_x + 60.0; world_cam_y = 0.0 }
action act_tab_ai     { ide_panel_activo = 6.0; world_cam_x = 0.0 - w6_x + 60.0; world_cam_y = 0.0 }
action act_belt_prev  { world_cam_x = world_cam_x + 400.0 }
action act_belt_next  { world_cam_x = world_cam_x - 400.0 }

action act_run_script {
    ide_panel_activo = 3.0
    world_cam_x = 0.0 - w3_x + 60.0
    world_cam_y = 0.0
}

action act_step_debug {
    ide_dbg_paused = 1.0
    ide_dbg_line = ide_dbg_line + 1.0
    if (ide_dbg_line > 10.0) { ide_dbg_line = 4.0 }
}

action act_resume_debug {
    ide_dbg_paused = 0.0
    ide_panel_activo = 1.0
    world_cam_x = 0.0 - w2_x + 60.0
    world_cam_y = 0.0
}

action act_pause_debug {
    ide_dbg_paused = 1.0
}

action act_self_compile {
    ide_build_count = ide_build_count + 1.0
    ide_panel_activo = 5.0
    world_cam_x = 0.0 - w5_x + 60.0
    world_cam_y = 0.0
}

action act_train_local_ai {
    ide_ia_emotion = 3.0
    ide_ia_status = 2.0
}

action act_toggle_net_modal {
    if (ide_sec_modal == 1.0) {
        ide_sec_modal = 0.0
    } else {
        ide_sec_modal = 1.0
    }
}

action act_barge_in_cut {
    ide_ia_talking = 0.0
    ide_ia_emotion = 1.0
}

// 6. BARRA DE ENCABEZADO Y CONTROLES DEL IDE
render_ide_header(vw, vh) = {
    rect(0.0, 0.0, vw, 48.0, 0x161B22)
    line(0.0, 48.0, vw, 48.0, 0x30363D)

    text("CHRONOS IDE", 16.0, 16.0, 14, 0x58A6FF)
    rect(130.0, 14.0, 64.0, 20.0, 0x238636)
    text("SELF-HOST", 134.0, 18.0, 8, 0xFFFFFF)

    if (vw < 768.0) {
        ide_modo_escritorio = 0.0
    } else {
        ide_modo_escritorio = 1.0
    }

    if (ide_modo_escritorio == 1.0) {
        btn("Editor", 210.0, 8.0, 75.0, 32.0, act_tab_editor, 0x1F6FEB)
        btn("Archivos", 290.0, 8.0, 75.0, 32.0, act_tab_files, 0x238636)
        btn("Lienzo Hz", 370.0, 8.0, 85.0, 32.0, act_tab_stage, 0x00E5FF)
        btn("Debug", 460.0, 8.0, 70.0, 32.0, act_tab_debug, 0xD29922)
        btn("Terminal", 535.0, 8.0, 80.0, 32.0, act_tab_disasm, 0x8957E5)
        btn("IA Avatar", 620.0, 8.0, 85.0, 32.0, act_tab_ai, 0xDB61A2)
        btn("<", 712.0, 8.0, 32.0, 32.0, act_belt_prev, 0x21262D)
        btn(">", 748.0, 8.0, 32.0, 32.0, act_belt_next, 0x21262D)

        bx_recomp = vw - 310.0
        btn("⚙ Re-Compilar (.wasm)", bx_recomp, 8.0, 160.0, 32.0, act_self_compile, 0x8957E5)
        bx_exec = vw - 140.0
        btn("▶ Ejecutar (F5)", bx_exec, 8.0, 125.0, 32.0, act_run_script, 0x238636)
    } else {
        bw = vw / 6.0
        btn("Edit", 0.0, 8.0, bw - 2.0, 32.0, act_tab_editor, 0x1F6FEB)
        b1 = bw
        btn("Files", b1, 8.0, bw - 2.0, 32.0, act_tab_files, 0x238636)
        b2 = bw * 2.0
        btn("Lienzo", b2, 8.0, bw - 2.0, 32.0, act_tab_stage, 0x00E5FF)
        b3 = bw * 3.0
        btn("Dbg", b3, 8.0, bw - 2.0, 32.0, act_tab_debug, 0xD29922)
        b4 = bw * 4.0
        btn("Term", b4, 8.0, bw - 2.0, 32.0, act_tab_disasm, 0x8957E5)
        b5 = bw * 5.0
        btn("IA", b5, 8.0, bw - 2.0, 32.0, act_tab_ai, 0xDB61A2)
    }
    1.0
}

// 7. VENTANA 1: EXPLORADOR DE PROYECTO AUTÓNOMO (100% PHASORLANG ZERO-GC)
render_window_explorer(vx, vy, vw, vh, sc_x, sc_y) = {
    rect(vx, vy, vw, vh, 0x090D13)

    // Toolbar superior
    rect(vx, vy, vw, 34.0, 0x161B22)
    line(vx, vy + 34.0, vx + vw, vy + 34.0, 0x30363D)
    tb_b1 = vx + 8.0
    btn("📁 Proyecto", tb_b1, vy + 4.0, 95.0, 26.0, act_tab_files, 0x1F6FEB)
    tb_b2 = vx + 108.0
    btn("⚡ samples", tb_b2, vy + 4.0, 95.0, 26.0, act_tab_editor, 0x238636)
    tb_b3 = vx + 208.0
    btn("📚 lib", tb_b3, vy + 4.0, 80.0, 26.0, act_subtab_docs, 0x30363D)

    // Cabecera del árbol
    fx = vx + 16.0 - sc_x
    fy = vy + 44.0 - sc_y
    text("EXPLORER: SketchWarePro", fx, fy, 10, 0x8B949E)
    line_w = vw - 32.0
    line(fx, fy + 16.0, fx + line_w, fy + 16.0, 0x21262D)

    // Nodos del árbol jerárquico con scroll 2D
    fy1 = fy + 26.0;  text("v 📁 samples/", fx + 8.0, fy1, 10, 0x79C0FF)
    fy2 = fy + 48.0;  text("    ⚡ phasor_ide.ph (Activo)", fx + 12.0, fy2, 10, 0x3FB950)
    fy3 = fy + 68.0;  text("    📄 demo_koradevs_master.fas", fx + 12.0, fy3, 10, 0x58A6FF)
    fy4 = fy + 88.0;  text("    📐 fractal_ui.ph", fx + 12.0, fy4, 10, 0x8B949E)

    fy5 = fy + 112.0; text("v 📁 lib/", fx + 8.0, fy5, 10, 0x79C0FF)
    fy6 = fy + 134.0; text("    ⚡ ui_ide_menu.ph (WindowManager)", fx + 12.0, fy6, 10, 0x3FB950)
    fy7 = fy + 154.0; text("    ⚡ file_explorer.ph", fx + 12.0, fy7, 10, 0x8B949E)
    fy8 = fy + 174.0; text("    ⚡ barge_in_assistant.ph", fx + 12.0, fy8, 10, 0xDB61A2)
    fy9 = fy + 194.0; text("    ⚡ tts_speech.ph", fx + 12.0, fy9, 10, 0xD29922)
    fy10 = fy + 214.0; text("    ⚡ procedural_video.ph", fx + 12.0, fy10, 10, 0x00E5FF)

    fy11 = fy + 238.0; text("v 📁 tests/", fx + 8.0, fy11, 10, 0x79C0FF)
    fy12 = fy + 260.0; text("    ✔ 01_test_pvm_jumps.fas", fx + 12.0, fy12, 10, 0x3FB950)
    fy13 = fy + 280.0; text("    ✔ 02_test_hertz_colors.fas", fx + 12.0, fy13, 10, 0x3FB950)
    fy14 = fy + 300.0; text("    ✔ 03_test_ui_responsive.fas", fx + 12.0, fy14, 10, 0x3FB950)
    fy15 = fy + 320.0; text("    ✔ 04_test_audio_bargein.fas", fx + 12.0, fy15, 10, 0x3FB950)
    fy16 = fy + 340.0; text("    ✔ 05_test_polyglot_hub.fas", fx + 12.0, fy16, 10, 0x3FB950)
    fy17 = fy + 360.0; text("    ✔ 06_test_file_explorer_tree.fas", fx + 12.0, fy17, 10, 0x3FB950)

    fy18 = fy + 384.0; text("v 📁 dist/", fx + 8.0, fy18, 10, 0x79C0FF)
    fy19 = fy + 406.0; text("    🌐 chronos_ide.html (Standalone)", fx + 12.0, fy19, 10, 0x58A6FF)
    fy20 = fy + 426.0; text("    ⚡ phasor_runtime.js (Micro-Runner)", fx + 12.0, fy20, 10, 0xE5C07B)

    fy21 = fy + 450.0; text("📄 GEMINI.md (Directrices Maestras)", fx + 8.0, fy21, 10, 0x58A6FF)
    fy22 = fy + 470.0; text("⚙ phasor.toml (Configuración)", fx + 8.0, fy22, 10, 0xD29922)
    fy23 = fy + 490.0; text("⎇ .gitignore", fx + 8.0, fy23, 10, 0xF85149)

    // Barra de estado de ventana
    bar_y = vy + vh - 22.0
    rect(vx, bar_y, vw, 22.0, 0x161B22)
    line(vx, bar_y, vx + vw, bar_y, 0x30363D)
    text("12 archivos indexados | 159 tests [PASS] | SoA Contiguo", vx + 10.0, bar_y + 6.0, 9, 0x8B949E)
    1.0
}

// 8. VENTANA 2: EDITOR DE CÓDIGO INTELIGENTE & DOCS CON SCROLL COHERENTE
render_window_editor(vx, vy, vw, vh, t_frame, sc_x, sc_y) = {
    rect(vx, vy, vw, vh, 0x0D1117)

    half_w = vw * 0.5
    tab_r_x = vx + half_w
    if (ide_editor_subtab == 1.0) {
        rect(vx, vy, half_w, 28.0, 0x1F6FEB)
        text("📝 Editor de Código", vx + 16.0, vy + 8.0, 10, 0xFFFFFF)
        rect(tab_r_x, vy, half_w, 28.0, 0x161B22)
        text("📚 Docs PhasorLang", tab_r_x + 16.0, vy + 8.0, 10, 0x8B949E)
        btn("📚 Docs", tab_r_x, vy, half_w, 28.0, act_subtab_docs, 0x21262D)
    } else {
        rect(vx, vy, half_w, 28.0, 0x161B22)
        text("📝 Editor de Código", vx + 16.0, vy + 8.0, 10, 0x8B949E)
        btn("📝 Editor", vx, vy, half_w, 28.0, act_subtab_code, 0x21262D)
        rect(tab_r_x, vy, half_w, 28.0, 0x238636)
        text("📚 Docs PhasorLang", tab_r_x + 16.0, vy + 8.0, 10, 0xFFFFFF)
    }
    line(vx, vy + 28.0, vx + vw, vy + 28.0, 0x30363D)

    if (ide_editor_subtab == 2.0) {
        dy = vy + 36.0 - sc_y
        dx = vx + 16.0 - sc_x
        text("GUÍA RÁPIDA DE SINTAXIS PHASORLANG & SNIPPETS", dx, dy, 11, 0x58A6FF)
        text("Lenguaje vectorial Zero-GC de ultra-alto rendimiento (120 FPS)", dx, dy + 18.0, 9, 0x8B949E)

        rect(dx - 2.0, dy + 38.0, vw - 28.0, 64.0, 0x161B22)
        line(dx - 2.0, dy + 38.0, dx - 2.0, dy + 102.0, 0x1F6FEB)
        text("1. Variables y Fasores Polares (Vec3 SIMD)", dx + 8.0, dy + 46.0, 10, 0x79C0FF)
        text("v: Vec3 = [120.0, 45.0, 0.0]  // Mag ∠ Ang", dx + 8.0, dy + 62.0, 10, 0xFFFFFF)
        text("f = 60.0; w = 2.0 * 3.14159 * f", dx + 8.0, dy + 78.0, 10, 0x3FB950)

        rect(dx - 2.0, dy + 110.0, vw - 28.0, 64.0, 0x161B22)
        line(dx - 2.0, dy + 110.0, dx - 2.0, dy + 174.0, 0x238636)
        text("2. Pantallas Reactivas y Renderizado", dx + 8.0, dy + 118.0, 10, 0x3FB950)
        text("screen \"main\" { cls(0x0D1117); circle(cx, cy, 50.0, 0x58A6FF) }", dx + 8.0, dy + 134.0, 10, 0xFFFFFF)
        text("rect(x, y, w, h, col); line(x1, y1, x2, y2, col)", dx + 8.0, dy + 150.0, 10, 0xD29922)

        rect(dx - 2.0, dy + 182.0, vw - 28.0, 64.0, 0x161B22)
        line(dx - 2.0, dy + 182.0, dx - 2.0, dy + 246.0, 0xD29922)
        text("3. Memoria SoA Zero-GC y Registros Hardware", dx + 8.0, dy + 190.0, 10, 0xD29922)
        text("buf = alloc_soa(3, 512)  // Structure of Arrays", dx + 8.0, dy + 206.0, 10, 0xFFFFFF)
        text("vw = R250; vh = R251; ptr_x = R252; ptr_y = R253", dx + 8.0, dy + 222.0, 10, 0x79C0FF)

        doc_bar_y = vy + vh - 24.0
        rect(vx, doc_bar_y, vw, 24.0, 0x161B22)
        line(vx, doc_bar_y, vx + vw, doc_bar_y, 0x30363D)
        text("Sintaxis Oficial PhasorLang v1.0 • KoraDevs Autonomous Ecosystem", vx + 12.0, doc_bar_y + 7.0, 10, 0x8B949E)
        1.0
    } else {
        rect(vx, vy + 28.0, vw, 30.0, 0x161B22)
        line(vx, vy + 58.0, vx + vw, vy + 58.0, 0x30363D)
        rect(vx, vy + 28.0, 200.0, 30.0, 0x0D1117)
        line(vx + 200.0, vy + 28.0, vx + 200.0, vy + 58.0, 0x30363D)
        text("⚡ samples/phasor_ide.ph (Self-Hosted)", vx + 12.0, vy + 38.0, 10, 0x58A6FF)

        gutter_w = 40.0
        rect(vx, vy + 58.0, gutter_w, vh - 82.0, 0x161B22)
        line(vx + gutter_w, vy + 58.0, vx + gutter_w, vy + vh - 24.0, 0x30363D)

        // Breakpoints visuales en el gutter con scroll Y
        bp_y1 = vy + 145.0 - sc_y
        bp_y2 = vy + 205.0 - sc_y
        if (bp_y1 >= vy + 58.0) { if (bp_y1 <= vy + vh - 24.0) { circle(vx + 14.0, bp_y1, 4.0, 0xF85149) } }
        if (bp_y2 >= vy + 58.0) { if (bp_y2 <= vy + vh - 24.0) { circle(vx + 14.0, bp_y2, 4.0, 0xF85149) } }

        // Numeración con scroll Y
        text("1", vx + 22.0, vy + 85.0 - sc_y, 10, 0x8B949E)
        text("2", vx + 22.0, vy + 105.0 - sc_y, 10, 0x8B949E)
        text("3", vx + 22.0, vy + 125.0 - sc_y, 10, 0x8B949E)
        text("4", vx + 22.0, vy + 145.0 - sc_y, 10, 0xF85149)
        text("5", vx + 22.0, vy + 165.0 - sc_y, 10, 0x8B949E)
        text("6", vx + 22.0, vy + 185.0 - sc_y, 10, 0x8B949E)
        text("7", vx + 22.0, vy + 205.0 - sc_y, 10, 0xF85149)
        text("8", vx + 22.0, vy + 225.0 - sc_y, 10, 0x8B949E)
        text("9", vx + 22.0, vy + 245.0 - sc_y, 10, 0x8B949E)
        text("10", vx + 16.0, vy + 265.0 - sc_y, 10, 0x8B949E)

        if (ide_dbg_paused == 1.0) {
            dbg_y = vy + 137.0 - sc_y
            if (dbg_y >= vy + 58.0) { if (dbg_y <= vy + vh - 24.0) {
                rect(vx + gutter_w, dbg_y, vw - gutter_w, 20.0, 0x2E2412)
                line(vx + gutter_w, dbg_y, vx + gutter_w, dbg_y + 20.0, 0xD29922)
                text("▶", vx + gutter_w - 12.0, dbg_y + 8.0, 9, 0xD29922)
            } }
        }

        // Líneas de código con scroll en X y en Y
        tx = vx + gutter_w + 14.0 - sc_x
        ty_base = vy - sc_y
        text("// CHRONOS IDE — Codigo fuente del IDE autohospedado en ejecucion", tx, ty_base + 85.0, 11, 0x8B949E)
        text("import ui_ide_menu", tx, ty_base + 105.0, 11, 0xBC8CFF)
        text("signal ide_fps = 120.0", tx, ty_base + 125.0, 11, 0x3FB950)
        text("v_smith: Vec3 = [120.0, 45.0, 0.0]  // Fasor (Mag ∠ Ang)", tx, ty_base + 145.0, 11, 0x79C0FF)
        text("screen \"main\" {", tx, ty_base + 165.0, 11, 0x58A6FF)
        text("    cls(0x0D1117)", tx, ty_base + 185.0, 11, 0x58A6FF)
        text("    ui_ide_menu.render_ide_workspace(R250, R251, t_global)", tx, ty_base + 205.0, 11, 0xD2A8FF)
        text("    smith_chart(cx, cy, 75.0, 0.35, 0.42)", tx, ty_base + 225.0, 11, 0x00E5FF)
        text("    procedural_ai_face(t_global, cx, cy, talking, 1.0)", tx, ty_base + 245.0, 11, 0xF778BA)
        text("}", tx, ty_base + 265.0, 11, 0x58A6FF)

        // Cursor parpadeante Zero-GC
        blink = (t_frame * 0.05) % 2.0
        if (blink > 1.0) {
            line(tx + 280.0, ty_base + 142.0, tx + 280.0, ty_base + 158.0, 0x00E5FF)
        } else {
            1.0
        }

        // Barras de scroll visuales (Vertical y Horizontal)
        // Vertical track & thumb
        rect(vx + vw - 8.0, vy + 58.0, 6.0, vh - 82.0, 0x161B22)
        thumb_h = 40.0
        thumb_y = vy + 58.0 + (sc_y * 0.15)
        if (thumb_y > vy + vh - 24.0 - thumb_h) { thumb_y = vy + vh - 24.0 - thumb_h }
        rect(vx + vw - 8.0, thumb_y, 6.0, thumb_h, 0x30363D)

        // Horizontal track & thumb
        rect(vx + gutter_w, vy + vh - 30.0, vw - gutter_w - 8.0, 6.0, 0x161B22)
        thumb_w = 40.0
        thumb_x = vx + gutter_w + (sc_x * 0.15)
        if (thumb_x > vx + vw - 8.0 - thumb_w) { thumb_x = vx + vw - 8.0 - thumb_w }
        rect(thumb_x, vy + vh - 30.0, thumb_w, 6.0, 0x30363D)

        // Barra de estado del editor
        ed_bar_y = vy + vh - 24.0
        rect(vx, ed_bar_y, vw, 24.0, 0x161B22)
        line(vx, ed_bar_y, vx + vw, ed_bar_y, 0x30363D)
        text("Ln 4, Col 32 | UTF-8 | GapBuffer SoA (64 KB) | Scroll 2D Activo", vx + 12.0, ed_bar_y + 7.0, 10, 0x8B949E)
        1.0
    }
}

// 9. VENTANA 3: ESCENARIO PVM & VISORES CIENTÍFICOS HZ (120 FPS)
render_window_stage(vx, vy, vw, vh, t_frame) = {
    rect(vx, vy, vw, vh, 0x070B12)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("🔬 ESCENARIO PVM — VISORES CIENTÍFICOS (120 FPS ZERO-GC)", vx + 12.0, vy + 10.0, 11, 0x00E5FF)

    cx = vx + (vw * 0.32)
    cy = vy + (vh * 0.48)
    r_smith = 80.0
    if (vw < 400.0) { r_smith = 55.0 }

    circle(cx, cy, r_smith, 0x1F6FEB)
    circle(cx, cy, r_smith * 0.5, 0x238636)
    circle(cx + (r_smith * 0.5), cy, r_smith * 0.5, 0x30363D)
    line(cx - r_smith, cy, cx + r_smith, cy, 0x30363D)
    line(cx, cy - r_smith, cx, cy + r_smith, 0x30363D)
    text("Gamma Real", cx + r_smith + 6.0, cy - 4.0, 9, 0x58A6FF)
    text("+j Imag", cx - 18.0, cy - r_smith - 8.0, 9, 0x58A6FF)

    ang = t_frame * 0.04
    fx = cx + (r_smith * 0.65 * cos(ang))
    fy = cy - (r_smith * 0.65 * sin(ang))
    line(cx, cy, fx, fy, 0x00E5FF)
    circle(fx, fy, 4.0, 0x3FB950)

    tx_start = cx + r_smith + 30.0
    tx_end = vx + vw - 20.0
    if (tx_end > tx_start + 40.0) {
        line(tx_start, cy, tx_end, cy, 0x30363D)
        text("t [s] (Forma de Onda)", tx_end - 90.0, cy - 8.0, 9, 0x8B949E)

        px = tx_start
        while (px < tx_end) {
            t_wave = (px - tx_start) * 0.08 - (t_frame * 0.08)
            py = cy + (sin(t_wave) * 35.0)
            circle(px, py, 1.5, 0x3FB950)
            px = px + 6.0
        }
    }

    st_bar_y = vy + vh - 24.0
    rect(vx, st_bar_y, vw, 24.0, 0x161B22)
    text("Simulación Activa | Carta de Smith + Senoide Temporal | Pausas GC: 0 | 120 FPS", vx + 12.0, st_bar_y + 7.0, 10, 0x3FB950)
    1.0
}

// 10. VENTANA 4: DEPURADOR E INSPECTOR DE REGISTROS SOA
render_window_debugger(vx, vy, vw, vh) = {
    rect(vx, vy, vw, vh, 0x0D1117)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("🐞 DEPURADOR & BANCO DE REGISTROS SOA (R0..R255)", vx + 12.0, vy + 10.0, 11, 0xD29922)

    rect(vx + 15.0, vy + 45.0, vw - 30.0, 48.0, 0x161B22)
    if (ide_dbg_paused == 1.0) {
        text("ESTADO: PAUSADO EN BREAKPOINT (Linea 4, PC=0x002A)", vx + 25.0, vy + 55.0, 10, 0xD29922)
        text("Instruccion: OP_VEC3_LOAD R1 = [120.0, 45.0, 0.0]", vx + 25.0, vy + 72.0, 10, 0x3FB950)
    } else {
        text("ESTADO: EJECUCION CONTINUA A 120 FPS ZERO-GC", vx + 25.0, vy + 55.0, 10, 0x3FB950)
        text("Watchdog: 0 fallos | Sin fugas de memoria | Stack SoA contiguo", vx + 25.0, vy + 72.0, 10, 0x8B949E)
    }

    text("[R0]  (Escalar)    : 60.0000 Hz", vx + 25.0, vy + 115.0, 11, 0x58A6FF)
    text("[R1]  (Vec3 SIMD)  : [120.00, 45.00, 0.00] (v_smith)", vx + 25.0, vy + 140.0, 11, 0x79C0FF)
    text("[R2]  (Fasor Polar): 120.00 ∠ 45.00° (84.85 + 84.85j)", vx + 25.0, vy + 165.0, 11, 0x3FB950)
    text("[R250] Viewport Width : R250 Dinamico Clamped", vx + 25.0, vy + 190.0, 11, 0xFFFFFF)
    text("[R251] Viewport Height: R251 Dinamico Clamped", vx + 25.0, vy + 215.0, 11, 0xFFFFFF)
    text("[R252..R255] Puntero Tactil y Scroll Clamped", vx + 25.0, vy + 240.0, 11, 0x8B949E)

    db_by = vy + vh - 45.0
    btn("▶ Continuar", vx + 15.0, db_by, 110.0, 34.0, act_resume_debug, 0x238636)
    btn("⏭️ Paso (Step)", vx + 135.0, db_by, 120.0, 34.0, act_step_debug, 0x1F6FEB)
    btn("⏸️ Pausar", vx + 265.0, db_by, 95.0, 34.0, act_pause_debug, 0xD29922)
    1.0
}

// 11. VENTANA 5: TERMINAL PVM & DESENSAMBLADOR BYTECODE
render_window_terminal(vx, vy, vw, vh) = {
    rect(vx, vy, vw, vh, 0x090D13)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("📟 TERMINAL PVM & DESENSAMBLADOR DE BYTECODE (OP_OUT)", vx + 12.0, vy + 10.0, 11, 0x8957E5)

    text("> [PVM Kernel] Chronos IDE Self-Hosted inicializado.", vx + 15.0, vy + 45.0, 10, 0x58A6FF)
    text("> [Auto-Compiler] Modulo 'samples/phasor_ide.ph' cargado en memoria SoA.", vx + 15.0, vy + 65.0, 10, 0x3FB950)
    text("> [Desensamblador 3-Operandos]:", vx + 15.0, vy + 90.0, 10, 0xD29922)
    text("    0x0000: OP_LOAD_K    R0, K0 (60.0000)", vx + 25.0, vy + 110.0, 10, 0xFFFFFF)
    text("    0x0004: OP_VEC3_LOAD R1, [120.0, 45.0, 0.0]", vx + 25.0, vy + 130.0, 10, 0x79C0FF)
    text("    0x0008: OP_SOA_STORE buf_gap, ch0, 1.0", vx + 25.0, vy + 150.0, 10, 0xBC8CFF)
    text("    0x000C: OP_SIGNAL_SET ide_fps, 120.0", vx + 25.0, vy + 170.0, 10, 0x00E5FF)
    text("    0x0010: OP_JMP_IF_ZERO R250, 0x0028", vx + 25.0, vy + 190.0, 10, 0xF778BA)
    text("> [OUT Stream]: Ciclos de recompilacion exitosos: 1 (Ready)", vx + 15.0, vy + 220.0, 10, 0x3FB950)
    text("> [PVM Profiler] Latencia de despacho: 18 us/frame | 0 allocations", vx + 15.0, vy + 240.0, 10, 0x8B949E)

    tm_by = vy + vh - 45.0
    tm_bw = vw - 30.0
    btn("Ejecutar phasorc.ph (Compilar IDE a WASM)", vx + 15.0, tm_by, tm_bw, 34.0, act_self_compile, 0x8957E5)
    1.0
}

// 12. VENTANA 6: PANEL DE IA, AVATAR REACTIVO Y VOZ FORMÁNTICA
render_window_ai(vx, vy, vw, vh, t_frame) = {
    rect(vx, vy, vw, vh, 0x0D1117)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("✨ ASISTENTE IA — AVATAR REACTIVO & VOZ FORMÁNTICA", vx + 12.0, vy + 10.0, 11, 0xDB61A2)

    avatar_cx = vx + (vw * 0.5)
    avatar_cy = vy + 120.0
    procedural_ai_face(t_frame, avatar_cx, avatar_cy, ide_ia_talking, ide_ia_emotion)

    rect(vx + 15.0, vy + 205.0, vw - 30.0, 60.0, 0x161B22)
    if (ide_ia_status == 1.0) {
        text("PROVEEDOR: Gemini Cloud Pro (Docente / Arquitecto)", vx + 25.0, vy + 218.0, 10, 0xBC8CFF)
        text("Genera código PhasorLang validado para entrenamiento local.", vx + 25.0, vy + 236.0, 9, 0x8B949E)
    } else {
        text("PROVEEDOR: Phasor-SLM Local (Estudiante Cuantizado)", vx + 25.0, vy + 218.0, 10, 0x3FB950)
        text("Inferencia 100% offline desde dataset_phasor_incremental.jsonl", vx + 25.0, vy + 236.0, 9, 0x8B949E)
    }

    ai_bw = (vw - 36.0) * 0.5
    ai_by1 = vy + 275.0
    btn("Entrenar Modelo Local (Fine-Tuning)", vx + 15.0, ai_by1, ai_bw, 34.0, act_train_local_ai, 0x8957E5)
    ai_bx2 = vx + 21.0 + ai_bw
    btn("Interrumpir (Barge-In O(1))", ai_bx2, ai_by1, ai_bw, 34.0, act_barge_in_cut, 0xD29922)
    ai_by2 = vy + vh - 45.0
    ai_bw2 = vw - 30.0
    btn("🔒 Permisos de Red y Privacidad", vx + 15.0, ai_by2, ai_bw2, 34.0, act_toggle_net_modal, 0x21262D)
    1.0
}

// 13. DIÁLOGO MODAL DE GOBERNANZA DE SEGURIDAD DE RED
render_security_modal(vw, vh) = {
    if (ide_sec_modal == 1.0) {
        rect(0.0, 0.0, vw, vh, 0x05070A)

        mw = 420.0
        if (vw < 460.0) { mw = vw - 30.0 }
        mh = 230.0
        mx = (vw - mw) * 0.5
        my = (vh - mh) * 0.5

        rect(mx, my, mw, mh, 0x161B22)
        rect(mx, my, mw, 36.0, 0x21262D)
        line(mx, my + 36.0, mx + mw, my + 36.0, 0xF85149)
        text("🔒 GOBERNANZA DE RED KORADEVS", mx + 16.0, my + 12.0, 11, 0xF85149)

        text("El IDE funciona 100% OFFLINE por defecto.", mx + 20.0, my + 55.0, 10, 0xFFFFFF)
        text("¿Autoriza la sincronización con Gemini Cloud Pro", mx + 20.0, my + 78.0, 10, 0x8B949E)
        text("para generar nuevas lecciones de aprendizaje?", mx + 20.0, my + 98.0, 10, 0x8B949E)
        text("Estado: Aislamiento Local Estricto Activo.", mx + 20.0, my + 124.0, 10, 0x3FB950)

        mb_w = (mw - 50.0) * 0.5
        mb_y = my + mh - 50.0
        btn("Permitir Conexión", mx + 20.0, mb_y, mb_w, 36.0, act_toggle_net_modal, 0x238636)
        mb_x2 = mx + 30.0 + mb_w
        btn("Mantener Offline", mb_x2, mb_y, mb_w, 36.0, act_toggle_net_modal, 0x30363D)
    }
    1.0
}

// 14. CONTENEDOR PRINCIPAL DEL WORKSPACE AUTÓNOMO (100% PHASORLANG)
render_ide_workspace(vw, vh, t_frame, mx, my, md, mw) = {
    render_ide_header(vw, vh)

    area_y = 56.0
    area_h = vh - 56.0 - 28.0

    if (ide_modo_escritorio == 1.0) {
        // --- 1. PROCESAMIENTO REACTIVO DE PUNTERO Y ARRASTRE LIBRE ---
        dmx = 0.0
        dmy = 0.0
        if (world_dragging == 1.0) {
            dmx = mx - world_prev_mx
            dmy = my - world_prev_my
        }

        // Posiciones visibles en pantalla de cada ventana:
        s1_x = w1_x + world_cam_x; s1_y = w1_y + world_cam_y; s1_h = w1_h
        if (w1_min == 1.0) { s1_h = 28.0 }

        s2_x = w2_x + world_cam_x; s2_y = w2_y + world_cam_y; s2_h = w2_h
        if (w2_min == 1.0) { s2_h = 28.0 }

        s3_x = w3_x + world_cam_x; s3_y = w3_y + world_cam_y; s3_h = w3_h
        if (w3_min == 1.0) { s3_h = 28.0 }

        s4_x = w4_x + world_cam_x; s4_y = w4_y + world_cam_y; s4_h = w4_h
        if (w4_min == 1.0) { s4_h = 28.0 }

        s5_x = w5_x + world_cam_x; s5_y = w5_y + world_cam_y; s5_h = w5_h
        if (w5_min == 1.0) { s5_h = 28.0 }

        s6_x = w6_x + world_cam_x; s6_y = w6_y + world_cam_y; s6_h = w6_h
        if (w6_min == 1.0) { s6_h = 28.0 }

        // MÁQUINA DE ESTADOS DE ARRASTRE Y SCROLL
        if (md == 1.0) {
            if (world_dragging == 0.0) {
                world_dragging = 1.0
                drag_win_id = 0.0
                scroll_win_id = 0.0

                // Hit-testing en barra de título de cada ventana (y > 48.0)
                if (my > 48.0) {
                    s6_r = s6_x + w6_w - 32.0; s6_b = s6_y + 28.0
                    if (mx >= s6_x) { if (mx <= s6_r) { if (my >= s6_y) { if (my <= s6_b) {
                        drag_win_id = 6.0; drag_win_ox = mx - w6_x; drag_win_oy = my - w6_y
                    } } } }

                    if (drag_win_id == 0.0) {
                        s5_r = s5_x + w5_w - 32.0; s5_b = s5_y + 28.0
                        if (mx >= s5_x) { if (mx <= s5_r) { if (my >= s5_y) { if (my <= s5_b) {
                            drag_win_id = 5.0; drag_win_ox = mx - w5_x; drag_win_oy = my - w5_y
                        } } } }
                    }

                    if (drag_win_id == 0.0) {
                        s4_r = s4_x + w4_w - 32.0; s4_b = s4_y + 28.0
                        if (mx >= s4_x) { if (mx <= s4_r) { if (my >= s4_y) { if (my <= s4_b) {
                            drag_win_id = 4.0; drag_win_ox = mx - w4_x; drag_win_oy = my - w4_y
                        } } } }
                    }

                    if (drag_win_id == 0.0) {
                        s3_r = s3_x + w3_w - 32.0; s3_b = s3_y + 28.0
                        if (mx >= s3_x) { if (mx <= s3_r) { if (my >= s3_y) { if (my <= s3_b) {
                            drag_win_id = 3.0; drag_win_ox = mx - w3_x; drag_win_oy = my - w3_y
                        } } } }
                    }

                    if (drag_win_id == 0.0) {
                        s2_r = s2_x + w2_w - 32.0; s2_b = s2_y + 28.0
                        if (mx >= s2_x) { if (mx <= s2_r) { if (my >= s2_y) { if (my <= s2_b) {
                            drag_win_id = 2.0; drag_win_ox = mx - w2_x; drag_win_oy = my - w2_y
                        } } } }
                    }

                    if (drag_win_id == 0.0) {
                        s1_r = s1_x + w1_w - 32.0; s1_b = s1_y + 28.0
                        if (mx >= s1_x) { if (mx <= s1_r) { if (my >= s1_y) { if (my <= s1_b) {
                            drag_win_id = 1.0; drag_win_ox = mx - w1_x; drag_win_oy = my - w1_y
                        } } } }
                    }

                    // Si no fue en título, verificar si fue arrastre interior para scroll diagonal/horizontal
                    if (drag_win_id == 0.0) {
                        if (w2_min == 0.0) {
                            s2_br = s2_x + w2_w; s2_bb = s2_y + s2_h
                            if (mx >= s2_x) { if (mx <= s2_br) { if (my > s2_y + 28.0) { if (my <= s2_bb) {
                                scroll_win_id = 2.0
                            } } } }
                        }
                        if (scroll_win_id == 0.0) {
                            if (w1_min == 0.0) {
                                s1_br = s1_x + w1_w; s1_bb = s1_y + s1_h
                                if (mx >= s1_x) { if (mx <= s1_br) { if (my > s1_y + 28.0) { if (my <= s1_bb) {
                                    scroll_win_id = 1.0
                                } } } }
                            }
                        }
                    }
                }
            } else {
                // Arrastre continuo
                if (drag_win_id == 1.0) { w1_x = mx - drag_win_ox; w1_y = my - drag_win_oy }
                if (drag_win_id == 2.0) { w2_x = mx - drag_win_ox; w2_y = my - drag_win_oy }
                if (drag_win_id == 3.0) { w3_x = mx - drag_win_ox; w3_y = my - drag_win_oy }
                if (drag_win_id == 4.0) { w4_x = mx - drag_win_ox; w4_y = my - drag_win_oy }
                if (drag_win_id == 5.0) { w5_x = mx - drag_win_ox; w5_y = my - drag_win_oy }
                if (drag_win_id == 6.0) { w6_x = mx - drag_win_ox; w6_y = my - drag_win_oy }

                if (drag_win_id == 0.0) {
                    if (scroll_win_id == 2.0) {
                        w2_sc_x = w2_sc_x - dmx
                        w2_sc_y = w2_sc_y - dmy
                        if (w2_sc_x < 0.0) { w2_sc_x = 0.0 }
                        if (w2_sc_y < 0.0) { w2_sc_y = 0.0 }
                    } else {
                        if (scroll_win_id == 1.0) {
                            w1_sc_x = w1_sc_x - dmx
                            w1_sc_y = w1_sc_y - dmy
                            if (w1_sc_x < 0.0) { w1_sc_x = 0.0 }
                            if (w1_sc_y < 0.0) { w1_sc_y = 0.0 }
                        } else {
                            // Arrastre del lienzo de fondo: Mueve todo el mundo virtual en 360° (X, Y y diagonal)
                            world_cam_x = world_cam_x + dmx
                            world_cam_y = world_cam_y + dmy
                        }
                    }
                }
            }
        } else {
            world_dragging = 0.0
            drag_win_id = 0.0
            scroll_win_id = 0.0
        }

        // Rueda de ratón (Scroll vertical & diagonal)
        if (mw != 0.0) {
            s2_br = s2_x + w2_w; s2_bb = s2_y + s2_h
            if (mx >= s2_x) { if (mx <= s2_br) { if (my >= s2_y) { if (my <= s2_bb) {
                w2_sc_y = w2_sc_y + (mw * 0.4)
                if (w2_sc_y < 0.0) { w2_sc_y = 0.0 }
            } } } }
            s1_br = s1_x + w1_w; s1_bb = s1_y + s1_h
            if (mx >= s1_x) { if (mx <= s1_br) { if (my >= s1_y) { if (my <= s1_bb) {
                w1_sc_y = w1_sc_y + (mw * 0.4)
                if (w1_sc_y < 0.0) { w1_sc_y = 0.0 }
            } } } }
        }

        world_prev_mx = mx
        world_prev_my = my

        // --- 2. REJILLA VIRTUAL DEL MUNDO 360° (PANORAMA PLANAR EN PANTALLA VISIBLE) ---
        line(0.0, 52.0, vw, 52.0, 0x1F2A38)
        line(0.0, 53.0, vw, 53.0, 0x0E1722)
        grid_b1 = vh - 26.0
        grid_b2 = vh - 25.0
        line(0.0, grid_b1, vw, grid_b1, 0x1F2A38)
        line(0.0, grid_b2, vw, grid_b2, 0x0E1722)

        slat_x = (world_cam_x % 60.0) - 60.0
        while (slat_x < vw + 60.0) {
            line(slat_x, 54.0, slat_x, grid_b1, 0x161B22)
            slat_x = slat_x + 60.0
        }

        slat_y = 54.0 + (world_cam_y % 60.0) - 60.0
        while (slat_y < grid_b1 + 60.0) {
            if (slat_y >= 54.0) {
                if (slat_y <= grid_b1) {
                    line(0.0, slat_y, vw, slat_y, 0x161B22)
                }
            }
            slat_y = slat_y + 60.0
        }

        // --- 3. RENDERIZADO DE LAS 6 VENTANAS EN EL MUNDO VIRTUAL ---
        // Ventana 1: Explorador de Archivos
        if (s1_x + w1_w > -50.0) {
            if (s1_x < vw + 50.0) {
                rect(s1_x, s1_y, w1_w, s1_h, 0x090D13)
                rect(s1_x, s1_y, w1_w, 28.0, 0x161B22)
                bar1_r = s1_x + w1_w
                bar1_b = s1_y + 28.0
                line(s1_x, bar1_b, bar1_r, bar1_b, 0x30363D)
                txt1_x = s1_x + 12.0
                txt1_y = s1_y + 8.0
                text("<s>1: Explorador de Archivos", txt1_x, txt1_y, 10, 0x238636)
                win1_b = s1_y + s1_h
                line(s1_x, s1_y, bar1_r, s1_y, 0x30363D)
                line(s1_x, s1_y, s1_x, win1_b, 0x30363D)
                line(bar1_r, s1_y, bar1_r, win1_b, 0x30363D)
                line(s1_x, win1_b, bar1_r, win1_b, 0x30363D)

                btn1_x = s1_x + w1_w - 26.0
                btn1_y = s1_y + 4.0
                if (w1_min == 0.0) {
                    btn("-", btn1_x, btn1_y, 20.0, 20.0, act_toggle_min_w1, 0x21262D)
                    w1_body_y = s1_y + 28.0
                    w1_body_h = s1_h - 28.0
                    render_window_explorer(s1_x, w1_body_y, w1_w, w1_body_h, w1_sc_x, w1_sc_y)
                } else {
                    btn("+", btn1_x, btn1_y, 20.0, 20.0, act_toggle_min_w1, 0x238636)
                }
            }
        }

        // Ventana 2: Editor & Docs PhasorLang
        if (s2_x + w2_w > -50.0) {
            if (s2_x < vw + 50.0) {
                rect(s2_x, s2_y, w2_w, s2_h, 0x0D1117)
                rect(s2_x, s2_y, w2_w, 28.0, 0x161B22)
                bar2_r = s2_x + w2_w
                bar2_b = s2_y + 28.0
                line(s2_x, bar2_b, bar2_r, bar2_b, 0x30363D)
                txt2_x = s2_x + 12.0
                txt2_y = s2_y + 8.0
                text("<s>2: Editor & Docs PhasorLang", txt2_x, txt2_y, 10, 0x58A6FF)
                win2_b = s2_y + s2_h
                line(s2_x, s2_y, bar2_r, s2_y, 0x30363D)
                line(s2_x, s2_y, s2_x, win2_b, 0x30363D)
                line(bar2_r, s2_y, bar2_r, win2_b, 0x30363D)
                line(s2_x, win2_b, bar2_r, win2_b, 0x30363D)

                btn2_x = s2_x + w2_w - 26.0
                btn2_y = s2_y + 4.0
                if (w2_min == 0.0) {
                    btn("-", btn2_x, btn2_y, 20.0, 20.0, act_toggle_min_w2, 0x21262D)
                    w2_body_y = s2_y + 28.0
                    w2_body_h = s2_h - 28.0
                    render_window_editor(s2_x, w2_body_y, w2_w, w2_body_h, t_frame, w2_sc_x, w2_sc_y)
                } else {
                    btn("+", btn2_x, btn2_y, 20.0, 20.0, act_toggle_min_w2, 0x238636)
                }
            }
        }

        // Ventana 3: Live Preview & Canvas (120 FPS)
        if (s3_x + w3_w > -50.0) {
            if (s3_x < vw + 50.0) {
                rect(s3_x, s3_y, w3_w, s3_h, 0x070B12)
                rect(s3_x, s3_y, w3_w, 28.0, 0x161B22)
                bar3_r = s3_x + w3_w
                bar3_b = s3_y + 28.0
                line(s3_x, bar3_b, bar3_r, bar3_b, 0x30363D)
                txt3_x = s3_x + 12.0
                txt3_y = s3_y + 8.0
                text("<s>3: Live Preview & Canvas (120 FPS)", txt3_x, txt3_y, 10, 0x00E5FF)
                win3_b = s3_y + s3_h
                line(s3_x, s3_y, bar3_r, s3_y, 0x30363D)
                line(s3_x, s3_y, s3_x, win3_b, 0x30363D)
                line(bar3_r, s3_y, bar3_r, win3_b, 0x30363D)
                line(s3_x, win3_b, bar3_r, win3_b, 0x30363D)

                btn3_x = s3_x + w3_w - 26.0
                btn3_y = s3_y + 4.0
                if (w3_min == 0.0) {
                    btn("-", btn3_x, btn3_y, 20.0, 20.0, act_toggle_min_w3, 0x21262D)
                    w3_body_y = s3_y + 28.0
                    w3_body_h = s3_h - 28.0
                    render_window_stage(s3_x, w3_body_y, w3_w, w3_body_h, t_frame)
                } else {
                    btn("+", btn3_x, btn3_y, 20.0, 20.0, act_toggle_min_w3, 0x238636)
                }
            }
        }

        // Ventana 4: Depurador PVM & Memoria SoA
        if (s4_x + w4_w > -50.0) {
            if (s4_x < vw + 50.0) {
                rect(s4_x, s4_y, w4_w, s4_h, 0x0B0E14)
                rect(s4_x, s4_y, w4_w, 28.0, 0x161B22)
                bar4_r = s4_x + w4_w
                bar4_b = s4_y + 28.0
                line(s4_x, bar4_b, bar4_r, bar4_b, 0x30363D)
                txt4_x = s4_x + 12.0
                txt4_y = s4_y + 8.0
                text("<s>4: Depurador PVM & Memoria SoA", txt4_x, txt4_y, 10, 0xD29922)
                win4_b = s4_y + s4_h
                line(s4_x, s4_y, bar4_r, s4_y, 0x30363D)
                line(s4_x, s4_y, s4_x, win4_b, 0x30363D)
                line(bar4_r, s4_y, bar4_r, win4_b, 0x30363D)
                line(s4_x, win4_b, bar4_r, win4_b, 0x30363D)

                btn4_x = s4_x + w4_w - 26.0
                btn4_y = s4_y + 4.0
                if (w4_min == 0.0) {
                    btn("-", btn4_x, btn4_y, 20.0, 20.0, act_toggle_min_w4, 0x21262D)
                    w4_body_y = s4_y + 28.0
                    w4_body_h = s4_h - 28.0
                    render_window_debugger(s4_x, w4_body_y, w4_w, w4_body_h)
                } else {
                    btn("+", btn4_x, btn4_y, 20.0, 20.0, act_toggle_min_w4, 0x238636)
                }
            }
        }

        // Ventana 5: Terminal Interactiva PVM CLI
        if (s5_x + w5_w > -50.0) {
            if (s5_x < vw + 50.0) {
                rect(s5_x, s5_y, w5_w, s5_h, 0x080B10)
                rect(s5_x, s5_y, w5_w, 28.0, 0x161B22)
                bar5_r = s5_x + w5_w
                bar5_b = s5_y + 28.0
                line(s5_x, bar5_b, bar5_r, bar5_b, 0x30363D)
                txt5_x = s5_x + 12.0
                txt5_y = s5_y + 8.0
                text("<s>5: Terminal Interactiva PVM CLI", txt5_x, txt5_y, 10, 0x8957E5)
                win5_b = s5_y + s5_h
                line(s5_x, s5_y, bar5_r, s5_y, 0x30363D)
                line(s5_x, s5_y, s5_x, win5_b, 0x30363D)
                line(bar5_r, s5_y, bar5_r, win5_b, 0x30363D)
                line(s5_x, win5_b, bar5_r, win5_b, 0x30363D)

                btn5_x = s5_x + w5_w - 26.0
                btn5_y = s5_y + 4.0
                if (w5_min == 0.0) {
                    btn("-", btn5_x, btn5_y, 20.0, 20.0, act_toggle_min_w5, 0x21262D)
                    w5_body_y = s5_y + 28.0
                    w5_body_h = s5_h - 28.0
                    render_window_terminal(s5_x, w5_body_y, w5_w, w5_body_h)
                } else {
                    btn("+", btn5_x, btn5_y, 20.0, 20.0, act_toggle_min_w5, 0x238636)
                }
            }
        }

        // Ventana 6: Asistente IA KoraDevs Copilot
        if (s6_x + w6_w > -50.0) {
            if (s6_x < vw + 50.0) {
                rect(s6_x, s6_y, w6_w, s6_h, 0x111620)
                rect(s6_x, s6_y, w6_w, 28.0, 0x161B22)
                bar6_r = s6_x + w6_w
                bar6_b = s6_y + 28.0
                line(s6_x, bar6_b, bar6_r, bar6_b, 0x30363D)
                txt6_x = s6_x + 12.0
                txt6_y = s6_y + 8.0
                text("<s>6: Asistente IA KoraDevs Copilot", txt6_x, txt6_y, 10, 0xDB61A2)
                win6_b = s6_y + s6_h
                line(s6_x, s6_y, bar6_r, s6_y, 0x30363D)
                line(s6_x, s6_y, s6_x, win6_b, 0x30363D)
                line(bar6_r, s6_y, bar6_r, win6_b, 0x30363D)
                line(s6_x, win6_b, bar6_r, win6_b, 0x30363D)

                btn6_x = s6_x + w6_w - 26.0
                btn6_y = s6_y + 4.0
                if (w6_min == 0.0) {
                    btn("-", btn6_x, btn6_y, 20.0, 20.0, act_toggle_min_w6, 0x21262D)
                    w6_body_y = s6_y + 28.0
                    w6_body_h = s6_h - 28.0
                    render_window_ai(s6_x, w6_body_y, w6_w, w6_body_h, t_frame)
                } else {
                    btn("+", btn6_x, btn6_y, 20.0, 20.0, act_toggle_min_w6, 0x238636)
                }
            }
        }

        // --- 4. CURVATURA 3D AUTOMÁTICA FUERA DE LA PANTALLA VISIBLE ---
        // La pantalla visible [0..vw] es 100% plana; la curvatura hacia atrás ocurre automáticamente al salirse
        curv_h = vh - 72.0
        curv_y2 = vh - 24.0
        curv_y3 = vh - 28.0
        rect(0.0, 48.0, 20.0, curv_h, 0x070A0F)
        line(0.0, 48.0, 20.0, 52.0, 0x1F2A38)
        line(0.0, curv_y2, 20.0, curv_y3, 0x1F2A38)
        line(20.0, 48.0, 20.0, curv_y2, 0x161B22)

        curv_xr = vw - 20.0
        rect(curv_xr, 48.0, 20.0, curv_h, 0x070A0F)
        line(curv_xr, 52.0, vw, 48.0, 0x1F2A38)
        line(curv_xr, curv_y3, vw, curv_y2, 0x1F2A38)
        line(curv_xr, 48.0, curv_xr, curv_y2, 0x161B22)

    } else {
        // En Modo Móvil: Snap 100% "Llave en Cerradura"
        if (ide_panel_activo == 1.0) { render_window_editor(0.0, area_y, vw, area_h, t_frame, 0.0, 0.0) }
        if (ide_panel_activo == 2.0) { render_window_explorer(0.0, area_y, vw, area_h, 0.0, 0.0) }
        if (ide_panel_activo == 3.0) { render_window_stage(0.0, area_y, vw, area_h, t_frame) }
        if (ide_panel_activo == 4.0) { render_window_debugger(0.0, area_y, vw, area_h) }
        if (ide_panel_activo == 5.0) { render_window_terminal(0.0, area_y, vw, area_h) }
        if (ide_panel_activo == 6.0) { render_window_ai(0.0, area_y, vw, area_h, t_frame) }
    }

    // Barra de Estado Inferior Global
    bot_y = vh - 24.0
    rect(0.0, bot_y, vw, 24.0, 0x161B22)
    line(0.0, bot_y, vw, bot_y, 0x30363D)
    text("Estado: Listo | Ventanas Libres & Scroll 2D | Mundo 360° | Zero-GC 120 FPS", 12.0, bot_y + 7.0, 10, 0x8B949E)
    ia_txt_x = vw - 220.0
    if (ide_ia_status == 1.0) {
        text("IA: Gemini Cloud Pro (Online)", ia_txt_x, bot_y + 7.0, 10, 0x3FB950)
    } else {
        text("IA: Phasor-SLM (Local Offline)", ia_txt_x, bot_y + 7.0, 10, 0xBC8CFF)
    }

    render_security_modal(vw, vh)
    1.0
}
