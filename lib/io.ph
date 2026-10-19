// ===============================================================
// LIB/IO.PH — Abstraccion Universal de Perifericos e Insumos Fisicos
// PhasorLang v1.0 [Fase 11 Multi-Dominio — Chronos IDE]
// Teclado, Gamepad, Toque Tactil Multi-Touch, Giroscopio, Acelerometro,
// Fusion Sensorial IMU, Camara y Captura de Pantalla sobre SoA Zero-GC
// ===============================================================

// 1. Constantes Universales de Teclas y Perifericos
KEY_LEFT   = 37.0
KEY_UP     = 38.0
KEY_RIGHT  = 39.0
KEY_DOWN   = 40.0
KEY_SPACE  = 32.0
KEY_ENTER  = 13.0
KEY_ESCAPE = 27.0
KEY_W      = 87.0
KEY_A      = 65.0
KEY_S      = 83.0
KEY_D      = 68.0
KEY_J      = 74.0
KEY_K      = 75.0

// 2. Estructura SoA para Teclado e Insumos Digitales
struct KeyboardSoA {
    key_id: Float,       // Campo 0: Codigo de tecla estandar
    is_down: Float,      // Campo 1: 1.0 si esta presionada, 0.0 si no
    just_pressed: Float, // Campo 2: 1.0 en el frame de transicion a presionado
    repeat_count: Float  // Campo 3: Contador de frames continuos presionada
}

// 3. Estructura SoA para Gamepad / Palancas Analogicas y Gatillos
struct GamepadSoA {
    axis_lx: Float,      // Campo 0: Palanca izquierda X [-1.0, 1.0]
    axis_ly: Float,      // Campo 1: Palanca izquierda Y [-1.0, 1.0]
    axis_rx: Float,      // Campo 2: Palanca derecha X [-1.0, 1.0]
    axis_ry: Float,      // Campo 3: Palanca derecha Y [-1.0, 1.0]
    btn_a: Float,        // Campo 4: Boton A / Cruz
    btn_b: Float,        // Campo 5: Boton B / Circulo
    btn_x: Float,        // Campo 6: Boton X / Cuadrado
    btn_y: Float         // Campo 7: Boton Y / Triangulo
}

// 4. Estructura SoA para Punteros Tactiles Multi-Touch
struct TouchSlotSoA {
    id: Float,           // Campo 0: Identificador de puntero / dedo
    x: Float,            // Campo 1: Posicion actual X en pantalla
    y: Float,            // Campo 2: Posicion actual Y en pantalla
    prev_x: Float,       // Campo 3: Posicion del frame anterior X
    prev_y: Float,       // Campo 4: Posicion del frame anterior Y
    is_active: Float,    // Campo 5: 1.0 si el contacto esta activo
    pressure: Float      // Campo 6: Presion normalizada [0.0, 1.0]
}

// 5. Estructura SoA para Fusion Sensorial IMU (Acelerometro + Giroscopio)
struct ImuSensorSoA {
    ax: Float,           // Campo 0: Aceleracion X (m/s^2 o G)
    ay: Float,           // Campo 1: Aceleracion Y (m/s^2 o G)
    az: Float,           // Campo 2: Aceleracion Z (m/s^2 o G)
    gx: Float,           // Campo 3: Velocidad angular Giroscopio X (rad/s)
    gy: Float,           // Campo 4: Velocidad angular Giroscopio Y (rad/s)
    gz: Float,           // Campo 5: Velocidad angular Giroscopio Z (rad/s)
    pitch: Float,        // Campo 6: Inclinacion Cabeceo calculada (rad)
    roll: Float          // Campo 7: Inclinacion Alabeo calculada (rad)
}

// 6. Estructura SoA para Control de Camara y Captura de Pantalla
struct MediaCaptureSoA {
    cam_id: Float,          // Campo 0: 0=Trasera, 1=Frontal
    is_streaming: Float,    // Campo 1: 1.0=Activo, 0.0=Inactivo
    res_w: Float,           // Campo 2: Ancho de captura
    res_h: Float,           // Campo 3: Alto de captura
    fps_stream: Float,      // Campo 4: FPS medido del sensor optico
    capture_trigger: Float  // Campo 5: 1.0=Solicitud instantanea de frame
}

