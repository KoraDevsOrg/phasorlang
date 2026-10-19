// ===============================================================
// LIB/ROB.PH — Libreria de Robotica, Cinematica y Electronica
// PhasorLang v1.0 [Fase 11 Multi-Dominio — Chronos IDE]
// Cinematica Directa/Inversa (FK/IK) 2D/3D, Modulacion PWM, Servos,
// Control PID Zero-GC, GPIO, Buses Seriales e Impedancia RLC sobre SoA
// ===============================================================

// 1. Constantes Universales de Robotica y Fisica
PI_CONST = 3.141592653589793
TWO_PI   = 6.283185307179586
HALF_PI  = 1.570796326794896

// 2. Estructura SoA para Servos y Actuadores
struct ActuatorSoA {
    id: Float,            // Campo 0: ID del actuador / junta
    duty_cycle: Float,    // Campo 1: Ciclo de trabajo PWM [0.0, 1.0]
    freq_hz: Float,       // Campo 2: Frecuencia de excitacion (Hz, ej. 50Hz)
    pulse_us: Float,      // Campo 3: Ancho de pulso en microsegundos (1000-2000 us)
    current_angle: Float, // Campo 4: Angulo actual medido (grados o rad)
    target_angle: Float,  // Campo 5: Angulo objetivo / consigna
    max_torque: Float,    // Campo 6: Limite de torque / par maximo (Nm)
    state: Float          // Campo 7: Estado operacional (1=Habilitado, 0=Apagado)
}

// 3. Estructura SoA para Controlador PID Zero-GC
struct PidControllerSoA {
    kp: Float,          // Campo 0: Ganancia proporcional
    ki: Float,          // Campo 1: Ganancia integral
    kd: Float,          // Campo 2: Ganancia derivativa
    prev_error: Float,  // Campo 3: Error del frame anterior
    integral: Float,    // Campo 4: Acumulador integral
    max_integral: Float,// Campo 5: Anti-windup / Limite superior del integrador
    min_output: Float,  // Campo 6: Saturacion minima de salida
    max_output: Float   // Campo 7: Saturacion maxima de salida
}

// 4. Estructura SoA para Pines GPIO y Senales Digitales
struct GpioPinSoA {
    pin_num: Float,  // Campo 0: Numero de pin fisico o logico
    mode: Float,     // Campo 1: 0=INPUT, 1=OUTPUT, 2=PWM, 3=ANALOG
    state: Float,    // Campo 2: Estado logico actual (0.0 o 1.0)
    pull: Float      // Campo 3: 0=FLOTANTE, 1=PULL_UP, 2=PULL_DOWN
}

// 5. Estructura SoA para Ring Buffer de Comunicacion Serial / UART / Bluetooth
struct SerialBufferSoA {
    baud_rate: Float, // Campo 0: Velocidad en baudios (9600, 115200, etc.)
    head: Float,      // Campo 1: Puntero de escritura
    tail: Float,      // Campo 2: Puntero de lectura
    bytes_count: Float// Campo 3: Total de bytes en transito
}

// ===============================================================
// 6. Utilidades Trigonometricas Analiticas Zero-GC
// ===============================================================

// Aproximacion Pade Racional Ultra-Rapida para atan2(y, x) [-pi, pi]
rob.atan2(y, x) = {
    abs_y = abs(y)
    abs_x = abs(x)
    ang = 0.0

    if (abs_x >= abs_y) {
        if (abs_x > 0.000001) {
            r = y / x
            ang = r / (1.0 + (0.28 * r * r))
            if (x < 0.0) {
                if (y >= 0.0) {
                    ang = ang + 3.14159265
                } else {
                    ang = ang - 3.14159265
                }
            }
        }
    } else {
        r = x / y
        term = r / (1.0 + (0.28 * r * r))
        if (y > 0.0) {
            ang = 1.57079632 - term
        } else {
            ang = -1.57079632 - term
        }
    }
    ang
}

// ===============================================================
// 7. Cinematica Directa (FK) e Inversa (IK) de Brazos Roboticos
// ===============================================================

