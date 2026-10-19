// ===============================================================
// PANTALLA 2: Lectura y Mutación de Estado Global Compartido
// ===============================================================

screen pantalla2 {
    cls(0x161B22)

    // Tarjeta superior con información persistente
    rect(30, 30, 320, 160, 0x0E1117)
    text("PANTALLA 2 - ESTADO VIVO", 45, 45, 14, 0xD29922)
    text("Valor leido en memoria:", 45, 80, 16, 0x8B949E)
    text(puntos, 45, 115, 40, 0x58A6FF)

    // Botones de interacción
    btn("Duplicar Puntos (*2)", 40, 220, 300, 50, duplicar, 0x8957E5)
    btn("Volver a Pantalla 1", 40, 290, 300, 50, pantalla1, 0x30363D)
}

action duplicar {
    puntos = puntos * 2
}
