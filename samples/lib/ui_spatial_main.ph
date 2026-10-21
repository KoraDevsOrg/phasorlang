// ===============================================================================
// LIB/UI_SPATIAL_MAIN.PH — HITO 1: ESPACIO ESPACIAL TOROIDAL (KORADEVS DESKTOP)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Espacio Continuo 3D/Plano con Wraparound Toroidal Infinito
// Invariante Estricto: 0 bytes en Heap, bucles deterministas a 120 FPS Zero-GC
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. VARIABLES GLOBALES DE ESTADO DEL ESPACIO TOROIDAL
// -------------------------------------------------------------------------------
signal spatial_pan_x = 0.0
signal spatial_pan_y = 0.0
signal spatial_is_panning = 0.0
signal spatial_anchor_mx = 0.0
signal spatial_anchor_my = 0.0
signal spatial_anchor_pan_x = 0.0
signal spatial_anchor_pan_y = 0.0
signal spatial_univ_w = 3600.0
signal spatial_univ_h = 2400.0
signal spatial_grid_step = 80.0
signal spatial_bg_color = 0x090D13
signal spatial_grid_color = 0x161F2E
signal spatial_star_color = 0x30363D

// Buffer SoA de Respaldo y Telemetría del Fondo Espacial (10 campos x 1 entidad)
// [0]: pan_x, [1]: pan_y, [2]: is_panning, [3]: anchor_mx, [4]: anchor_my
// [5]: anchor_pan_x, [6]: anchor_pan_y, [7]: univ_w, [8]: univ_h, [9]: grid_step
spatial_main_soa = alloc_soa(10, 1)

// -------------------------------------------------------------------------------
// 2. INICIALIZACIÓN DEL ESPACIO TOROIDAL
// -------------------------------------------------------------------------------
spatial_main_init(univ_w, univ_h, grid_step) = {
    uw = univ_w
    if (uw < 800.0) { uw = 3600.0 } else { 1.0 }
    uh = univ_h
    if (uh < 600.0) { uh = 2400.0 } else { 1.0 }
    gs = grid_step
    if (gs < 20.0) { gs = 80.0 } else { 1.0 }

    spatial_univ_w = uw
    spatial_univ_h = uh
    spatial_grid_step = gs
    spatial_pan_x = 0.0
    spatial_pan_y = 0.0
    spatial_is_panning = 0.0
    spatial_anchor_mx = 0.0
    spatial_anchor_my = 0.0
    spatial_anchor_pan_x = 0.0
    spatial_anchor_pan_y = 0.0

    set_soa(spatial_main_soa, 0, 0, 1, 0.0)
    set_soa(spatial_main_soa, 1, 0, 1, 0.0)
    set_soa(spatial_main_soa, 2, 0, 1, 0.0)
    set_soa(spatial_main_soa, 3, 0, 1, 0.0)
    set_soa(spatial_main_soa, 4, 0, 1, 0.0)
    set_soa(spatial_main_soa, 5, 0, 1, 0.0)
    set_soa(spatial_main_soa, 6, 0, 1, 0.0)
    set_soa(spatial_main_soa, 7, 0, 1, uw)
    set_soa(spatial_main_soa, 8, 0, 1, uh)
    set_soa(spatial_main_soa, 9, 0, 1, gs)
    1.0
}

// -------------------------------------------------------------------------------
// 3. MATEMÁTICA PURA TOROIDAL: WRAPAROUND MODULAR BIDIMENSIONAL
// ((val % max) + max) % max garantiza un rango cerrado [0.0, max_size)
// -------------------------------------------------------------------------------
spatial_main_wrap_coord(val, max_size) = {
    res = val % max_size
    if (res < 0.0) {
        res = res + max_size
    } else {
        1.0
    }
    res
}

// -------------------------------------------------------------------------------
// Periodic Boundary Condition (PBC): Distancia continua en [-max_size/2, +max_size/2]
// Garantiza CERO saltos o parpadeos dentro del viewport visible
// -------------------------------------------------------------------------------
spatial_main_wrap_pbc(val, max_size) = {
    m = val % max_size
    if (m < 0.0) { m = m + max_size } else { 1.0 }
    half = max_size * 0.5
    if (m > half) { m = m - max_size } else { 1.0 }
    m
}

// -------------------------------------------------------------------------------
// 4. TRANSFORMACIÓN DE COORDENADAS MUNDO -> PANTALLA (ZERO FLICKER)
// Proyecta una posición de objeto (wx, wy) sobre el viewport (vw, vh)
// -------------------------------------------------------------------------------
spatial_world_to_screen_x(world_x, obj_w, viewport_w) = {
    uw = spatial_univ_w
    if (uw < 800.0) { uw = 3600.0 } else { 1.0 }
    raw_x = world_x + spatial_pan_x
    spatial_main_wrap_pbc(raw_x, uw)
}

spatial_world_to_screen_y(world_y, obj_h, viewport_h) = {
    uh = spatial_univ_h
    if (uh < 600.0) { uh = 2400.0 } else { 1.0 }
    raw_y = world_y + spatial_pan_y
    spatial_main_wrap_pbc(raw_y, uh)
}

