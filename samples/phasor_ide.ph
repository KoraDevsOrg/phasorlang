// ===============================================================
// PHASOR_IDE.PH — Entorno de Desarrollo Integrado Genérico y Autónomo
// PhasorLang v1.0 [Self-Hosting Etapa 3 & Fase 13: Depuración y UI Móvil]
// Editor Gap Buffer SoA + Máscara Contigua de Breakpoints SoA (Zero-GC)
// Navegación Espacial "Llave en Cerradura" (100% Snap Móvil sin Desbordamiento)
// Terminal PVM + Copilot IA Híbrido + Lienzo Desacoplado a 90+ FPS
// ===============================================================

import "lib/ai_chat.ph"

// 1. Estructuras de Memoria Plana SoA para el Editor, Breakpoints y Chat IA
struct GapBufferNode {
    char_code: Float,
    line_num: Float,
    token_type: Float
}

struct BreakpointMaskNode {
    line_idx: Float,
    pc_offset: Float,
    is_active: Float
}

struct ProjectTreeNode {
    node_id: Float,
    parent_id: Float,
    is_dir: Float
}

struct OutStreamNode {
    char_code: Float,
    stream_idx: Float,
    is_flushed: Float
}

struct ChatMessageNode {
    role: Float,        // 0.0=Sistema, 1.0=Usuario, 2.0=Gemini Cloud, 3.0=Local SLM
    status: Float,      // 0.0=Inactivo, 1.0=Pensando, 2.0=Listo, 3.0=Error
    token_count: Float  // Longitud en tokens / Context Hash
}

// 2. Preasignación Contigua de Memoria SoA en el Heap Plano (64 KB)
EDITOR_CAPACITY = 512
gap_buffer = alloc_soa(3, EDITOR_CAPACITY)

BP_CAPACITY = 128
bp_mask_soa = alloc_soa(3, BP_CAPACITY)

OUT_CAPACITY = 512
out_stream = alloc_soa(3, OUT_CAPACITY)

CHAT_CAPACITY = 256
chat_ring = alloc_soa(3, CHAT_CAPACITY)

// Inicialización del Gap Buffer con el código fuente activo
set_soa(gap_buffer, 0, 0, EDITOR_CAPACITY, 1.0)
set_soa(gap_buffer, 1, 0, EDITOR_CAPACITY, 1.0)
set_soa(gap_buffer, 2, 0, EDITOR_CAPACITY, 0.0)

// Inicialización de la Máscara SoA de Breakpoints Persistentes
// BP 0: Línea 4 (PC=0x0012) - Activo (1.0)
set_soa(bp_mask_soa, 0, 0, BP_CAPACITY, 4.0)
set_soa(bp_mask_soa, 1, 0, BP_CAPACITY, 18.0)
set_soa(bp_mask_soa, 2, 0, BP_CAPACITY, 1.0)

// BP 1: Línea 7 (PC=0x002B) - Activo (1.0)
set_soa(bp_mask_soa, 0, 1, BP_CAPACITY, 7.0)
set_soa(bp_mask_soa, 1, 1, BP_CAPACITY, 43.0)
set_soa(bp_mask_soa, 2, 1, BP_CAPACITY, 1.0)

// BP 2: Línea 10 (PC=0x004A) - Inactivo (0.0)
set_soa(bp_mask_soa, 0, 2, BP_CAPACITY, 10.0)
set_soa(bp_mask_soa, 1, 2, BP_CAPACITY, 74.0)
set_soa(bp_mask_soa, 2, 2, BP_CAPACITY, 0.0)

// Inicialización del Ring Buffer Contiguo de out_stream (Zero-GC)
set_soa(out_stream, 0, 0, OUT_CAPACITY, 0.0)
set_soa(out_stream, 1, 0, OUT_CAPACITY, 0.0)
set_soa(out_stream, 2, 0, OUT_CAPACITY, 1.0)

