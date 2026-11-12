// ===============================================================================
// LIB/UI_SPATIAL_MAIN.PH — ESPACIO TOROIDAL 2D CONTINUO (MÓVIL + ESCRITORIO)
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Topología: Toroide T^2 = S^1 x S^1 con Wrap-Around Infinito en 4 Direcciones
// Invariante Estricto: 0 bytes en Heap, bucles deterministas a 120 FPS Zero-GC
// ===============================================================================

// -------------------------------------------------------------------------------
// 1. VARIABLES GLOBALES DE ESTADO DEL ESPACIO TOROIDAL
// -------------------------------------------------------------------------------
signal spatial_pan_x = 0.0
signal spatial_pan_y = 0.0
signal spatial_target_x = 0.0
signal spatial_target_y = 0.0
signal spatial_is_panning = 0.0
signal spatial_anchor_mx = 0.0
signal spatial_anchor_my = 0.0
signal spatial_anchor_pan_x = 0.0
signal spatial_anchor_pan_y = 0.0

// Dimensiones del universo toroidal y celdas (2x2 cuadrantes por defecto)
signal spatial_univ_w = 1600.0
signal spatial_univ_h = 1200.0
signal spatial_cell_w = 800.0
signal spatial_cell_h = 600.0
signal spatial_grid_step = 64.0
signal spatial_sector_col = 0.0
signal spatial_sector_row = 0.0

// Modo de vista: 0=Auto, 1=Forzar Móvil (1 pantalla enfocada), 2=Forzar Escritorio
signal spatial_view_mode = 0.0

signal spatial_bg_color = 0x090D13
signal spatial_grid_color = 0x161F2E
signal spatial_star_color = 0x30363D

// Buffer SoA de Telemetría del Fondo Espacial (10 campos x 1 entidad)
spatial_main_soa = alloc_soa(10, 1)

// -------------------------------------------------------------------------------
// 2. INICIALIZACIÓN Y SINCRONIZACIÓN DE GEOMETRÍA TOROIDAL
// -------------------------------------------------------------------------------
spatial_main_init(univ_w, univ_h, grid_step) = {
    uw = univ_w
    if (uw < 480.0) { uw = 1600.0 } else { 1.0 }
    uh = univ_h
    if (uh < 480.0) { uh = 1200.0 } else { 1.0 }
    gs = grid_step
    if (gs < 20.0) { gs = 64.0 } else { 1.0 }

    spatial_univ_w = uw
    spatial_univ_h = uh
    spatial_cell_w = uw * 0.5
    spatial_cell_h = uh * 0.5
    spatial_grid_step = gs
    spatial_pan_x = 0.0
    spatial_pan_y = 0.0
    spatial_target_x = 0.0
    spatial_target_y = 0.0
    spatial_is_panning = 0.0

    set_soa(spatial_main_soa, 0, 0, 1, 0.0)
    set_soa(spatial_main_soa, 1, 0, 1, 0.0)
    set_soa(spatial_main_soa, 7, 0, 1, uw)
    set_soa(spatial_main_soa, 8, 0, 1, uh)
    set_soa(spatial_main_soa, 9, 0, 1, gs)
    1.0
}

spatial_is_mobile_view(sw) = {
    mob = 0.0
    if (spatial_view_mode == 1.0) {
        mob = 1.0
    } else {
        if (spatial_view_mode == 2.0) {
            mob = 0.0
        } else {
            if (sw < 768.0) { mob = 1.0 } else { mob = 0.0 }
        }
    }
    mob
}

// Ajusta el tamaño de celda del toroide según el modo (Celular vs Escritorio)
spatial_sync_topology(sw, sh) = {
    mob = spatial_is_mobile_view(sw)
    if (mob == 1.0) {
        cw = sw
        ch = sh
        uw = cw * 2.0
        uh = ch * 2.0
        if (abs(spatial_univ_w - uw) > 1.0) {
            spatial_cell_w = cw
            spatial_cell_h = ch
            spatial_univ_w = uw
            spatial_univ_h = uh
            spatial_target_x = 0.0 - (spatial_sector_col * cw)
            spatial_target_y = 0.0 - (spatial_sector_row * ch)
            spatial_pan_x = spatial_target_x
            spatial_pan_y = spatial_target_y
        } else { 1.0 }
    } else {
        uw = 1680.0
        uh = 1040.0
        if (abs(spatial_univ_w - uw) > 1.0) {
            spatial_univ_w = uw
            spatial_univ_h = uh
            spatial_cell_w = uw * 0.5
            spatial_cell_h = uh * 0.5
            spatial_pan_x = 0.0
            spatial_pan_y = 0.0
            spatial_target_x = 0.0
            spatial_target_y = 0.0
        } else { 1.0 }
    }
    1.0
}

