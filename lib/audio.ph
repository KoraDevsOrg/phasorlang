// ===============================================================
// LIB/AUDIO.PH — Motor de DSP Acústico y Procesamiento PCM a 44.1 kHz
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Filtros Resonantes Biquad, Pulso Glótico y Memoria Contigua Zero-GC
// ===============================================================

// Constantes de audio estándar
// Frecuencia de muestreo: fs = 44100.0 Hz
// Período de muestreo: Ts = 1.0 / 44100.0 = 2.26757e-5 segundos

// 1. Pulso Glótico de Rosenberg (Excitación de Cuerdas Vocales)
// Modela la apertura y cierre asimétrico de la glotis para voz natural
glottal_pulse(phase, open_quotient) = {
    // phase en rango [0.0 .. 1.0] dentro del ciclo fundamental
    p = phase % 1.0
    oq = open_quotient
    if (oq < 0.2) { oq = 0.6 } else { 1.0 }

    if (p < oq) {
        // Fase de apertura y flujo creciente: g(t) = 0.5 * (1 - cos(PI * t / oq))
        arg = (3.14159265359 * p) / oq
        0.5 * (1.0 - cos(arg))
    } else {
        // Fase de cierre brusco exponencial
        closing_t = (p - oq) / (1.0 - oq)
        exp_decay = 2.71828182846 ^ (-closing_t * 6.0)
        exp_decay * 0.5
    }
}

// 2. Filtro Resonador Pasa-Banda Biquad de Formantes en Tiempo Discreto
// s_in = muestra de entrada, fc = frecuencia de resonancia en Hz, q = factor de calidad
// x1, x2 = estados previos de entrada; y1, y2 = estados previos de salida
biquad_resonator(s_in, fc, q, x1, x2, y1, y2) = {
    fs = 44100.0
    pi_val = 3.14159265359
    
    // Frecuencia angular normalizada: w0 = 2 * PI * fc / fs
    w0 = (2.0 * pi_val * fc) / fs
    sin_w0 = sin(w0)
    cos_w0 = cos(w0)
    
    // Parámetro de ancho de banda: alpha = sin(w0) / (2 * Q)
    alpha = sin_w0 / (2.0 * q)
    
    // Coeficientes del filtro resonador (Ganancia unitaria en el pico)
    b0 = alpha
    b1 = 0.0
    b2 = -alpha
    a0 = 1.0 + alpha
    a1 = -2.0 * cos_w0
    a2 = 1.0 - alpha
    
    // Ecuación en diferencias finitas normalizada por a0
    out_y = ((b0 * s_in) + (b1 * x1) + (b2 * x2) - (a1 * y1) - (a2 * y2)) / a0
    out_y
}

// 3. Generador de Ruido Rosa / Blanco para Fonemas Fricativos ('S', 'F', 'CH')
noise_generator(seed) = {
    // Generador congruencial lineal rápido en punto flotante
    new_seed = ((seed * 1103515245.0) + 12345.0) % 2147483648.0
    normalized = (new_seed / 1073741824.0) - 1.0
    normalized
}

// 4. Envolvente ADSR Acústica (Ataque, Decaimiento, Sostenimiento, Relajación)
envelope_adsr(sample_idx, total_samples) = {
    progress = sample_idx / total_samples
    if (progress < 0.1) {
        // Ataque (Attack): subida lineal
        progress / 0.1
    } else {
        if (progress < 0.25) {
            // Decaimiento (Decay) al 80%
            1.0 - ((progress - 0.1) * 1.33)
        } else {
            if (progress < 0.85) {
                // Sostenimiento (Sustain)
                0.8
            } else {
                // Relajación (Release) a cero
                (1.0 - progress) / 0.15 * 0.8
            }
        }
    }
}
