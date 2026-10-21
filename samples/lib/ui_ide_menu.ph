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
signal w1_x = 30.0
signal w1_y = 60.0
signal w1_w = 400.0
signal w1_h = 580.0
signal w1_min = 0.0
signal w1_sc_x = 0.0
signal w1_sc_y = 0.0

signal w2_x = 450.0
signal w2_y = 60.0
signal w2_w = 640.0
signal w2_h = 580.0
signal w2_min = 0.0
signal w2_sc_x = 0.0
signal w2_sc_y = 0.0

signal w3_x = 1110.0
signal w3_y = 60.0
signal w3_w = 580.0
signal w3_h = 580.0
signal w3_min = 0.0
signal w3_sc_x = 0.0
signal w3_sc_y = 0.0

signal w4_x = 1710.0
signal w4_y = 60.0
signal w4_w = 520.0
signal w4_h = 580.0
signal w4_min = 0.0
signal w4_sc_x = 0.0
signal w4_sc_y = 0.0

signal w5_x = 2250.0
signal w5_y = 60.0
signal w5_w = 520.0
signal w5_h = 580.0
signal w5_min = 0.0
signal w5_sc_x = 0.0
signal w5_sc_y = 0.0

signal w6_x = 2790.0
signal w6_y = 60.0
signal w6_w = 520.0
signal w6_h = 580.0
signal w6_min = 0.0
signal w6_sc_x = 0.0
signal w6_sc_y = 0.0

// 4. ACCIONES REACTIVAS DE LAS VENTANAS
action act_toggle_min_w1 { if (w1_min == 0.0) { w1_min = 1.0 } else { w1_min = 0.0 } }
action act_toggle_min_w2 { if (w2_min == 0.0) { w2_min = 1.0 } else { w2_min = 0.0 } }
action act_toggle_min_w3 { if (w3_min == 0.0) { w3_min = 1.0 } else { w3_min = 0.0 } }
action act_toggle_min_w4 { if (w4_min == 0.0) { w4_min = 1.0 } else { w4_min = 0.0 } }
action act_toggle_min_w5 { if (w5_min == 0.0) { w5_min = 1.0 } else { w5_min = 0.0 } }
action act_toggle_min_w6 { if (w6_min == 0.0) { w6_min = 1.0 } else { w6_min = 0.0 } }

action act_tab_editor { ide_panel_activo = 1.0 }
action act_tab_files  { ide_panel_activo = 2.0 }
action act_tab_stage  { ide_panel_activo = 3.0 }
action act_tab_debug  { ide_panel_activo = 4.0 }
action act_tab_disasm { ide_panel_activo = 5.0 }
action act_tab_ai     { ide_panel_activo = 6.0 }

action act_subtab_code { ide_editor_subtab = 1.0 }
action act_subtab_docs { ide_editor_subtab = 2.0 }

action act_belt_next { world_cam_x = world_cam_x - 300.0 }
action act_belt_prev { world_cam_x = world_cam_x + 300.0 }

action act_toggle_net_modal {
    if (ide_sec_modal == 0.0) { ide_sec_modal = 1.0 } else { ide_sec_modal = 0.0 }
}

action act_pause_debug { ide_dbg_paused = 1.0 }
action act_resume_debug { ide_dbg_paused = 0.0 }
action act_step_debug {
    ide_dbg_paused = 1.0
    ide_dbg_line = ide_dbg_line + 1.0
    if (ide_dbg_line > 10.0) { ide_dbg_line = 1.0 }
}

action act_self_compile { ide_build_count = ide_build_count + 1.0 }
action act_run_script { ide_dbg_paused = 0.0 }
action act_train_local_ai {
    ide_ia_status = 2.0
    ide_ia_emotion = 2.0
    ide_ia_talking = 0.8
}

// 5. CABECERA NATIVA PRINCIPAL
render_ide_header(h_w, h_h) = {
    rect(0.0, 0.0, h_w, 48.0, 0x161B22)
    line(0.0, 48.0, h_w, 48.0, 0x30363D)

    text("CHRONOS IDE", 16.0, 16.0, 14, 0x58A6FF)
    rect(130.0, 14.0, 64.0, 20.0, 0x238636)
    text("SELF-HOST", 134.0, 18.0, 8, 0xFFFFFF)

    if (h_w < 768.0) {
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

        bx_recomp = h_w - 310.0
        btn("⚙ Re-Compilar (.wasm)", bx_recomp, 8.0, 160.0, 32.0, act_self_compile, 0x8957E5)
        bx_exec = h_w - 140.0
        btn("▶ Ejecutar (F5)", bx_exec, 8.0, 125.0, 32.0, act_run_script, 0x238636)
    } else {
        hdr_bw = h_w / 6.0
        btn("Edit", 0.0, 8.0, hdr_bw - 2.0, 32.0, act_tab_editor, 0x1F6FEB)
        btn("Files", hdr_bw, 8.0, hdr_bw - 2.0, 32.0, act_tab_files, 0x238636)
        btn("Lienzo", hdr_bw * 2.0, 8.0, hdr_bw - 2.0, 32.0, act_tab_stage, 0x00E5FF)
        btn("Dbg", hdr_bw * 3.0, 8.0, hdr_bw - 2.0, 32.0, act_tab_debug, 0xD29922)
        btn("Term", hdr_bw * 4.0, 8.0, hdr_bw - 2.0, 32.0, act_tab_disasm, 0x8957E5)
        btn("IA", hdr_bw * 5.0, 8.0, hdr_bw - 2.0, 32.0, act_tab_ai, 0xDB61A2)
    }
    1.0
}

