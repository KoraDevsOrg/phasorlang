// ===============================================================
// LIB/PLATFORMER.PH — Motor de Videojuego de Plataformas SoA Zero-GC
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Cinemática, Colisiones AABB/Circulares, Fricción y Gestión de Vidas
// ===============================================================

// Estructura de Campos SoA para Entidades de Plataformas (Capacidad fija contigua):
// Campo 0: x (Posición horizontal)
// Campo 1: y (Posición vertical)
// Campo 2: vx (Velocidad horizontal)
// Campo 3: vy (Velocidad vertical)
// Campo 4: w (Ancho de caja / Radio)
// Campo 5: h (Alto de caja)
// Campo 6: flags (1=en_suelo, 2=corriendo, 4=saltando, 8=invulnerable, 16=mirando_der)
// Campo 7: vidas (Vidas / Salud restante, ej. 3.0)

// 1. Inicializar Entidad Jugador en el buffer SoA
init_platformer_player(soa_ptr, id, cap, start_x, start_y, initial_lives) = {
    set_soa(soa_ptr, 0, id, cap, start_x)
    set_soa(soa_ptr, 1, id, cap, start_y)
    set_soa(soa_ptr, 2, id, cap, 0.0)      // vx
    set_soa(soa_ptr, 3, id, cap, 0.0)      // vy
    set_soa(soa_ptr, 4, id, cap, 28.0)     // w
    set_soa(soa_ptr, 5, id, cap, 42.0)     // h
    set_soa(soa_ptr, 6, id, cap, 17.0)     // flags: 1 (suelo) + 16 (mirando_der)
    set_soa(soa_ptr, 7, id, cap, initial_lives)
    1.0
}

// 2. Función de Alto Nivel: saltar()
// Aplica impulso vertical fasorial solo si el personaje está apoyado en el suelo
saltar(player_soa, id, fuerza) = {
    cap = 512.0
    flags = get_soa(player_soa, 6, id, cap)
    
    // Comprobación de flag 1 (en_suelo)
    is_grounded = (flags % 2.0) >= 1.0

    if (is_grounded) {
        // Asignar velocidad vertical negativa (hacia arriba)
        set_soa(player_soa, 3, id, cap, -fuerza)
        
        // Actualizar flags: quitar suelo (flag 1) y agregar saltando (flag 4)
        new_flags = (flags - 1.0) + 4.0
        set_soa(player_soa, 6, id, cap, new_flags)
        1.0
    } else {
        0.0 // No puede saltar en el aire
    }
}

// 3. Función de Alto Nivel: correr()
// Acelera rápidamente en la dirección deseada hasta la velocidad de carrera
correr(player_soa, id, direccion, max_vel) = {
    cap = 512.0
    curr_vx = get_soa(player_soa, 2, id, cap)
    flags = get_soa(player_soa, 6, id, cap)

    // Aceleración de carrera sostenida
    accel = 2.4
    target_vx = direccion * max_vel
    new_vx = curr_vx + (direccion * accel)

    // Limitar a max_vel
    if (direccion > 0.0) {
        if (new_vx > target_vx) { new_vx = target_vx } else { 1.0 }
        // Actualizar orientación a la derecha (flag 16)
        set_soa(player_soa, 6, id, cap, (flags - (flags % 32.0)) + 18.0) // corriendo + der
    } else {
        if (new_vx < target_vx) { new_vx = target_vx } else { 1.0 }
        // Orientación a la izquierda
        set_soa(player_soa, 6, id, cap, (flags - (flags % 32.0)) + 2.0)  // corriendo
    }

    set_soa(player_soa, 2, id, cap, new_vx)
    1.0
}

// 4. Función de Alto Nivel: caminar()
// Desplazamiento moderado a velocidad estándar
caminar(player_soa, id, direccion) = {
    cap = 512.0
    walk_speed = 3.6
    set_soa(player_soa, 2, id, cap, direccion * walk_speed)
    
    flags = get_soa(player_soa, 6, id, cap)
    if (direccion > 0.0) {
        set_soa(player_soa, 6, id, cap, (flags - (flags % 32.0)) + 17.0) // suelo + der
    } else {
        set_soa(player_soa, 6, id, cap, (flags - (flags % 32.0)) + 1.0)  // suelo + izq
    }
    1.0
}

