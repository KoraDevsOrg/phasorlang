// ===============================================================
// LIB/UI.PH — Sistema de UI Reactivo, Adaptativo y Detección Automática
// PhasorLang v1.0 [Fase de Consolidación — Chronos IDE]
// Zero-GC, Zonas Táctiles Ergonómicas (>=44px Móvil) y Viewport R250/R251
// Maquetación "Llave en Cerradura" (<768px), Contenedores Padre/Hijo
// y Autocontención de Texto en Modales (Zero-Overflow)
// ===============================================================

// 1. Detección Automática de Dispositivo (Móvil vs Escritorio)
// Consulta los registros de lectura de viewport R250 (ancho) y R251 (alto).
// Retorna 1.0 si es pantalla móvil (<768px o aspect ratio vertical <= 1.0), 0.0 si es desktop.
auto_is_mobile() = {
    vw = R250
    vh = R251
    
    // Si el ancho es estrecho (< 768px) o la pantalla está en vertical, es móvil
    if (vw < 768.0) {
        1.0
    } else {
        if (vw <= vh) {
            1.0
        } else {
            0.0
        }
    }
}

ui.auto_is_mobile() = {
    auto_is_mobile()
}

// 2. Getters directos de Viewport inyectado en PVM (R250 / R251)
get_viewport_w() = {
    R250
}

get_viewport_h() = {
    R251
}

ui.get_w() = {
    R250
}

ui.get_h() = {
    R251
}

// 3. Altura ergonómica mínima de zona táctil según directrices de accesibilidad (Apple/Material)
touch_min_height() = {
    if (auto_is_mobile() == 1.0) {
        44.0 // Mínimo de 44px en móviles para toques precisos
    } else {
        32.0 // En escritorio con cursor de ratón es suficiente 32px
    }
}

// 4. Cálculos dimensionales para botones y componentes
ui.calc_button_h() = {
    if (auto_is_mobile() == 1.0) {
        48.0 // Altura táctil móvil ergonómica ampliada (>= 44px)
    } else {
        34.0 // Altura estándar para cursor de escritorio
    }
}

ui.calc_button_w(margin) = {
    if (auto_is_mobile() == 1.0) {
        // En móvil modo Llave en Cerradura: 100% del viewport menos márgenes laterales
        R250 - (margin * 2.0)
    } else {
        // En escritorio modo Docking Windows: ancho estándar de panel acoplable
        180.0
    }
}

// 5. Botón Adaptativo (ui.button)
ui.button() = {
    ui.calc_button_h()
}

ui.button_h() = {
    ui.calc_button_h()
}

ui.button_w(margin) = {
    ui.calc_button_w(margin)
}

btn_auto(text_id, x, y, w, action_id, color_val) = {
    h = ui.calc_button_h()
    btn(text_id, x, y, w, h, action_id, color_val)
    1.0
}

// 6. Contenedor Adaptativo al 100% de la Pantalla (screen_auto y ui.screen_auto)
// Se adapta dinámicamente al viewport R250/R251 sin necesidad de código condicional
screen_auto(bg_color) = {
    vw = R250
    vh = R251
    rect(0.0, 0.0, vw, vh, bg_color)
    line(0.0, 0.0, vw, 0.0, 0x30363D)
    vw
}

ui.screen_auto() = {
    screen_auto(0x0D1117)
}

ui.screen_auto(bg_color) = {
    screen_auto(bg_color)
}

ui.screen_w() = {
    R250
}

ui.screen_h() = {
    R251
}

// 7. Tarjeta Contenedora Adaptativa (card_auto)
card_auto(x, y, w, min_h, bg_color, border_color) = {
    rect(x, y, w, min_h, bg_color)
    line(x, y, x + w, y, border_color)
    line(x + w, y, x + w, y + min_h, border_color)
    line(x + w, y + min_h, x, y + min_h, border_color)
    line(x, y + min_h, x, y, border_color)
    1.0
}

// 8. Barra de Navegación / Encabezado Adaptativo
header_auto(title_id, bg_color, border_color) = {
    vw = R250
    is_mob = auto_is_mobile()
    nav_h = 56.0
    if (is_mob == 1.0) {
        nav_h = 64.0 // Holgura para Notch / Status Bar
    } else {
        nav_h = 48.0
    }

    rect(0.0, 0.0, vw, nav_h, bg_color)
    line(0.0, nav_h, vw, nav_h, border_color)
    
    // Título centrado verticalmente
    text_y = (nav_h * 0.5) - 8.0
    text("CHRONOS IDE - KORADEVS", 16.0, text_y, 14.0, 0x58A6FF)
    1.0
}