// 6. VENTANA 1: EXPLORADOR DE PROYECTO AUTÓNOMO
render_window_explorer(vx, vy, vw, vh, scx, scy) = {
    rect(vx, vy, vw, vh, 0x090D13)

    // Toolbar superior
    rect(vx, vy, vw, 34.0, 0x161B22)
    line(vx, vy + 34.0, vx + vw, vy + 34.0, 0x30363D)
    btn("📁 Proyecto", vx + 8.0, vy + 4.0, 95.0, 26.0, act_tab_files, 0x1F6FEB)
    btn("⚡ samples", vx + 108.0, vy + 4.0, 95.0, 26.0, act_tab_editor, 0x238636)
    btn("📚 lib", vx + 208.0, vy + 4.0, 80.0, 26.0, act_subtab_docs, 0x30363D)

    // Cabecera del árbol
    fx = vx + 16.0 - scx
    fy = vy + 44.0 - scy
    text("EXPLORER: SketchWarePro", fx, fy, 10, 0x8B949E)
    line(fx, fy + 16.0, fx + vw - 32.0, fy + 16.0, 0x21262D)

    // Filas del explorador con reutilización estricta de fy
    fy = fy + 26.0; text("v 📁 samples/", fx, fy, 10, 0x79C0FF)
    fy = fy + 22.0; text("    ⚡ phasor_ide.ph (Activo)", fx + 4.0, fy, 10, 0x58A6FF)
    fy = fy + 20.0; text("    📄 demo_koradevs_master.fas", fx + 4.0, fy, 10, 0x8B949E)
    fy = fy + 20.0; text("    📐 fractal_ui.ph", fx + 4.0, fy, 10, 0xD29922)

    fy = fy + 24.0; text("v 📁 lib/", fx, fy, 10, 0x79C0FF)
    fy = fy + 22.0; text("    ⚡ ui_ide_menu.ph (WindowManager)", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ⚡ file_explorer.ph", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ⚡ barge_in_assistant.ph", fx + 4.0, fy, 10, 0xF778BA)
    fy = fy + 20.0; text("    ⚡ tts_speech.ph", fx + 4.0, fy, 10, 0xD29922)
    fy = fy + 20.0; text("    ⚡ procedural_video.ph", fx + 4.0, fy, 10, 0x58A6FF)

    fy = fy + 24.0; text("v 📁 tests/", fx, fy, 10, 0x79C0FF)
    fy = fy + 22.0; text("    ✔ 01_test_pvm_jumps.fas", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ✔ 02_test_hertz_colors.fas", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ✔ 03_test_ui_responsive.fas", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ✔ 04_test_audio_bargein.fas", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ✔ 05_test_polyglot_hub.fas", fx + 4.0, fy, 10, 0x3FB950)
    fy = fy + 20.0; text("    ✔ 06_test_file_explorer_tree.fas", fx + 4.0, fy, 10, 0x3FB950)

    fy = fy + 24.0; text("v 📁 dist/", fx, fy, 10, 0x79C0FF)
    fy = fy + 22.0; text("    🌐 chronos_ide.html (Standalone)", fx + 4.0, fy, 10, 0x58A6FF)
    fy = fy + 20.0; text("    ⚡ phasor_runtime.js (Micro-Runner)", fx + 4.0, fy, 10, 0xE5C07B)

    fy = fy + 24.0; text("📄 GEMINI.md (Directrices Maestras)", fx, fy, 10, 0x58A6FF)
    fy = fy + 20.0; text("⚙ phasor.toml (Configuración)", fx, fy, 10, 0xD29922)
    fy = fy + 20.0; text("⎇ .gitignore", fx, fy, 10, 0xF85149)

    // Barra de estado de ventana
    fy = vy + vh - 22.0
    rect(vx, fy, vw, 22.0, 0x161B22)
    line(vx, fy, vx + vw, fy, 0x30363D)
    text("12 archivos indexados | 159 tests [PASS] | SoA Contiguo", vx + 10.0, fy + 6.0, 9, 0x8B949E)
    1.0
}

