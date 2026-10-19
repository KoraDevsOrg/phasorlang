// ===============================================================
// LIB/LOWLEVEL_RENDER.PH — Transformaciones de Grupo SoA y Curvas Gamma(z)
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Streaming Directo Zero-GC, Álgebra Afín y Renderizado Atmosférico
// ===============================================================

// 1. Aproximación Continua de la Función Factorial Gamma(z) para z > 0
// Utiliza la aproximación analítica de Stirling / Nemes para suavidad procedural
gamma_approx(z) = {
    // Si z es muy pequeño, evitar singularidad en cero
    val_z = z
    if (val_z < 0.1) { val_z = 0.1 } else { 1.0 }

    // Stirling: Gamma(z) ~ sqrt(2*PI / z) * ((z/e) * sqrt(z * sinh(1/z)))^z
    // Versión simplificada ultra-rápida en punto flotante
    inv_z = 1.0 / val_z
    term = (val_z * 0.36787944117) // z / e
    sqrt_term = (6.28318530718 * inv_z) ^ 0.5
    
    // Potencia factorial: (z/e)^z
    pow_factor = term ^ val_z
    
    // Corrección de Stirling de primer orden: 1 + 1/(12*z)
    corr = 1.0 + (inv_z * 0.08333333333)
    
    sqrt_term * pow_factor * corr
}

// 2. Curva Factorial Normalizada de Densidad de Nube: D(t) = (t^(z-1) * e^-t) / Gamma(z)
gamma_density(t, z) = {
    if (t <= 0.0) {
        0.0
    } else {
        gz = gamma_approx(z)
        if (gz < 0.0001) { gz = 0.0001 } else { 1.0 }
        
        // t^(z-1) * e^(-t)
        pow_t = t ^ (z - 1.0)
        exp_neg = 2.71828182846 ^ (-t)
        (pow_t * exp_neg) / gz
    }
}

// ===============================================================
// 3. Transformaciones de Grupo SoA (Zero-GC Streaming)
// ===============================================================

// Traslación en lote de todas las entidades en el buffer SoA
soa_group_translate(soa_ptr, count, cap, tx, ty) = {
    i = 0.0
    while (i < count) {
        x = get_soa(soa_ptr, 0, i, cap)
        y = get_soa(soa_ptr, 1, i, cap)
        set_soa(soa_ptr, 0, i, cap, x + tx)
        set_soa(soa_ptr, 1, i, cap, y + ty)
        i = i + 1.0
    }
    1.0
}

// Rotación Fasorial en lote alrededor de un centro (cx, cy)
soa_group_rotate_phasor(soa_ptr, count, cap, cx, cy, theta_rad) = {
    cos_th = cos(theta_rad)
    sin_th = sin(theta_rad)
    i = 0.0
    while (i < count) {
        x = get_soa(soa_ptr, 0, i, cap) - cx
        y = get_soa(soa_ptr, 1, i, cap) - cy

        // Rotación fasorial ortogonal 2D
        new_x = (x * cos_th) - (y * sin_th)
        new_y = (x * sin_th) + (y * cos_th)

        set_soa(soa_ptr, 0, i, cap, new_x + cx)
        set_soa(soa_ptr, 1, i, cap, new_y + cy)
        i = i + 1.0
    }
    1.0
}

// Escalado uniforme en lote alrededor de un centro focal (cx, cy)
soa_group_scale(soa_ptr, count, cap, cx, cy, factor) = {
    i = 0.0
    while (i < count) {
        x = get_soa(soa_ptr, 0, i, cap)
        y = get_soa(soa_ptr, 1, i, cap)
        w = get_soa(soa_ptr, 3, i, cap)
        h = get_soa(soa_ptr, 4, i, cap)

        new_x = cx + ((x - cx) * factor)
        new_y = cy + ((y - cy) * factor)

        set_soa(soa_ptr, 0, i, cap, new_x)
        set_soa(soa_ptr, 1, i, cap, new_y)
        set_soa(soa_ptr, 3, i, cap, w * factor)
        set_soa(soa_ptr, 4, i, cap, h * factor)
        i = i + 1.0
    }
    1.0
}

