// Grado 2: Controlador Toroidal 2x2 — Prioriza botones internos; swipe desde bordes (22px) o D-Pad
import "lib/core/primitives.ph"

signal tor_col = 0.0
signal tor_row = 0.0
signal tor_pan_x = 0.0
signal tor_pan_y = 0.0
signal tor_target_x = 0.0
signal tor_target_y = 0.0

signal gest_active = 0.0
signal gest_start_x = 0.0
signal gest_start_y = 0.0
signal gest_axis = 0.0
signal gest_prev_pd = 0.0
signal force_mobile = 1.0

torus_is_mobile(sw) = {
    res = force_mobile
    if (sw >= 900.0) { res = 0.0 } else { 1.0 }
    res
}

torus_goto(col, row, cw, ch) = {
    c = col % 2.0
    if (c < 0.0) { c = c + 2.0 } else { 1.0 }
    r = row % 2.0
    if (r < 0.0) { r = r + 2.0 } else { 1.0 }
    tor_col = c
    tor_row = r
    tor_target_x = 0.0 - (c * cw)
    tor_target_y = 0.0 - (r * ch)
}

torus_step(mx, my, pd, sw, sh, hud_consumed) = {
    mob = torus_is_mobile(sw)
    cw = sw
    ch = sh
    if (mob == 0.0) {
        cw = sw * 0.5
        ch = (sh - 34.0) * 0.5
    } else { 1.0 }

    if (pd == 1.0) {
        if (gest_prev_pd == 0.0) {
            // En móvil: solo iniciar swipe toroidal si el dedo toca el margen lateral (<=24px o >=sw-24px)
            // Dejando todo el centro libre para botones, carpetas y menús del IDE
            edge_ok = 0.0
            if (mob == 0.0) { edge_ok = 1.0 } else { 1.0 }
            if ((mx <= 24.0) || (mx >= (sw - 24.0))) { edge_ok = 1.0 } else { 1.0 }

            if ((hud_consumed == 0.0) && (my > 34.0) && (edge_ok == 1.0)) {
                gest_active = 1.0
                gest_start_x = mx
                gest_start_y = my
                gest_axis = 0.0
            } else {
                gest_active = 0.0
            }
        } else {
            if (gest_active == 1.0) {
                dx = mx - gest_start_x
                dy = my - gest_start_y
                adx = prim_abs(dx)
                ady = prim_abs(dy)

                if ((gest_axis == 0.0) && ((adx > 14.0) || (ady > 14.0))) {
                    if (adx >= ady) {
                        gest_axis = 1.0
                    } else {
                        gest_axis = 2.0
                    }
                } else { 1.0 }

                if (gest_axis == 1.0) {
                    tor_pan_x = (0.0 - (tor_col * cw)) + dx
                    tor_pan_y = 0.0 - (tor_row * ch)
                } else {
                    if (gest_axis == 2.0) {
                        tor_pan_x = 0.0 - (tor_col * cw)
                        tor_pan_y = (0.0 - (tor_row * ch)) + dy
                    } else { 1.0 }
                }
            } else { 1.0 }
        }
    } else {
        if (gest_active == 1.0) {
            dx_end = mx - gest_start_x
            dy_end = my - gest_start_y
            if (gest_axis == 1.0) {
                if (dx_end < -40.0) {
                    torus_goto(tor_col + 1.0, tor_row, cw, ch)
                } else {
                    if (dx_end > 40.0) {
                        torus_goto(tor_col - 1.0, tor_row, cw, ch)
                    } else {
                        torus_goto(tor_col, tor_row, cw, ch)
                    }
                }
            } else {
                if (gest_axis == 2.0) {
                    if (dy_end < -40.0) {
                        torus_goto(tor_col, tor_row + 1.0, cw, ch)
                    } else {
                        if (dy_end > 40.0) {
                            torus_goto(tor_col, tor_row - 1.0, cw, ch)
                        } else {
                            torus_goto(tor_col, tor_row, cw, ch)
                        }
                    }
                } else {
                    torus_goto(tor_col, tor_row, cw, ch)
                }
            }
            gest_active = 0.0
            gest_axis = 0.0
        } else {
            tor_target_x = 0.0 - (tor_col * cw)
            tor_target_y = 0.0 - (tor_row * ch)
            err_x = tor_target_x - tor_pan_x
            err_y = tor_target_y - tor_pan_y
            if (prim_abs(err_x) < 1.0) {
                tor_pan_x = tor_target_x
            } else {
                tor_pan_x = tor_pan_x + (err_x * 0.32)
            }
            if (prim_abs(err_y) < 1.0) {
                tor_pan_y = tor_target_y
            } else {
                tor_pan_y = tor_pan_y + (err_y * 0.32)
            }
        }
    }
    gest_prev_pd = pd
}