// 9. Cálculo de Columnas de Rejilla Adaptativa (grid_cols)
grid_auto_cols() = {
    vw = R250
    if (vw < 500.0) {
        1.0
    } else {
        if (vw < 900.0) {
            2.0
        } else {
            if (vw < 1300.0) {
                3.0
            } else {
                4.0
            }
        }
    }
}

// ===============================================================
// 10. AUTOCONTENCIÓN DE TEXTO EN MODALES (ui.modal_card)
// Calcula automáticamente el ancho disponible y reduce el tamaño
// de fuente para garantizar Zero-Overflow absoluto sin salirse de los bordes.
// ===============================================================

// Cálculo dinámico de fuente adaptativa para evitar desbordamiento
ui.modal_calc_font_size(w, padding, text_len, def_size) = {
    avail_w = w - (padding * 2.0)
    if (avail_w <= 0.0) {
        8.0
    } else {
        est_w = text_len * (def_size * 0.6)
        if (est_w > avail_w) {
            calc_s = avail_w / (text_len * 0.6)
            if (calc_s < 8.0) {
                8.0
            } else {
                calc_s
            }
        } else {
            def_size
        }
    }
}

// Cálculo del ancho efectivo del texto con la fuente escalada
ui.modal_calc_text_w(text_len, font_size) = {
    text_len * (font_size * 0.6)
}

// Verificación matemática de autocontención: retorna 1.0 si no hay desbordamiento
ui.modal_check_containment(w, padding, text_len, font_size) = {
    avail_w = w - (padding * 2.0)
    text_w = text_len * (font_size * 0.6)
    if (text_w <= avail_w) {
        1.0
    } else {
        0.0
    }
}

// Renderizado de modal con autocontención
modal_card(titulo_id, texto_msj_id, x, y, w, h) = {
    // Fondo de modal
    rect(x, y, w, h, 0x161B22)
    line(x, y, x + w, y, 0x58A6FF)
    line(x + w, y, x + w, y + h, 0x30363D)
    line(x + w, y + h, x, y + h, 0x30363D)
    line(x, y + h, x, y, 0x30363D)

    // Barra de título del modal
    title_h = 30.0
    rect(x, y, w, title_h, 0x21262D)
    line(x, y + title_h, x + w, y + title_h, 0x30363D)

    // Título ajustado
    text("MODAL DE DIALOGO", x + 12.0, y + 8.0, 11.0, 0x58A6FF)

    // Mensaje con padding de 14px
    text("AUTOCONTENIDO ZERO-OVERFLOW", x + 14.0, y + title_h + 16.0, 10.0, 0xC9D1D9)
    1.0
}

ui.modal_card(titulo_id, texto_msj_id, x, y, w, h) = {
    modal_card(titulo_id, texto_msj_id, x, y, w, h)
}

// ===============================================================
// 11. CONTENEDORES PADRE E HIJOS FLEXIBLES (WORKSPACE MAIN & SUB_SCREEN)
// Arquitectura escalable para N sub-pantallas hijas (1 a 32 hijos).
// Modo Escritorio: Drag & Drop libre, redimensión en tiempo real en todos los sentidos
//                  (arriba, abajo, izquierda, derecha, diagonal) y minimizado a barrita de título.
// Modo Móvil: Snap 100% al viewport y navegación 2D/360 virtual con 2 dedos/pellizco.
// ===============================================================

MAX_SUB_SCREENS = 32
// Estructura SoA plana para las sub-pantallas hijas (12 canales Zero-GC):
// 0: id
// 1: x (posición X en escritorio)
// 2: y (posición Y en escritorio)
// 3: w (ancho visible del viewport de la ventana)
// 4: h (alto visible del viewport de la ventana)
// 5: state (1.0 = expandida/cuerpo visible, 0.0 = minimizada a solo barra de título)
// 6: grid_x (coordenada virtual X para navegación móvil en cuadrante 2D/360)
// 7: grid_y (coordenada virtual Y para navegación móvil en cuadrante 2D/360)
// 8: scroll_x (desplazamiento horizontal del contenido interior)
// 9: scroll_y (desplazamiento vertical del contenido interior)
// 10: content_w (ancho virtual total del contenido interior)
// 11: content_h (alto virtual total del contenido interior)
sub_screens_soa = alloc_soa(12, MAX_SUB_SCREENS)

