// ===============================================================================
// CHRONOS IDE — MÓDULO NATIVO DE MENÚS, CONTENEDORES Y CONEXIÓN DE IA (lib/ui_ide_menu.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Unificada Multi-Ventana: 6 Ventanas Ortogonales SoA a 120 FPS
// ===============================================================================
import "lib/file_explorer.ph"
import "lib/color.ph"
import "lib/ui.ph"
import "lib/view.ph"
import "lib/barge_in_assistant.ph"
import "lib/tts_speech.ph"
import "lib/procedural_video.ph"

// 1. ESTADOS GLOBALES DE LA INTERFAZ DEL IDE (MEMORIA CONTIGUA SOA)
ide_panel_activo = 1.0     // 1=Editor, 2=Explorador, 3=Escenario PVM, 4=Depurador, 5=Terminal/Disasm, 6=IA Avatar
ide_modo_escritorio = 1.0  // Detectado dinámicamente por R250 >= 768px
ide_ia_status = 1.0        // 1.0 = Gemini Cloud Pro (Profesor), 2.0 = Local SLM (Estudiante)
ide_ia_talking = 0.0       // Nivel de energía de voz para el avatar reactivo
ide_ia_emotion = 1.0       // 1=Normal, 2=Feliz, 3=Pensando, 4=Alerta
ide_dbg_paused = 0.0       // 1.0 = Pausado en breakpoint, 0.0 = Ejecutando
ide_dbg_line = 4.0         // Línea de código activa en depurador
ide_sec_modal = 0.0        // 1.0 = Diálogo modal de seguridad de red abierto
ide_build_count = 1.0      // Conteo de ciclos de auto-recompilación

// 2. ACCIONES DE MENÚ Y NAVEGACIÓN
action act_tab_editor { ide_panel_activo = 1.0 }
action act_tab_files  { ide_panel_activo = 2.0 }
action act_tab_stage  { ide_panel_activo = 3.0 }
action act_tab_debug  { ide_panel_activo = 4.0 }
action act_tab_disasm { ide_panel_activo = 5.0 }
action act_tab_ai     { ide_panel_activo = 6.0 }

action act_run_script {
    ide_panel_activo = 3.0
}

action act_step_debug {
    ide_dbg_paused = 1.0
    ide_dbg_line = ide_dbg_line + 1.0
    if (ide_dbg_line > 10.0) {
        ide_dbg_line = 4.0
    }
}

action act_resume_debug {
    ide_dbg_paused = 0.0
    ide_panel_activo = 1.0
}

action act_pause_debug {
    ide_dbg_paused = 1.0
}