// ===============================================================
// 7. Modulo de Teclado (Zero-GC)
// ===============================================================

io.alloc_keyboard(capacity) = {
    alloc_soa(4, capacity)
}

io.set_key_state(kb_soa, idx, key_code, down, cap) = {
    prev_down = get_soa(kb_soa, 1, idx, cap)
    just = 0.0
    if (down == 1.0) {
        if (prev_down == 0.0) {
            just = 1.0
        }
    }
    set_soa(kb_soa, 0, idx, cap, key_code)
    set_soa(kb_soa, 1, idx, cap, down)
    set_soa(kb_soa, 2, idx, cap, just)
    1.0
}

io.is_down(kb_soa, key_code, count, cap) = {
    found = 0.0
    i = 0.0
    while (i < count) {
        k = get_soa(kb_soa, 0, i, cap)
        if (k == key_code) {
            d = get_soa(kb_soa, 1, i, cap)
            if (d == 1.0) {
                found = 1.0
            }
        }
        i = i + 1.0
    }
    found
}

io.just_pressed(kb_soa, key_code, count, cap) = {
    found = 0.0
    i = 0.0
    while (i < count) {
        k = get_soa(kb_soa, 0, i, cap)
        if (k == key_code) {
            jp = get_soa(kb_soa, 2, i, cap)
            if (jp == 1.0) {
                found = 1.0
            }
        }
        i = i + 1.0
    }
    found
}

// ===============================================================
// 8. Modulo de Gamepad y Palancas Analogicas
// ===============================================================

io.alloc_gamepad() = {
    alloc_soa(8, 4)
}

// Filtro analitico de zona muerta (Deadzone) para palancas
io.filter_deadzone(axis_val, deadzone) = {
    val = axis_val
    sign = 1.0
    if (val < 0.0) {
        sign = -1.0
        val = -val
    }
    if (val < deadzone) {
        0.0
    } else {
        // Reescalado lineal continuo fuera de la zona muerta
        norm = (val - deadzone) / (1.0 - deadzone)
        norm * sign
    }
}

io.gamepad_set_axes(gp_soa, lx, ly, rx, ry) = {
    flx = io.filter_deadzone(lx, 0.15)
    fly = io.filter_deadzone(ly, 0.15)
    frx = io.filter_deadzone(rx, 0.15)
    fry = io.filter_deadzone(ry, 0.15)

    set_soa(gp_soa, 0, 0, 4, flx)
    set_soa(gp_soa, 1, 0, 4, fly)
    set_soa(gp_soa, 2, 0, 4, frx)
    set_soa(gp_soa, 3, 0, 4, fry)
    1.0
}

io.gamepad_set_buttons(gp_soa, a, b, x, y) = {
    set_soa(gp_soa, 4, 0, 4, a)
    set_soa(gp_soa, 5, 0, 4, b)
    set_soa(gp_soa, 6, 0, 4, x)
    set_soa(gp_soa, 7, 0, 4, y)
    1.0
}

io.gamepad_axis_lx(gp_soa) = { get_soa(gp_soa, 0, 0, 4) }
io.gamepad_axis_ly(gp_soa) = { get_soa(gp_soa, 1, 0, 4) }
io.gamepad_axis_rx(gp_soa) = { get_soa(gp_soa, 2, 0, 4) }
io.gamepad_axis_ry(gp_soa) = { get_soa(gp_soa, 3, 0, 4) }
io.gamepad_btn_a(gp_soa)   = { get_soa(gp_soa, 4, 0, 4) }
io.gamepad_btn_b(gp_soa)   = { get_soa(gp_soa, 5, 0, 4) }

// ===============================================================
// 9. Modulo de Toque Tactil Multi-Touch
// ===============================================================

io.alloc_touches(max_touches) = {
    alloc_soa(7, max_touches)
}