// Estado global de pantalla activa
ui_active_child = 0.0

// Contenedor Padre Principal (ui.workspace_main)
ui.workspace_main(bg_color) = {
    vw = R250
    vh = R251
    is_mob = auto_is_mobile()

    // Fondo del espacio de trabajo
    rect(0.0, 0.0, vw, vh, bg_color)

    if (is_mob == 1.0) {
        // En Móvil: delimitador sutil de viewport 100%
        line(0.0, 0.0, vw, 0.0, 0x30363D)
    } else {
        // En Escritorio: Barra superior de acoplamiento (Docking Bar)
        dock_h = 36.0
        rect(0.0, 0.0, vw, dock_h, 0x161B22)
        line(0.0, dock_h, vw, dock_h, 0x30363D)
        text("CHRONOS WORKSPACE — MULTI-SCREEN DOCK", 16.0, 10.0, 12.0, 0x58A6FF)
    }
    vw
}

// Creación de sub-pantalla hija (el usuario puede crear de 1 a 32 a gusto)
ui.sub_screen_create(child_id, def_x, def_y, grid_x, grid_y) = {
    set_soa(sub_screens_soa, 0, child_id, MAX_SUB_SCREENS, child_id)
    set_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS, def_x)
    set_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS, def_y)
    set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, 360.0) // Proporción pantalla móvil
    set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, 640.0)
    set_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS, 1.0)   // 1.0 = expandida
    set_soa(sub_screens_soa, 6, child_id, MAX_SUB_SCREENS, grid_x)
    set_soa(sub_screens_soa, 7, child_id, MAX_SUB_SCREENS, grid_y)
    set_soa(sub_screens_soa, 8, child_id, MAX_SUB_SCREENS, 0.0)   // scroll_x inicial
    set_soa(sub_screens_soa, 9, child_id, MAX_SUB_SCREENS, 0.0)   // scroll_y inicial
    set_soa(sub_screens_soa, 10, child_id, MAX_SUB_SCREENS, 360.0) // content_w inicial
    set_soa(sub_screens_soa, 11, child_id, MAX_SUB_SCREENS, 640.0) // content_h inicial
    1.0
}

// Reposicionamiento Drag & Drop en modo Escritorio
ui.sub_screen_drag(child_id, new_x, new_y) = {
    set_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS, new_x)
    set_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS, new_y)
    1.0
}

// Redimensionar ancho y alto en modo Escritorio de forma independiente
ui.sub_screen_resize(child_id, new_w, new_h) = {
    w_val = new_w
    if (new_w < 120.0) {
        w_val = 120.0
    }
    h_val = new_h
    if (new_h < 60.0) {
        h_val = 60.0
    }
    set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, w_val)
    set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, h_val)
    w_val
}

// Redimensionar fijando límites completos (x, y, w, h)
ui.sub_screen_set_bounds(child_id, new_x, new_y, new_w, new_h) = {
    w_val = new_w
    if (new_w < 120.0) {
        w_val = 120.0
    }
    h_val = new_h
    if (new_h < 60.0) {
        h_val = 60.0
    }
    set_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS, new_x)
    set_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS, new_y)
    set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, w_val)
    set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, h_val)
    w_val
}

// Redimensión en tiempo real en todos los sentidos:
// dir: 1.0=Derecha (E), 2.0=Izquierda (W), 3.0=Abajo (S), 4.0=Arriba (N),
//      5.0=Diagonal SE, 6.0=Diagonal NW, 7.0=Diagonal NE, 8.0=Diagonal SW
ui.sub_screen_resize_dir(child_id, dir, delta) = {
    cx = get_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS)
    cy = get_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS)
    cw = get_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS)
    ch = get_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS)

    if (dir == 1.0) {
        // Derecha (E): amplía o estrecha ancho
        set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, cw + delta)
    } else {
        if (dir == 2.0) {
            // Izquierda (W): desplaza X y ajusta ancho
            set_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS, cx - delta)
            set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, cw + delta)
        } else {
            if (dir == 3.0) {
                // Abajo (S): amplía o estrecha alto
                set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, ch + delta)
            } else {
                if (dir == 4.0) {
                    // Arriba (N): desplaza Y y ajusta alto
                    set_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS, cy - delta)
                    set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, ch + delta)
                } else {
                    if (dir == 5.0) {
                        // Diagonal Sureste (SE): amplía w y h
                        set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, cw + delta)
                        set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, ch + delta)
                    } else {
                        if (dir == 6.0) {
                            // Diagonal Noroeste (NW): desplaza x, y y ajusta w, h
                            set_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS, cx - delta)
                            set_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS, cy - delta)
                            set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, cw + delta)
                            set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, ch + delta)
                        } else {
                            if (dir == 7.0) {
                                // Diagonal Noreste (NE): desplaza y y ajusta w, h
                                set_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS, cy - delta)
                                set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, cw + delta)
                                set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, ch + delta)
                            } else {
                                if (dir == 8.0) {
                                    // Diagonal Suroeste (SW): desplaza x y ajusta w, h
                                    set_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS, cx - delta)
                                    set_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS, cw + delta)
                                    set_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS, ch + delta)
                                } else {
                                    0.0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    1.0
}

