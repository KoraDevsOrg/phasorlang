// ===============================================================
// LIB/COLOR.PH — Motor Físico Espectral de Color en Hertz
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Conversión Físico-Óptica entre Frecuencia (4.0e14 a 7.5e14 Hz),
// Componentes RGB (0-255), Hexadecimal (0xRRGGBB) y Nombres Nominales
// ===============================================================

// Constantes físicas del espectro óptico
// Frecuencia mínima visible (Rojo profundo): 400 THz = 4.0e14 Hz (~750 nm)
// Frecuencia máxima visible (Violeta extremo): 750 THz = 7.5e14 Hz (~400 nm)
// Velocidad de la luz: c = 2.99792458e8 m/s

// 1. Conversión de Frecuencia Espectral (Hz) a Canal Rojo (0 - 255)
hz_to_r(hz) = {
    // Normalizar frecuencia relativa entre 4.0e14 y 7.5e14
    f = hz
    if (f < 4.0e14) { f = 4.0e14 } else { 1.0 }
    if (f > 7.5e14) { f = 7.5e14 } else { 1.0 }

    // Rango rojo-naranja-amarillo (4.0e14 a 5.4e14)
    if (f < 5.1e14) {
        255.0
    } else {
        if (f < 5.8e14) {
            // Caída de rojo hacia verde
            frac = (5.8e14 - f) / 7.0e13
            frac * 255.0
        } else {
            if (f > 6.8e14) {
                // Componente rojo en el violeta espectral
                frac = (f - 6.8e14) / 7.0e13
                frac * 160.0
            } else {
                0.0
            }
        }
    }
}

// 2. Conversión de Frecuencia Espectral (Hz) a Canal Verde (0 - 255)
hz_to_g(hz) = {
    f = hz
    if (f < 4.0e14) { f = 4.0e14 } else { 1.0 }
    if (f > 7.5e14) { f = 7.5e14 } else { 1.0 }

    // Verde ausente en rojo profundo
    if (f < 4.8e14) {
        0.0
    } else {
        if (f < 5.5e14) {
            // Subida rápida de verde (naranja -> amarillo -> verde)
            frac = (f - 4.8e14) / 7.0e13
            frac * 255.0
        } else {
            if (f < 6.2e14) {
                // Meseta verde y cian
                255.0
            } else {
                if (f < 6.8e14) {
                    // Caída de verde hacia azul
                    frac = (6.8e14 - f) / 6.0e13
                    frac * 255.0
                } else {
                    0.0
                }
            }
        }
    }
}

// 3. Conversión de Frecuencia Espectral (Hz) a Canal Azul (0 - 255)
hz_to_b(hz) = {
    f = hz
    if (f < 4.0e14) { f = 4.0e14 } else { 1.0 }
    if (f > 7.5e14) { f = 7.5e14 } else { 1.0 }

    if (f < 5.8e14) {
        0.0
    } else {
        if (f < 6.4e14) {
            // Subida hacia cian y azul
            frac = (f - 5.8e14) / 6.0e13
            frac * 255.0
        } else {
            // Azul pleno y violeta
            255.0
        }
    }
}

// 4. Empaquetar componentes RGB (0-255) a valor entero Hex (0xRRGGBB)
rgb_to_hex(r, g, b) = {
    r_clamped = r
    if (r_clamped < 0.0) { r_clamped = 0.0 } else { 1.0 }
    if (r_clamped > 255.0) { r_clamped = 255.0 } else { 1.0 }

    g_clamped = g
    if (g_clamped < 0.0) { g_clamped = 0.0 } else { 1.0 }
    if (g_clamped > 255.0) { g_clamped = 255.0 } else { 1.0 }

    b_clamped = b
    if (b_clamped < 0.0) { b_clamped = 0.0 } else { 1.0 }
    if (b_clamped > 255.0) { b_clamped = 255.0 } else { 1.0 }

    // Empaquetado binario por multiplicación posicional
    (r_clamped * 65536.0) + (g_clamped * 256.0) + b_clamped
}

// 5. Conversión directa transparente de Frecuencia en Hertz a Hex (0xRRGGBB)
hz_to_hex(hz) = {
    r = hz_to_r(hz)
    g = hz_to_g(hz)
    b = hz_to_b(hz)
    rgb_to_hex(r, g, b)
}

// 6. Conversión inversa de RGB a Frecuencia Espectral Dominante en Hertz
rgb_to_hz(r, g, b) = {
    total = r + g + b
    if (total <= 0.001) {
        // Negro / ausencia de radiación: se asume umbral infrarrojo
        4.0e14
    } else {
        rn = r / total
        gn = g / total
        bn = b / total

        // Estimación espectral ponderada
        // Rojo puro: 4.5e14, Verde puro: 5.6e14, Azul puro: 6.6e14
        hz_est = (rn * 4.4e14) + (gn * 5.6e14) + (bn * 6.7e14)
        hz_est
    }
}

// 7. Desempaquetado de color Hexadecimal a componentes individuales
hex_to_r(hex_val) = {
    (hex_val / 65536.0) % 256.0
}