io.touch_update(t_soa, slot, touch_id, new_x, new_y, active, pressure, cap) = {
    old_x = get_soa(t_soa, 1, slot, cap)
    old_y = get_soa(t_soa, 2, slot, cap)

    set_soa(t_soa, 0, slot, cap, touch_id)
    set_soa(t_soa, 1, slot, cap, new_x)
    set_soa(t_soa, 2, slot, cap, new_y)
    set_soa(t_soa, 3, slot, cap, old_x)
    set_soa(t_soa, 4, slot, cap, old_y)
    set_soa(t_soa, 5, slot, cap, active)
    set_soa(t_soa, 6, slot, cap, pressure)
    1.0
}

io.touch_dx(t_soa, slot, cap) = {
    x = get_soa(t_soa, 1, slot, cap)
    px = get_soa(t_soa, 3, slot, cap)
    x - px
}

io.touch_dy(t_soa, slot, cap) = {
    y = get_soa(t_soa, 2, slot, cap)
    py = get_soa(t_soa, 4, slot, cap)
    y - py
}

// Calculo euclidiano Zero-GC entre dos coordenadas de toque
io.touch_distance(x1, y1, x2, y2) = {
    dx = x2 - x1
    dy = y2 - y1
    sqrt((dx * dx) + (dy * dy))
}

// Gesto Pinch-to-Zoom entre los dedos 0 y 1
io.touch_pinch_ratio(t_soa, cap) = {
    act0 = get_soa(t_soa, 5, 0, cap)
    act1 = get_soa(t_soa, 5, 1, cap)

    if (act0 == 1.0) {
        if (act1 == 1.0) {
            x0 = get_soa(t_soa, 1, 0, cap)
            y0 = get_soa(t_soa, 2, 0, cap)
            x1 = get_soa(t_soa, 1, 1, cap)
            y1 = get_soa(t_soa, 2, 1, cap)

            px0 = get_soa(t_soa, 3, 0, cap)
            py0 = get_soa(t_soa, 4, 0, cap)
            px1 = get_soa(t_soa, 3, 1, cap)
            py1 = get_soa(t_soa, 4, 1, cap)

            cur_dist = io.touch_distance(x0, y0, x1, y1)
            prev_dist = io.touch_distance(px0, py0, px1, py1)

            if (prev_dist > 5.0) {
                cur_dist / prev_dist
            } else {
                1.0
            }
        } else {
            1.0
        }
    } else {
        1.0
    }
}

// ===============================================================
// 10. Modulo de Sensórica IMU y Fusion Complementaria Zero-GC
// ===============================================================

io.alloc_imu() = {
    alloc_soa(8, 4)
}

io.imu_set_raw(imu_soa, ax, ay, az, gx, gy, gz) = {
    set_soa(imu_soa, 0, 0, 4, ax)
    set_soa(imu_soa, 1, 0, 4, ay)
    set_soa(imu_soa, 2, 0, 4, az)
    set_soa(imu_soa, 3, 0, 4, gx)
    set_soa(imu_soa, 4, 0, 4, gy)
    set_soa(imu_soa, 5, 0, 4, gz)
    1.0
}

// Filtro Complementario Zero-GC para estimacion robusta de Pitch y Roll
// Combina giroscopio de alta frecuencia con acelerometro de baja frecuencia
io.imu_update_fusion(imu_soa, dt, alpha) = {
    ax = get_soa(imu_soa, 0, 0, 4)
    ay = get_soa(imu_soa, 1, 0, 4)
    az = get_soa(imu_soa, 2, 0, 4)
    gx = get_soa(imu_soa, 3, 0, 4)
    gy = get_soa(imu_soa, 4, 0, 4)

    cur_pitch = get_soa(imu_soa, 6, 0, 4)
    cur_roll  = get_soa(imu_soa, 7, 0, 4)

    // Estimacion de angulo por acelerometro (vector de gravedad)
    // Aproximacion Pade rapida para angulos en radianes
    accel_roll = ay * 0.10197
    if (accel_roll > 1.57)  { accel_roll = 1.57 }
    if (accel_roll < -1.57) { accel_roll = -1.57 }

    accel_pitch = -ax * 0.10197
    if (accel_pitch > 1.57)  { accel_pitch = 1.57 }
    if (accel_pitch < -1.57) { accel_pitch = -1.57 }

    // Integracion del giroscopio
    gyro_pitch = cur_pitch + (gx * dt)
    gyro_roll  = cur_roll + (gy * dt)

    // Fusion: new_angle = alpha * (gyro) + (1 - alpha) * (accel)
    new_pitch = (alpha * gyro_pitch) + ((1.0 - alpha) * accel_pitch)
    new_roll  = (alpha * gyro_roll) + ((1.0 - alpha) * accel_roll)

    set_soa(imu_soa, 6, 0, 4, new_pitch)
    set_soa(imu_soa, 7, 0, 4, new_roll)
    new_pitch
}