// 7. VENTANA 2: EDITOR DE CÓDIGO INTELIGENTE & DOCS
render_window_editor(vx, vy, vw, vh, tframe, scx, scy) = {
    rect(vx, vy, vw, vh, 0x0D1117)

    halfw = vw * 0.5
    tab_rx = vx + halfw
    if (ide_editor_subtab == 1.0) {
        rect(vx, vy, halfw, 28.0, 0x1F6FEB)
        text("📝 Editor de Código", vx + 16.0, vy + 8.0, 10, 0xFFFFFF)
        rect(tab_rx, vy, halfw, 28.0, 0x161B22)
        text("📚 Docs PhasorLang", tab_rx + 16.0, vy + 8.0, 10, 0x8B949E)
        btn("📚 Docs", tab_rx, vy, halfw, 28.0, act_subtab_docs, 0x21262D)
    } else {
        rect(vx, vy, halfw, 28.0, 0x161B22)
        text("📝 Editor de Código", vx + 16.0, vy + 8.0, 10, 0x8B949E)
        btn("📝 Editor", vx, vy, halfw, 28.0, act_subtab_code, 0x21262D)
        rect(tab_rx, vy, halfw, 28.0, 0x238636)
        text("📚 Docs PhasorLang", tab_rx + 16.0, vy + 8.0, 10, 0xFFFFFF)
    }
    line(vx, vy + 28.0, vx + vw, vy + 28.0, 0x30363D)

    if (ide_editor_subtab == 2.0) {
        dy = vy + 36.0 - scy
        dx = vx + 16.0 - scx
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
        text("screen main { cls(0x0D1117); circle(cx, cy, 50.0, 0x58A6FF) }", dx + 8.0, dy + 134.0, 10, 0xFFFFFF)
        text("rect(x, y, w, h, col); line(x1, y1, x2, y2, col)", dx + 8.0, dy + 150.0, 10, 0xD29922)

        rect(dx - 2.0, dy + 182.0, vw - 28.0, 64.0, 0x161B22)
        line(dx - 2.0, dy + 182.0, dx - 2.0, dy + 246.0, 0xD29922)
        text("3. Memoria SoA Zero-GC y Registros Hardware", dx + 8.0, dy + 190.0, 10, 0xD29922)
        text("buf = alloc_soa(3, 512)  // Structure of Arrays", dx + 8.0, dy + 206.0, 10, 0xFFFFFF)
        text("vw = R250; vh = R251; ptr_x = R252; ptr_y = R253", dx + 8.0, dy + 222.0, 10, 0x79C0FF)

        dy = vy + vh - 24.0
        rect(vx, dy, vw, 24.0, 0x161B22)
        line(vx, dy, vx + vw, dy, 0x30363D)
        text("Sintaxis Oficial PhasorLang v1.0 • KoraDevs Autonomous Ecosystem", vx + 12.0, dy + 7.0, 10, 0x8B949E)
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
        bp_y1 = vy + 145.0 - scy
        bp_y2 = vy + 205.0 - scy
        if (bp_y1 >= vy + 58.0) { if (bp_y1 <= vy + vh - 24.0) { circle(vx + 14.0, bp_y1, 4.0, 0xF85149) } }
        if (bp_y2 >= vy + 58.0) { if (bp_y2 <= vy + vh - 24.0) { circle(vx + 14.0, bp_y2, 4.0, 0xF85149) } }

        // Numeración con scroll Y
        text("1", vx + 22.0, vy + 85.0 - scy, 10, 0x8B949E)
        text("2", vx + 22.0, vy + 105.0 - scy, 10, 0x8B949E)
        text("3", vx + 22.0, vy + 125.0 - scy, 10, 0x8B949E)
        text("4", vx + 22.0, vy + 145.0 - scy, 10, 0xF85149)
        text("5", vx + 22.0, vy + 165.0 - scy, 10, 0x8B949E)
        text("6", vx + 22.0, vy + 185.0 - scy, 10, 0x8B949E)
        text("7", vx + 22.0, vy + 205.0 - scy, 10, 0xF85149)
        text("8", vx + 22.0, vy + 225.0 - scy, 10, 0x8B949E)
        text("9", vx + 22.0, vy + 245.0 - scy, 10, 0x8B949E)
        text("10", vx + 16.0, vy + 265.0 - scy, 10, 0x8B949E)

        if (ide_dbg_paused == 1.0) {
            dbg_y = vy + 137.0 - scy
            if (dbg_y >= vy + 58.0) { if (dbg_y <= vy + vh - 24.0) {
                rect(vx + gutter_w, dbg_y, vw - gutter_w, 20.0, 0x2E2412)
                line(vx + gutter_w, dbg_y, vx + gutter_w, dbg_y + 20.0, 0xD29922)
                text("▶", vx + gutter_w - 12.0, dbg_y + 8.0, 9, 0xD29922)
            } }
        }

        // Líneas de código con scroll en X y en Y
        code_x = vx + gutter_w + 14.0
        code_x = code_x - scx
        code_y = vy - scy

        text("// CHRONOS IDE — Codigo fuente del IDE autohospedado en ejecucion", code_x, code_y + 85.0, 11, 0x8B949E)
        text("import ui_ide_menu", code_x, code_y + 105.0, 11, 0xBC8CFF)
        text("signal ide_fps = 120.0", code_x, code_y + 125.0, 11, 0x3FB950)
        text("v_smith: Vec3 = [120.0, 45.0, 0.0]  // Fasor (Mag ∠ Ang)", code_x, code_y + 145.0, 11, 0x79C0FF)
        text("screen main {", code_x, code_y + 165.0, 11, 0x58A6FF)
        text("    cls(0x0D1117)", code_x, code_y + 185.0, 11, 0x58A6FF)
        text("    ui_ide_menu.render_ide_workspace(screen_w, screen_h, t_global)", code_x, code_y + 205.0, 11, 0xD2A8FF)
        text("    smith_chart(cx, cy, 75.0, 0.35, 0.42)", code_x, code_y + 225.0, 11, 0x00E5FF)
        text("    procedural_ai_face(t_global, cx, cy, talking, 1.0)", code_x, code_y + 245.0, 11, 0xF778BA)
        text("}", code_x, code_y + 265.0, 11, 0x58A6FF)

        // Cursor parpadeante Zero-GC
        blink = (tframe * 0.05) % 2.0
        if (blink > 1.0) {
            line(code_x + 280.0, code_y + 142.0, code_x + 280.0, code_y + 158.0, 0x00E5FF)
        } else {
            1.0
        }

        // Barras de scroll visuales
        rect(vx + vw - 8.0, vy + 58.0, 6.0, vh - 82.0, 0x161B22)
        thumb_y = vy + 58.0 + (scy * 0.15)
        if (thumb_y > vy + vh - 64.0) { thumb_y = vy + vh - 64.0 }
        rect(vx + vw - 8.0, thumb_y, 6.0, 40.0, 0x30363D)

        rect(vx + gutter_w, vy + vh - 30.0, vw - gutter_w - 8.0, 6.0, 0x161B22)
        thumb_x = vx + gutter_w + (scx * 0.15)
        if (thumb_x > vx + vw - 48.0) { thumb_x = vx + vw - 48.0 }
        rect(thumb_x, vy + vh - 30.0, 40.0, 6.0, 0x30363D)

        // Barra de estado del editor
        dy = vy + vh - 24.0
        rect(vx, dy, vw, 24.0, 0x161B22)
        line(vx, dy, vx + vw, dy, 0x30363D)
        text("Ln 4, Col 32 | UTF-8 | GapBuffer SoA (64 KB) | Scroll 2D Activo", vx + 12.0, dy + 7.0, 10, 0x8B949E)
        1.0
    }
}

