// Test Interactivo de Hito 1: Fondo Toroidal + Ventana Arrastrable
import "lib/ui_spatial_main.ph"
import "lib/ui_window.ph"

signal t_sim = 0.0
signal win1_x = 100.0
signal win1_y = 100.0
signal win1_w = 400.0
signal win1_h = 280.0

signal drag_active = 0.0
signal drag_ox = 0.0
signal drag_oy = 0.0

screen main {
    t_sim = t_sim + 1.0
    if (t_sim <= 1.0) {
        spatial_main_init(3600.0, 2400.0, 80.0)
    } else { 1.0 }

    sw = R250
    sh = R251
    mx = R252
    my = R253
    pd = R254

    if (sw < 200.0) { sw = 800.0 } else { 1.0 }
    if (sh < 200.0) { sh = 600.0 } else { 1.0 }

    // Interacción
    pan_x = spatial_main_get_pan_x()
    pan_y = spatial_main_get_pan_y()

    if (pd == 1.0) {
        if (drag_active == 1.0) {
            // Arrastrando ventana 1
            scr_x = mx - drag_ox
            scr_y = my - drag_oy
            win1_x = scr_x - pan_x
            win1_y = scr_y - pan_y
        } else {
            // Verificar si clic en barra de título
            hit = window_hit_title(win1_x, win1_y, win1_w, win1_h, sw, sh, mx, my)
            if (hit == 1.0) {
                drag_active = 1.0
                hx = spatial_world_to_screen_x(win1_x, win1_w, sw)
                hy = spatial_world_to_screen_y(win1_y, win1_h, sh)
                drag_ox = mx - hx
                drag_oy = my - hy
            } else {
                // Verificar si clic en cuerpo
                hit_body = window_hit_body(win1_x, win1_y, win1_w, win1_h, sw, sh, mx, my)
                if (hit_body == 0.0) {
                    spatial_main_handle_input(mx, my, pd, 1.0)
                } else {
                    1.0
                }
            }
        }
    } else {
        drag_active = 0.0
        spatial_main_handle_input(mx, my, 0.0, 0.0)
    }

    // Render del fondo toroidal
    spatial_main_render(sw, sh)

    // Render de la ventana
    render_window_frame(win1_x, win1_y, win1_w, win1_h, sw, sh)
    hx = spatial_world_to_screen_x(win1_x, win1_w, sw)
    hy = spatial_world_to_screen_y(win1_y, win1_h, sh)
    text("Editor de Codigo (Hito 1)", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
}