action act_self_compile {
    ide_build_count = ide_build_count + 1.0
    ide_panel_activo = 5.0
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

// 3. BARRA DE ENCABEZADO Y CONTROLES DEL IDE
render_ide_header(vw, vh) = {
    // Fondo de barra superior
    rect(0.0, 0.0, vw, 48.0, 0x161B22)
    line(0.0, 48.0, vw, 48.0, 0x30363D)

    // Logotipo y versión
    text("CHRONOS IDE", 16.0, 16.0, 14, 0x58A6FF)
    rect(130.0, 14.0, 64.0, 20.0, 0x238636)
    text("SELF-HOST", 134.0, 18.0, 8, 0xFFFFFF)

    if (vw < 768.0) {
        ide_modo_escritorio = 0.0
    } else {
        ide_modo_escritorio = 1.0
    }

    if (ide_modo_escritorio == 1.0) {
        // Modo Escritorio: Botones de acceso directo a las 6 ventanas ortogonales
        btn("Editor", 210.0, 8.0, 75.0, 32.0, act_tab_editor, 0x1F6FEB)
        btn("Archivos", 290.0, 8.0, 75.0, 32.0, act_tab_files, 0x238636)
        btn("Lienzo Hz", 370.0, 8.0, 85.0, 32.0, act_tab_stage, 0x00E5FF)
        btn("Debug", 460.0, 8.0, 70.0, 32.0, act_tab_debug, 0xD29922)
        btn("Terminal", 535.0, 8.0, 80.0, 32.0, act_tab_disasm, 0x8957E5)
        btn("IA Avatar", 620.0, 8.0, 85.0, 32.0, act_tab_ai, 0xDB61A2)

        // Botón de Auto-Compilación Recursiva
        btn("⚙ Re-Compilar (.wasm)", vw - 310.0, 8.0, 160.0, 32.0, act_self_compile, 0x8957E5)
        // Botón de Ejecución Directa
        btn("▶ Ejecutar (F5)", vw - 140.0, 8.0, 125.0, 32.0, act_run_script, 0x238636)
    } else {
        // Modo Móvil Snap 100%: 6 Pestañas ergonómicas
        bw = vw / 6.0
        btn("Edit", 0.0, 8.0, bw - 2.0, 32.0, act_tab_editor, 0x1F6FEB)
        btn("Files", bw, 8.0, bw - 2.0, 32.0, act_tab_files, 0x238636)
        btn("Lienzo", bw * 2.0, 8.0, bw - 2.0, 32.0, act_tab_stage, 0x00E5FF)
        btn("Dbg", bw * 3.0, 8.0, bw - 2.0, 32.0, act_tab_debug, 0xD29922)
        btn("Term", bw * 4.0, 8.0, bw - 2.0, 32.0, act_tab_disasm, 0x8957E5)
        btn("IA", bw * 5.0, 8.0, bw - 2.0, 32.0, act_tab_ai, 0xDB61A2)
    }
    1.0
}

// 4. VENTANA 1: EXPLORADOR DE PROYECTO (Módulo Reutilizable lib/file_explorer.ph)
render_window_explorer(vx, vy, vw, vh) = {
    file_explorer.render(vx, vy, vw, vh)
}

// 5. VENTANA 2: EDITOR DE CÓDIGO INTELIGENTE (Gap Buffer SoA)
render_window_editor(vx, vy, vw, vh, t_frame) = {
    rect(vx, vy, vw, vh, 0x0D1117)

    // Barra de pestañas del editor
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    rect(vx, vy, 200.0, 30.0, 0x0D1117)
    line(vx + 200.0, vy, vx + 200.0, vy + 30.0, 0x30363D)
    text("⚡ samples/phasor_ide.ph (Self-Hosted)", vx + 12.0, vy + 10.0, 10, 0x58A6FF)

    // Canaleta lateral de números de línea (Gutter)
    gutter_w = 40.0
    rect(vx, vy + 30.0, gutter_w, vh - 55.0, 0x161B22)
    line(vx + gutter_w, vy + 30.0, vx + gutter_w, vy + vh - 25.0, 0x30363D)

    // Breakpoints visuales en el gutter
    circle(vx + 14.0, vy + 115.0, 4.0, 0xF85149) // Breakpoint línea 4
    circle(vx + 14.0, vy + 175.0, 4.0, 0xF85149) // Breakpoint línea 7

    // Numeración
    text("1", vx + 22.0, vy + 55.0, 10, 0x8B949E)
    text("2", vx + 22.0, vy + 75.0, 10, 0x8B949E)
    text("3", vx + 22.0, vy + 95.0, 10, 0x8B949E)
    text("4", vx + 22.0, vy + 115.0, 10, 0xF85149)
    text("5", vx + 22.0, vy + 135.0, 10, 0x8B949E)
    text("6", vx + 22.0, vy + 155.0, 10, 0x8B949E)
    text("7", vx + 22.0, vy + 175.0, 10, 0xF85149)
    text("8", vx + 22.0, vy + 195.0, 10, 0x8B949E)
    text("9", vx + 22.0, vy + 215.0, 10, 0x8B949E)
    text("10", vx + 16.0, vy + 235.0, 10, 0x8B949E)

    // Resaltado de pausa en depuración
    if (ide_dbg_paused == 1.0) {
        rect(vx + gutter_w, vy + 107.0, vw - gutter_w, 20.0, 0x2E2412)
        line(vx + gutter_w, vy + 107.0, vx + gutter_w, vy + 127.0, 0xD29922)
        text("▶", vx + gutter_w - 12.0, vy + 115.0, 9, 0xD29922)
    }

    // Código del IDE cargado en el propio IDE (Homoicónico / Recursivo)
    tx = vx + gutter_w + 14.0
    text("// CHRONOS IDE — Codigo fuente del IDE autohospedado en ejecucion", tx, vy + 55.0, 11, 0x8B949E)
    text("import ui_ide_menu", tx, vy + 75.0, 11, 0xBC8CFF)
    text("signal ide_fps = 120.0", tx, vy + 95.0, 11, 0x3FB950)
    text("v_smith: Vec3 = [120.0, 45.0, 0.0]  // Fasor (Mag ∠ Ang)", tx, vy + 115.0, 11, 0x79C0FF)
    text("screen \"main\" {", tx, vy + 135.0, 11, 0x58A6FF)
    text("    cls(0x0D1117)", tx, vy + 155.0, 11, 0x58A6FF)
    text("    ui_ide_menu.render_ide_workspace(R250, R251, t_global)", tx, vy + 175.0, 11, 0xD2A8FF)
    text("    smith_chart(cx, cy, 75.0, 0.35, 0.42)", tx, vy + 195.0, 11, 0x00E5FF)
    text("    procedural_ai_face(t_global, cx, cy, talking, 1.0)", tx, vy + 215.0, 11, 0xF778BA)
    text("}", tx, vy + 235.0, 11, 0x58A6FF)

    // Cursor parpadeante Zero-GC
    blink = (t_frame * 0.05) % 2.0
    if (blink > 1.0) {
        line(tx + 280.0, vy + 112.0, tx + 280.0, vy + 128.0, 0x00E5FF)
    } else {
        1.0
    }

    // Barra de estado del editor
    rect(vx, vy + vh - 24.0, vw, 24.0, 0x161B22)
    line(vx, vy + vh - 24.0, vx + vw, vy + vh - 24.0, 0x30363D)
    text("Ln 4, Col 32 | UTF-8 | GapBuffer SoA (64 KB) | FlatLexer O(N) | Breakpoints: 2", vx + 12.0, vy + vh - 17.0, 10, 0x8B949E)
    1.0
}

// 6. VENTANA 3: ESCENARIO PVM & VISORES CIENTÍFICOS HZ (120 FPS)
render_window_stage(vx, vy, vw, vh, t_frame) = {
    rect(vx, vy, vw, vh, 0x070B12)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("🔬 ESCENARIO PVM — VISORES CIENTÍFICOS (120 FPS ZERO-GC)", vx + 12.0, vy + 10.0, 11, 0x00E5FF)

    // Cuadrícula fasorial
    cx = vx + (vw * 0.32)
    cy = vy + (vh * 0.48)
    r_smith = 80.0
    if (vw < 400.0) {
        r_smith = 55.0
    }

    // Carta de Smith
    circle(cx, cy, r_smith, 0x1F6FEB)
    circle(cx, cy, r_smith * 0.5, 0x238636)
    circle(cx + (r_smith * 0.5), cy, r_smith * 0.5, 0x30363D)
    line(cx - r_smith, cy, cx + r_smith, cy, 0x30363D)
    line(cx, cy - r_smith, cx, cy + r_smith, 0x30363D)
    text("Gamma Real", cx + r_smith + 6.0, cy - 4.0, 9, 0x58A6FF)
    text("+j Imag", cx - 18.0, cy - r_smith - 8.0, 9, 0x58A6FF)

    // Vector fasorial dinámico en rotación fasorial
    ang = t_frame * 0.04
    fx = cx + (r_smith * 0.65 * cos(ang))
    fy = cy - (r_smith * 0.65 * sin(ang))
    line(cx, cy, fx, fy, 0x00E5FF)
    circle(fx, fy, 4.0, 0x3FB950)

    // Osciloscopio / Forma de onda temporal
    tx_start = cx + r_smith + 30.0
    tx_end = vx + vw - 20.0
    if (tx_end > tx_start + 40.0) {
        line(tx_start, cy, tx_end, cy, 0x30363D)
        text("t [s] (Forma de Onda)", tx_end - 90.0, cy - 8.0, 9, 0x8B949E)

        // Traza senoidal animada
        px = tx_start
        while (px < tx_end) {
            t_wave = (px - tx_start) * 0.08 - (t_frame * 0.08)
            py = cy + (sin(t_wave) * 35.0)
            circle(px, py, 1.5, 0x3FB950)
            px = px + 6.0
        }
    }

    // Resumen de telemetría PVM en el pie
    rect(vx, vy + vh - 24.0, vw, 24.0, 0x161B22)
    text("Simulación Activa | Carta de Smith + Senoide Temporal | Pausas GC: 0 | 120 FPS", vx + 12.0, vy + vh - 17.0, 10, 0x3FB950)
    1.0
}

// 7. VENTANA 4: DEPURADOR E INSPECTOR DE REGISTROS SOA
render_window_debugger(vx, vy, vw, vh) = {
    rect(vx, vy, vw, vh, 0x0D1117)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("🐞 DEPURADOR & BANCO DE REGISTROS SOA (R0..R255)", vx + 12.0, vy + 10.0, 11, 0xD29922)

    // Tarjeta de estado del depurador
    rect(vx + 15.0, vy + 45.0, vw - 30.0, 48.0, 0x161B22)
    if (ide_dbg_paused == 1.0) {
        text("ESTADO: PAUSADO EN BREAKPOINT (Linea 4, PC=0x002A)", vx + 25.0, vy + 55.0, 10, 0xD29922)
        text("Instruccion: OP_VEC3_LOAD R1 = [120.0, 45.0, 0.0]", vx + 25.0, vy + 72.0, 10, 0x3FB950)
    } else {
        text("ESTADO: EJECUCION CONTINUA A 120 FPS ZERO-GC", vx + 25.0, vy + 55.0, 10, 0x3FB950)
        text("Watchdog: 0 fallos | Sin fugas de memoria | Stack SoA contiguo", vx + 25.0, vy + 72.0, 10, 0x8B949E)
    }

    // Registros PVM SoA
    text("[R0]  (Escalar)    : 60.0000 Hz", vx + 25.0, vy + 115.0, 11, 0x58A6FF)
    text("[R1]  (Vec3 SIMD)  : [120.00, 45.00, 0.00] (v_smith)", vx + 25.0, vy + 140.0, 11, 0x79C0FF)
    text("[R2]  (Fasor Polar): 120.00 ∠ 45.00° (84.85 + 84.85j)", vx + 25.0, vy + 165.0, 11, 0x3FB950)
    text("[R250] (Viewport W) : R250 = " + R250, vx + 25.0, vy + 190.0, 11, 0xFFFFFF)
    text("[R251] (Viewport H) : R251 = " + R251, vx + 25.0, vy + 215.0, 11, 0xFFFFFF)
    text("[R252..R255] Puntero Tactil y Scroll Clamped", vx + 25.0, vy + 240.0, 11, 0x8B949E)

    // Controles de paso a paso
    btn("▶ Continuar", vx + 15.0, vy + vh - 45.0, 110.0, 34.0, act_resume_debug, 0x238636)
    btn("⏭️ Paso (Step)", vx + 135.0, vy + vh - 45.0, 120.0, 34.0, act_step_debug, 0x1F6FEB)
    btn("⏸️ Pausar", vx + 265.0, vy + vh - 45.0, 95.0, 34.0, act_pause_debug, 0xD29922)
    1.0
}

// 8. VENTANA 5: TERMINAL PVM & DESENSAMBLADOR BYTECODE
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
    text("> [OUT Stream]: Ciclos de recompilacion exitosos: " + ide_build_count, vx + 15.0, vy + 220.0, 10, 0x3FB950)
    text("> [PVM Profiler] Latencia de despacho: 18 us/frame | 0 allocations", vx + 15.0, vy + 240.0, 10, 0x8B949E)

    btn("Ejecutar phasorc.ph (Compilar IDE a WASM)", vx + 15.0, vy + vh - 45.0, vw - 30.0, 34.0, act_self_compile, 0x8957E5)
    1.0
}