// -------------------------------------------------------------------------------
// 3. MATEMÁTICA PURA TOROIDAL: WRAPAROUND MODULAR BIDIMENSIONAL (T^2)
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

// Periodic Boundary Condition (PBC): Distancia continua en [-max_size/2, +max_size/2]
spatial_main_wrap_pbc(val, max_size) = {
    m = val % max_size
    if (m < 0.0) { m = m + max_size } else { 1.0 }
    half = max_size * 0.5
    if (m > half) { m = m - max_size } else { 1.0 }
    m
}

// Proyección World -> Screen con Wraparound Toroidal continuo (sin solapamientos)
spatial_world_to_screen_x(world_x, obj_w, viewport_w) = {
    uw = spatial_univ_w
    if (uw < 300.0) { uw = 1600.0 } else { 1.0 }
    raw_x = world_x + spatial_pan_x
    m = raw_x % uw
    if (m < 0.0) { m = m + uw } else { 1.0 }
    if (m >= (uw - 12.0)) {
        m = m - uw
    } else { 1.0 }
    m
}

spatial_world_to_screen_y(world_y, obj_h, viewport_h) = {
    uh = spatial_univ_h
    if (uh < 300.0) { uh = 1200.0 } else { 1.0 }
    raw_y = world_y + spatial_pan_y
    m = raw_y % uh
    if (m < 0.0) { m = m + uh } else { 1.0 }
    if (m >= (uh - 12.0)) {
        m = m - uh
    } else { 1.0 }
    m
}

// -------------------------------------------------------------------------------
// 4. NAVEGACIÓN POR CUADRANTES TOROIDALES (BOTONES D-PAD Y SWIPE MAGNÉTICO)
// -------------------------------------------------------------------------------
spatial_step_sector(dcol, drow) = {
    nc = (spatial_sector_col + dcol) % 2.0
    if (nc < 0.0) { nc = nc + 2.0 } else { 1.0 }
    nr = (spatial_sector_row + drow) % 2.0
    if (nr < 0.0) { nr = nr + 2.0 } else { 1.0 }
    spatial_sector_col = nc
    spatial_sector_row = nr

    // Calcular desplazamiento continuo más corto en el toroide
    desired_x = 0.0 - (nc * spatial_cell_w)
    desired_y = 0.0 - (nr * spatial_cell_h)
    diff_x = spatial_main_wrap_pbc(desired_x - spatial_pan_x, spatial_univ_w)
    diff_y = spatial_main_wrap_pbc(desired_y - spatial_pan_y, spatial_univ_h)

    spatial_target_x = spatial_pan_x + diff_x
    spatial_target_y = spatial_pan_y + diff_y
    1.0
}

spatial_go_sector(col, row) = {
    nc = col % 2.0
    if (nc < 0.0) { nc = nc + 2.0 } else { 1.0 }
    nr = row % 2.0
    if (nr < 0.0) { nr = nr + 2.0 } else { 1.0 }
    spatial_sector_col = nc
    spatial_sector_row = nr

    desired_x = 0.0 - (nc * spatial_cell_w)
    desired_y = 0.0 - (nr * spatial_cell_h)
    diff_x = spatial_main_wrap_pbc(desired_x - spatial_pan_x, spatial_univ_w)
    diff_y = spatial_main_wrap_pbc(desired_y - spatial_pan_y, spatial_univ_h)

    spatial_target_x = spatial_pan_x + diff_x
    spatial_target_y = spatial_pan_y + diff_y
    1.0
}

// Actualiza interpolación exponencial suave hacia el objetivo toroidal (120 FPS Zero-GC)
spatial_main_tick(sw) = {
    if (spatial_is_panning == 0.0) {
        mob = spatial_is_mobile_view(sw)
        if (mob == 1.0) {
            err_x = spatial_target_x - spatial_pan_x
            err_y = spatial_target_y - spatial_pan_y
            if ((abs(err_x) > 0.4) || (abs(err_y) > 0.4)) {
                spatial_pan_x = spatial_pan_x + (err_x * 0.22)
                spatial_pan_y = spatial_pan_y + (err_y * 0.22)
            } else {
                spatial_pan_x = spatial_main_wrap_coord(spatial_target_x, spatial_univ_w)
                spatial_pan_y = spatial_main_wrap_coord(spatial_target_y, spatial_univ_h)
                spatial_target_x = spatial_pan_x
                spatial_target_y = spatial_pan_y
            }
        } else {
            spatial_pan_x = spatial_main_wrap_coord(spatial_pan_x, spatial_univ_w)
            spatial_pan_y = spatial_main_wrap_coord(spatial_pan_y, spatial_univ_h)
        }
    } else { 1.0 }
    set_soa(spatial_main_soa, 0, 0, 1, spatial_pan_x)
    set_soa(spatial_main_soa, 1, 0, 1, spatial_pan_y)
    1.0
}