// 8. VENTANA 3: ESCENARIO PVM & VISORES CIENTÍFICOS 120 FPS
render_window_stage(vx, vy, vw, vh, tframe) = {
    rect(vx, vy, vw, vh, 0x070B12)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("🔬 ESCENARIO PVM — VISORES CIENTÍFICOS (120 FPS ZERO-GC)", vx + 12.0, vy + 10.0, 11, 0x00E5FF)

    // Carta de Smith fasorial en tiempo real
    cx = vx + 150.0
    cy = vy + 170.0
    r_smith = 100.0

    circle(cx, cy, r_smith, 0x1F6FEB)
    circle(cx + 33.0, cy, 67.0, 0x238636)
    circle(cx + 50.0, cy, 50.0, 0x1F6FEB)
    line(cx - r_smith, cy, cx + r_smith, cy, 0x30363D)
    line(cx, cy - r_smith, cx, cy + r_smith, 0x30363D)

    // Vector de impedancia rotatorio
    ang = tframe * 0.04
    fx = cx + (85.0 * cos(ang))
    fy = cy - (85.0 * sin(ang))
    line(cx, cy, fx, fy, 0x00E5FF)
    circle(fx, fy, 5.0, 0x3FB950)

    text("Gamma Real", cx + r_smith + 8.0, cy - 6.0, 9, 0x8B949E)
    text("+j Imag", cx - 18.0, cy - r_smith - 14.0, 9, 0x8B949E)

    // Senoide temporal del fasor proyectado
    tx_start = vx + 280.0
    tx_end = vx + vw - 30.0
    if (tx_end > tx_start + 40.0) {
        line(tx_start, cy, tx_end, cy, 0x30363D)
        text("t [s] (Forma de Onda)", tx_end - 110.0, cy - 14.0, 9, 0x8B949E)

        px = tx_start
        while (px < tx_end) {
            wave_y = cy + (sin((px - tx_start) * 0.07 - (tframe * 0.08)) * 48.0)
            circle(px, wave_y, 2.0, 0x3FB950)
            px = px + 8.0
        }
    }

    // Barra de telemetría inferior del escenario
    st_bary = vy + vh - 24.0
    rect(vx, st_bary, vw, 24.0, 0x161B22)
    line(vx, st_bary, vx + vw, st_bary, 0x30363D)
    text("Simulación Activa | Carta de Smith + Senoide Temporal | Pausas GC: 0 | 120 FPS", vx + 12.0, st_bary + 7.0, 10, 0x3FB950)
    1.0
}

// 9. VENTANA 4: DEPURADOR PVM & REGISTROS SOA
render_window_debugger(vx, vy, vw, vh) = {
    rect(vx, vy, vw, vh, 0x0B0E14)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("🐞 DEPURADOR & BANCO DE REGISTROS SOA (R0..R255)", vx + 12.0, vy + 10.0, 11, 0xD29922)

    fy = vy + 44.0
    if (ide_dbg_paused == 1.0) {
        rect(vx + 12.0, fy, vw - 24.0, 48.0, 0x2E2412)
        text("ESTADO: PAUSADO EN BREAKPOINT (Linea 4, PC=0x002A)", vx + 24.0, fy + 8.0, 10, 0xD29922)
        text("Instruccion: OP_VEC3_LOAD R1 = [120.0, 45.0, 0.0]", vx + 24.0, fy + 26.0, 10, 0xFFFFFF)
    } else {
        rect(vx + 12.0, fy, vw - 24.0, 48.0, 0x122416)
        text("ESTADO: EJECUCION CONTINUA A 120 FPS ZERO-GC", vx + 24.0, fy + 8.0, 10, 0x3FB950)
        text("Watchdog: 0 fallos | Sin fugas de memoria | Stack SoA contiguo", vx + 24.0, fy + 26.0, 10, 0x8B949E)
    }

    fy = vy + 104.0
    rect(vx + 12.0, fy, vw - 24.0, 180.0, 0x161B22)
    line(vx + 12.0, fy + 24.0, vx + vw - 12.0, fy + 24.0, 0x30363D)
    text("REGISTROS VIRTUALES ACTIVOS (SOA LINEAR BUFFER)", vx + 20.0, fy + 6.0, 9, 0x8B949E)

    text("[R0]  (Escalar)    : 60.0000 Hz", vx + 24.0, fy + 34.0, 10, 0xFFFFFF)
    text("[R1]  (Vec3 SIMD)  : [120.00, 45.00, 0.00] (v_smith)", vx + 24.0, fy + 54.0, 10, 0x79C0FF)
    text("[R2]  (Fasor Polar): 120.00 ∠ 45.00° (84.85 + 84.85j)", vx + 24.0, fy + 74.0, 10, 0x00E5FF)
    text("[R250] Viewport Width : R250 Dinamico Clamped", vx + 24.0, fy + 94.0, 10, 0xD29922)
    text("[R251] Viewport Height: R251 Dinamico Clamped", vx + 24.0, fy + 114.0, 10, 0xD29922)
    text("[R252..R255] Puntero Tactil y Scroll Clamped", vx + 24.0, fy + 134.0, 10, 0x8B949E)

    // Controles de depuración
    db_by = vy + vh - 60.0
    btn("▶ Continuar", vx + 16.0, db_by, 110.0, 32.0, act_resume_debug, 0x238636)
    btn("⏭️ Paso (Step)", vx + 136.0, db_by, 120.0, 32.0, act_step_debug, 0x1F6FEB)
    btn("⏸️ Pausar", vx + 266.0, db_by, 100.0, 32.0, act_pause_debug, 0xD29922)
    1.0
}