// 5. Función de Alto Nivel: chocar()
// Detección precisa de colisión entre dos entidades (AABB + Circular) en O(1)
chocar(soa_a, id_a, soa_b, id_b) = {
    cap = 512.0
    xa = get_soa(soa_a, 0, id_a, cap)
    ya = get_soa(soa_a, 1, id_a, cap)
    wa = get_soa(soa_a, 4, id_a, cap)
    ha = get_soa(soa_a, 5, id_a, cap)

    xb = get_soa(soa_b, 0, id_b, cap)
    yb = get_soa(soa_b, 1, id_b, cap)
    wb = get_soa(soa_b, 4, id_b, cap)
    hb = get_soa(soa_b, 5, id_b, cap)

    // Comprobación de solapamiento de cajas AABB
    overlap_x = (xa < (xb + wb)) && ((xa + wa) > xb)
    overlap_y = (ya < (yb + hb)) && ((ya + ha) > yb)

    if (overlap_x && overlap_y) {
        1.0 // Colisión detectada
    } else {
        0.0 // Sin colisión
    }
}

// 6. Función de Alto Nivel: gestionar_vidas()
// Modifica la salud/vidas aplicando marcos de invulnerabilidad temporal
gestionar_vidas(player_soa, id, vidas_delta) = {
    cap = 512.0
    vidas_actuales = get_soa(player_soa, 7, id, cap)
    flags = get_soa(player_soa, 6, id, cap)

    // Comprobar flag de invulnerabilidad (bit 8)
    is_invulnerable = ((flags / 8.0) % 2.0) >= 1.0

    if (vidas_delta < 0.0) {
        // Daño recibido
        if (is_invulnerable) {
            vidas_actuales // Protegido contra daño
        } else {
            nuevas_vidas = vidas_actuales + vidas_delta
            if (nuevas_vidas < 0.0) { nuevas_vidas = 0.0 } else { 1.0 }
            
            // Activar invulnerabilidad (flag 8)
            set_soa(player_soa, 6, id, cap, flags + 8.0)
            set_soa(player_soa, 7, id, cap, nuevas_vidas)
            nuevas_vidas
        }
    } else {
        // Curación o vida extra
        nuevas_vidas = vidas_actuales + vidas_delta
        set_soa(player_soa, 7, id, cap, nuevas_vidas)
        nuevas_vidas
    }
}

// 7. Bucle de Integración Física Euleriana (Gravedad, Suelo, Fricción)
update_platformer_physics(soa_ptr, count, cap, dt, gravity, friction, floor_y) = {
    i = 0.0
    while (i < count) {
        px = get_soa(soa_ptr, 0, i, cap)
        py = get_soa(soa_ptr, 1, i, cap)
        vx = get_soa(soa_ptr, 2, i, cap)
        vy = get_soa(soa_ptr, 3, i, cap)
        pw = get_soa(soa_ptr, 4, i, cap)
        ph = get_soa(soa_ptr, 5, i, cap)
        flags = get_soa(soa_ptr, 6, i, cap)

        // Aplicar aceleración gravitatoria vertical
        new_vy = vy + (gravity * dt)
        new_py = py + (new_vy * dt)

        // Detección de suelo estático
        if ((new_py + ph) >= floor_y) {
            new_py = floor_y - ph
            new_vy = 0.0
            // Marcar en_suelo (flag 1) y limpiar saltando
            flags = (flags - (flags % 2.0)) + 1.0
        } else {
            1.0
        }

        // Aplicar fricción horizontal en el suelo
        new_vx = vx * friction
        if ((new_vx * new_vx) < 0.01) {
            new_vx = 0.0
        } else {
            1.0
        }

        new_px = px + (new_vx * dt)

        // Guardar estado actualizado en el heap SoA
        set_soa(soa_ptr, 0, i, cap, new_px)
        set_soa(soa_ptr, 1, i, cap, new_py)
        set_soa(soa_ptr, 2, i, cap, new_vx)
        set_soa(soa_ptr, 3, i, cap, new_vy)
        set_soa(soa_ptr, 6, i, cap, flags)

        i = i + 1.0
    }
    1.0
}

// 8. Renderizado del Personaje Vectorial en PVM
render_platformer_character(soa_ptr, id, cap, hex_color) = {
    px = get_soa(soa_ptr, 0, id, cap)
    py = get_soa(soa_ptr, 1, id, cap)
    pw = get_soa(soa_ptr, 4, id, cap)
    ph = get_soa(soa_ptr, 5, id, cap)
    flags = get_soa(soa_ptr, 6, id, cap)

    // Cuerpo principal
    rect(px, py + 12.0, pw, ph - 12.0, hex_color)
    
    // Cabeza circular
    half_w = pw * 0.5
    circle(px + half_w, py + 8.0, 8.0, 0xFFE0BD)
    
    // Ojo según la dirección
    is_facing_right = (flags / 16.0) % 2.0 >= 1.0
    eye_x = px + half_w + 3.0
    if (is_facing_right) {
        eye_x = px + half_w + 3.0
    } else {
        eye_x = px + half_w - 5.0
    }
    circle(eye_x, py + 7.0, 2.0, 0x000000)

    1.0
}
