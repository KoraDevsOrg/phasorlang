// Grado 3: Las 4 Subpantallas del Chronos IDE construidas con componentes Grado 1 y 2
import "lib/core/primitives.ph"
import "lib/ui/label.ph"
import "lib/ui/button.ph"
import "lib/spatial/gesture_lock.ph"

render_card_shell(title_id, x, y, w, h, hdr_col) = {
    prim_box(x, y, w, h, 0x0D1117)
    prim_box(x, y, w, 26.0, hdr_col)
    prim_stroke(x, y, w, h, 0x30363D)
    ui_label(title_id, x + 10.0, y + 17.0, 11.0, 0xFFFFFF)
}

screen_editor_view(x, y, w, h) = {
    render_card_shell("📝 Screen 1: Editor (.ph)", x, y, w, h, 0x162234)
    ui_button("Plantilla", x + 10.0, y + 32.0, 68.0, 22.0, 0x1F6FEB, 0x58A6FF, 0xFFFFFF, 9.0)
    ui_button("Compilar", x + 84.0, y + 32.0, 68.0, 22.0, 0x238636, 0x3FB950, 0xFFFFFF, 9.0)

    prim_box(x + 8.0, y + 60.0, w - 16.0, h - 70.0, 0x090D13)
    ui_label("// Arquitectura BOM por Capas", x + 16.0, y + 80.0, 10.0, 0x8B949E)
    ui_label("import \"lib/ui/hud_topbar.ph\"", x + 16.0, y + 98.0, 10.0, 0x79C0FF)
    ui_label("import \"lib/ui/hud_dpad.ph\"", x + 16.0, y + 116.0, 10.0, 0x79C0FF)
    ui_label("signal frecuencia = 60.0", x + 16.0, y + 134.0, 10.0, 0x3FB950)
    ui_label("screen main { render_ide() }", x + 16.0, y + 152.0, 10.0, 0xFFA657)
}

screen_explorer_view(x, y, w, h) = {
    render_card_shell("📁 Screen 2: Explorador (BOM)", x, y, w, h, 0x14261C)
    ui_label("PROYECTO: SketchWarePro [Phasor]", x + 12.0, y + 46.0, 10.0, 0x3FB950)
    ui_label("v lib/core/ (Grado 0)", x + 14.0, y + 68.0, 10.0, 0xC9D1D9)
    ui_label("   • primitives.ph", x + 22.0, y + 86.0, 10.0, 0x58A6FF)
    ui_label("v lib/ui/ (Grado 1 & 2)", x + 14.0, y + 106.0, 10.0, 0xC9D1D9)
    ui_label("   • label.ph  |  button.ph", x + 22.0, y + 124.0, 10.0, 0x58A6FF)
    ui_label("   • hud_topbar.ph  |  hud_dpad.ph", x + 22.0, y + 142.0, 10.0, 0x58A6FF)
    ui_label("v lib/screens/ (Grado 3)", x + 14.0, y + 162.0, 10.0, 0xC9D1D9)
    ui_label("   • ide_screens.ph", x + 22.0, y + 180.0, 10.0, 0x3FB950)
}

screen_preview_view(x, y, w, h, t_phase) = {
    render_card_shell("🔬 Screen 3: Live Preview PVM", x, y, w, h, 0x261B30)
    cx = x + (w * 0.5)
    cy = y + (h * 0.54)
    r = 68.0
    circle(cx, cy, r, 0x161B22)
    line(cx - r, cy, cx + r, cy, 0x30363D)
    line(cx, cy - r, cx, cy + r, 0x30363D)
    vx = cx + (cos(t_phase) * r * 0.85)
    vy = cy - (sin(t_phase) * r * 0.85)
    line(cx, cy, vx, vy, 0x3FB950)
    circle(vx, vy, 5.0, 0x58A6FF)
    ui_label("120 FPS Zero-GC | Oscilador Activo", x + 14.0, y + h - 14.0, 10.0, 0x3FB950)
}

screen_terminal_view(x, y, w, h) = {
    render_card_shell("🧠 Screen 4: Memoria SoA & Terminal", x, y, w, h, 0x2B1D14)
    ui_label("> [PVM] Arquitectura BOM por Grados activa", x + 12.0, y + 48.0, 10.0, 0x3FB950)
    ui_label("> [Torus] Wrap-around 2x2 con Axis-Lock", x + 12.0, y + 68.0, 10.0, 0x58A6FF)
    ui_label("> [Heap] 0 Bytes asignados por frame", x + 12.0, y + 88.0, 10.0, 0xC9D1D9)
}
