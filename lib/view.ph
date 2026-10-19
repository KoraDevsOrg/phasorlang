// ===============================================================
// LIB/VIEW.PH — Libreria Grafica Nativa de Componentes Visuales
// PhasorLang v1.0 [Self-Hosting Etapa 3 & Decoupled Architecture]
// Renderizado procedural sobre Canvas Declarativo Zero-GC (90+ FPS)
// ===============================================================

// 1. Componente: Carta de Smith Dinamica (smith_chart)
// Renderiza el plano de coeficientes de reflexion Gamma (|Gamma| <= 1),
// circulos de resistencia normalizada y vector fasorial S11.
smith_chart(cx, cy, r, gr, gi) = {
    // Marco exterior unitario (|Gamma| = 1.0)
    circle(cx, cy, r, 0x30363D)

    // Eje real de transmision (horizontal central)
    line(cx - r, cy, cx + r, cy, 0x21262D)

    // Circulos de Resistencia Normalizada Constante
    // Circulo rn = 1.0 (Pasa por el centro Zo y por 1,0)
    r1_rad = r * 0.5
    circle(cx + r1_rad, cy, r1_rad, 0x21262D)

    // Circulo rn = 0.5 (Impedancias menores a Zo)
    r05_rad = r * 0.666
    circle(cx + (r * 0.333), cy, r05_rad, 0x161B22)

    // Circulo rn = 2.0 (Impedancias altas)
    r2_rad = r * 0.333
    circle(cx + (r * 0.666), cy, r2_rad, 0x161B22)

    // Centro del plano: Impedancia caracteristica normalizada (1.0 + j0.0)
    circle(cx, cy, 3, 0x58A6FF)
    text("Zo (50 ohm)", cx - 28, cy + 12, 10, 0x8B949E)
    text("SMITH CHART", cx - r, cy - r - 10, 11, 0x58A6FF)

    // Calculo del punto de reflexion fasorial S11: Gamma = gr + j*gi
    px = cx + (gr * r)
    py = cy - (gi * r)

    // Vector de reflexion fasorial
    line(cx, cy, px, py, 0x58A6FF)
    circle(px, py, 5, 0x39D353)
    text("S11", px + 8, py - 4, 11, 0x39D353)

    1.0
}

// 2. Componente: Osciloscopio de Lissajous (lissajous_scope)
// Visualiza el desfase y correlacion en cuadratura entre dos canales fasoriales (X e Y)
lissajous_scope(x, y, w, h, ch1, ch2) = {
    // Contenedor oscuro
    rect(x, y, w, h, 0x0D1117)

    // Bordes exteriores del visor
    line(x, y, x + w, y, 0x30363D)
    line(x + w, y, x + w, y + h, 0x30363D)
    line(x + w, y + h, x, y + h, 0x30363D)
    line(x, y + h, x, y, 0x30363D)

    // Reticula ortogonal central
    mid_x = x + (w * 0.5)
    mid_y = y + (h * 0.5)
    line(x, mid_y, x + w, mid_y, 0x1F242C)
    line(mid_x, y, mid_x, y + h, 0x1F242C)

    // Circulo guia de orbita
    guia_rad = (w * 0.38)
    circle(mid_x, mid_y, guia_rad, 0x161B22)

    // Titulo y telemetria
    text("LISSAJOUS (X/Y)", x + 10, y + 8, 11, 0xBC8CFF)

    // Calculo de posicion del haz fasorial X/Y
    spot_x = mid_x + (ch1 * guia_rad)
    spot_y = mid_y - (ch2 * guia_rad)

    line(mid_x, mid_y, spot_x, spot_y, 0x79C0FF)
    circle(spot_x, spot_y, 5, 0xBC8CFF)

    text("CH1 (X)", x + 10, y + h - 16, 10, 0x00E5FF)
    text("CH2 (Y)", x + w - 55, y + h - 16, 10, 0xBC8CFF)

    1.0
}

// 3. Componente: Plano Cartesiano Temporal (cartesian_plane)
// Renderiza el dominio del tiempo con eje de cero voltios, lineas de referencia y amplitud
cartesian_plane(x, y, w, h, ejeX, ejeY) = {
    // Contenedor del visor
    rect(x, y, w, h, 0x0D1117)

    // Bordes exteriores
    line(x, y, x + w, y, 0x30363D)
    line(x + w, y, x + w, y + h, 0x30363D)
    line(x + w, y + h, x, y + h, 0x30363D)
    line(x, y + h, x, y, 0x30363D)

    // Eje de cero y lineas de cuadricula (+0.5V y -0.5V)
    mid_y = y + (h * 0.5)
    line(x, mid_y, x + w, mid_y, 0x238636)
    line(x, y + (h * 0.25), x + w, y + (h * 0.25), 0x161B22)
    line(x, y + (h * 0.75), x + w, y + (h * 0.75), 0x161B22)

    // Titulo
    text("PLANO CARTESIANO [t]", x + 10, y + 8, 11, 0x3FB950)

    // Amplitud y haz de onda instantaneo
    amp_scale = (h * 0.40)
    wave_y = mid_y - (ejeY * amp_scale)

    line(x, wave_y, x + w, wave_y, 0x1F6FEB)
    circle(x + (w * 0.5), wave_y, 5, 0x3FB950)

    text("V(t)", x + 10, y + h - 16, 10, 0x3FB950)
    text("0.0V", x + w - 35, mid_y - 6, 9, 0x8B949E)

    1.0
}

// 4. Alias de compatibilidad funcional
smith(cx, cy, r, gr, gi) = smith_chart(cx, cy, r, gr, gi)
lissajous(x, y, w, h, ch1, ch2) = lissajous_scope(x, y, w, h, ch1, ch2)
cartesian(x, y, w, h, ex, ey) = cartesian_plane(x, y, w, h, ex, ey)
