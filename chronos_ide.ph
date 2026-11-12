// Grado 4: Orquestador Raíz Chronos IDE (Ensamblaje de Lista de Materiales)
import "lib/core/primitives.ph"
import "lib/ui/hud_topbar.ph"
import "lib/ui/hud_dpad.ph"
import "lib/screens/ide_screens.ph"

signal phase_t = 0.0
signal prev_pd_root = 0.0

screen main {
    sw = R250
    sh = R251
    mx = R252
    my = R253
    pd = R254
    phase_t = phase_t + 0.04

    // 1. Detección de clics en HUD por flanco único (Edge-Trigger)
    hud_hit = 0.0
    if ((pd == 1.0) && (prev_pd_root == 0.0)) {
        h1 = topbar_handle_click(mx, my, sw, sh)
        h2 = dpad_handle_click(mx, my, sw, sh)
        if ((h1 == 1.0) || (h2 == 1.0)) { hud_hit = 1.0 } else { 1.0 }
    } else { 1.0 }
    prev_pd_root = pd

    // 2. Actualizar cámara toroidal con bloqueo de eje ortogonal
    torus_step(mx, my, pd, sw, sh, hud_hit)

    // 3. Limpiar lienzo una única vez por frame
    cls(0x070B12)

    mob = torus_is_mobile(sw)
    cw = sw
    ch = sh
    if (mob == 0.0) {
        cw = sw * 0.5
        ch = (sh - 34.0) * 0.5
    } else { 1.0 }

    uw = cw * 2.0
    uh = ch * 2.0

    // Proyección toroidal continua sin parpadeo
    x1 = prim_wrap(tor_pan_x + 6.0, uw)
    if (x1 > (uw - 20.0)) { x1 = x1 - uw } else { 1.0 }
    y1 = prim_wrap(tor_pan_y + 38.0, uh)
    if (y1 > (uh - 20.0)) { y1 = y1 - uh } else { 1.0 }

    x2 = prim_wrap(tor_pan_x + 6.0, uw)
    if (x2 > (uw - 20.0)) { x2 = x2 - uw } else { 1.0 }
    y2 = prim_wrap(tor_pan_y + ch + 38.0, uh)
    if (y2 > (uh - 20.0)) { y2 = y2 - uh } else { 1.0 }

    x3 = prim_wrap(tor_pan_x + cw + 6.0, uw)
    if (x3 > (uw - 20.0)) { x3 = x3 - uw } else { 1.0 }
    y3 = prim_wrap(tor_pan_y + 38.0, uh)
    if (y3 > (uh - 20.0)) { y3 = y3 - uh } else { 1.0 }

    x4 = prim_wrap(tor_pan_x + cw + 6.0, uw)
    if (x4 > (uw - 20.0)) { x4 = x4 - uw } else { 1.0 }
    y4 = prim_wrap(tor_pan_y + ch + 38.0, uh)
    if (y4 > (uh - 20.0)) { y4 = y4 - uh } else { 1.0 }

    win_w = cw - 12.0
    win_h = ch - 44.0
    if (mob == 0.0) { win_h = ch - 10.0 } else { 1.0 }

    // 4. Renderizar las 4 pantallas modulares
    screen_editor_view(x1, y1, win_w, win_h)
    screen_explorer_view(x2, y2, win_w, win_h)
    screen_preview_view(x3, y3, win_w, win_h, phase_t)
    screen_terminal_view(x4, y4, win_w, win_h)

    // 5. Renderizar HUD fijo encima
    topbar_render(sw)
    if (mob == 1.0) {
        dpad_render(sw, sh)
    } else { 1.0 }
}
