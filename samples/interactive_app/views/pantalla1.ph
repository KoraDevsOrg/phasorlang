// ===============================================================
// PANTALLA 1: Contador y Estado Reactivo Local/Global
// ===============================================================

screen pantalla1 {
    cls(0x0E1117)

    // Tarjeta superior con información de estado
    rect(30, 30, 320, 160, 0x161B22)
    text("APP INTERACTIVA PHASOR", 45, 45, 14, 0x58A6FF)
    text("Puntos acumulados:", 45, 80, 16, 0x8B949E)
    text(puntos, 45, 115, 40, 0x3FB950)

    // Botones de interacción
    btn("Sumar Puntos (+1)", 40, 220, 300, 50, sumar, 0x238636)
    btn("Ir a Pantalla 2", 40, 290, 300, 50, pantalla2, 0x1F6FEB)
}

action sumar {
    puntos = puntos + 1
}