// Cinematica Directa (FK) Brazo Articulado Planar 2-Link (SCARA)
// Entrada: Longitudes L1, L2 y angulos th1, th2 en radianes
// Salida: Retorna la coordenada de extremo efector X (o usa getters)
rob.fk_2link_x(l1, th1, l2, th2) = {
    (l1 * cos(th1)) + (l2 * cos(th1 + th2))
}

rob.fk_2link_y(l1, th1, l2, th2) = {
    (l1 * sin(th1)) + (l2 * sin(th1 + th2))
}

// Cinematica Directa (FK) Codo intermedio (Joint 2)
rob.fk_elbow_x(l1, th1) = {
    l1 * cos(th1)
}

rob.fk_elbow_y(l1, th1) = {
    l1 * sin(th1)
}

// Cinematica Inversa (IK) Brazo Planar 2-Link (Ley del Coseno Analitica)
// Entrada: Longitudes L1, L2, posicion objetivo tx, ty, codo_arriba (1.0 o 0.0)
// Retorna angulo articular th2 en radianes
rob.ik_2link_th2(l1, l2, tx, ty, elbow_up) = {
    d_sq = (tx * tx) + (ty * ty)
    num = d_sq - (l1 * l1) - (l2 * l2)
    denom = 2.0 * l1 * l2
    if (denom < 0.0001) { denom = 0.0001 }

    cos_th2 = num / denom
    if (cos_th2 > 1.0)  { cos_th2 = 1.0 }
    if (cos_th2 < -1.0) { cos_th2 = -1.0 }

    sin_th2 = sqrt(1.0 - (cos_th2 * cos_th2))
    if (elbow_up == 0.0) {
        sin_th2 = -sin_th2
    }
    rob.atan2(sin_th2, cos_th2)
}

// Retorna angulo articular th1 en radianes para la misma configuracion
rob.ik_2link_th1(l1, l2, tx, ty, th2) = {
    k1 = l1 + (l2 * cos(th2))
    k2 = l2 * sin(th2)
    beta = rob.atan2(k2, k1)
    gamma = rob.atan2(ty, tx)
    gamma - beta
}

// Verificacion de Alcance del Extremo Efector
rob.is_reachable(l1, l2, tx, ty) = {
    dist = sqrt((tx * tx) + (ty * ty))
    max_reach = l1 + l2
    min_reach = abs(l1 - l2)
    if (dist <= max_reach) {
        if (dist >= min_reach) {
            1.0
        } else {
            0.0
        }
    } else {
        0.0
    }
}

// Cinematica 3D: Rotacion de Base Azimutal + Plano Polar
rob.arm_3d_x(r_planar, theta_base) = {
    r_planar * cos(theta_base)
}

rob.arm_3d_y(r_planar, theta_base) = {
    r_planar * sin(theta_base)
}

// ===============================================================
// 8. Gestion de Actuadores, Servos y Modulacion PWM
// ===============================================================

rob.alloc_actuators(capacity) = {
    alloc_soa(8, capacity)
}

// Configura angulo de servo y convierte a pulso PWM de 50Hz (1000 a 2000 microsegundos)
rob.set_servo_angle(act_soa, idx, angle_deg, cap) = {
    _deg = angle_deg
    if (_deg < 0.0)   { _deg = 0.0 }
    if (_deg > 180.0) { _deg = 180.0 }

    // Rango estandar de servo hobby: 1000 us (0 deg) a 2000 us (180 deg)
    pulse = 1000.0 + ((_deg / 180.0) * 1000.0)
    // A 50Hz, el periodo total T = 20,000 us -> Duty Cycle = pulse / 20000.0
    duty = pulse / 20000.0

    set_soa(act_soa, 0, idx, cap, idx)
    set_soa(act_soa, 1, idx, cap, duty)
    set_soa(act_soa, 2, idx, cap, 50.0)
    set_soa(act_soa, 3, idx, cap, pulse)
    set_soa(act_soa, 4, idx, cap, _deg)
    set_soa(act_soa, 5, idx, cap, _deg)
    set_soa(act_soa, 6, idx, cap, 1.5)
    set_soa(act_soa, 7, idx, cap, 1.0)
    pulse
}

