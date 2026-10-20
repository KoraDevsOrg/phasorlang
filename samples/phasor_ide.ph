// ===============================================================================
// CHRONOS IDE — SCRIPT PRINCIPAL AUTOHOSPEDADO, RECURSIVO Y ZERO-GC (samples/phasor_ide.ph)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Entorno de Desarrollo 100% Autohospedado (Self-Hosted) en Memoria Contigua SoA
// Topología Unificada de 6 Ventanas: Desktop Docking 8D vs Mobile Snap 100%
// ===============================================================================

import "lib/ui_ide_menu.ph"
import "lib/file_explorer.ph"
import "lib/color.ph"
import "lib/ui.ph"
import "lib/view.ph"
import "lib/barge_in_assistant.ph"
import "lib/tts_speech.ph"
import "lib/procedural_video.ph"

// -------------------------------------------------------------------------------
// 1. ESTRUCTURAS DE MEMORIA PLANA SOA PARA EL KERNEL DEL IDE (ZERO-GC)
// -------------------------------------------------------------------------------
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

struct OutStreamNode {
    char_code: Float,
    stream_idx: Float,
    is_flushed: Float
}

struct ChatMessageNode {
    role: Float,        // 1.0=Usuario, 2.0=Gemini Cloud Pro, 3.0=Local SLM
    status: Float,      // 0.0=Inactivo, 1.0=Pensando, 2.0=Listo
    token_count: Float
}

// -------------------------------------------------------------------------------
// 2. PREASIGNACIÓN CONTIGUA EN EL HEAP PLANO SOA (CAPACIDAD DE 64 KB)
// -------------------------------------------------------------------------------
EDITOR_CAPACITY = 512
gap_buffer = alloc_soa(3, EDITOR_CAPACITY)

BP_CAPACITY = 128
bp_mask_soa = alloc_soa(3, BP_CAPACITY)

OUT_CAPACITY = 512
out_stream = alloc_soa(3, OUT_CAPACITY)

CHAT_CAPACITY = 256
chat_ring = alloc_soa(3, CHAT_CAPACITY)

// Inicialización de Breakpoints persistentes en la máscara SoA
// BP 0: Línea 4 (PC=0x0012) - Activo (1.0)
set_soa(bp_mask_soa, 0, 0, BP_CAPACITY, 4.0)
set_soa(bp_mask_soa, 1, 0, BP_CAPACITY, 18.0)
set_soa(bp_mask_soa, 2, 0, BP_CAPACITY, 1.0)

// BP 1: Línea 7 (PC=0x002B) - Activo (1.0)
set_soa(bp_mask_soa, 0, 1, BP_CAPACITY, 7.0)
set_soa(bp_mask_soa, 1, 1, BP_CAPACITY, 43.0)
set_soa(bp_mask_soa, 2, 1, BP_CAPACITY, 1.0)

// Inicialización del OutStream y ChatRing
set_soa(out_stream, 0, 0, OUT_CAPACITY, 0.0)
set_soa(out_stream, 1, 0, OUT_CAPACITY, 0.0)
set_soa(out_stream, 2, 0, OUT_CAPACITY, 1.0)

set_soa(chat_ring, 0, 0, CHAT_CAPACITY, 2.0) // Gemini Cloud
set_soa(chat_ring, 1, 0, CHAT_CAPACITY, 2.0) // Listo
set_soa(chat_ring, 2, 0, CHAT_CAPACITY, 120.0)

// -------------------------------------------------------------------------------
// 3. SEÑALES REACTIVAS DE HARDWARE Y TIEMPO REAL
// -------------------------------------------------------------------------------
signal t_global_ide = 0.0
signal ide_render_fps = 120.0
signal ide_pvm_latency_us = 16.0

// -------------------------------------------------------------------------------
// 4. PANTALLA PRINCIPAL DEL IDE (100% RECURSIVA & AUTOHOSPEDADA A 120 FPS)
// -------------------------------------------------------------------------------
screen main {
    cls(0x0D1117)
    t_global_ide = t_global_ide + 1.0

    // Captura los registros de hardware virtual inyectados por el host (R250 y R251)
    vw = R250
    vh = R251

    // Clamping de seguridad para viewports iniciales mínimos
    if (vw < 240.0) { vw = 800.0 }
    if (vh < 240.0) { vh = 600.0 }

    // Renderiza el espacio de trabajo modular de 6 ventanas ortogonales
    render_ide_workspace(vw, vh, t_global_ide)
}