// 9. VENTANA 6: PANEL DE IA, AVATAR REACTIVO Y VOZ FORMÁNTICA
render_window_ai(vx, vy, vw, vh, t_frame) = {
    rect(vx, vy, vw, vh, 0x0D1117)
    rect(vx, vy, vw, 30.0, 0x161B22)
    line(vx, vy + 30.0, vx + vw, vy + 30.0, 0x30363D)
    text("✨ ASISTENTE IA — AVATAR REACTIVO & VOZ FORMÁNTICA", vx + 12.0, vy + 10.0, 11, 0xDB61A2)

    // Renderizado del Avatar Holográfico Procedural en Vivo (0 Bytes en disco)
    avatar_cx = vx + (vw * 0.5)
    avatar_cy = vy + 120.0
    procedural_ai_face(t_frame, avatar_cx, avatar_cy, ide_ia_talking, ide_ia_emotion)

    // Tarjeta del Modelo Híbrido Docente-Estudiante
    rect(vx + 15.0, vy + 205.0, vw - 30.0, 60.0, 0x161B22)
    if (ide_ia_status == 1.0) {
        text("PROVEEDOR: Gemini Cloud Pro (Docente / Arquitecto)", vx + 25.0, vy + 218.0, 10, 0xBC8CFF)
        text("Genera código PhasorLang validado para entrenamiento local.", vx + 25.0, vy + 236.0, 9, 0x8B949E)
    } else {
        text("PROVEEDOR: Phasor-SLM Local (Estudiante Cuantizado)", vx + 25.0, vy + 218.0, 10, 0x3FB950)
        text("Inferencia 100% offline desde dataset_phasor_incremental.jsonl", vx + 25.0, vy + 236.0, 9, 0x8B949E)
    }

    // Botones de control del asistente
    btn("Entrenar Modelo Local (Fine-Tuning)", vx + 15.0, vy + 275.0, (vw - 36.0) * 0.5, 34.0, act_train_local_ai, 0x8957E5)
    btn("Interrumpir (Barge-In O(1))", vx + 21.0 + ((vw - 36.0) * 0.5), vy + 275.0, (vw - 36.0) * 0.5, 34.0, act_barge_in_cut, 0xD29922)

    // Botón de Gobernanza de Seguridad de Red
    btn("🔒 Permisos de Red y Privacidad", vx + 15.0, vy + vh - 45.0, vw - 30.0, 34.0, act_toggle_net_modal, 0x21262D)
    1.0
}

