// ===============================================================
// GRAFICADORA_FASORIAL.FAS — Calculadora Gráfica Fasorial Multi-Ventana
// PhasorLang v1.0 [KoraDevs Ecosystem — Chronos IDE]
//
// Demuestra el Paradigma Multi-Ventana Nativo de PhasorLang:
// - Ventana 1 (<s>1): Ecuaciones, Parámetros y Señales Fasoriales
// - Ventana 2 (<s>2): Lienzo Gráfico Cartesiano & Polar a 120 FPS
// - Ventana 3 (<s>3): Teclado Científico, Presets y Ajustes de Zoom
// ===============================================================

signal amp = 2.0
signal freq = 1.0
signal fase = 45.0
signal zoom = 1.0
signal tipo_onda = 1.0
signal r_res = 12.0
signal x_react = 16.0

out("=== INICIANDO CALCULADORA GRÁFICA FASORIAL KORADEVS ===")
out("[Parametros Iniciales] Amp:", amp)
out("[Parametros Iniciales] Freq:", freq)
out("[Parametros Iniciales] Fase:", fase)

// ===============================================================
// VENTANA 1: ECUACIONES Y PARÁMETROS FASORIALES (<s>1)
// ===============================================================
screen ecuaciones {
    cls(0x0B0E14)

    // Marco exterior de la ventana
    rect(10, 10, 350, 480, 0x161B22)
    line(10, 10, 360, 10, 0x30363D)
    line(360, 10, 360, 490, 0x30363D)
    line(360, 490, 10, 490, 0x30363D)
    line(10, 490, 10, 10, 0x30363D)

    // Título principal
    text("ECUACIONES & SEÑALES FASORIALES", 22, 22, 11, 0x58A6FF)

    // Tarjeta 1: Función Matemática Activa
    rect(20, 42, 330, 68, 0x0D1117)
    line(20, 42, 350, 42, 0x21262D)
    line(350, 42, 350, 110, 0x21262D)
    line(350, 110, 20, 110, 0x21262D)
    line(20, 110, 20, 42, 0x21262D)

    text("FORMA DE ONDA / ECUACIÓN ACTIVA:", 30, 52, 9, 0x8B949E)
    if (tipo_onda == 1.0) {
        text("f(t) = A * sin(w*t + phi)", 30, 72, 13, 0x3FB950)
        text("Onda Senoidal Pura (Fasor Base)", 30, 92, 9, 0x79C0FF)
    }
    if (tipo_onda == 2.0) {
        text("f(t) = A * cos(w*t) [Fasor 90°]", 30, 72, 13, 0x58A6FF)
        text("Señal en Cuadratura (Componente Real)", 30, 92, 9, 0x79C0FF)
    }
    if (tipo_onda == 3.0) {
        text("f(t) = A * sin(3w*t + 45°)", 30, 72, 13, 0xBC8CFF)
        text("Armónico de Alta Frecuencia (3w)", 30, 92, 9, 0x79C0FF)
    }
    if (tipo_onda == 4.0) {
        text("f(t) = A * exp(-0.1t) * sin(w*t)", 30, 72, 13, 0xD29922)
        text("Oscilación Amortiguada Transitoria", 30, 92, 9, 0x79C0FF)
    }

    // Tarjeta 2: Panel de Parámetros Dinámicos
    rect(20, 122, 330, 210, 0x0D1117)
    line(20, 122, 350, 122, 0x21262D)
    line(350, 122, 350, 332, 0x21262D)
    line(350, 332, 20, 332, 0x21262D)
    line(20, 332, 20, 122, 0x21262D)

    text("AJUSTE DE PARÁMETROS FASORIALES:", 30, 134, 9, 0x58A6FF)

    // Fila 1: Amplitud A
    text("Amplitud (A):", 30, 158, 10, 0xC9D1D9)
    text(amp, 140, 158, 11, 0x3FB950)
    btn("A +", 205, 152, 60, 30, act_amp_mas, 0x1F6FEB)
    btn("A -", 275, 152, 60, 30, act_amp_menos, 0x21262D)

    // Fila 2: Frecuencia Angular w
    text("Frecuencia (w):", 30, 198, 10, 0xC9D1D9)
    text(freq, 140, 198, 11, 0x3FB950)
    btn("w +", 205, 192, 60, 30, act_freq_mas, 0x1F6FEB)
    btn("w -", 275, 192, 60, 30, act_freq_menos, 0x21262D)

    // Fila 3: Fase phi
    text("Fase (phi):", 30, 238, 10, 0xC9D1D9)
    text(fase, 140, 238, 11, 0x3FB950)
    btn("phi +", 205, 232, 60, 30, act_fase_mas, 0x1F6FEB)
    btn("phi -", 275, 232, 60, 30, act_fase_menos, 0x21262D)

    // Separador
    line(30, 276, 340, 276, 0x21262D)

    // Notación Fasorial Polar y Compleja
    text("Fasor Polar:", 30, 288, 10, 0x8B949E)
    text(amp, 120, 288, 10, 0x58A6FF)
    text("/_ deg:", 145, 288, 10, 0x8B949E)
    text(fase, 195, 288, 10, 0x58A6FF)

    text("Impedancia RLC:", 30, 310, 10, 0x8B949E)
    text("Z = 12.0 + j16.0 Ohm (|Z|=20.0)", 140, 310, 9, 0x3FB950)

    // Tarjeta 3: Telemetría de Frecuencia
    rect(20, 344, 330, 126, 0x0D1117)
    line(20, 344, 350, 344, 0x21262D)
    line(350, 344, 350, 470, 0x21262D)
    line(350, 470, 20, 470, 0x21262D)
    line(20, 470, 20, 344, 0x21262D)

    text("TELEMETRÍA FASORIAL ZERO-GC:", 30, 356, 9, 0x3FB950)
    text("Periodo T = 2*pi / w [s]", 30, 376, 9, 0x79C0FF)
    text("Modulo Fasor = sqrt(Re^2 + Im^2)", 30, 396, 9, 0x79C0FF)
    text("Angulo Fasor = arctan(Im / Re)", 30, 416, 9, 0x79C0FF)
    text("Tasa de Muestreo: 120 FPS PVM SoA", 30, 436, 9, 0x58A6FF)
}