hex_to_g(hex_val) = {
    (hex_val / 256.0) % 256.0
}

hex_to_b(hex_val) = {
    hex_val % 256.0
}

// 8. Frecuencia Espectral Nominal en Hertz a partir de Códigos Nominales
// 1 = Rojo, 2 = Naranja, 3 = Amarillo, 4 = Verde, 5 = Cian, 6 = Azul, 7 = Violeta
color_name_to_hz(code) = {
    if (code == 1.0) {
        4.4e14 // Rojo (~680 nm)
    } else {
        if (code == 2.0) {
            4.9e14 // Naranja (~610 nm)
        } else {
            if (code == 3.0) {
                5.2e14 // Amarillo (~575 nm)
            } else {
                if (code == 4.0) {
                    5.6e14 // Verde (~535 nm)
                } else {
                    if (code == 5.0) {
                        6.2e14 // Cian (~485 nm)
                    } else {
                        if (code == 6.0) {
                            6.6e14 // Azul (~455 nm)
                        } else {
                            7.1e14 // Violeta (~420 nm)
                        }
                    }
                }
            }
        }
    }
}

// 9. Código Nominal a partir de una Frecuencia en Hertz
hz_to_color_name_code(hz) = {
    if (hz < 4.7e14) {
        1.0 // Rojo
    } else {
        if (hz < 5.05e14) {
            2.0 // Naranja
        } else {
            if (hz < 5.4e14) {
                3.0 // Amarillo
            } else {
                if (hz < 6.0e14) {
                    4.0 // Verde
                } else {
                    if (hz < 6.4e14) {
                        5.0 // Cian
                    } else {
                        if (hz < 6.9e14) {
                            6.0 // Azul
                        } else {
                            7.0 // Violeta
                        }
                    }
                }
            }
        }
    }
}

// 10. Mezcla Espectral Armónica de dos frecuencias (Interpolación óptica)
spectral_blend_hz(hz1, hz2, t) = {
    clamped_t = t
    if (clamped_t < 0.0) { clamped_t = 0.0 } else { 1.0 }
    if (clamped_t > 1.0) { clamped_t = 1.0 } else { 1.0 }
    
    // Interpolación armónica lineal continua
    (hz1 * (1.0 - clamped_t)) + (hz2 * clamped_t)
}

// 11. Efecto Doppler Relativista Óptico (Corrimiento al Rojo / Azul)
// v_c = velocidad relativa de la fuente / c (-1.0 a 1.0). Positivo = alejándose (Redshift)
doppler_shift_hz(base_hz, v_c) = {
    // Factor de corrimiento aproximado: f' = f * (1 - v/c)
    shift_factor = 1.0 - v_c
    if (shift_factor < 0.1) { shift_factor = 0.1 } else { 1.0 }
    base_hz * shift_factor
}

// 12. Conversión nominal de nombre de color a frecuencia en Hertz (400-750 THz)
hz_from_name(name) = {
    if (name == "red") {
        4.4e14
    } else {
        if (name == "rojo") {
            4.4e14
        } else {
            if (name == "green") {
                5.6e14
            } else {
                if (name == "verde") {
                    5.6e14
                } else {
                    if (name == "blue") {
                        6.6e14
                    } else {
                        if (name == "azul") {
                            6.6e14
                        } else {
                            if (name == "yellow") {
                                5.2e14
                            } else {
                                if (name == "amarillo") {
                                    5.2e14
                                } else {
                                    if (name == "cyan") {
                                        6.2e14
                                    } else {
                                        if (name == "cian") {
                                            6.2e14
                                        } else {
                                            if (name == "orange") {
                                                4.9e14
                                            } else {
                                                if (name == "naranja") {
                                                    4.9e14
                                                } else {
                                                    if (name == "violet") {
                                                        7.1e14
                                                    } else {
                                                        if (name == "violeta") {
                                                            7.1e14
                                                        } else {
                                                            color_name_to_hz(name)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

color.hz_from_name(name) = {
    hz_from_name(name)
}

// 13. Conversión de componentes RGB a frecuencia espectral equivalente en Hertz
hz_from_rgb(r, g, b) = {
    rgb_to_hz(r, g, b)
}

color.hz_from_rgb(r, g, b) = {
    hz_from_rgb(r, g, b)
}

// 14. Conversión de frecuencia espectral en Hertz a valor de píxel RGB empaquetado (0xRRGGBB)
hz_to_pixel_color(hz) = {
    if (hz == 4.4e14) {
        16711680.0 // 0xFF0000 (Rojo puro)
    } else {
        if (hz == 5.6e14) {
            65280.0 // 0x00FF00 (Verde puro)
        } else {
            if (hz == 6.6e14) {
                255.0 // 0x0000FF (Azul puro)
            } else {
                if (hz == 5.2e14) {
                    16776960.0 // 0xFFFF00 (Amarillo puro)
                } else {
                    hz_to_hex(hz)
                }
            }
        }
    }
}

color.hz_to_pixel_color(hz) = {
    hz_to_pixel_color(hz)
}