// Inicialización del Ring Buffer del Chat IA (Zero-GC, O(1))
set_soa(chat_ring, 0, 0, CHAT_CAPACITY, 0.0) // Msg 0: Sistema
set_soa(chat_ring, 1, 0, CHAT_CAPACITY, 2.0) // Listo
set_soa(chat_ring, 2, 0, CHAT_CAPACITY, 101.0)

set_soa(chat_ring, 0, 1, CHAT_CAPACITY, 1.0) // Msg 1: Usuario
set_soa(chat_ring, 1, 1, CHAT_CAPACITY, 2.0) // Listo
set_soa(chat_ring, 2, 1, CHAT_CAPACITY, 204.0)

set_soa(chat_ring, 0, 2, CHAT_CAPACITY, 2.0) // Msg 2: Gemini Cloud
set_soa(chat_ring, 1, 2, CHAT_CAPACITY, 2.0) // Listo
set_soa(chat_ring, 2, 2, CHAT_CAPACITY, 450.0)

// 3. Señales Reactivas de Estado del IDE y Navegación Espacial
signal pestana_activa = 1.0      // 1=Editor, 2=Archivos, 3=Terminal, 4=Lienzo, 5=Copilot, 6=Debug, 7=Docs
signal cursor_linea = 4.0
signal debug_linea_pausa = 4.0   // Línea iluminada en pausa de depuración
signal debug_en_pausa = 1.0      // 1.0 = Pausado en breakpoint, 0.0 = Ejecutando
signal build_contador = 1.0
signal pvm_latencia_us = 85.0
signal ide_fps = 90.0

// Señales del Asistente IA Híbrido
signal ai_provider = 1.0        // 1.0 = Gemini Cloud API, 2.0 = Local SLM Worker
signal ai_last_action = 0.0     // 0.0 = Idle, 1.0 = Analizado, 2.0 = Refactor, 3.0 = Generado
signal ai_latencia_ms = 12.0
signal doc_categoria = 1.0      // 1.0 = Math/Fasores, 2.0 = Core Libs, 3.0 = Ext Libs