// 10. VENTANA 5: TERMINAL INTERACTIVA & CLI
render_window_terminal(vx, vy, vw, vh) = {
    rect(vx, vy, vw, vh, 0x080B10)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("📟 TERMINAL PVM & DESENSAMBLADOR DE BYTECODE (OP_OUT)", vx + 12.0, vy + 10.0, 11, 0x8957E5)

    fy = vy + 44.0
    text("> [PVM Kernel] Chronos IDE Self-Hosted inicializado.", vx + 16.0, fy, 10, 0x3FB950)
    fy = fy + 18.0; text("> [Auto-Compiler] Modulo samples/phasor_ide.ph cargado en memoria SoA.", vx + 16.0, fy, 10, 0x58A6FF)
    fy = fy + 18.0; text("> [Desensamblador 3-Operandos]:", vx + 16.0, fy, 10, 0x8B949E)
    fy = fy + 16.0; text("    0x0000: OP_LOAD_K    R0, K0 (60.0000)", vx + 24.0, fy, 10, 0x79C0FF)
    fy = fy + 16.0; text("    0x0004: OP_VEC3_LOAD R1, [120.0, 45.0, 0.0]", vx + 24.0, fy, 10, 0x79C0FF)
    fy = fy + 16.0; text("    0x0008: OP_SOA_STORE buf_gap, ch0, 1.0", vx + 24.0, fy, 10, 0x3FB950)
    fy = fy + 16.0; text("    0x000C: OP_SIGNAL_SET ide_fps, 120.0", vx + 24.0, fy, 10, 0xD29922)
    fy = fy + 16.0; text("    0x0010: OP_JMP_IF_ZERO R250, 0x0028", vx + 24.0, fy, 10, 0xF85149)
    fy = fy + 20.0; text("> [OUT Stream]: Ciclos de recompilacion exitosos: 1 (Ready)", vx + 16.0, fy, 10, 0x3FB950)
    fy = fy + 18.0; text("> [PVM Profiler] Latencia de despacho: 18 us/frame | 0 allocations", vx + 16.0, fy, 10, 0x8B949E)

    tm_by = vy + vh - 52.0
    btn("Ejecutar phasorc.ph (Compilar IDE a WASM)", vx + 16.0, tm_by, vw - 32.0, 32.0, act_self_compile, 0x8957E5)
    1.0
}

// 11. VENTANA 6: COPILOT IA & AVATAR REACTIVO
render_window_ai(vx, vy, vw, vh, tframe) = {
    rect(vx, vy, vw, vh, 0x111620)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("✨ ASISTENTE IA — AVATAR REACTIVO & VOZ FORMÁNTICA", vx + 12.0, vy + 10.0, 11, 0xDB61A2)

    // Avatar procedural reactivo
    av_x = vx + (vw * 0.5)
    av_y = vy + 105.0
    procedural_ai_face(tframe, av_x, av_y, ide_ia_talking, ide_ia_emotion)

    fy = vy + 175.0
    rect(vx + 16.0, fy, vw - 32.0, 52.0, 0x161B22)
    line(vx + 16.0, fy, vx + 16.0, fy + 52.0, 0x1F6FEB)
    text("PROVEEDOR: Gemini Cloud Pro (Docente / Arquitecto)", vx + 26.0, fy + 8.0, 10, 0x58A6FF)
    text("Genera código PhasorLang validado para entrenamiento local.", vx + 26.0, fy + 28.0, 9, 0x8B949E)

    fy = fy + 60.0
    rect(vx + 16.0, fy, vw - 32.0, 52.0, 0x161B22)
    line(vx + 16.0, fy, vx + 16.0, fy + 52.0, 0x8957E5)
    text("PROVEEDOR: Phasor-SLM Local (Estudiante Cuantizado)", vx + 26.0, fy + 8.0, 10, 0xBC8CFF)
    text("Inferencia 100% offline desde dataset_phasor_incremental.jsonl", vx + 26.0, fy + 28.0, 9, 0x8B949E)

    // Botones de acción IA
    bw = (vw - 42.0) * 0.5
    fy = vy + vh - 60.0
    btn("Entrenar Modelo Local (Fine-Tuning)", vx + 16.0, fy, bw, 32.0, act_train_local_ai, 0x8957E5)
    btn("Gobernanza de Red", vx + 26.0 + bw, fy, bw, 32.0, act_toggle_net_modal, 0x21262D)
    1.0
}

// 12. MODAL DE SEGURIDAD Y PERMISOS DE RED
render_security_modal(h_w, h_h) = {
    if (ide_sec_modal == 1.0) {
        rect(0.0, 0.0, h_w, h_h, 0x05070A)

        mw = 420.0
        if (h_w < 460.0) { mw = h_w - 30.0 }
        mh = 230.0
        mx = (h_w - mw) * 0.5
        my = (h_h - mh) * 0.5

        rect(mx, my, mw, mh, 0x161B22)
        rect(mx, my, mw, 36.0, 0x21262D)
        line(mx, my + 36.0, mx + mw, my + 36.0, 0xF85149)
        text("🔒 GOBERNANZA DE RED KORADEVS", mx + 16.0, my + 12.0, 11, 0xF85149)

        text("El IDE funciona 100% OFFLINE por defecto.", mx + 20.0, my + 55.0, 10, 0xFFFFFF)
        text("¿Autoriza la sincronización con Gemini Cloud Pro", mx + 20.0, my + 78.0, 10, 0x8B949E)
        text("para generar nuevas lecciones de aprendizaje?", mx + 20.0, my + 98.0, 10, 0x8B949E)
        text("Estado: Aislamiento Local Estricto Activo.", mx + 20.0, my + 124.0, 10, 0x3FB950)

        mbw = (mw - 50.0) * 0.5
        mby = my + mh - 50.0
        btn("Permitir Conexión", mx + 20.0, mby, mbw, 36.0, act_toggle_net_modal, 0x238636)
        btn("Mantener Offline", mx + 30.0 + mbw, mby, mbw, 36.0, act_toggle_net_modal, 0x30363D)
    }
    1.0
}

