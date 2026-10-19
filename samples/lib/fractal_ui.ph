// ===============================================================
// LIB/FRACTAL_UI.PH — Componentes de Interfaz Fractal Mapeados en Hertz
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Conjunto de Julia Dinámico, Curvas de Koch Espectrales y Botones Fractales
// ===============================================================

// 1. Evaluación de Píxel en el Conjunto de Julia: z = z^2 + c
// Retorna la tasa de escape normalizada [0.0 .. 1.0]
julia_pixel(zx, zy, cr, ci, max_iter) = {
    x = zx
    y = zy
    i = 0.0
    escaped = 0.0

    while (i < max_iter) {
        x2 = x * x
        y2 = y * y
        
        // Comprobación de radio de escape (|z|^2 > 4.0)
        if ((x2 + y2) > 4.0) {
            escaped = 1.0
            i = max_iter // Salida anticipada
        } else {
            // z = z^2 + c
            new_y = (2.0 * x * y) + ci
            new_x = (x2 - y2) + cr
            x = new_x
            y = new_y
            i = i + 1.0
        }
    }

    if (escaped == 1.0) {
        i / max_iter
    } else {
        0.0 // Perteneciente al conjunto de Julia interior
    }
}

// 2. Mapeo de Escape de Julia a Frecuencia Espectral en Hertz (400 a 750 THz)
julia_escape_to_hz(escape_ratio) = {
    // 4.0e14 Hz (Rojo) hasta 7.4e14 Hz (Violeta)
    4.0e14 + (escape_ratio * 3.4e14)
}

// 3. Renderizado de Panel Fractal de Julia de Baja Resolución (Grid Matrix Zero-GC)
render_julia_panel(px, py, pw, ph, cr, ci, step_size) = {
    // Muestreo matricial para renderizado a 90+ FPS en Canvas Declarativo
    step = step_size
    if (step < 4.0) { step = 4.0 } else { 1.0 }

    aspect = pw / ph
    curr_y = 0.0

    while (curr_y < ph) {
        curr_x = 0.0
        // Normalización al plano complejo (-1.5 a 1.5)
        zy = ((curr_y / ph) * 2.4) - 1.2

        while (curr_x < pw) {
            zx = (((curr_x / pw) * 2.4 * aspect) - (1.2 * aspect))
            esc = julia_pixel(zx, zy, cr, ci, 16.0)

            if (esc > 0.0) {
                // Color derivado de Hertz
                hz = julia_escape_to_hz(esc)
                // Color aproximado rápido
                col = 0x58A6FF
                if (esc < 0.3) {
                    col = 0x3FB950 // Verde
                } else {
                    if (esc < 0.7) {
                        col = 0x58A6FF // Azul
                    } else {
                        col = 0xBC8CFF // Violeta
                    }
                }
                rect(px + curr_x, py + curr_y, step, step, col)
            } else {
                rect(px + curr_x, py + curr_y, step, step, 0x0D1117)
            }

            curr_x = curr_x + step
        }
        curr_y = curr_y + step
    }

    // Borde delimitador
    line(px, py, px + pw, py, 0x30363D)
    line(px + pw, py, px + pw, py + ph, 0x30363D)
    line(px + pw, py + ph, px, py + ph, 0x30363D)
    line(px, py + ph, px, py, 0x30363D)
    1.0
}

// 4. Función de Trazado de Curva de Koch Fractal Mapeada en Hertz
koch_curve_hz(x1, y1, x2, y2, depth, base_hz) = {
    // Selección de color según frecuencia espectral en Hertz
    line_col = 0x58A6FF
    if (base_hz < 5.0e14) {
        line_col = 0xF85149 // Rojizo (<500 THz)
    } else {
        if (base_hz < 6.0e14) {
            line_col = 0x3FB950 // Verde (500-600 THz)
        } else {
            line_col = 0x58A6FF // Azul / Cian (>600 THz)
        }
    }

    // Nivel 1: Cuatro sub-segmentos con triángulo equilátero
    dx = (x2 - x1) / 3.0
    dy = (y2 - y1) / 3.0

    p1x = x1 + dx
    p1y = y1 + dy

    p3x = x1 + (2.0 * dx)
    p3y = y1 + (2.0 * dy)

    // Rotación fasorial de 60 grados: cos(60)=0.5, sin(60)=0.8660254
    peak_x = p1x + (dx * 0.5) - (dy * 0.8660254)
    peak_y = p1y + (dx * 0.8660254) + (dy * 0.5)

    // Trazado de los 4 segmentos de Koch
    line(x1, y1, p1x, p1y, line_col)
    line(p1x, p1y, peak_x, peak_y, line_col)
    line(peak_x, peak_y, p3x, p3y, line_col)
    line(p3x, p3y, x2, y2, line_col)
    1.0
}

// 6. Copo de Nieve Fractal de Koch Completo (3 lados en triángulo)
koch_snowflake_hz(cx, cy, radius, depth, base_hz) = {
    // 3 vértices equiláteros
    // Vértice superior: (cx, cy - r)
    // Vértice inferior der: (cx + r*cos(30), cy + r*sin(30)) -> cos(30)=0.866, sin(30)=0.5
    // Vértice inferior izq: (cx - r*cos(30), cy + r*sin(30))
    r = radius
    x1 = cx
    y1 = cy - r

    x2 = cx + (r * 0.8660254)
    y2 = cy + (r * 0.5)

    x3 = cx - (r * 0.8660254)
    y3 = cy + (r * 0.5)

    koch_curve_hz(x1, y1, x2, y2, depth, base_hz)
    koch_curve_hz(x2, y2, x3, y3, depth, base_hz)
    koch_curve_hz(x3, y3, x1, y1, depth, base_hz)
    1.0
}

// 7. Botón Fractal Ergonómico Táctil (Borde Koch + Fondo Reactivo)
fractal_button(text_id, x, y, w, h, action_id, base_hz) = {
    // Fondo de botón suave
    rect(x, y, w, h, 0x161B22)

    // Borde fractal de Koch en el borde superior
    koch_curve_hz(x, y, x + w, y, 2.0, base_hz)
    
    // Bordes laterales e inferior
    line(x + w, y, x + w, y + h, 0x30363D)
    line(x + w, y + h, x, y + h, 0x30363D)
    line(x, y + h, x, y, 0x30363D)

    // Botón PVM para interactividad táctil
    btn(text_id, x, y, w, h, action_id, 0x238636)
    1.0
}
