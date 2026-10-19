// ===============================================================
// LIB/PROCEDURAL_VIDEO.PH — Síntesis de Video Procedural en Tiempo Real
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Generación en Vivo de Océanos, Chimeneas y Rostros de IA (0 Bytes en Disco)
// ===============================================================

// 1. Síntesis Procedural de Océano Dinámico y Oleaje Gerstner
// Genera ondas armónicas superpuestas y brillo solar especular continuo
procedural_ocean(t, w, h, wave_freq) = {
    // Fondo de cielo y crepúsculo
    rect(0.0, 0.0, w, h * 0.45, 0x0A192F)
    
    // Sol radiante en el horizonte
    sun_x = w * 0.5
    sun_y = h * 0.35
    circle(sun_x, sun_y, 24.0, 0xFFA500)
    circle(sun_x, sun_y, 16.0, 0xFFFFE0)

    // Horizonte marino base
    base_sea_y = h * 0.45
    rect(0.0, base_sea_y, w, h - base_sea_y, 0x001B3A)

    // Trazado de 4 capas de oleaje Gerstner en perspectiva
    layer = 1.0
    while (layer <= 4.0) {
        layer_y = base_sea_y + (layer * (h * 0.12))
        amp = 4.0 + (layer * 3.5)
        k = (0.015 / layer) * wave_freq
        speed = t * (1.8 + layer)

        prev_wx = 0.0
        prev_wy = layer_y
        step_x = 16.0
        curr_x = step_x

        layer_color = 0x0A3069
        if (layer == 2.0) { layer_color = 0x0969DA } else { 1.0 }
        if (layer == 3.0) { layer_color = 0x218BFF } else { 1.0 }
        if (layer == 4.0) { layer_color = 0x54AEFF } else { 1.0 }

        while (curr_x <= w) {
            // Modulación de onda Gerstner: y = A * cos(k*x - omega*t)
            phase = (curr_x * k) - speed
            wave_offset = amp * cos(phase)
            
            // Componente de cresta trochoidal
            trochoid = amp * 0.35 * sin(phase * 2.0)
            curr_wy = layer_y + wave_offset + trochoid

            // Trazado del segmento de agua
            line(prev_wx, prev_wy, curr_x, curr_wy, layer_color)

            // Reflejo solar especular cerca del centro
            dist_sun = curr_x - sun_x
            if ((dist_sun * dist_sun) < 3600.0) {
                // Brillo blanco en la cresta
                circle(curr_x, curr_wy - 1.0, 2.0, 0xFFFFE0)
            } else {
                1.0
            }

            prev_wx = curr_x
            prev_wy = curr_wy
            curr_x = curr_x + step_x
        }

        layer = layer + 1.0
    }
    1.0
}

// 2. Síntesis Procedural de Chimenea y Fuego Convectivo
// Simulación de llamas turbulentas y brasas ascendentes por flotabilidad
procedural_chimney(t, cx, cy, ember_count) = {
    // Estructura arquitectónica de la chimenea (ladrillos oscuros)
    chim_w = 140.0
    chim_h = 180.0
    chim_x = cx - (chim_w * 0.5)
    chim_y = cy - chim_h

    // Marco exterior de mampostería
    rect(chim_x, chim_y, chim_w, chim_h, 0x1E1E1E)
    rect(chim_x + 15.0, chim_y + 30.0, chim_w - 30.0, chim_h - 30.0, 0x0A0A0A)

    // Base del hogar de fuego (leños)
    log_y = cy - 20.0
    rect(chim_x + 25.0, log_y, chim_w - 50.0, 14.0, 0x4A2511)

    // Llamas dinámicas procedurales (3 capas de fuego: rojo, naranja, amarillo)
    f = 1.0
    while (f <= 5.0) {
        flame_offset_x = (f - 3.0) * 18.0
        // Oscilador armónico no lineal para turbulencia de llama
        turb = sin((t * 8.0) + (f * 1.5)) * cos((t * 12.0) + (f * 0.7))
        flame_h = 35.0 + (turb * 18.0) + (f * 6.0)
        
        flame_base_x = cx + flame_offset_x
        flame_top_y = log_y - flame_h

        // Color de llama según proximidad al núcleo
        flame_col = 0xD03801 // Rojo fuego exterior
        if (f >= 2.0 && f <= 4.0) { flame_col = 0xF56D00 } else { 1.0 }
        if (f == 3.0) { flame_col = 0xFFD000 } else { 1.0 } // Núcleo amarillo brillante

        // Trazado de lengüetas de fuego
        line(flame_base_x - 8.0, log_y, flame_base_x, flame_top_y, flame_col)
        line(flame_base_x + 8.0, log_y, flame_base_x, flame_top_y, flame_col)
        circle(flame_base_x, log_y - (flame_h * 0.4), 10.0, flame_col)

        f = f + 1.0
    }

    // Brasas ascendentes (partículas térmicas convectivas)
    p = 1.0
    while (p <= ember_count) {
        // Posición derivada del tiempo y semilla de partícula
        seed = p * 43.17
        travel = (t * 60.0) + seed
        ember_y = log_y - (travel % 160.0)
        
        // Deriva lateral por vórtices de calor
        sway = sin((t * 4.0) + seed) * 16.0
        ember_x = cx + sway + ((seed % 40.0) - 20.0)

        // Dibujar chispa incandescente
        circle(ember_x, ember_y, 2.0, 0xFFA500)
        p = p + 1.0
    }
    1.0
}