// ===============================================================
// VENTANA 2: LIENZO GRÁFICO CARTESIANO & POLAR (<s>2)
// ===============================================================
screen grafico {
    cls(0x05080E)

    // Cuadrícula sutil de fondo
    line(40, 60, 40, 440, 0x101620)
    line(80, 60, 80, 440, 0x101620)
    line(120, 60, 120, 440, 0x101620)
    line(160, 60, 160, 440, 0x101620)
    line(200, 60, 200, 440, 0x101620)
    line(240, 60, 240, 440, 0x101620)
    line(280, 60, 280, 440, 0x101620)
    line(320, 60, 320, 440, 0x101620)
    line(360, 60, 360, 440, 0x101620)
    line(400, 60, 400, 440, 0x101620)
    line(440, 60, 440, 440, 0x101620)
    line(480, 60, 480, 440, 0x101620)
    line(520, 60, 520, 440, 0x101620)

    line(20, 120, 550, 120, 0x101620)
    line(20, 160, 550, 160, 0x101620)
    line(20, 200, 550, 200, 0x101620)
    line(20, 240, 550, 240, 0x161B22)
    line(20, 280, 550, 280, 0x101620)
    line(20, 320, 550, 320, 0x101620)
    line(20, 360, 550, 360, 0x101620)

    // Encabezado del lienzo gráfico
    text("PLANO COMPLEJO (FASOR) | FORMA DE ONDA TEMPORAL f(t)", 20, 20, 11, 0x58A6FF)
    text("Lienzo Cartesiano & Polar • 120 FPS Zero-GC", 20, 36, 9, 0x8B949E)

    // -----------------------------------------------------------
    // 1. PLANO COMPLEJO / CÍRCULO TRIGONOMÉTRICO (Izquierda)
    // -----------------------------------------------------------
    // Origen de coordenadas del fasor: (140, 240)
    line(40, 240, 240, 240, 0x30363D)  // Eje Real (Horizontal)
    line(140, 140, 140, 340, 0x30363D) // Eje Imaginario (Vertical)
    text("Re", 244, 235, 9, 0x58A6FF)
    text("+j Im", 144, 134, 9, 0x58A6FF)

    // Círculo unitario fasorial escalado por la amplitud
    circle(140, 240, 75, 0x1F6FEB)
    circle(140, 240, 40, 0x161B22)

    // Vector Fasorial Rotatorio según la fase activa
    if (fase == 0.0) {
        line(140, 240, 215, 240, 0x3FB950)
        circle(215, 240, 5, 0x3FB950)
        line(215, 240, 260, 240, 0x8957E5) // Proyección
    }
    if (fase == 45.0) {
        line(140, 240, 193, 187, 0x3FB950)
        circle(193, 187, 5, 0x3FB950)
        line(193, 187, 260, 187, 0x8957E5)
    }
    if (fase == 90.0) {
        line(140, 240, 140, 165, 0x3FB950)
        circle(140, 165, 5, 0x3FB950)
        line(140, 165, 260, 165, 0x8957E5)
    }
    if (fase == 180.0) {
        line(140, 240, 65, 240, 0x3FB950)
        circle(65, 240, 5, 0x3FB950)
        line(65, 240, 260, 240, 0x8957E5)
    }

    // -----------------------------------------------------------
    // 2. LIENZO TEMPORAL CONTINUO f(t) (Derecha)
    // -----------------------------------------------------------
    // Eje de tiempo central
    line(260, 240, 550, 240, 0x58A6FF)
    text("t [s]", 552, 235, 9, 0x58A6FF)

    // Líneas límites de amplitud (+A y -A)
    line(260, 165, 550, 165, 0x21262D)
    line(260, 315, 550, 315, 0x21262D)
    text("+A", 264, 155, 9, 0x8B949E)
    text("-A", 264, 318, 9, 0x8B949E)

    // Trazado continuo de la onda senoidal mediante 14 segmentos matemáticos
    if (fase == 0.0) {
        line(260, 240, 280, 190, 0x3FB950)
        line(280, 190, 300, 165, 0x3FB950)
        line(300, 165, 320, 190, 0x3FB950)
        line(320, 190, 340, 240, 0x3FB950)
        line(340, 240, 360, 290, 0x3FB950)
        line(360, 290, 380, 315, 0x3FB950)
        line(380, 315, 400, 290, 0x3FB950)
        line(400, 290, 420, 240, 0x3FB950)
        line(420, 240, 440, 190, 0x3FB950)
        line(440, 190, 460, 165, 0x3FB950)
        line(460, 165, 480, 190, 0x3FB950)
        line(480, 190, 500, 240, 0x3FB950)
        line(500, 240, 520, 290, 0x3FB950)
        line(520, 290, 540, 315, 0x3FB950)
    }
    if (fase == 45.0) {
        line(260, 187, 280, 165, 0x3FB950)
        line(280, 165, 300, 190, 0x3FB950)
        line(300, 190, 320, 240, 0x3FB950)
        line(320, 240, 340, 290, 0x3FB950)
        line(340, 290, 360, 315, 0x3FB950)
        line(360, 315, 380, 290, 0x3FB950)
        line(380, 290, 400, 240, 0x3FB950)
        line(400, 240, 420, 190, 0x3FB950)
        line(420, 190, 440, 165, 0x3FB950)
        line(440, 165, 460, 190, 0x3FB950)
        line(460, 190, 480, 240, 0x3FB950)
        line(480, 240, 500, 290, 0x3FB950)
        line(500, 290, 520, 315, 0x3FB950)
        line(520, 315, 540, 290, 0x3FB950)
    }
    if (fase == 90.0) {
        line(260, 165, 280, 190, 0x3FB950)
        line(280, 190, 300, 240, 0x3FB950)
        line(300, 240, 320, 290, 0x3FB950)
        line(320, 290, 340, 315, 0x3FB950)
        line(340, 315, 360, 290, 0x3FB950)
        line(360, 290, 380, 240, 0x3FB950)
        line(380, 240, 400, 190, 0x3FB950)
        line(400, 190, 420, 165, 0x3FB950)
        line(420, 165, 440, 190, 0x3FB950)
        line(440, 190, 460, 240, 0x3FB950)
        line(460, 240, 480, 290, 0x3FB950)
        line(480, 290, 500, 315, 0x3FB950)
        line(500, 315, 520, 290, 0x3FB950)
        line(520, 290, 540, 240, 0x3FB950)
    }
    if (fase == 180.0) {
        line(260, 240, 280, 290, 0x3FB950)
        line(280, 290, 300, 315, 0x3FB950)
        line(300, 315, 320, 290, 0x3FB950)
        line(320, 290, 340, 240, 0x3FB950)
        line(340, 240, 360, 190, 0x3FB950)
        line(360, 190, 380, 165, 0x3FB950)
        line(380, 165, 400, 190, 0x3FB950)
        line(400, 190, 420, 240, 0x3FB950)
        line(420, 240, 440, 290, 0x3FB950)
        line(440, 290, 460, 315, 0x3FB950)
        line(460, 315, 480, 290, 0x3FB950)
        line(480, 290, 500, 240, 0x3FB950)
        line(500, 240, 520, 190, 0x3FB950)
        line(520, 190, 540, 165, 0x3FB950)
    }

    // Pie de estado
    text("Vector Fasorial: Radio = A * 75px | Fase = phi [deg]", 20, 420, 9, 0x79C0FF)
    text("Forma de Onda: Muestreo continuo 120 FPS sin pausas GC", 20, 436, 9, 0x3FB950)
}

