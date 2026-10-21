// ===============================================================================
// LIB/CALCULUS.PH — Módulo de Cálculo Diferencial, Integral y Fasorial Zero-GC
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Integración Numérica (Trapecios, Simpson, Fourier) y Diferenciación Continua
// Invariante Estricto: 0 bytes en Heap, bucles deterministas a 120 FPS
// ===============================================================================

// 1. Evaluación de Funciones Matemáticas Escalares Paramétricas
// f_id: Selector de función
// 1.0 = Seno sin(x)
// 2.0 = Coseno cos(x)
// 3.0 = Parábola polinómica x^2
// 4.0 = Curva Cúbica x^3 - x
// 5.0 = Campana Gaussiana 1 / (1 + 0.5*x^2)
// 6.0 = Onda cuadrada aproximada
calc_eval_func(f_id, x) = {
    res = 0.0
    if (f_id == 1.0) {
        res = sin(x)
    } else {
        if (f_id == 2.0) {
            res = cos(x)
        } else {
            if (f_id == 3.0) {
                res = x * x
            } else {
                if (f_id == 4.0) {
                    res = (x * x * x) - x
                } else {
                    if (f_id == 5.0) {
                        res = 1.0 / (1.0 + (x * x * 0.5))
                    } else {
                        res = x
                    }
                }
            }
        }
    }
    res
}

// 2. Integral Definida por Regla Trapezoidal Compuesta O(N) Zero-GC
// I = ∫[a,b] f(x) dx ≈ h * [ 0.5*f(a) + 0.5*f(b) + ∑_{k=1}^{N-1} f(a + k*h) ]
integral_trapezoidal(f_id, a, b, n_steps) = {
    steps = n_steps
    if (steps < 2.0) { steps = 2.0 } else { 1.0 }

    h = (b - a) / steps
    fa = calc_eval_func(f_id, a)
    fb = calc_eval_func(f_id, b)
    sum_interior = 0.0

    k = 1.0
    while (k < steps) {
        xk = a + (k * h)
        fk = calc_eval_func(f_id, xk)
        sum_interior = sum_interior + fk
        k = k + 1.0
    }

    area = h * ((0.5 * fa) + (0.5 * fb) + sum_interior)
    area
}

// 3. Integral Definida de Alta Precisión por Regla de Simpson 1/3 (Orden 4)
// I = ∫[a,b] f(x) dx ≈ (h/3) * [ f(a) + 4*∑(impares) + 2*∑(pares) + f(b) ]
integral_simpson(f_id, a, b, n_pairs) = {
    pairs = n_pairs
    if (pairs < 2.0) { pairs = 2.0 } else { 1.0 }
    n = pairs * 2.0 // subdivisiones pares obligatorias
    h = (b - a) / n

    fa = calc_eval_func(f_id, a)
    fb = calc_eval_func(f_id, b)
    sum_odds = 0.0
    sum_evens = 0.0

    i = 1.0
    while (i < n) {
        xi = a + (i * h)
        fi = calc_eval_func(f_id, xi)
        is_odd = i % 2.0
        if (is_odd == 1.0) {
            sum_odds = sum_odds + fi
        } else {
            sum_evens = sum_evens + fi
        }
        i = i + 1.0
    }

    area = (h / 3.0) * (fa + (4.0 * sum_odds) + (2.0 * sum_evens) + fb)
    area
}

// 4. Integración Temporal Reactiva Continua (Euler / DSP / Robótica PID)
// y_k = y_{k-1} + (valor_muestreado * dt)
integral_step(accum, val, dt, max_windup) = {
    new_accum = accum + (val * dt)
    if (new_accum > max_windup) { new_accum = max_windup } else { 1.0 }
    if (new_accum < (0.0 - max_windup)) { new_accum = 0.0 - max_windup } else { 1.0 }
    new_accum
}

// 5. Diferenciación Numérica Finita Central (Derivada f'(x))
// f'(x) ≈ [f(x + h) - f(x - h)] / (2h)
derivative_central(f_id, x, h_step) = {
    h = h_step
    if (h == 0.0) { h = 0.0001 } else { 1.0 }
    xp = x + h
    xm = x - h
    f_plus = calc_eval_func(f_id, xp)
    f_minus = calc_eval_func(f_id, xm)
    delta = f_plus - f_minus
    two_h = 2.0 * h
    df = delta / two_h
    df
}

// 6. Cálculo de Potencia Eléctrica Activa Promedio por Integral Fasorial
// P = (1/T) ∫[0,T] v(t)*i(t) dt
integral_potencia_rms(v_mag, v_ang_deg, i_mag, i_ang_deg, freq_hz, steps) = {
    w = 2.0 * 3.14159265 * freq_hz
    t_period = 1.0 / freq_hz
    dt = t_period / steps

    v_rad = v_ang_deg * (3.14159265 / 180.0)
    i_rad = i_ang_deg * (3.14159265 / 180.0)

    p_sum = 0.0
    t = 0.0
    while (t < t_period) {
        vt = v_mag * sin((w * t) + v_rad)
        it = i_mag * sin((w * t) + i_rad)
        p_sum = p_sum + (vt * it * dt)
        t = t + dt
    }

    potencia = p_sum / t_period
    potencia
}