// -------------------------------------------------------------------------------
// 5. MÁQUINA DE ESTADOS DE ARRASTRE Y SWIPE TOROIDAL
// -------------------------------------------------------------------------------
spatial_main_handle_input(mx, my, mouse_down, can_pan_main, sw) = {
    mob = spatial_is_mobile_view(sw)
    if (mouse_down == 1.0) {
        if (spatial_is_panning == 1.0) {
            delta_x = mx - spatial_anchor_mx
            delta_y = my - spatial_anchor_my
            new_px = spatial_anchor_pan_x + delta_x
            new_py = spatial_anchor_pan_y + delta_y

            spatial_pan_x = spatial_main_wrap_coord(new_px, spatial_univ_w)
            spatial_pan_y = spatial_main_wrap_coord(new_py, spatial_univ_h)
            spatial_target_x = spatial_pan_x
            spatial_target_y = spatial_pan_y
        } else {
            if (can_pan_main == 1.0) {
                spatial_is_panning = 1.0
                spatial_anchor_mx = mx
                spatial_anchor_my = my
                spatial_anchor_pan_x = spatial_pan_x
                spatial_anchor_pan_y = spatial_pan_y
            } else { 1.0 }
        }
    } else {
        if (spatial_is_panning == 1.0) {
            spatial_is_panning = 0.0
            // En modo celular, al soltar el dedo hace snap magnético al cuadrante más cercano
            if (mob == 1.0) {
                swipe_dx = mx - spatial_anchor_mx
                swipe_dy = my - spatial_anchor_my
                dcol = 0.0
                drow = 0.0
                if (swipe_dx < -45.0) { dcol = 1.0 } else {
                    if (swipe_dx > 45.0) { dcol = -1.0 } else { 1.0 }
                }
                if (swipe_dy < -45.0) { drow = 1.0 } else {
                    if (swipe_dy > 45.0) { drow = -1.0 } else { 1.0 }
                }
                if ((dcol != 0.0) || (drow != 0.0)) {
                    spatial_step_sector(dcol, drow)
                } else {
                    spatial_go_sector(spatial_sector_col, spatial_sector_row)
                }
            } else { 1.0 }
        } else { 1.0 }
    }
    spatial_is_panning
}

// -------------------------------------------------------------------------------
// 6. RENDERIZADO DEL FONDO ESPACIAL TOROIDAL (120 FPS ZERO-GC)
// -------------------------------------------------------------------------------
spatial_main_render(viewport_w, viewport_h) = {
    cls(spatial_bg_color)

    vw = viewport_w
    vh = viewport_h
    gs = spatial_grid_step
    col_grid = spatial_grid_color
    col_star = spatial_star_color

    off_x = spatial_pan_x % gs
    if (off_x < 0.0) { off_x = off_x + gs } else { 1.0 }
    off_y = spatial_pan_y % gs
    if (off_y < 0.0) { off_y = off_y + gs } else { 1.0 }

    gx = off_x - gs
    while (gx < (vw + gs)) {
        line(gx, 32.0, gx, vh - 24.0, col_grid)
        gx = gx + gs
    }

    gy = off_y - gs
    while (gy < (vh - 24.0)) {
        if (gy >= 32.0) {
            line(0.0, gy, vw, gy, col_grid)
        } else { 1.0 }
        gy = gy + gs
    }

    sy = off_y - gs
    while (sy < (vh - 24.0)) {
        if (sy >= 32.0) {
            sx = off_x - gs
            while (sx < (vw + gs)) {
                circle(sx, sy, 1.3, col_star)
                sx = sx + gs
            }
        } else { 1.0 }
        sy = sy + gs
    }

    1.0
}

// -------------------------------------------------------------------------------
// 7. GETTERS Y ACCESO EXTERNO O(1)
// -------------------------------------------------------------------------------
spatial_main_get_pan_x() = { spatial_pan_x }
spatial_main_get_pan_y() = { spatial_pan_y }
spatial_main_is_active() = { spatial_is_panning }
spatial_main_get_univ_w() = { spatial_univ_w }
spatial_main_get_univ_h() = { spatial_univ_h }

spatial_main_set_pan(px, py) = {
    spatial_pan_x = spatial_main_wrap_coord(px, spatial_univ_w)
    spatial_pan_y = spatial_main_wrap_coord(py, spatial_univ_h)
    spatial_target_x = spatial_pan_x
    spatial_target_y = spatial_pan_y
    1.0
}

spatial_main_pan(dx, dy) = {
    spatial_pan_x = spatial_main_wrap_coord(spatial_pan_x + dx, spatial_univ_w)
    spatial_pan_y = spatial_main_wrap_coord(spatial_pan_y + dy, spatial_univ_h)
    spatial_target_x = spatial_pan_x
    spatial_target_y = spatial_pan_y
    1.0
}