// -------------------------------------------------------------------------------
// 5. MÁQUINA DE ESTADOS DE ARRASTRE DEL FONDO ESPACIAL (EXCLUSIVE PAN CAPTURE)
// can_pan_main: 1.0 si ningún elemento hijo (ventana/botón/scrollbar) tiene el foco
// -------------------------------------------------------------------------------
spatial_main_handle_input(mx, my, mouse_down, can_pan_main) = {
    if (mouse_down == 1.0) {
        if (spatial_is_panning == 1.0) {
            // Arrastre continuo en progreso
            delta_x = mx - spatial_anchor_mx
            delta_y = my - spatial_anchor_my
            new_px = spatial_anchor_pan_x + delta_x
            new_py = spatial_anchor_pan_y + delta_y

            spatial_pan_x = spatial_main_wrap_coord(new_px, spatial_univ_w)
            spatial_pan_y = spatial_main_wrap_coord(new_py, spatial_univ_h)

            set_soa(spatial_main_soa, 0, 0, 1, spatial_pan_x)
            set_soa(spatial_main_soa, 1, 0, 1, spatial_pan_y)
        } else {
            // Iniciar arrastre solo si el clic ocurrió fuera de las ventanas
            if (can_pan_main == 1.0) {
                spatial_is_panning = 1.0
                spatial_anchor_mx = mx
                spatial_anchor_my = my
                spatial_anchor_pan_x = spatial_pan_x
                spatial_anchor_pan_y = spatial_pan_y

                set_soa(spatial_main_soa, 2, 0, 1, 1.0)
                set_soa(spatial_main_soa, 3, 0, 1, mx)
                set_soa(spatial_main_soa, 4, 0, 1, my)
                set_soa(spatial_main_soa, 5, 0, 1, spatial_pan_x)
                set_soa(spatial_main_soa, 6, 0, 1, spatial_pan_y)
            } else {
                1.0
            }
        }
    } else {
        // Soltar mouse finaliza el arrastre
        if (spatial_is_panning == 1.0) {
            spatial_is_panning = 0.0
            set_soa(spatial_main_soa, 2, 0, 1, 0.0)
        } else {
            1.0
        }
    }
    spatial_is_panning
}

// -------------------------------------------------------------------------------
// 6. RENDERIZADO DEL FONDO ESPACIAL TOROIDAL (120 FPS ZERO-GC)
// Cuadrícula ortogonal y constelación de puntos de referencia continuos
// -------------------------------------------------------------------------------
spatial_main_render(viewport_w, viewport_h) = {
    // 1. Limpieza base del fondo espacial profundo
    cls(spatial_bg_color)

    vw = viewport_w
    vh = viewport_h
    gs = spatial_grid_step
    col_grid = spatial_grid_color
    col_star = spatial_star_color

    // Desplazamiento relativo para la cuadrícula infinita
    off_x = spatial_pan_x % gs
    if (off_x < 0.0) { off_x = off_x + gs } else { 1.0 }
    off_y = spatial_pan_y % gs
    if (off_y < 0.0) { off_y = off_y + gs } else { 1.0 }

    // 2. Líneas verticales continuas
    gx = off_x - gs
    while (gx < (vw + gs)) {
        line(gx, 48.0, gx, vh, col_grid)
        gx = gx + gs
    }

    // 3. Líneas horizontales continuas
    gy = off_y - gs
    while (gy < (vh + gs)) {
        if (gy >= 48.0) {
            line(0.0, gy, vw, gy, col_grid)
        } else {
            1.0
        }
        gy = gy + gs
    }

    // 4. Marcadores estelares discretos en las intersecciones (Sensación 3D espacial)
    sy = off_y - gs
    while (sy < (vh + gs)) {
        if (sy >= 48.0) {
            sx = off_x - gs
            while (sx < (vw + gs)) {
                circle(sx, sy, 1.5, col_star)
                sx = sx + gs
            }
        } else {
            1.0
        }
        sy = sy + gs
    }

    1.0
}

// -------------------------------------------------------------------------------
// 7. GETTERS DE TELEMETRÍA Y ACCESO EXTERNO O(1)
// -------------------------------------------------------------------------------
spatial_main_get_pan_x() = { spatial_pan_x }
spatial_main_get_pan_y() = { spatial_pan_y }
spatial_main_is_active() = { spatial_is_panning }
spatial_main_get_univ_w() = { spatial_univ_w }
spatial_main_get_univ_h() = { spatial_univ_h }

spatial_main_set_pan(px, py) = {
    spatial_pan_x = spatial_main_wrap_coord(px, spatial_univ_w)
    spatial_pan_y = spatial_main_wrap_coord(py, spatial_univ_h)
    set_soa(spatial_main_soa, 0, 0, 1, spatial_pan_x)
    set_soa(spatial_main_soa, 1, 0, 1, spatial_pan_y)
    1.0
}
