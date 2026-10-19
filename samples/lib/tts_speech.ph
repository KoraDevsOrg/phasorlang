// ===============================================================
// LIB/TTS_SPEECH.PH — Síntesis de Voz Formántica en Streaming PCM 44.1 kHz
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Articulación de Formantes Vocálicos (F0, F1, F2, F3) en Tiempo Real
// ===============================================================

// 1. Tabla de Frecuencias de Formantes Vocálicos en Hertz (F0, F1, F2, F3)
// 1.0 = 'A' -> F1: 800 Hz,  F2: 1200 Hz, F3: 2500 Hz
// 2.0 = 'E' -> F1: 400 Hz,  F2: 2000 Hz, F3: 2800 Hz
// 3.0 = 'I' -> F1: 280 Hz,  F2: 2300 Hz, F3: 3000 Hz
// 4.0 = 'O' -> F1: 500 Hz,  F2: 900 Hz,  F3: 2400 Hz
// 5.0 = 'U' -> F1: 320 Hz,  F2: 800 Hz,  F3: 2200 Hz

get_vowel_f1(vowel_id) = {
    if (vowel_id == 1.0) { 800.0 } // 'A'
    else {
        if (vowel_id == 2.0) { 400.0 } // 'E'
        else {
            if (vowel_id == 3.0) { 280.0 } // 'I'
            else {
                if (vowel_id == 4.0) { 500.0 } // 'O'
                else { 320.0 } // 'U'
            }
        }
    }
}

get_vowel_f2(vowel_id) = {
    if (vowel_id == 1.0) { 1200.0 } // 'A'
    else {
        if (vowel_id == 2.0) { 2000.0 } // 'E'
        else {
            if (vowel_id == 3.0) { 2300.0 } // 'I'
            else {
                if (vowel_id == 4.0) { 900.0 }  // 'O'
                else { 800.0 }  // 'U'
            }
        }
    }
}

get_vowel_f3(vowel_id) = {
    if (vowel_id == 1.0) { 2500.0 } // 'A'
    else {
        if (vowel_id == 2.0) { 2800.0 } // 'E'
        else {
            if (vowel_id == 3.0) { 3000.0 } // 'I'
            else {
                if (vowel_id == 4.0) { 2400.0 } // 'O'
                else { 2200.0 } // 'U'
            }
        }
    }
}

// 2. Síntesis Formántica de un Fonema Vocálico en un Buffer SoA PCM
// Genera muestras de audio a 44.1 kHz mediante la excitación glótica y 3 formantes resonantes
formant_synth_vowel(pcm_soa_ptr, vowel_id, f0_pitch, duration_samples, cap) = {
    fs = 44100.0
    f1 = get_vowel_f1(vowel_id)
    f2 = get_vowel_f2(vowel_id)
    f3 = get_vowel_f3(vowel_id)

    // Estados previos de los 3 filtros biquad resonadores
    x1_f1 = 0.0
    x2_f1 = 0.0
    y1_f1 = 0.0
    y2_f1 = 0.0

    x1_f2 = 0.0
    x2_f2 = 0.0
    y1_f2 = 0.0
    y2_f2 = 0.0

    x1_f3 = 0.0
    x2_f3 = 0.0
    y1_f3 = 0.0
    y2_f3 = 0.0

    phase = 0.0
    phase_inc = f0_pitch / fs
    q_factor = 7.0 // Resonancia vocal típica

    n = 0.0
    while (n < duration_samples) {
        // Excitación glótica
        pulse = glottal_pulse(phase, 0.65)
        phase = phase + phase_inc

        // Resonancia a través de F1
        out1 = biquad_resonator(pulse, f1, q_factor, x1_f1, x2_f1, y1_f1, y2_f1)
        x2_f1 = x1_f1
        x1_f1 = pulse
        y2_f1 = y1_f1
        y1_f1 = out1

        // Resonancia a través de F2
        out2 = biquad_resonator(pulse, f2, q_factor, x1_f2, x2_f2, y1_f2, y2_f2)
        x2_f2 = x1_f2
        x1_f2 = pulse
        y2_f2 = y1_f2
        y1_f2 = out2

        // Resonancia a través de F3
        out3 = biquad_resonator(pulse, f3, q_factor, x1_f3, x2_f3, y1_f3, y2_f3)
        x2_f3 = x1_f3
        x1_f3 = pulse
        y2_f3 = y1_f3
        y1_f3 = out3

        // Mezcla ponderada de formantes con envolvente temporal ADSR
        env = envelope_adsr(n, duration_samples)
        sample_val = ((out1 * 1.0) + (out2 * 0.6) + (out3 * 0.3)) * env * 0.4

        // Almacenar muestra PCM continua en memoria contigua SoA
        set_soa(pcm_soa_ptr, 0, n, cap, sample_val)
        n = n + 1.0
    }
    1.0
}

// 3. Síntesis de Frases Articuladas en Streaming de Fonemas
// Secuencia fonética encadenada con coarticulación continua
tts_speak_phrase(pcm_soa_ptr, phrase_id, f0_base, cap) = {
    // Fonemas de 4410 muestras (~100 ms por fonema a 44.1 kHz)
    phoneme_len = 4410.0

    if (phrase_id == 101.0) {
        // Frase 101: "K-O-R-A P-H-A-S-O-R"
        // Secuencia vocálica aproximada: O -> A -> A -> O
        formant_synth_vowel(pcm_soa_ptr, 4.0, f0_base, phoneme_len, cap) // 'O'
        formant_synth_vowel(pcm_soa_ptr, 1.0, f0_base * 1.05, phoneme_len, cap) // 'A'
        formant_synth_vowel(pcm_soa_ptr, 1.0, f0_base, phoneme_len, cap) // 'A'
        formant_synth_vowel(pcm_soa_ptr, 4.0, f0_base * 0.95, phoneme_len, cap) // 'O'
    } else {
        if (phrase_id == 102.0) {
            // Frase 102: "S-I-S-T-E-M-A" -> I -> E -> A
            formant_synth_vowel(pcm_soa_ptr, 3.0, f0_base, phoneme_len, cap) // 'I'
            formant_synth_vowel(pcm_soa_ptr, 2.0, f0_base, phoneme_len, cap) // 'E'
            formant_synth_vowel(pcm_soa_ptr, 1.0, f0_base * 0.92, phoneme_len, cap) // 'A'
        } else {
            // Frase por defecto: Vocal pura 'A' (Calibración)
            formant_synth_vowel(pcm_soa_ptr, 1.0, f0_base, phoneme_len, cap)
        }
    }
    1.0
}