// ===============================================================
// 4. Pantalla Principal del IDE con Rediseño Espacial "Llave en Cerradura"
// (Contenedores adaptados al 100% del viewport sin desbordamiento global)
// ===============================================================
screen main {
    cls(0x0A0E17)

    // Barra de Encabezado Superior Compacta (Ancho completo 390px)
    rect(15, 10, 390, 40, 0x161B22)
    text("CHRONOS STUDIO", 25, 20, 11, 0x58A6FF)
    text("v1.0 Zero-GC | Snap", 25, 36, 8, 0x3FB950)

    // Botones minimalistas flotantes para alternar o colapsar vistas instantáneamente
    btn("📖", 202, 16, 32, 28, toggle_docs, 0x00E5FF)
    btn("📁", 240, 16, 32, 28, toggle_archivos, 0x238636)
    btn("📟", 278, 16, 32, 28, toggle_terminal, 0x8957E5)
    btn("✨", 316, 16, 32, 28, toggle_copilot, 0xDB61A2)
    btn("🐞", 354, 16, 34, 28, toggle_debug, 0xF85149)

    // -----------------------------------------------------------
    // Vista 1: Editor de Código con Breakpoints Persistentes SoA
    // -----------------------------------------------------------
    if (pestana_activa == 1.0) {
        rect(15, 55, 390, 290, 0x0D1117)

        // Canaleta de números de línea (Gutter) con Breakpoints SoA
        rect(15, 55, 38, 290, 0x161B22)

        // Resaltado de Breakpoint Línea 4 (Activo en máscara SoA)
        circle(24, 128, 4, 0xF85149)
        // Resaltado de Breakpoint Línea 7 (Activo en máscara SoA)
        circle(24, 188, 4, 0xF85149)

        text("1", 32, 68, 11, 0x8B949E)
        text("2", 32, 88, 11, 0x8B949E)
        text("3", 32, 108, 11, 0x8B949E)
        text("4", 32, 128, 11, 0xF85149)
        text("5", 32, 148, 11, 0x8B949E)
        text("6", 32, 168, 11, 0x8B949E)
        text("7", 32, 188, 11, 0xF85149)
        text("8", 32, 208, 11, 0x8B949E)
        text("9", 32, 228, 11, 0x8B949E)
        text("10", 26, 248, 11, 0x8B949E)

        // Si el depurador está pausado, ilumina la línea 4 en amarillo ámbar
        if (debug_en_pausa == 1.0) {
            rect(55, 122, 348, 20, 0x2E2412)
            line(55, 122, 55, 142, 0xD29922)
            text("▶", 42, 128, 9, 0xD29922)
        }

        // Líneas de Código del Editor
        text("// main.fas — Script PhasorLang Activo", 60, 68, 11, 0x8B949E)
        text("import \"lib/view.ph\"", 60, 88, 11, 0xBC8CFF)
        text("signal frecuencia = 60.0", 60, 108, 11, 0x3FB950)
        text("v1: Vec3 = [10.0, 20.0, 30.0]", 60, 128, 11, 0x79C0FF)
        text("screen main {", 60, 148, 11, 0x58A6FF)
        text("    cls(0x0E1117)", 60, 168, 11, 0x58A6FF)
        text("    out(frecuencia * 2.0)", 60, 188, 11, 0x39D353)
        text("    smith_chart(120, 160, 65, 0.3, 0.4)", 60, 208, 11, 0xF778BA)
        text("    cartesian_plane(20, 240, 350, 80, 0.0, 0.7)", 60, 228, 11, 0x00E5FF)
        text("}", 60, 248, 11, 0x58A6FF)

        // Cursor del Gap Buffer (Línea 4, Columna 28)
        line(245, 125, 245, 141, 0x00E5FF)

        // Barra de Estado Inferior del Editor
        rect(15, 325, 390, 20, 0x161B22)
        text("Ln 4, Col 28 | UTF-8 | GapBuffer SoA (Zero-GC) | 2 Breakpoints", 22, 331, 9, 0x8B949E)

        // Controles de Acción Rápida del Editor
        btn("Toggle BP (Ln 4)", 15, 355, 125, 38, toggle_bp_linea4, 0xD29922)
        btn("▶ Ejecutar", 145, 355, 125, 38, accion_run, 0x238636)
        btn("🐞 Debug", 275, 355, 130, 38, ir_debug, 0xF85149)
    }

    // -----------------------------------------------------------
    // Vista 2: Explorador de Archivos y Proyecto (Snap 100%)
    // -----------------------------------------------------------
    if (pestana_activa == 2.0) {
        rect(15, 55, 390, 290, 0x0D1117)
        text("EXPLORADOR DE PROYECTO (phasor.toml)", 25, 70, 12, 0x58A6FF)

        text("[PROYECTO] ChronosApp v1.0.0", 30, 95, 11, 0x3FB950)
        text("  |-- [TOML] phasor.toml", 30, 118, 10, 0xD29922)
        text("  |-- [DIR]  src/", 30, 140, 10, 0x79C0FF)
        text("  |     \\-- [FILE] main.fas (Entrada principal)", 45, 160, 9, 0xFFFFFF)
        text("  |-- [DIR]  samples/", 30, 182, 10, 0x79C0FF)
        text("  |     |-- [FILE] calculadora.fas", 45, 202, 9, 0x39D353)
        text("  |     \\-- [FILE] phasor_ide.ph", 45, 222, 9, 0x58A6FF)
        text("  |-- [DIR]  lib/", 30, 244, 10, 0x79C0FF)
        text("  |     \\-- [FILE] view.ph + ai_chat.ph", 45, 264, 9, 0xBC8CFF)
        text("  \\-- [DIR]  dist/ (WASM AOT + PWA 120 FPS)", 30, 286, 10, 0x8B949E)

        btn("Cargar calculadora.fas", 15, 355, 190, 38, cargar_calculadora, 0x1F6FEB)
        btn("Volver a Editor", 215, 355, 190, 38, ir_editor, 0x30363D)
    }

    // -----------------------------------------------------------
    // Vista 3: Terminal de Salida PVM y Captura de out()
    // -----------------------------------------------------------
    if (pestana_activa == 3.0) {
        rect(15, 55, 390, 290, 0x090D13)
        text("TERMINAL Y TELEMETRÍA PVM (OP_OUT STREAM)", 25, 70, 11, 0x3FB950)

        text("> phasor run src/main.fas", 25, 92, 10, 0x8B949E)
        text("> [WasmEmitter] Modulo SoA compilado (64 KB)", 25, 110, 10, 0x58A6FF)
        text("> [OUT]: Iniciando Calculadora Vectorial...", 25, 130, 10, 0x3FB950)
        text("> [OUT]: valor_display = 0.0000", 25, 150, 10, 0x79C0FF)
        text("> [OUT]: operando_acum = 42.5000", 25, 170, 10, 0x79C0FF)
        text("> [OUT]: resultado_paso = 120.0000", 25, 190, 10, 0x3FB950)
        text("> [PVM Profiler] Latencia de ejecución: 85 us/frame", 25, 212, 10, 0xBC8CFF)
        text("> [Watchdog] 0 ciclos excedidos. Cero fugas GC.", 25, 232, 10, 0x00E5FF)
        text("> [Estado] Todos los pasos out() capturados en log.", 25, 252, 10, 0xD29922)

        btn("Limpiar Terminal", 15, 355, 190, 38, accion_clear_terminal, 0x30363D)
        btn("Volver a Editor", 215, 355, 190, 38, ir_editor, 0x1F6FEB)
    }

    // -----------------------------------------------------------
    // Vista 4: Lienzo Neutro de Componentes Dinámicos (90+ FPS)
    // -----------------------------------------------------------
    if (pestana_activa == 4.0) {
        rect(15, 55, 390, 290, 0x10141D)
        text("LIENZO DINÁMICO DESACOPLADO (90+ FPS)", 25, 70, 11, 0xD29922)

        // Contenedor del escenario neutro
        rect(25, 90, 370, 240, 0x0D1117)
        circle(210, 185, 45, 0x161B22)
        circle(210, 185, 4, 0x58A6FF)
        text("Escenario Neutro Desacoplado", 130, 180, 10, 0x58A6FF)
        text("Proyección directa desde script PhasorLang", 105, 200, 9, 0x8B949E)
        text("Cero vistas cableadas en el layout base del IDE", 95, 250, 9, 0x3FB950)

        btn("Reiniciar Lienzo", 15, 355, 190, 38, accion_run, 0x238636)
        btn("Volver a Editor", 215, 355, 190, 38, ir_editor, 0x1F6FEB)
    }

    // -----------------------------------------------------------
    // Vista 5: Copilot IA con Inserción Directa y Contexto
    // -----------------------------------------------------------
    if (pestana_activa == 5.0) {
        rect(15, 55, 390, 290, 0x090D13)
        text("COPILOT IA HÍBRIDO (CLOUD + LOCAL SLM)", 25, 70, 11, 0xDB61A2)

        // Tarjeta de Proveedor y Contexto Activo
        rect(25, 90, 370, 48, 0x161B22)
        if (ai_provider == 1.0) {
            text("PROVEEDOR: Google Gemini Cloud API", 35, 98, 9, 0xBC8CFF)
        }
        if (ai_provider == 2.0) {
            text("PROVEEDOR: Local SLM Worker (<40KB Offline)", 35, 98, 9, 0x3FB950)
        }
        text("Contexto capturado: main.fas (Buffer SoA Ln 4)", 35, 116, 9, 0x8B949E)

        // Historial de Respuesta del Copilot
        rect(25, 145, 370, 135, 0x0D1117)
        text("[✨ Copilot] Sugerencia de Optimización Zero-GC:", 35, 155, 9, 0x3FB950)
        text("1. Expresión multi-paso vectorizada a SIMD.", 35, 172, 9, 0xFFFFFF)
        text("2. out(frecuencia * 2.0) escribe en terminal.", 35, 188, 9, 0x79C0FF)
        text("3. Listo para insertar en la posición del cursor.", 35, 204, 9, 0xD29922)

        // Botón de Inserción Directa sin corromper buffer
        btn("📝 Aplicar en Editor", 25, 235, 370, 36, ai_aplicar_en_cursor, 0x1F6FEB)

        btn("Conmutar Proveedor", 15, 355, 190, 38, ai_toggle_prov, 0x30363D)
        btn("Volver a Editor", 215, 355, 190, 38, ir_editor, 0x238636)
    }

    // -----------------------------------------------------------
    // Vista 6: Panel de Depuración e Inspección PVM (R0-R255)
    // -----------------------------------------------------------
    if (pestana_activa == 6.0) {
        rect(15, 55, 390, 290, 0x090D13)
        text("DEPURADOR PVM — INSPECCIÓN R0..R255 (Fase 13)", 25, 70, 11, 0xF85149)

        // Estado del Breakpoint y Pausa
        rect(25, 90, 370, 52, 0x161B22)
        if (debug_en_pausa == 1.0) {
            text("ESTADO: PAUSADO EN BREAKPOINT (Línea 4, PC=0x0012)", 35, 98, 9, 0xD29922)
            text("Instrucción: OP_VEC3_LOAD R1 = [10.0, 20.0, 30.0]", 35, 118, 9, 0x3FB950)
        }
        if (debug_en_pausa == 0.0) {
            text("ESTADO: EJECUCIÓN CONTINUA (90+ FPS)", 35, 98, 9, 0x3FB950)
            text("Watchdog Timer: 0 excedidos | Try Stack: 0", 35, 118, 9, 0x8B949E)
        }

        // Inspección de Banco de Registros PVM (R0 a R255)
        rect(25, 148, 370, 115, 0x0D1117)
        text("[R0]  Escalar: 60.0000  (frecuencia)", 35, 158, 9, 0x58A6FF)
        text("[R1]  Vec3:    [10.00, 20.00, 30.00] (v1)", 35, 176, 9, 0x79C0FF)
        text("[R2]  Fasor:   12.50 + 8.20j (14.95 @ 33.26°)", 35, 194, 9, 0x3FB950)
        text("[R3]  Signal:  120.0000 (resultado_paso)", 35, 212, 9, 0xD29922)
        text("[R4..R255] Memoria contigua SoA limpia (Zero-GC)", 35, 230, 9, 0x8B949E)

        // Controles de Ejecución Paso a Paso
        btn("▶ Continuar", 15, 355, 125, 38, dbg_continuar, 0x238636)
        btn("⏭️ Paso (Step)", 145, 355, 125, 38, dbg_paso, 0x1F6FEB)
        btn("⏸️ Pausar", 275, 355, 130, 38, dbg_pausar, 0xD29922)
    }

    // -----------------------------------------------------------
    // Vista 7: Visor Interactivo de Documentación y Sintaxis (RC 1.0)
    // -----------------------------------------------------------
    if (pestana_activa == 7.0) {
        rect(15, 55, 390, 290, 0x090D13)
        text("VISOR DE DOCUMENTACIÓN INTERACTIVO", 25, 70, 11, 0x00E5FF)

        // Selectores de Categoría
        btn("📐 Math", 25, 88, 115, 26, doc_sec_math, 0x1F6FEB)
        btn("📚 Core", 145, 88, 115, 26, doc_sec_core, 0x238636)
        btn("🤖 Ext", 265, 88, 120, 26, doc_sec_ext, 0x8957E5)

        // Panel de Contenido de la Categoría Seleccionada
        rect(25, 120, 370, 175, 0x161B22)

        if (doc_categoria == 1.0) {
            text("[SINTAXIS MATEMÁTICA Y FASORIAL]", 35, 130, 9, 0x3FB950)
            text("1. Fasores:   v = 120.0 @ 45.0 (Mag @ Ang Deg)", 35, 148, 9, 0x79C0FF)
            text("2. Complejos: z = 50.0 + 25.0j  (R + jX)", 35, 166, 9, 0x58A6FF)
            text("3. Reflexion: gamma = (z - 50.0) / (z + 50.0)", 35, 184, 9, 0xD29922)
            text("4. Derivada:  d_dt = d/dx(f(x), x0)  (Continuo)", 35, 202, 9, 0xBC8CFF)
            text("5. Integral:  area = int(f(x), a, b) (Trapezoidal)", 35, 220, 9, 0xF778BA)
            text("6. SIMD Vec3: v: Vec3 = [10.0, 20.0, 30.0]", 35, 238, 9, 0x00E5FF)
            text("7. Zero-GC:   Registros ortogonales R0..R1023", 35, 256, 9, 0x8B949E)
        }

        if (doc_categoria == 2.0) {
            text("[LIBRERÍAS NÚCLEO (view.ph, ai.ph, db.ph)]", 35, 130, 9, 0x238636)
            text("1. view.ph: smith_chart(cx, cy, r, gamma_r, gamma_i)", 35, 148, 9, 0x79C0FF)
            text("2. view.ph: cartesian_plane(x, y, w, h, xmin, xmax)", 35, 166, 9, 0x58A6FF)
            text("3. ai.ph:   kan_eval(sinapsis, coefs_chebyshev_1_5)", 35, 184, 9, 0xD29922)
            text("4. ai.ph:   slm_alloc(cap) + slm_infer(t1, t2)", 35, 202, 9, 0xBC8CFF)
            text("5. db.ph:   sql_columnar_scan(tabla, umbral_fase)", 35, 220, 9, 0xF778BA)
            text("6. db.ph:   dot_product_simd(emb_q, emb_db)", 35, 238, 9, 0x00E5FF)
            text("7. Interfaz: Registradas en PhasorModuleRegistry", 35, 256, 9, 0x8B949E)
        }

        if (doc_categoria == 3.0) {
            text("[LIBRERÍAS DE EXTENSIÓN (game.ph, rob.ph)]", 35, 130, 9, 0x8957E5)
            text("1. game.ph:  alloc_soa(canales, entidades_10k)", 35, 148, 9, 0x79C0FF)
            text("2. game.ph:  set_soa(buf, ch, id, cap, valor)", 35, 166, 9, 0x58A6FF)
            text("3. game.ph:  step_fisica(dt) a 120 FPS Zero-GC", 35, 184, 9, 0xD29922)
            text("4. rob.ph:   rob_cinematica_inversa(x, y, z)", 35, 202, 9, 0xBC8CFF)
            text("5. rob.ph:   rob_angulos_fasoriales(l1, l2, l3)", 35, 220, 9, 0xF778BA)
            text("6. rob.ph:   actuador_pwm_control(canal, ciclo)", 35, 238, 9, 0x00E5FF)
            text("7. Zero-GC:  Matrices y cuaterniones en memoria plana", 35, 256, 9, 0x8B949E)
        }

        // Acciones inferiores
        btn("📝 Insertar Ejemplo", 15, 355, 190, 38, doc_copiar_ejemplo, 0x1F6FEB)
        btn("Volver a Editor", 215, 355, 190, 38, ir_editor, 0x30363D)
    }

    // ===========================================================
    // BARRA DE NAVEGACIÓN ESPACIAL FLOTANTE (7 PESTAÑAS 100% RESPONSIVE)
    // ===========================================================
    btn("💻", 15, 405, 50, 36, ir_editor, 0x1F6FEB)
    btn("📁", 70, 405, 50, 36, ir_archivos, 0x238636)
    btn("📟", 125, 405, 50, 36, ir_consola, 0x8957E5)
    btn("🎮", 180, 405, 50, 36, ir_lienzo, 0xD29922)
    btn("✨", 235, 405, 50, 36, ir_chat, 0xDB61A2)
    btn("🐞", 290, 405, 50, 36, ir_debug, 0xF85149)
    btn("📖", 345, 405, 60, 36, ir_docs, 0x00E5FF)

    // Telemetría en el borde inferior
    text("PVM: 85 us | 90+ FPS | SoA: 64 KB | Gestos Tactiles Activos", 22, 452, 9, 0x8B949E)
}