// Minimizar / Restaurar sub-pantalla:
// Al minimizar, NO se esconde del todo: queda viéndose solo la barrita de título (28px)
ui.sub_screen_toggle(child_id) = {
    st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
    new_st = 1.0 - st
    set_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS, new_st)
    new_st
}

ui.sub_screen_is_minimized(child_id) = {
    st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
    if (st == 0.0) {
        1.0
    } else {
        0.0
    }
}

ui.sub_screen_is_visible(child_id) = {
    // 1.0 si expandida, 0.0 si minimizada a solo barra de título
    get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
}

// Coordenadas calculadas según el modo (Escritorio vs Móvil)
ui.sub_screen_get_x(child_id) = {
    if (auto_is_mobile() == 1.0) {
        if (child_id == ui_active_child) {
            0.0
        } else {
            gx = get_soa(sub_screens_soa, 6, child_id, MAX_SUB_SCREENS)
            gx * R250
        }
    } else {
        get_soa(sub_screens_soa, 1, child_id, MAX_SUB_SCREENS)
    }
}

ui.sub_screen_get_y(child_id) = {
    if (auto_is_mobile() == 1.0) {
        if (child_id == ui_active_child) {
            0.0
        } else {
            gy = get_soa(sub_screens_soa, 7, child_id, MAX_SUB_SCREENS)
            gy * R251
        }
    } else {
        get_soa(sub_screens_soa, 2, child_id, MAX_SUB_SCREENS)
    }
}

// Dimensiones calculadas según el modo
ui.sub_screen_get_w(child_id) = {
    if (auto_is_mobile() == 1.0) {
        R250
    } else {
        get_soa(sub_screens_soa, 3, child_id, MAX_SUB_SCREENS)
    }
}

ui.sub_screen_get_h(child_id) = {
    if (auto_is_mobile() == 1.0) {
        R251
    } else {
        st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
        if (st == 0.0) {
            // Minimizada: solo la barrita de título (28px) visible
            28.0
        } else {
            // Expandida: altura completa configurada
            get_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS)
        }
    }
}

ui.sub_screen_get_full_h(child_id) = {
    get_soa(sub_screens_soa, 4, child_id, MAX_SUB_SCREENS)
}

// Selección de hijo activo
ui.sub_screen_select(child_id) = {
    ui_active_child = child_id
    ui_active_child
}

// Navegación táctil con dos dedos / pellizco / arrastre entre cuadrantes
ui.sub_screen_pinch_swipe(target_child_id) = {
    ui_active_child = target_child_id
    ui_active_child
}