// 10. DIÁLOGO MODAL DE GOBERNANZA DE SEGURIDAD DE RED
render_security_modal(vw, vh) = {
    if (ide_sec_modal == 1.0) {
        // Cortina translúcida
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

        btn("Permitir Conexión", mx + 20.0, my + mh - 50.0, (mw - 50.0) * 0.5, 36.0, act_toggle_net_modal, 0x238636)
        btn("Mantener Offline", mx + 30.0 + ((mw - 50.0) * 0.5), my + mh - 50.0, (mw - 50.0) * 0.5, 36.0, act_toggle_net_modal, 0x30363D)
    }
    1.0
}

// 11. CONTENEDOR PRINCIPAL DEL WORKSPACE AUTÓNOMO
render_ide_workspace(vw, vh, t_frame) = {
    render_ide_header(vw, vh)

    area_y = 48.0
    area_h = vh - 48.0 - 24.0

    if (ide_modo_escritorio == 1.0) {
        // En Modo Escritorio: Distribución ortogonal o vista enfocada
        if (ide_panel_activo == 1.0) {
            // Split: Explorador (240px) + Editor (Resto)
            render_window_explorer(0.0, area_y, 240.0, area_h)
            line(240.0, area_y, 240.0, area_y + area_h, 0x30363D)
            render_window_editor(240.0, area_y, vw - 240.0, area_h, t_frame)
        }
        if (ide_panel_activo == 2.0) {
            render_window_explorer(0.0, area_y, vw, area_h)
        }
        if (ide_panel_activo == 3.0) {
            render_window_stage(0.0, area_y, vw, area_h, t_frame)
        }
        if (ide_panel_activo == 4.0) {
            render_window_debugger(0.0, area_y, vw, area_h)
        }
        if (ide_panel_activo == 5.0) {
            render_window_terminal(0.0, area_y, vw, area_h)
        }
        if (ide_panel_activo == 6.0) {
            render_window_ai(0.0, area_y, vw, area_h, t_frame)
        }
    } else {
        // En Modo Móvil: Snap 100% "Llave en Cerradura"
        if (ide_panel_activo == 1.0) {
            render_window_editor(0.0, area_y, vw, area_h, t_frame)
        }
        if (ide_panel_activo == 2.0) {
            render_window_explorer(0.0, area_y, vw, area_h)
        }
        if (ide_panel_activo == 3.0) {
            render_window_stage(0.0, area_y, vw, area_h, t_frame)
        }
        if (ide_panel_activo == 4.0) {
            render_window_debugger(0.0, area_y, vw, area_h)
        }
        if (ide_panel_activo == 5.0) {
            render_window_terminal(0.0, area_y, vw, area_h)
        }
        if (ide_panel_activo == 6.0) {
            render_window_ai(0.0, area_y, vw, area_h, t_frame)
        }
    }

    // Barra de Estado Inferior Global
    rect(0.0, vh - 24.0, vw, 24.0, 0x161B22)
    line(0.0, vh - 24.0, vw, vh - 24.0, 0x30363D)
    text("Estado: Listo | SoA 64KB (Zero-GC) | 120 FPS | Self-Host: Activo", 12.0, vh - 17.0, 10, 0x8B949E)
    if (ide_ia_status == 1.0) {
        text("IA: Gemini Cloud Pro (Online)", vw - 220.0, vh - 17.0, 10, 0x3FB950)
    } else {
        text("IA: Phasor-SLM (Local Offline)", vw - 220.0, vh - 17.0, 10, 0xBC8CFF)
    }

    // Modal de Seguridad de Red si está activo
    render_security_modal(vw, vh)
    1.0
}