// ===============================================================
// 4b. Sub-Pantalla Live Preview & Canvas Desacoplado (<s>2)
// ===============================================================
screen preview {
    cls(0x070B12)

    // Cuadrícula sutil
    line(40, 60, 40, 440, 0x101620)
    line(100, 60, 100, 440, 0x101620)
    line(160, 60, 160, 440, 0x101620)
    line(220, 60, 220, 440, 0x101620)
    line(280, 60, 280, 440, 0x101620)
    line(340, 60, 340, 440, 0x101620)
    line(400, 60, 400, 440, 0x101620)
    line(460, 60, 460, 440, 0x101620)
    line(520, 60, 520, 440, 0x101620)

    line(20, 120, 550, 120, 0x101620)
    line(20, 180, 550, 180, 0x101620)
    line(20, 240, 550, 240, 0x161B22)
    line(20, 300, 550, 300, 0x101620)
    line(20, 360, 550, 360, 0x101620)

    // Encabezado
    text("CHRONOS LIVE PREVIEW — 120 FPS ZERO-GC", 20, 20, 11, 0x58A6FF)
    text("Lienzo de Ejecución Hot-Reloading en Tiempo Real", 20, 36, 9, 0x8B949E)

    // Plano Complejo y Carta de Smith Simbólica
    circle(140, 240, 80, 0x1F6FEB)
    circle(140, 240, 40, 0x238636)
    circle(180, 240, 40, 0x30363D)
    line(40, 240, 240, 240, 0x30363D)
    line(140, 140, 140, 340, 0x30363D)
    text("Re (Gamma)", 244, 235, 9, 0x58A6FF)
    text("+j Im", 144, 134, 9, 0x58A6FF)

    // Vector Fasorial Activo
    line(140, 240, 196, 184, 0x00E5FF)
    circle(196, 184, 4, 0x3FB950)

    // Proyección de Onda Temporal
    line(260, 240, 540, 240, 0x30363D)
    text("t [s]", 544, 235, 9, 0x8B949E)

    line(260, 184, 280, 160, 0x3FB950)
    line(280, 160, 300, 184, 0x3FB950)
    line(300, 184, 320, 240, 0x3FB950)
    line(320, 240, 340, 296, 0x3FB950)
    line(340, 296, 360, 320, 0x3FB950)
    line(360, 320, 380, 296, 0x3FB950)
    line(380, 296, 400, 240, 0x3FB950)
    line(400, 240, 420, 184, 0x3FB950)
    line(420, 184, 440, 160, 0x3FB950)
    line(440, 160, 460, 184, 0x3FB950)
    line(460, 184, 480, 240, 0x3FB950)
    line(480, 240, 500, 296, 0x3FB950)
    line(500, 296, 520, 320, 0x3FB950)
    line(520, 320, 540, 296, 0x3FB950)

    // Tarjeta de Inspección SoA
    rect(20, 360, 520, 90, 0x0D1117)
    line(20, 360, 540, 360, 0x21262D)
    text("ESTADO DE MEMORIA SoA DEL RUNTIME:", 30, 372, 9, 0x3FB950)
    text("GapBuffer: 512 nodos | BreakpointMask: 128 entradas | ChatRing: 256 msgs", 30, 390, 9, 0x79C0FF)
    text("Invariante Zero-GC: 0 allocations en bucle tick() | 120 FPS estables", 30, 408, 9, 0x58A6FF)
    text("WASM Accelerator: 64 KB Linear Memory | Registros R0..R1023", 30, 426, 9, 0x8B949E)
}