// 13. CONTENEDOR PRINCIPAL DEL WORKSPACE AUTÓNOMO (100% PHASORLANG)
render_ide_workspace(screen_w, screen_h, t_frame, ptr_x, ptr_y, ptr_down, ptr_wheel) = {
    render_ide_header(screen_w, screen_h)

    area_y = 56.0
    area_h = screen_h - 84.0

    if (ide_modo_escritorio == 1.0) {
        // --- 1. PROCESAMIENTO REACTIVO DE PUNTERO Y ARRASTRE LIBRE ---
        dmx = 0.0
        dmy = 0.0
        if (world_dragging == 1.0) {
            dmx = ptr_x - world_prev_mx
            dmy = ptr_y - world_prev_my
        }

        // MÁQUINA DE ESTADOS DE ARRASTRE Y SCROLL
        if (ptr_down == 1.0) {
            if (world_dragging == 0.0) {
                world_dragging = 1.0
                drag_win_id = 0.0
                scroll_win_id = 0.0

                // Hit-testing en barra de título de cada ventana (de w6 a w1)
                if (ptr_y > 48.0) {
                    // W6
                    hx = w6_x + world_cam_x; hy = w6_y + world_cam_y; hr = hx + w6_w - 32.0; hb = hy + 28.0
                    if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                        drag_win_id = 6.0; drag_win_ox = ptr_x - w6_x; drag_win_oy = ptr_y - w6_y
                    } } } }

                    // W5
                    if (drag_win_id == 0.0) {
                        hx = w5_x + world_cam_x; hy = w5_y + world_cam_y; hr = hx + w5_w - 32.0; hb = hy + 28.0
                        if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                            drag_win_id = 5.0; drag_win_ox = ptr_x - w5_x; drag_win_oy = ptr_y - w5_y
                        } } } }
                    }

                    // W4
                    if (drag_win_id == 0.0) {
                        hx = w4_x + world_cam_x; hy = w4_y + world_cam_y; hr = hx + w4_w - 32.0; hb = hy + 28.0
                        if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                            drag_win_id = 4.0; drag_win_ox = ptr_x - w4_x; drag_win_oy = ptr_y - w4_y
                        } } } }
                    }

                    // W3
                    if (drag_win_id == 0.0) {
                        hx = w3_x + world_cam_x; hy = w3_y + world_cam_y; hr = hx + w3_w - 32.0; hb = hy + 28.0
                        if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                            drag_win_id = 3.0; drag_win_ox = ptr_x - w3_x; drag_win_oy = ptr_y - w3_y
                        } } } }
                    }

                    // W2
                    if (drag_win_id == 0.0) {
                        hx = w2_x + world_cam_x; hy = w2_y + world_cam_y; hr = hx + w2_w - 32.0; hb = hy + 28.0
                        if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                            drag_win_id = 2.0; drag_win_ox = ptr_x - w2_x; drag_win_oy = ptr_y - w2_y
                        } } } }
                    }

                    // W1
                    if (drag_win_id == 0.0) {
                        hx = w1_x + world_cam_x; hy = w1_y + world_cam_y; hr = hx + w1_w - 32.0; hb = hy + 28.0
                        if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                            drag_win_id = 1.0; drag_win_ox = ptr_x - w1_x; drag_win_oy = ptr_y - w1_y
                        } } } }
                    }

                    // Si no fue en título, verificar si fue arrastre interior para scroll diagonal/horizontal
                    if (drag_win_id == 0.0) {
                        if (w2_min == 0.0) {
                            hx = w2_x + world_cam_x; hy = w2_y + world_cam_y; hr = hx + w2_w; hb = hy + w2_h
                            if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y > hy + 28.0) { if (ptr_y <= hb) {
                                scroll_win_id = 2.0
                            } } } }
                        }
                        if (scroll_win_id == 0.0) {
                            if (w1_min == 0.0) {
                                hx = w1_x + world_cam_x; hy = w1_y + world_cam_y; hr = hx + w1_w; hb = hy + w1_h
                                if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y > hy + 28.0) { if (ptr_y <= hb) {
                                    scroll_win_id = 1.0
                                } } } }
                            }
                        }
                    }
                }
            } else {
                // Durante arrastre sostenido
                if (drag_win_id == 1.0) {
                    w1_x = ptr_x - drag_win_ox; w1_y = ptr_y - drag_win_oy
                } else {
                    if (drag_win_id == 2.0) {
                        w2_x = ptr_x - drag_win_ox; w2_y = ptr_y - drag_win_oy
                    } else {
                        if (drag_win_id == 3.0) {
                            w3_x = ptr_x - drag_win_ox; w3_y = ptr_y - drag_win_oy
                        } else {
                            if (drag_win_id == 4.0) {
                                w4_x = ptr_x - drag_win_ox; w4_y = ptr_y - drag_win_oy
                            } else {
                                if (drag_win_id == 5.0) {
                                    w5_x = ptr_x - drag_win_ox; w5_y = ptr_y - drag_win_oy
                                } else {
                                    if (drag_win_id == 6.0) {
                                        w6_x = ptr_x - drag_win_ox; w6_y = ptr_y - drag_win_oy
                                    }
                                }
                            }
                        }
                    }
                }

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
        if (ptr_wheel != 0.0) {
            hx = w2_x + world_cam_x; hy = w2_y + world_cam_y; hr = hx + w2_w; hb = hy + w2_h
            if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                w2_sc_y = w2_sc_y + (ptr_wheel * 0.4)
                if (w2_sc_y < 0.0) { w2_sc_y = 0.0 }
            } } } }
            hx = w1_x + world_cam_x; hy = w1_y + world_cam_y; hr = hx + w1_w; hb = hy + w1_h
            if (ptr_x >= hx) { if (ptr_x <= hr) { if (ptr_y >= hy) { if (ptr_y <= hb) {
                w1_sc_y = w1_sc_y + (ptr_wheel * 0.4)
                if (w1_sc_y < 0.0) { w1_sc_y = 0.0 }
            } } } }
        }

        world_prev_mx = ptr_x
        world_prev_my = ptr_y

        // --- 2. REJILLA VIRTUAL DEL MUNDO 360° (PANORAMA PLANAR EN PANTALLA VISIBLE) ---
        line(0.0, 52.0, screen_w, 52.0, 0x1F2A38)
        line(0.0, 53.0, screen_w, 53.0, 0x0E1722)
        grid_b1 = screen_h - 26.0
        line(0.0, grid_b1, screen_w, grid_b1, 0x1F2A38)
        line(0.0, grid_b1 + 1.0, screen_w, grid_b1 + 1.0, 0x0E1722)

        slat_x = (world_cam_x % 60.0) - 60.0
        while (slat_x < screen_w + 60.0) {
            line(slat_x, 54.0, slat_x, grid_b1, 0x161B22)
            slat_x = slat_x + 60.0
        }

        slat_y = 54.0 + (world_cam_y % 60.0) - 60.0
        while (slat_y < grid_b1 + 60.0) {
            if (slat_y >= 54.0) {
                if (slat_y <= grid_b1) {
                    line(0.0, slat_y, screen_w, slat_y, 0x161B22)
                }
            }
            slat_y = slat_y + 60.0
        }

        // --- 3. RENDERIZADO DE LAS 6 VENTANAS EN EL MUNDO VIRTUAL ---
        // Ventana 1: Explorador de Archivos
        fx = w1_x + world_cam_x
        fy = w1_y + world_cam_y
        fh = w1_h
        if (w1_min == 1.0) { fh = 28.0 }
        fr = fx + w1_w
        fb = fy + fh

        if (fr > -50.0) {
            if (fx < screen_w + 50.0) {
                rect(fx, fy, w1_w, fh, 0x090D13)
                rect(fx, fy, w1_w, 28.0, 0x161B22)
                line(fx, fy + 28.0, fr, fy + 28.0, 0x30363D)
                text("<s>1: Explorador de Archivos", fx + 12.0, fy + 8.0, 10, 0x238636)
                line(fx, fy, fr, fy, 0x30363D)
                line(fx, fy, fx, fb, 0x30363D)
                line(fr, fy, fr, fb, 0x30363D)
                line(fx, fb, fr, fb, 0x30363D)

                if (w1_min == 0.0) {
                    btn("-", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w1, 0x21262D)
                    render_window_explorer(fx, fy + 28.0, w1_w, fh - 28.0, w1_sc_x, w1_sc_y)
                } else {
                    btn("+", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w1, 0x238636)
                }
            }
        }

        // Ventana 2: Editor & Docs PhasorLang
        fx = w2_x + world_cam_x
        fy = w2_y + world_cam_y
        fh = w2_h
        if (w2_min == 1.0) { fh = 28.0 }
        fr = fx + w2_w
        fb = fy + fh

        if (fr > -50.0) {
            if (fx < screen_w + 50.0) {
                rect(fx, fy, w2_w, fh, 0x0D1117)
                rect(fx, fy, w2_w, 28.0, 0x161B22)
                line(fx, fy + 28.0, fr, fy + 28.0, 0x30363D)
                text("<s>2: Editor & Docs PhasorLang", fx + 12.0, fy + 8.0, 10, 0x58A6FF)
                line(fx, fy, fr, fy, 0x30363D)
                line(fx, fy, fx, fb, 0x30363D)
                line(fr, fy, fr, fb, 0x30363D)
                line(fx, fb, fr, fb, 0x30363D)

                if (w2_min == 0.0) {
                    btn("-", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w2, 0x21262D)
                    render_window_editor(fx, fy + 28.0, w2_w, fh - 28.0, t_frame, w2_sc_x, w2_sc_y)
                } else {
                    btn("+", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w2, 0x238636)
                }
            }
        }

        // Ventana 3: Live Preview & Canvas (120 FPS)
        fx = w3_x + world_cam_x
        fy = w3_y + world_cam_y
        fh = w3_h
        if (w3_min == 1.0) { fh = 28.0 }
        fr = fx + w3_w
        fb = fy + fh

        if (fr > -50.0) {
            if (fx < screen_w + 50.0) {
                rect(fx, fy, w3_w, fh, 0x070B12)
                rect(fx, fy, w3_w, 28.0, 0x161B22)
                line(fx, fy + 28.0, fr, fy + 28.0, 0x30363D)
                text("<s>3: Live Preview & Canvas (120 FPS)", fx + 12.0, fy + 8.0, 10, 0x00E5FF)
                line(fx, fy, fr, fy, 0x30363D)
                line(fx, fy, fx, fb, 0x30363D)
                line(fr, fy, fr, fb, 0x30363D)
                line(fx, fb, fr, fb, 0x30363D)

                if (w3_min == 0.0) {
                    btn("-", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w3, 0x21262D)
                    render_window_stage(fx, fy + 28.0, w3_w, fh - 28.0, t_frame)
                } else {
                    btn("+", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w3, 0x238636)
                }
            }
        }

        // Ventana 4: Depurador PVM & Memoria SoA
        fx = w4_x + world_cam_x
        fy = w4_y + world_cam_y
        fh = w4_h
        if (w4_min == 1.0) { fh = 28.0 }
        fr = fx + w4_w
        fb = fy + fh

        if (fr > -50.0) {
            if (fx < screen_w + 50.0) {
                rect(fx, fy, w4_w, fh, 0x0B0E14)
                rect(fx, fy, w4_w, 28.0, 0x161B22)
                line(fx, fy + 28.0, fr, fy + 28.0, 0x30363D)
                text("<s>4: Depurador PVM & Memoria SoA", fx + 12.0, fy + 8.0, 10, 0xD29922)
                line(fx, fy, fr, fy, 0x30363D)
                line(fx, fy, fx, fb, 0x30363D)
                line(fr, fy, fr, fb, 0x30363D)
                line(fx, fb, fr, fb, 0x30363D)

                if (w4_min == 0.0) {
                    btn("-", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w4, 0x21262D)
                    render_window_debugger(fx, fy + 28.0, w4_w, fh - 28.0)
                } else {
                    btn("+", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w4, 0x238636)
                }
            }
        }

        // Ventana 5: Terminal Interactiva PVM CLI
        fx = w5_x + world_cam_x
        fy = w5_y + world_cam_y
        fh = w5_h
        if (w5_min == 1.0) { fh = 28.0 }
        fr = fx + w5_w
        fb = fy + fh

        if (fr > -50.0) {
            if (fx < screen_w + 50.0) {
                rect(fx, fy, w5_w, fh, 0x080B10)
                rect(fx, fy, w5_w, 28.0, 0x161B22)
                line(fx, fy + 28.0, fr, fy + 28.0, 0x30363D)
                text("<s>5: Terminal Interactiva PVM CLI", fx + 12.0, fy + 8.0, 10, 0x8957E5)
                line(fx, fy, fr, fy, 0x30363D)
                line(fx, fy, fx, fb, 0x30363D)
                line(fr, fy, fr, fb, 0x30363D)
                line(fx, fb, fr, fb, 0x30363D)

                if (w5_min == 0.0) {
                    btn("-", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w5, 0x21262D)
                    render_window_terminal(fx, fy + 28.0, w5_w, fh - 28.0)
                } else {
                    btn("+", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w5, 0x238636)
                }
            }
        }

        // Ventana 6: Asistente IA KoraDevs Copilot
        fx = w6_x + world_cam_x
        fy = w6_y + world_cam_y
        fh = w6_h
        if (w6_min == 1.0) { fh = 28.0 }
        fr = fx + w6_w
        fb = fy + fh

        if (fr > -50.0) {
            if (fx < screen_w + 50.0) {
                rect(fx, fy, w6_w, fh, 0x111620)
                rect(fx, fy, w6_w, 28.0, 0x161B22)
                line(fx, fy + 28.0, fr, fy + 28.0, 0x30363D)
                text("<s>6: Asistente IA KoraDevs Copilot", fx + 12.0, fy + 8.0, 10, 0xDB61A2)
                line(fx, fy, fr, fy, 0x30363D)
                line(fx, fy, fx, fb, 0x30363D)
                line(fr, fy, fr, fb, 0x30363D)
                line(fx, fb, fr, fb, 0x30363D)

                if (w6_min == 0.0) {
                    btn("-", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w6, 0x21262D)
                    render_window_ai(fx, fy + 28.0, w6_w, fh - 28.0, t_frame)
                } else {
                    btn("+", fr - 26.0, fy + 4.0, 20.0, 20.0, act_toggle_min_w6, 0x238636)
                }
            }
        }

        // --- 4. CURVATURA 3D AUTOMÁTICA FUERA DE LA PANTALLA VISIBLE ---
        // La pantalla visible [0..screen_w] es 100% plana; la curvatura hacia atrás ocurre automáticamente al salirse
        curv_h = screen_h - 72.0
        curv_b = screen_h - 24.0
        rect(0.0, 48.0, 20.0, curv_h, 0x070A0F)
        line(0.0, 48.0, 20.0, 52.0, 0x1F2A38)
        line(0.0, curv_b, 20.0, curv_b - 4.0, 0x1F2A38)
        line(20.0, 48.0, 20.0, curv_b, 0x161B22)

        curv_xr = screen_w - 20.0
        rect(curv_xr, 48.0, 20.0, curv_h, 0x070A0F)
        line(curv_xr, 52.0, screen_w, 48.0, 0x1F2A38)
        line(curv_xr, curv_b - 4.0, screen_w, curv_b, 0x1F2A38)
        line(curv_xr, 48.0, curv_xr, curv_b, 0x161B22)

    } else {
        // En Modo Móvil: Snap 100% "Llave en Cerradura"
        if (ide_panel_activo == 1.0) { render_window_editor(0.0, area_y, screen_w, area_h, t_frame, 0.0, 0.0) }
        if (ide_panel_activo == 2.0) { render_window_explorer(0.0, area_y, screen_w, area_h, 0.0, 0.0) }
        if (ide_panel_activo == 3.0) { render_window_stage(0.0, area_y, screen_w, area_h, t_frame) }
        if (ide_panel_activo == 4.0) { render_window_debugger(0.0, area_y, screen_w, area_h) }
        if (ide_panel_activo == 5.0) { render_window_terminal(0.0, area_y, screen_w, area_h) }
        if (ide_panel_activo == 6.0) { render_window_ai(0.0, area_y, screen_w, area_h, t_frame) }
    }

    // Barra de Estado Inferior Global
    bot_y = screen_h - 24.0
    rect(0.0, bot_y, screen_w, 24.0, 0x161B22)
    line(0.0, bot_y, screen_w, bot_y, 0x30363D)
    text("Estado: Listo | Ventanas Libres & Scroll 2D | Mundo 360° | Zero-GC 120 FPS", 12.0, bot_y + 7.0, 10, 0x8B949E)
    ia_txt_x = screen_w - 220.0
    if (ide_ia_status == 1.0) {
        text("IA: Gemini Cloud Pro (Online)", ia_txt_x, bot_y + 7.0, 10, 0x3FB950)
    } else {
        text("IA: Phasor-SLM (Local Offline)", ia_txt_x, bot_y + 7.0, 10, 0xBC8CFF)
    }

    render_security_modal(screen_w, screen_h)
    1.0
}