// Renderizado de sub-pantalla hija
ui.sub_screen_render(child_id, bg_color) = {
    sx = ui.sub_screen_get_x(child_id)
    sy = ui.sub_screen_get_y(child_id)
    sw = ui.sub_screen_get_w(child_id)
    sh = ui.sub_screen_get_h(child_id)
    st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)

    if (auto_is_mobile() == 1.0) {
        // En Móvil: Snap 100%
        rect(sx, sy, sw, sh, bg_color)
        line(sx, sy, sx + sw, sy, 0x30363D)
        line(sx + sw, sy, sx + sw, sy + sh, 0x30363D)
        line(sx + sw, sy + sh, sx, sy + sh, 0x30363D)
        line(sx, sy + sh, sx, sy, 0x30363D)
    } else {
        title_h = 28.0
        if (st == 0.0) {
            // Minimizada en Escritorio: Solo se ve la barrita de título arrastrable
            rect(sx, sy, sw, title_h, 0x1C2128)
            line(sx, sy, sx + sw, sy, 0x58A6FF)
            line(sx + sw, sy, sx + sw, sy + title_h, 0x30363D)
            line(sx + sw, sy + title_h, sx, sy + title_h, 0x30363D)
            line(sx, sy + title_h, sx, sy, 0x30363D)
            text("VENTANA HIJA [MIN]", sx + 10.0, sy + 6.0, 10.0, 0x8B949E)
            btn("+", sx + sw - 24.0, sy + 4.0, 18.0, 18.0, 0.0, 0x238636)
        } else {
            // Expandida en Escritorio: Cuerpo completo + Barra + Agarradera de Redimensión
            rect(sx, sy, sw, sh, bg_color)
            line(sx, sy, sx + sw, sy, 0x30363D)
            line(sx + sw, sy, sx + sw, sy + sh, 0x30363D)
            line(sx + sw, sy + sh, sx, sy + sh, 0x30363D)
            line(sx, sy + sh, sx, sy, 0x30363D)

            // Barra de título arrastrable
            rect(sx, sy, sw, title_h, 0x21262D)
            line(sx, sy + title_h, sx + sw, sy + title_h, 0x30363D)
            text("VENTANA HIJA", sx + 10.0, sy + 6.0, 11.0, 0x58A6FF)
            btn("-", sx + sw - 24.0, sy + 4.0, 18.0, 18.0, 0.0, 0x30363D)

            // Agarradera visual de redimensión en la esquina inferior derecha
            line(sx + sw - 12.0, sy + sh - 2.0, sx + sw - 2.0, sy + sh - 12.0, 0x58A6FF)
            line(sx + sw - 8.0, sy + sh - 2.0, sx + sw - 2.0, sy + sh - 8.0, 0x58A6FF)
            line(sx + sw - 4.0, sy + sh - 2.0, sx + sw - 2.0, sy + sh - 4.0, 0x58A6FF)

            // Renderizado de barras de desplazamiento vertical y horizontal si el contenido excede el viewport
            ui.sub_screen_render_scrollbars(child_id, 10.0)
        }
    }
    sw
}

// ===============================================================
// 12. VIEWPORT INTERIOR, MODO WRAP, CLIPPING Y SCROLL (V/H)
// Arquitectura 100% nativa PhasorLang (Zero-GC):
// - Modo Wrap: Envoltura de texto y elementos al ancho disponible interior.
// - Clipping ("como si viéramos a través de una ventana"):
//   El contenido excedente queda estrictamente recortado y oculto.
//   Si la ventana se minimiza/cierra, todo el contenido interior queda en 0.0 (oculto).
// - Scroll V/H: Desplazamiento horizontal y vertical con clamping estricto.
// - Scrollbars: Barras de desplazamiento con track y thumb proporcionales.
// ===============================================================

// Dimensiones interiores del viewport visible (área útil de contenido)
ui.sub_screen_inner_w(child_id, padding) = {
    w = ui.sub_screen_get_w(child_id)
    avail = w - (padding * 2.0)
    if (avail < 10.0) {
        10.0
    } else {
        avail
    }
}

ui.sub_screen_inner_h(child_id, padding) = {
    st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
    if (st == 0.0) {
        // Ventana minimizada a barrita de título: altura interior de contenido es 0.0
        0.0
    } else {
        h = ui.sub_screen_get_h(child_id)
        title_h = 28.0
        avail = h - title_h - (padding * 2.0)
        if (avail < 0.0) {
            0.0
        } else {
            avail
        }
    }
}

// 1. MODO WRAP: Cálculo de caracteres por línea según ancho disponible y fuente
ui.wrap_calc_chars_per_line(avail_w, font_size) = {
    char_w = font_size * 0.60
    if (char_w <= 0.0) {
        1.0
    } else {
        c = avail_w / char_w
        if (c < 1.0) {
            1.0
        } else {
            c
        }
    }
}

// Cálculo del número de líneas de texto generadas al aplicar wrap
ui.wrap_calc_line_count(text_len, avail_w, font_size) = {
    cpl = ui.wrap_calc_chars_per_line(avail_w, font_size)
    lines_float = text_len / cpl
    // Ceil entero: si hay residuo fraccionario, sumar 1
    lines_res = lines_float
    if (lines_float > 0.0) {
        lines_res = lines_float + 0.999
    }
    if (lines_res < 1.0) {
        1.0
    } else {
        lines_res
    }
}