// Generador de Onda PWM instantanea (Comparador Analitico de Portadora Diente de Sierra)
rob.pwm_sample(duty_cycle, t, freq_hz) = {
    period = 1.0 / freq_hz
    t_mod = t - (floor(t / period) * period)
    sawtooth = t_mod / period
    if (sawtooth <= duty_cycle) {
        1.0
    } else {
        0.0
    }
}

// ===============================================================
// 9. Controlador PID Zero-GC (Proporcional-Integral-Derivativo)
// ===============================================================

rob.alloc_pid(capacity) = {
    alloc_soa(8, capacity)
}

rob.pid_init(pid_soa, idx, kp, ki, kd, max_i, min_o, max_o, cap) = {
    set_soa(pid_soa, 0, idx, cap, kp)
    set_soa(pid_soa, 1, idx, cap, ki)
    set_soa(pid_soa, 2, idx, cap, kd)
    set_soa(pid_soa, 3, idx, cap, 0.0)
    set_soa(pid_soa, 4, idx, cap, 0.0)
    set_soa(pid_soa, 5, idx, cap, max_i)
    set_soa(pid_soa, 6, idx, cap, min_o)
    set_soa(pid_soa, 7, idx, cap, max_o)
    1.0
}

// Bucle de Control PID con Anti-Windup y Limitacion de Saturacion
rob.pid_update(pid_soa, idx, setpoint, measured, dt, cap) = {
    kp = get_soa(pid_soa, 0, idx, cap)
    ki = get_soa(pid_soa, 1, idx, cap)
    kd = get_soa(pid_soa, 2, idx, cap)
    prev_e = get_soa(pid_soa, 3, idx, cap)
    integral = get_soa(pid_soa, 4, idx, cap)
    max_i = get_soa(pid_soa, 5, idx, cap)
    min_o = get_soa(pid_soa, 6, idx, cap)
    max_o = get_soa(pid_soa, 7, idx, cap)

    error = setpoint - measured

    // Integracion con supresion de desbordamiento (Anti-Windup)
    new_integral = integral + (error * dt)
    if (new_integral > max_i)  { new_integral = max_i }
    if (new_integral < -max_i) { new_integral = -max_i }

    // Termino derivativo acotado
    safe_dt = dt
    if (safe_dt < 0.0001) { safe_dt = 0.0001 }
    derivative = (error - prev_e) / safe_dt

    // Esfuerzo de control resultante
    output = (kp * error) + (ki * new_integral) + (kd * derivative)

    // Saturacion de la senal de salida
    if (output > max_o) { output = max_o }
    if (output < min_o) { output = min_o }

    set_soa(pid_soa, 3, idx, cap, error)
    set_soa(pid_soa, 4, idx, cap, new_integral)
    output
}

// ===============================================================
// 10. GPIO y Senales Digitales / Seriales
// ===============================================================

rob.alloc_gpio(pins_count) = {
    alloc_soa(4, pins_count)
}

rob.gpio_write(gpio_soa, pin, state, cap) = {
    val = 0.0
    if (state > 0.5) { val = 1.0 }
    set_soa(gpio_soa, 0, pin, cap, pin)
    set_soa(gpio_soa, 1, pin, cap, 1.0)
    set_soa(gpio_soa, 2, pin, cap, val)
    val
}

rob.gpio_read(gpio_soa, pin, cap) = {
    get_soa(gpio_soa, 2, pin, cap)
}

rob.alloc_serial(capacity) = {
    alloc_soa(4, capacity)
}

// Verificacion de Suma de Comprobacion de Paquete (XOR Parity Checksum)
rob.packet_checksum(b0, b1, b2, b3) = {
    // Calculo modular de paridad de bytes
    sum = b0 + b1 + b2 + b3
    sum - (floor(sum / 256.0) * 256.0)
}