// ===============================================================
// VENTANA 3: TECLADO CIENTÍFICO, PRESETS Y ZOOM (<s>3)
// ===============================================================
screen teclado {
    cls(0x0B0E14)

    // Marco exterior de la ventana
    rect(10, 10, 280, 480, 0x161B22)
    line(10, 10, 290, 10, 0x30363D)
    line(290, 10, 290, 490, 0x30363D)
    line(290, 490, 10, 490, 0x30363D)
    line(10, 490, 10, 10, 0x30363D)

    text("PRESETS & TECLADO CIENTÍFICO", 20, 22, 11, 0x58A6FF)

    // Sección 1: Presets Inmediatos de Señal
    btn("Seno Simple (0 deg)", 20, 46, 260, 38, act_pre_seno, 0x238636)
    btn("Coseno / Cuadratura (90 deg)", 20, 92, 260, 38, act_pre_cos, 0x1F6FEB)
    btn("Armonico 3w (45 deg)", 20, 138, 260, 38, act_pre_alta, 0x8957E5)
    btn("Inversion de Fase (180 deg)", 20, 184, 260, 38, act_pre_amor, 0xD29922)

    // Separador
    line(20, 232, 280, 232, 0x21262D)

    // Sección 2: Controles de Escala y Zoom
    text("CONTROLES DE ZOOM Y VISTA:", 20, 246, 9, 0x8B949E)
    btn("Zoom +", 20, 266, 125, 38, act_zoom_in, 0x30363D)
    btn("Zoom -", 155, 266, 125, 38, act_zoom_out, 0x30363D)
    btn("Restablecer Parametros", 20, 312, 260, 38, act_reset, 0x21262D)

    // Sección 3: Tarjeta de Constantes Físicas y Matemáticas
    rect(20, 362, 260, 114, 0x0D1117)
    line(20, 362, 280, 362, 0x21262D)
    line(280, 362, 280, 476, 0x21262D)
    line(280, 476, 20, 476, 0x21262D)
    line(20, 476, 20, 362, 0x21262D)

    text("CONSTANTES FUNDAMENTALES:", 30, 374, 9, 0x3FB950)
    text("pi = 3.1415926535", 30, 394, 9, 0x79C0FF)
    text("e  = 2.7182818284", 30, 412, 9, 0x79C0FF)
    text("j  = sqrt(-1) [Unidad Imag]", 30, 430, 9, 0x79C0FF)
    text("Z0 = 376.73 Ohm [Vacio]", 30, 448, 9, 0x58A6FF)
}