io.imu_pitch(imu_soa) = { get_soa(imu_soa, 6, 0, 4) }
io.imu_roll(imu_soa)  = { get_soa(imu_soa, 7, 0, 4) }

// Deteccion de Sacudida / Agitado (Shake Gesture)
io.imu_is_shake(imu_soa, threshold_g) = {
    ax = get_soa(imu_soa, 0, 0, 4)
    ay = get_soa(imu_soa, 1, 0, 4)
    az = get_soa(imu_soa, 2, 0, 4)

    total_accel = sqrt((ax * ax) + (ay * ay) + (az * az))
    // Descontar aceleracion de la gravedad estatica (1.0G = ~9.8 m/s^2)
    dynamic_accel = abs(total_accel - 9.806)

    if (dynamic_accel > threshold_g) {
        1.0
    } else {
        0.0
    }
}

// ===============================================================
// 11. Modulo de Camara y Captura de Pantalla
// ===============================================================

io.alloc_media() = {
    alloc_soa(6, 4)
}

io.media_init(media_soa, cam_id, w, h) = {
    set_soa(media_soa, 0, 0, 4, cam_id)
    set_soa(media_soa, 1, 0, 4, 1.0)
    set_soa(media_soa, 2, 0, 4, w)
    set_soa(media_soa, 3, 0, 4, h)
    set_soa(media_soa, 4, 0, 4, 60.0)
    set_soa(media_soa, 5, 0, 4, 0.0)
    1.0
}

io.screen_capture_request(media_soa) = {
    set_soa(media_soa, 5, 0, 4, 1.0)
    1.0
}

io.screen_capture_poll(media_soa) = {
    req = get_soa(media_soa, 5, 0, 4)
    if (req == 1.0) {
        set_soa(media_soa, 5, 0, 4, 0.0)
        1.0
    } else {
        0.0
    }
}

// ===============================================================
// 12. Alias Globales de Conveniencia
// ===============================================================
alloc_keyboard(cap) = io.alloc_keyboard(cap)
set_key_state(kb, i, k, d, cap) = io.set_key_state(kb, i, k, d, cap)
is_key_down(kb, k, n, cap) = io.is_down(kb, k, n, cap)
key_just_pressed(kb, k, n, cap) = io.just_pressed(kb, k, n, cap)

alloc_gamepad() = io.alloc_gamepad()
gamepad_set_axes(gp, lx, ly, rx, ry) = io.gamepad_set_axes(gp, lx, ly, rx, ry)
gamepad_set_buttons(gp, a, b, x, y) = io.gamepad_set_buttons(gp, a, b, x, y)
filter_deadzone(v, dz) = io.filter_deadzone(v, dz)

alloc_touches(n) = io.alloc_touches(n)
touch_update(t, s, id, x, y, act, pr, cap) = io.touch_update(t, s, id, x, y, act, pr, cap)
touch_dx(t, s, cap) = io.touch_dx(t, s, cap)
touch_dy(t, s, cap) = io.touch_dy(t, s, cap)
touch_distance(x1, y1, x2, y2) = io.touch_distance(x1, y1, x2, y2)
touch_pinch_ratio(t, cap) = io.touch_pinch_ratio(t, cap)

alloc_imu() = io.alloc_imu()
imu_set_raw(imu, ax, ay, az, gx, gy, gz) = io.imu_set_raw(imu, ax, ay, az, gx, gy, gz)
imu_update_fusion(imu, dt, alpha) = io.imu_update_fusion(imu, dt, alpha)
imu_is_shake(imu, th) = io.imu_is_shake(imu, th)