// Duracion temporal de 1 bit segun velocidad en baudios
rob.baud_period_us(baud_rate) = {
    1000000.0 / baud_rate
}

// ===============================================================
// 11. Circuitos Electronicos y Modelado Fasorial de Impedancia
// ===============================================================

// Frecuencia de Resonancia Natural RLC: f0 = 1 / (2*pi*sqrt(L*C))
rob.rlc_f0(inductance_h, capacitance_f) = {
    denom = 6.2831853 * sqrt(inductance_h * capacitance_f)
    if (denom < 0.000001) { denom = 0.000001 }
    1.0 / denom
}

// Factor de Calidad Q de Circuito RLC Serie: Q = (1 / R) * sqrt(L / C)
rob.rlc_quality_factor(r, l, c) = {
    safe_r = r
    if (safe_r < 0.0001) { safe_r = 0.0001 }
    (1.0 / safe_r) * sqrt(l / c)
}

// Modulo de Impedancia RLC Serie: |Z| = sqrt(R^2 + (XL - XC)^2)
rob.impedance_rlc_mag(r, l, c, freq) = {
    omega = 6.2831853 * freq
    xl = omega * l
    xc_denom = omega * c
    if (xc_denom < 0.000001) { xc_denom = 0.000001 }
    xc = 1.0 / xc_denom
    reactance = xl - xc
    sqrt((r * r) + (reactance * reactance))
}

// Constante de Torque de Motor Electrico: Torque = Kt * Corriente
rob.motor_torque(kt, current_a) = {
    kt * current_a
}

// Fuerza Contraelectromotriz (Back-EMF): V_emf = Ke * omega_rad_s
rob.motor_back_emf(ke, omega) = {
    ke * omega
}

// ===============================================================
// 12. Alias Globales de Conveniencia
// ===============================================================
atan2_fast(y, x) = rob.atan2(y, x)

fk_2link_x(l1, th1, l2, th2) = rob.fk_2link_x(l1, th1, l2, th2)
fk_2link_y(l1, th1, l2, th2) = rob.fk_2link_y(l1, th1, l2, th2)
fk_elbow_x(l1, th1) = rob.fk_elbow_x(l1, th1)
fk_elbow_y(l1, th1) = rob.fk_elbow_y(l1, th1)
ik_2link_th2(l1, l2, tx, ty, up) = rob.ik_2link_th2(l1, l2, tx, ty, up)
ik_2link_th1(l1, l2, tx, ty, th2) = rob.ik_2link_th1(l1, l2, tx, ty, th2)
is_reachable(l1, l2, tx, ty) = rob.is_reachable(l1, l2, tx, ty)

alloc_actuators(cap) = rob.alloc_actuators(cap)
set_servo_angle(act, i, deg, cap) = rob.set_servo_angle(act, i, deg, cap)
pwm_sample(duty, t, f) = rob.pwm_sample(duty, t, f)

alloc_pid(cap) = rob.alloc_pid(cap)
pid_init(p, i, kp, ki, kd, mi, min_o, max_o, cap) = rob.pid_init(p, i, kp, ki, kd, mi, min_o, max_o, cap)
pid_update(p, i, sp, meas, dt, cap) = rob.pid_update(p, i, sp, meas, dt, cap)

alloc_gpio(pins) = rob.alloc_gpio(pins)
gpio_write(g, p, s, cap) = rob.gpio_write(g, p, s, cap)
gpio_read(g, p, cap) = rob.gpio_read(g, p, cap)
alloc_serial(cap) = rob.alloc_serial(cap)
packet_checksum(b0, b1, b2, b3) = rob.packet_checksum(b0, b1, b2, b3)

rlc_f0(l, c) = rob.rlc_f0(l, c)
rlc_quality_factor(r, l, c) = rob.rlc_quality_factor(r, l, c)
impedance_rlc_mag(r, l, c, f) = rob.impedance_rlc_mag(r, l, c, f)
motor_torque(kt, i) = rob.motor_torque(kt, i)
motor_back_emf(ke, w) = rob.motor_back_emf(ke, w)