// Altura total requerida por el contenido con wrap
ui.wrap_calc_content_h(text_len, avail_w, font_size, line_spacing) = {
    lines = ui.wrap_calc_line_count(text_len, avail_w, font_size)
    line_h = font_size + line_spacing
    lines * line_h
}

// 2. CLIPPING: Comprobación de recorte de contenido
// Retorna 1.0 si el elemento relativo es visible dentro de la ventana, o 0.0 si queda recortado/oculto
ui.sub_screen_is_visible_within(child_id, rel_x, rel_y, item_w, item_h, padding) = {
    st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
    if (st == 0.0) {
        // Si está minimizada (cerrada), todo el contenido interior queda estrictamente oculto
        0.0
    } else {
        sc_x = get_soa(sub_screens_soa, 8, child_id, MAX_SUB_SCREENS)
        sc_y = get_soa(sub_screens_soa, 9, child_id, MAX_SUB_SCREENS)
        eff_x = rel_x - sc_x
        eff_y = rel_y - sc_y
        in_w = ui.sub_screen_inner_w(child_id, padding)
        in_h = ui.sub_screen_inner_h(child_id, padding)

        if (eff_x + item_w <= 0.0) {
            0.0 // Oculto por borde izquierdo
        } else {
            if (eff_x >= in_w) {
                0.0 // Oculto por borde derecho
            } else {
                if (eff_y + item_h <= 0.0) {
                    0.0 // Oculto por borde superior
                } else {
                    if (eff_y >= in_h) {
                        0.0 // Oculto por borde inferior
                    } else {
                        1.0 // Visible a través de la ventana
                    }
                }
            }
        }
    }
}

// Retorna 1.0 si el elemento queda recortado (fuera de la ventana)
ui.sub_screen_is_clipped(child_id, rel_x, rel_y, item_w, item_h, padding) = {
    vis = ui.sub_screen_is_visible_within(child_id, rel_x, rel_y, item_w, item_h, padding)
    1.0 - vis
}

// 3. SCROLL VERTICAL Y HORIZONTAL
ui.sub_screen_set_content_size(child_id, total_w, total_h) = {
    set_soa(sub_screens_soa, 10, child_id, MAX_SUB_SCREENS, total_w)
    set_soa(sub_screens_soa, 11, child_id, MAX_SUB_SCREENS, total_h)
    1.0
}

ui.sub_screen_get_content_w(child_id) = {
    get_soa(sub_screens_soa, 10, child_id, MAX_SUB_SCREENS)
}

ui.sub_screen_get_content_h(child_id) = {
    get_soa(sub_screens_soa, 11, child_id, MAX_SUB_SCREENS)
}

ui.sub_screen_get_scroll_x(child_id) = {
    get_soa(sub_screens_soa, 8, child_id, MAX_SUB_SCREENS)
}

ui.sub_screen_get_scroll_y(child_id) = {
    get_soa(sub_screens_soa, 9, child_id, MAX_SUB_SCREENS)
}

ui.sub_screen_max_scroll_x(child_id, padding) = {
    cw = ui.sub_screen_get_content_w(child_id)
    iw = ui.sub_screen_inner_w(child_id, padding)
    diff = cw - iw
    if (diff <= 0.0) {
        0.0
    } else {
        diff
    }
}

ui.sub_screen_max_scroll_y(child_id, padding) = {
    ch = ui.sub_screen_get_content_h(child_id)
    ih = ui.sub_screen_inner_h(child_id, padding)
    diff = ch - ih
    if (diff <= 0.0) {
        0.0
    } else {
        diff
    }
}

ui.sub_screen_scroll(child_id, delta_x, delta_y) = {
    padding = 10.0
    cur_x = get_soa(sub_screens_soa, 8, child_id, MAX_SUB_SCREENS)
    cur_y = get_soa(sub_screens_soa, 9, child_id, MAX_SUB_SCREENS)
    max_x = ui.sub_screen_max_scroll_x(child_id, padding)
    max_y = ui.sub_screen_max_scroll_y(child_id, padding)

    new_x = cur_x + delta_x
    if (new_x < 0.0) {
        new_x = 0.0
    } else {
        if (new_x > max_x) {
            new_x = max_x
        }
    }

    new_y = cur_y + delta_y
    if (new_y < 0.0) {
        new_y = 0.0
    } else {
        if (new_y > max_y) {
            new_y = max_y
        }
    }

    set_soa(sub_screens_soa, 8, child_id, MAX_SUB_SCREENS, new_x)
    set_soa(sub_screens_soa, 9, child_id, MAX_SUB_SCREENS, new_y)
    1.0
}