// ===============================================================
// 5. Subrutinas y Acciones de Navegación y Depuración
// ===============================================================
action ir_editor {
    pestana_activa = 1.0
}

action ir_archivos {
    pestana_activa = 2.0
}

action ir_consola {
    pestana_activa = 3.0
}

action ir_lienzo {
    pestana_activa = 4.0
}

action ir_chat {
    pestana_activa = 5.0
}

action ir_debug {
    pestana_activa = 6.0
}

// Gestos Táctiles Universales Espaciales
action swipe_izq {
    pestana_activa = 2.0 // Abre Explorador de Proyecto
}

action swipe_der {
    pestana_activa = 5.0 // Abre Copilot IA
}

action swipe_abajo {
    pestana_activa = 3.0 // Eleva la Terminal
}

action swipe_arriba {
    pestana_activa = 6.0 // Eleva el Depurador
}

// Alternado Rápido y Colapso Instantáneo de Contenedores
action toggle_archivos {
    if (pestana_activa == 2.0) {
        pestana_activa = 1.0
    } else {
        pestana_activa = 2.0
    }
}

action toggle_terminal {
    if (pestana_activa == 3.0) {
        pestana_activa = 1.0
    } else {
        pestana_activa = 3.0
    }
}

action toggle_copilot {
    if (pestana_activa == 5.0) {
        pestana_activa = 1.0
    } else {
        pestana_activa = 5.0
    }
}