// Transformación afín combinada en una sola pasada (Traslación + Rotación + Escala)
soa_transform_group(soa_ptr, count, cap, tx, ty, factor, theta_rad) = {
    cos_th = cos(theta_rad)
    sin_th = sin(theta_rad)
    i = 0.0
    while (i < count) {
        x = get_soa(soa_ptr, 0, i, cap)
        y = get_soa(soa_ptr, 1, i, cap)
        w = get_soa(soa_ptr, 3, i, cap)
        h = get_soa(soa_ptr, 4, i, cap)

        // Escala
        sx = x * factor
        sy = y * factor

        // Rotación fasorial
        rx = (sx * cos_th) - (sy * sin_th)
        ry = (sx * sin_th) + (sy * cos_th)

        // Traslación final
        set_soa(soa_ptr, 0, i, cap, rx + tx)
        set_soa(soa_ptr, 1, i, cap, ry + ty)
        set_soa(soa_ptr, 3, i, cap, w * factor)
        set_soa(soa_ptr, 4, i, cap, h * factor)

        i = i + 1.0
    }
    1.0
}

// ===============================================================
// 4. Renderizado Procedural de Nubes y Atmósferas con Curvas Gamma(z)
// ===============================================================

// Renderiza un cúmulo de nubes esponjoso donde la dispersión radial sigue Gamma(z)
render_cloud_gamma(cx, cy, r_base, z_param, hz_tinte) = {
    // Conversión de tinte en Hertz a hexadecimal para renderizado
    // Frecuencia nominal de luz solar dispersa: ~5.6e14 Hz (luz diurna)
    color_cuerpo = 0xEAEEF2 // Blanco suave con tinte atmosférico
    color_sombra = 0x8B949E // Gris azulado de base

    // Muestreo de 7 círculos concéntricos y desplazados gobernados por Gamma(z)
    k = 1.0
    while (k <= 7.0) {
        // t varía a lo largo de la curva factorial
        t_sample = (k * 0.6)
        density = gamma_density(t_sample, z_param)
        
        // Radio expandido según la densidad factorial Gamma
        r_step = r_base * (0.35 + (density * 1.8))
        
        // Desplazamiento radial armónico
        ang = k * 0.897 // ~51.4 grados por lóbulo
        dx = cos(ang) * (r_base * 0.45)
        dy = sin(ang) * (r_base * 0.25)
        
        col = color_cuerpo
        if (k > 5.0) {
            col = color_sombra
        } else {
            1.0
        }
        
        // Renderizado del lóbulo circular en PVM
        circle(cx + dx, cy + dy, r_step, col)
        
        k = k + 1.0
    }

    // Núcleo central brillante
    circle(cx, cy - (r_base * 0.1), r_base * 0.55, 0xFFFFFF)
    1.0
}

// Renderizado de Terreno / Siluetas de Montañas continuas con distribución Gamma
render_scenery_gamma(base_y, w, num_picos, z_curve, hex_color) = {
    dx = w / num_picos
    x_curr = 0.0
    prev_y = base_y
    i = 0.0

    while (i < num_picos) {
        // Modulación factorial del pico
        t = (i * 0.5) % 4.0
        dens = gamma_density(t + 0.5, z_curve)
        peak_h = dens * 120.0
        curr_y = base_y - peak_h

        // Trazado de aristas del paisaje
        next_x = x_curr + dx
        line(x_curr, prev_y, next_x, curr_y, hex_color)

        prev_y = curr_y
        x_curr = next_x
        i = i + 1.0
    }

    // Línea base del horizonte
    line(0.0, base_y, w, base_y, hex_color)
    1.0
}