// 3. Síntesis Procedural de Rostro Vectorial de IA (Holográfico y Expresivo)
// Incluye parpadeo ocular periódico y apertura bucal sincronizada con energía de habla
procedural_ai_face(t, cx, cy, talking_energy, emotion_id) = {
    // Halo holográfico exterior
    circle(cx, cy, 75.0, 0x09264A)
    circle(cx, cy, 65.0, 0x0D1117)
    
    // Contorno de cabeza / visera futurista
    line(cx - 50.0, cy - 25.0, cx + 50.0, cy - 25.0, 0x58A6FF)
    line(cx - 50.0, cy - 25.0, cx - 35.0, cy + 45.0, 0x58A6FF)
    line(cx + 50.0, cy - 25.0, cx + 35.0, cy + 45.0, 0x58A6FF)
    line(cx - 35.0, cy + 45.0, cx + 35.0, cy + 45.0, 0x58A6FF)

    // Ojos Vectoriales con Parpadeo Procedural
    // El parpadeo ocurre cada ~4 segundos: blink_timer
    blink_cycle = (t * 0.75) % 3.0
    is_blinking = blink_cycle > 2.85

    eye_w = 18.0
    eye_h = 10.0
    if (is_blinking) {
        eye_h = 1.5 // Ojo cerrado / línea fina
    } else {
        1.0
    }

    // Color de ojos según estado emocional
    eye_col = 0x58A6FF // Normal (Azul cian)
    if (emotion_id == 2.0) { eye_col = 0x3FB950 } else { 1.0 } // Feliz (Verde)
    if (emotion_id == 3.0) { eye_col = 0xBC8CFF } else { 1.0 } // Pensando / Analizando (Violeta)
    if (emotion_id == 4.0) { eye_col = 0xF85149 } else { 1.0 } // Alerta (Rojo)

    // Ojo Izquierdo
    eye_left_x = cx - 24.0
    eye_y = cy - 8.0
    rect(eye_left_x - (eye_w * 0.5), eye_y - (eye_h * 0.5), eye_w, eye_h, eye_col)
    
    // Ojo Derecho
    eye_right_x = cx + 24.0
    rect(eye_right_x - (eye_w * 0.5), eye_y - (eye_h * 0.5), eye_w, eye_h, eye_col)

    // Cejas Expresivas
    brow_y = eye_y - 10.0
    if (emotion_id == 2.0) {
        // Cejas arqueadas hacia arriba (feliz)
        line(eye_left_x - 10.0, brow_y, eye_left_x + 10.0, brow_y - 3.0, eye_col)
        line(eye_right_x - 10.0, brow_y - 3.0, eye_right_x + 10.0, brow_y, eye_col)
    } else {
        line(eye_left_x - 10.0, brow_y, eye_left_x + 10.0, brow_y, eye_col)
        line(eye_right_x - 10.0, brow_y, eye_right_x + 10.0, brow_y, eye_col)
    }

    // Boca Sintética Reactiva (Apertura sincronizada con energía acústica)
    mouth_y = cy + 24.0
    mouth_w = 26.0
    // Apertura vertical en función de talking_energy [0.0..1.0]
    mouth_open_h = 2.0 + (talking_energy * 14.0)

    rect(cx - (mouth_w * 0.5), mouth_y - (mouth_open_h * 0.5), mouth_w, mouth_open_h, eye_col)

    // Telemetría de estado neuronal
    text("KORA-AI ASSISTANT", cx - 44.0, cy + 56.0, 9.0, 0x8B949E)
    1.0
}