// -------------------------------------------------------------------------------
// 5. SUB-PANTALLA DE LIVE PREVIEW DESACOPLADA (<s>2 A 120 FPS)
// -------------------------------------------------------------------------------
screen preview {
    cls(0x070B12)

    // Cuadrícula sutil del escenario neutro
    line(40.0, 60.0, 40.0, 440.0, 0x101620)
    line(140.0, 60.0, 140.0, 440.0, 0x101620)
    line(240.0, 60.0, 240.0, 440.0, 0x101620)
    line(340.0, 60.0, 340.0, 440.0, 0x101620)
    line(440.0, 60.0, 440.0, 440.0, 0x101620)

    // Título de Live Preview
    text("CHRONOS LIVE PREVIEW — 120 FPS ZERO-GC", 20.0, 20.0, 11, 0x58A6FF)
    text("Lienzo de Ejecución Hot-Reloading Desacoplado", 20.0, 36.0, 9, 0x8B949E)

    // Proyección fasorial en tiempo real
    cx = 140.0
    cy = 240.0
    circle(cx, cy, 80.0, 0x1F6FEB)
    circle(cx, cy, 40.0, 0x238636)
    line(cx - 80.0, cy, cx + 80.0, cy, 0x30363D)
    line(cx, cy - 80.0, cx, cy + 80.0, 0x30363D)

    // Vector activo
    ang = t_global_ide * 0.05
    fx = cx + (65.0 * cos(ang))
    fy = cy - (65.0 * sin(ang))
    line(cx, cy, fx, fy, 0x00E5FF)
    circle(fx, fy, 4.0, 0x3FB950)

    // Proyección de onda senoidal temporal
    tx_start = 260.0
    tx_end = 540.0
    line(tx_start, cy, tx_end, cy, 0x30363D)
    text("t [s]", tx_end + 5.0, cy - 4.0, 9, 0x8B949E)

    px = tx_start
    while (px < tx_end) {
        wave_y = cy + (sin((px - tx_start) * 0.08 - (t_global_ide * 0.08)) * 32.0)
        circle(px, wave_y, 1.5, 0x3FB950)
        px = px + 6.0
    }

    // Tarjeta de telemetría de memoria SoA
    rect(20.0, 360.0, 520.0, 85.0, 0x0D1117)
    line(20.0, 360.0, 540.0, 360.0, 0x21262D)
    text("ESTADO DEL KERNEL PVM:", 30.0, 374.0, 9, 0x3FB950)
    text("GapBuffer: 512 nodos | BreakpointMask: 128 entradas | ChatRing: 256 msgs", 30.0, 392.0, 9, 0x79C0FF)
    text("Zero-GC: 0 allocations en bucle tick() | 120 FPS estables sostenidos", 30.0, 410.0, 9, 0x58A6FF)
    text("WASM Accelerator: 64 KB Linear Memory SoA | Registros R0..R255", 30.0, 428.0, 9, 0x8B949E)
}

// -------------------------------------------------------------------------------
// 6. SUB-PANTALLA DEDICADA DEL EXPLORADOR DE PROYECTOS (<s>1 A 120 FPS)
// -------------------------------------------------------------------------------
screen explorer_screen {
    cls(0x090D13)
    vw = R250
    vh = R251
    if (vw < 240.0) { vw = 480.0 }
    if (vh < 240.0) { vh = 600.0 }
    file_explorer.render(0.0, 0.0, vw, vh)
}

// -------------------------------------------------------------------------------
// 7. SUB-PANTALLA DEDICADA DE EDITOR & DOCS PHASORLANG (<s>2 A 120 FPS)
// -------------------------------------------------------------------------------
screen editor_screen {
    cls(0x0D1117)
    vw = R250
    vh = R251
    if (vw < 240.0) { vw = 680.0 }
    if (vh < 240.0) { vh = 600.0 }
    render_window_editor(0.0, 0.0, vw, vh, t_global_ide)
}

// -------------------------------------------------------------------------------
// 8. SUB-PANTALLA DEDICADA DEL DEPURADOR PVM & REGISTROS SOA (<s>3 A 120 FPS)
// -------------------------------------------------------------------------------
screen debugger_screen {
    cls(0x0B0E14)
    vw = R250
    vh = R251
    if (vw < 240.0) { vw = 560.0 }
    if (vh < 240.0) { vh = 600.0 }
    render_window_debugger(0.0, 0.0, vw, vh)
}

// -------------------------------------------------------------------------------
// 9. SUB-PANTALLA DEDICADA DE TERMINAL INTERACTIVA & CLI (<s>4 A 120 FPS)
// -------------------------------------------------------------------------------
screen terminal_screen {
    cls(0x080B10)
    vw = R250
    vh = R251
    if (vw < 240.0) { vw = 560.0 }
    if (vh < 240.0) { vh = 600.0 }
    render_window_terminal(0.0, 0.0, vw, vh)
}

// -------------------------------------------------------------------------------
// 10. SUB-PANTALLA DEDICADA DE COPILOT IA & AVATAR REACTIVO (<s>5 A 120 FPS)
// -------------------------------------------------------------------------------
screen ai_screen {
    cls(0x111620)
    vw = R250
    vh = R251
    if (vw < 240.0) { vw = 560.0 }
    if (vh < 240.0) { vh = 600.0 }
    render_window_ai(0.0, 0.0, vw, vh, t_global_ide)
}