// ===============================================================
// ACCIONES Y SUBRUTINAS DE ENTRADA Y CONTROL
// ===============================================================
action act_amp_mas {
    amp = amp + 0.5
    out("[Graficadora] Amplitud incrementada a:", amp)
}

action act_amp_menos {
    if (amp > 0.5) {
        amp = amp - 0.5
    }
    out("[Graficadora] Amplitud reducida a:", amp)
}

action act_freq_mas {
    freq = freq + 0.5
    out("[Graficadora] Frecuencia incrementada a:", freq)
}

action act_freq_menos {
    if (freq > 0.5) {
        freq = freq - 0.5
    }
    out("[Graficadora] Frecuencia reducida a:", freq)
}

action act_fase_mas {
    if (fase == 0.0) {
        fase = 45.0
    } else {
        if (fase == 45.0) {
            fase = 90.0
        } else {
            if (fase == 90.0) {
                fase = 180.0
            } else {
                fase = 0.0
            }
        }
    }
    out("[Graficadora] Fase modificada a:", fase)
}

action act_fase_menos {
    if (fase == 180.0) {
        fase = 90.0
    } else {
        if (fase == 90.0) {
            fase = 45.0
        } else {
            if (fase == 45.0) {
                fase = 0.0
            } else {
                fase = 180.0
            }
        }
    }
    out("[Graficadora] Fase reducida a:", fase)
}

action act_pre_seno {
    tipo_onda = 1.0
    amp = 2.0
    freq = 1.0
    fase = 0.0
    out("[Preset] Seno Simple activado")
}

action act_pre_cos {
    tipo_onda = 2.0
    amp = 2.0
    freq = 1.0
    fase = 90.0
    out("[Preset] Coseno / Cuadratura activado")
}

action act_pre_alta {
    tipo_onda = 3.0
    amp = 2.5
    freq = 2.0
    fase = 45.0
    out("[Preset] Armonico activado")
}

action act_pre_amor {
    tipo_onda = 4.0
    amp = 2.0
    freq = 1.0
    fase = 180.0
    out("[Preset] Inversion de Fase activada")
}

action act_zoom_in {
    zoom = zoom + 0.2
    out("[Vista] Zoom incrementado:", zoom)
}

action act_zoom_out {
    if (zoom > 0.4) {
        zoom = zoom - 0.2
    }
    out("[Vista] Zoom reducido:", zoom)
}

action act_reset {
    amp = 2.0
    freq = 1.0
    fase = 45.0
    zoom = 1.0
    tipo_onda = 1.0
    out("[Vista] Parametros restablecidos a valores nominales")
}
