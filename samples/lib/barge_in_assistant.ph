// ===============================================================
// LIB/BARGE_IN_ASSISTANT.PH — Asistente Full-Duplex y Cancelación de Eco
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Cancelación de Eco por Resta de Fase Fasorial y Corte Inmediato por Voz O(1)
// ===============================================================

// Estados del Asistente (Campo 0 del buffer de estado):
// 0.0 = IDLE (En reposo)
// 1.0 = LISTENING (Escuchando al usuario)
// 2.0 = THINKING (Procesando respuesta en SLM local)
// 3.0 = SPEAKING (Sintetizando voz en streaming)

// 1. Cancelación de Eco Acústico por Resta de Fase Fasorial (AEC en O(1))
// Sustrae la señal enviada al altavoz con desfase y atenuación de retorno
phase_cancel_echo(mic_sample, speaker_soa, delay_idx, attenuation, cap) = {
    // Muestra previa emitida por el altavoz recuperada del buffer circular SoA
    spk_sample = get_soa(speaker_soa, 0, delay_idx, cap)
    
    // Resta de fase fasorial pura: s_clean = s_mic - (alpha * s_spk)
    clean_sample = mic_sample - (attenuation * spk_sample)
    clean_sample
}

// 2. Detección Inmediata de Actividad de Voz (VAD / Energy Detector)
// Calcula la energía instantánea cuadrática y compara contra el umbral de interrupción
barge_in_detect(clean_sample, threshold_energy) = {
    energy = clean_sample * clean_sample
    if (energy > threshold_energy) {
        1.0 // Usuario detectado hablando
    } else {
        0.0 // Solo ruido de fondo o silencio
    }
}

// 3. Corte Inmediato de Síntesis por Voz (Full-Duplex Barge-In O(1))
// Si el asistente está hablando y el usuario interrumpe, se detiene la salida al instante
assistant_interrupt_tts(state_soa, id, cap) = {
    curr_state = get_soa(state_soa, 0, id, cap)
    
    // Si estaba hablando (3.0), cambiar inmediatamente a escuchar (1.0)
    if (curr_state == 3.0) {
        set_soa(state_soa, 0, id, cap, 1.0) // Pasar a LISTENING
        set_soa(state_soa, 1, id, cap, 0.0) // Reiniciar cabezal de reproducción a cero
        set_soa(state_soa, 2, id, cap, 1.0) // Marcar flag de interrupción exitosa (barge_in_event)
        1.0
    } else {
        0.0
    }
}

// 4. Paso Integral del Bucle Full-Duplex en Tiempo Real
// Procesa la muestra del micrófono, cancela el eco, valida interrupción y actualiza el estado
assistant_full_duplex_step(mic_sample, speaker_soa, delay_idx, state_soa, id, threshold, cap) = {
    // 1. Resta de fase de eco
    clean_voice = phase_cancel_echo(mic_sample, speaker_soa, delay_idx, 0.85, cap)

    // 2. Detección de interrupción
    is_user_talking = barge_in_detect(clean_voice, threshold)

    // 3. Ejecutar Barge-In si el usuario habló mientras el asistente emitía audio
    if (is_user_talking == 1.0) {
        assistant_interrupt_tts(state_soa, id, cap)
    } else {
        1.0
    }

    // Retorna la señal de voz limpia de eco para alimentar al reconocedor o SLM
    clean_voice
}

// 5. Inicialización de Estado del Asistente
init_assistant_state(state_soa, id, cap) = {
    set_soa(state_soa, 0, id, cap, 1.0) // Estado inicial: LISTENING
    set_soa(state_soa, 1, id, cap, 0.0) // Puntero de streaming en cero
    set_soa(state_soa, 2, id, cap, 0.0) // Eventos de barge-in
    set_soa(state_soa, 3, id, cap, 0.0) // Nivel de energía de entrada
    1.0
}