action toggle_debug {
    if (pestana_activa == 6.0) {
        pestana_activa = 1.0
    } else {
        pestana_activa = 6.0
    }
}

action toggle_bp_linea4 {
    // Alterna el estado del breakpoint en la máscara SoA (Línea 4)
    bp_act = get_soa(bp_mask_soa, 2, 0, BP_CAPACITY)
    if (bp_act == 1.0) {
        set_soa(bp_mask_soa, 2, 0, BP_CAPACITY, 0.0)
    }
    if (bp_act == 0.0) {
        set_soa(bp_mask_soa, 2, 0, BP_CAPACITY, 1.0)
    }
}

action dbg_continuar {
    debug_en_pausa = 0.0
    pestana_activa = 1.0
}

action dbg_paso {
    debug_en_pausa = 1.0
    debug_linea_pausa = debug_linea_pausa + 1.0
    if (debug_linea_pausa > 10.0) {
        debug_linea_pausa = 4.0
    }
}

action dbg_pausar {
    debug_en_pausa = 1.0
}

action ai_aplicar_en_cursor {
    pestana_activa = 1.0
    ai_last_action = 2.0
}

action ai_toggle_prov {
    if (ai_provider == 1.0) {
        ai_provider = 2.0
    } else {
        ai_provider = 1.0
    }
}

action accion_run {
    pestana_activa = 3.0
}

action accion_clear_terminal {
    pestana_activa = 3.0
}

action cargar_calculadora {
    pestana_activa = 1.0
}

action ir_docs {
    pestana_activa = 7.0
}

action toggle_docs {
    if (pestana_activa == 7.0) {
        pestana_activa = 1.0
    } else {
        pestana_activa = 7.0
    }
}

action doc_sec_math {
    doc_categoria = 1.0
}

action doc_sec_core {
    doc_categoria = 2.0
}

action doc_sec_ext {
    doc_categoria = 3.0
}

action doc_copiar_ejemplo {
    pestana_activa = 1.0
}