ui.sub_screen_set_scroll(child_id, target_x, target_y) = {
    padding = 10.0
    max_x = ui.sub_screen_max_scroll_x(child_id, padding)
    max_y = ui.sub_screen_max_scroll_y(child_id, padding)

    nx = target_x
    if (nx < 0.0) {
        nx = 0.0
    } else {
        if (nx > max_x) {
            nx = max_x
        }
    }

    ny = target_y
    if (ny < 0.0) {
        ny = 0.0
    } else {
        if (ny > max_y) {
            ny = max_y
        }
    }

    set_soa(sub_screens_soa, 8, child_id, MAX_SUB_SCREENS, nx)
    set_soa(sub_screens_soa, 9, child_id, MAX_SUB_SCREENS, ny)
    1.0
}

// 4. RENDERIZADO DE BARRAS DE DESPLAZAMIENTO (SCROLLBARS) EN PHASORLANG
ui.sub_screen_render_scrollbars(child_id, padding) = {
    st = get_soa(sub_screens_soa, 5, child_id, MAX_SUB_SCREENS)
    if (st == 1.0) {
        sx = ui.sub_screen_get_x(child_id)
        sy = ui.sub_screen_get_y(child_id)
        sw = ui.sub_screen_get_w(child_id)
        sh = ui.sub_screen_get_h(child_id)
        title_h = 28.0

        in_y = sy + title_h
        in_w = sw - (padding * 2.0)
        in_h = sh - title_h - (padding * 2.0)

        cw = ui.sub_screen_get_content_w(child_id)
        ch = ui.sub_screen_get_content_h(child_id)
        sc_x = ui.sub_screen_get_scroll_x(child_id)
        sc_y = ui.sub_screen_get_scroll_y(child_id)
        max_x = ui.sub_screen_max_scroll_x(child_id, padding)
        max_y = ui.sub_screen_max_scroll_y(child_id, padding)

        // Barra de Scroll Vertical (si el contenido excede el alto disponible)
        if (ch > in_h) {
            bar_w = 6.0
            track_x = sx + sw - bar_w - 2.0
            track_y = in_y + 2.0
            track_h = in_h - 18.0
            if (track_h < 10.0) {
                track_h = 10.0
            }
            rect(track_x, track_y, bar_w, track_h, 0x161B22)

            thumb_ratio = in_h / ch
            thumb_h = track_h * thumb_ratio
            if (thumb_h < 18.0) {
                thumb_h = 18.0
            }
            if (thumb_h > track_h) {
                thumb_h = track_h
            }

            scroll_ratio = 0.0
            if (max_y > 0.0) {
                scroll_ratio = sc_y / max_y
                if (scroll_ratio > 1.0) {
                    scroll_ratio = 1.0
                }
                if (scroll_ratio < 0.0) {
                    scroll_ratio = 0.0
                }
            }
            thumb_y = track_y + (scroll_ratio * (track_h - thumb_h))
            rect(track_x, thumb_y, bar_w, thumb_h, 0x58A6FF)
        }

        // Barra de Scroll Horizontal (si el contenido excede el ancho disponible)
        if (cw > in_w) {
            bar_h = 6.0
            track_x = sx + 2.0
            track_y = sy + sh - bar_h - 2.0
            track_w = in_w - 18.0
            if (track_w < 10.0) {
                track_w = 10.0
            }
            rect(track_x, track_y, track_w, bar_h, 0x161B22)

            thumb_ratio = in_w / cw
            thumb_w = track_w * thumb_ratio
            if (thumb_w < 18.0) {
                thumb_w = 18.0
            }
            if (thumb_w > track_w) {
                thumb_w = track_w
            }

            scroll_ratio = 0.0
            if (max_x > 0.0) {
                scroll_ratio = sc_x / max_x
                if (scroll_ratio > 1.0) {
                    scroll_ratio = 1.0
                }
                if (scroll_ratio < 0.0) {
                    scroll_ratio = 0.0
                }
            }
            thumb_x = track_x + (scroll_ratio * (track_w - thumb_w))
            rect(thumb_x, track_y, thumb_w, bar_h, 0x58A6FF)
        }
    }
    1.0
}

