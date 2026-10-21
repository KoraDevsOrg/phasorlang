import "lib/ui_spatial_main.ph"
import "lib/ui_window.ph"

signal t_test = 0.0

screen main {
    t_test = t_test + 1.0
    if (t_test <= 1.0) {
        spatial_main_init(3600.0, 2400.0, 80.0)
    } else { 1.0 }

    sw = R250
    sh = R251
    if (sw < 200.0) { sw = 800.0 } else { 1.0 }
    if (sh < 200.0) { sh = 600.0 } else { 1.0 }

    spatial_main_render(sw, sh)
    render_window_frame(40.0, 60.0, 400.0, 300.0, sw, sh)
    
    hx = spatial_world_to_screen_x(40.0, 400.0, sw)
    hy = spatial_world_to_screen_y(60.0, 300.0, sh)
    text("Editor de Codigo", hx + 12.0, hy + 8.0, 10, 0x58A6FF)
}
