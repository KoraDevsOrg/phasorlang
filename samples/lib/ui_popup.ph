// ===============================================================================
// SAMPLES/LIB/UI_POPUP.PH — Librería Universal Reutilizable de Menús Popup y Tooltips
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Arquitectura Zero-GC, Memoria Plana SoA, Menús Contextuales de 3 Puntos (⋮),
// Tooltips Flotantes Clamped y Soporte Universal Multi-Pantalla
// ===============================================================================

import "lib/color.ph"

// -------------------------------------------------------------------------------
// 1. CONSTANTES Y CONFIGURACIÓN DE MEMORIA CONTIGUA SOA (ZERO-GC)
// -------------------------------------------------------------------------------
MAX_POPUP_ITEMS = 16.0

// Buffer Contiguo SoA para ítems del menú popup (4 campos x 16 ítems)
// Campo 0: id del ítem [0..15]
// Campo 1: action_code (1=Abrir, 2=Importar, 3=Copiar, 4=Renombrar, 5=Eliminar, etc.)
// Campo 2: is_disabled (0.0 = activo, 1.0 = deshabilitado)
// Campo 3: color_hex (color del elemento visual)
popup_items_soa = alloc_soa(4, 16)

// Variables de Estado Global del Menú Popup
popup_is_open = 0.0
popup_x = 0.0
popup_y = 0.0
popup_w = 170.0
popup_item_h = 28.0
popup_item_count = 0.0
popup_target_id = -1.0
popup_hover_idx = -1.0
popup_last_action = 0.0

// Variables de Estado del Tooltip Flotante
tooltip_is_visible = 0.0
tooltip_x = 0.0
tooltip_y = 0.0
tooltip_w = 220.0
tooltip_h = 32.0
tooltip_target_id = -1.0

// -------------------------------------------------------------------------------
// 2. INICIALIZACIÓN Y GESTIÓN DEL MENÚ POPUP
// -------------------------------------------------------------------------------
ui_popup.init() = {
    idx = 0.0
    while (idx < MAX_POPUP_ITEMS) {
        set_soa(popup_items_soa, 0, idx, 16, idx)
        set_soa(popup_items_soa, 1, idx, 16, 0.0)
        set_soa(popup_items_soa, 2, idx, 16, 0.0)
        set_soa(popup_items_soa, 3, idx, 16, 0x58A6FF)
        idx = idx + 1.0
    }
    popup_is_open = 0.0
    popup_item_count = 0.0
    popup_target_id = -1.0
    popup_hover_idx = -1.0
    popup_last_action = 0.0
    tooltip_is_visible = 0.0
    1.0
}

ui_popup.open(x, y, w, target_id) = {
    popup_x = x
    popup_y = y
    if (w > 80.0) {
        popup_w = w
    } else {
        popup_w = 170.0
    }
    popup_target_id = target_id
    popup_item_count = 0.0
    popup_is_open = 1.0
    popup_hover_idx = -1.0
    1.0
}

ui_popup.close() = {
    popup_is_open = 0.0
    popup_hover_idx = -1.0
    1.0
}

ui_popup.is_open() = {
    popup_is_open
}

ui_popup.add_item(action_code, color_hex) = {
    if (popup_item_count < MAX_POPUP_ITEMS) {
        cur_idx = popup_item_count
        set_soa(popup_items_soa, 0, cur_idx, 16, cur_idx)
        set_soa(popup_items_soa, 1, cur_idx, 16, action_code)
        set_soa(popup_items_soa, 2, cur_idx, 16, 0.0)
        set_soa(popup_items_soa, 3, cur_idx, 16, color_hex)
        popup_item_count = popup_item_count + 1.0
        cur_idx
    } else {
        -1.0
    }
}

ui_popup.get_target_id() = {
    popup_target_id
}

ui_popup.get_last_action() = {
    popup_last_action
}

ui_popup.clear_action() = {
    popup_last_action = 0.0
    1.0
}

// -------------------------------------------------------------------------------
// 3. DESPACHO DE INTERACCIÓN (CLIC & HOVER ZERO-GC)
// -------------------------------------------------------------------------------
ui_popup.handle_click(click_x, click_y) = {
    if (popup_is_open == 1.0) {
        total_h = (popup_item_count * popup_item_h) + 8.0
        in_x = 0.0
        if (click_x >= popup_x) {
            if (click_x <= (popup_x + popup_w)) {
                in_x = 1.0
            }
        }
        in_y = 0.0
        if (click_y >= popup_y) {
            if (click_y <= (popup_y + total_h)) {
                in_y = 1.0
            }
        }

        if (in_x == 1.0) {
            if (in_y == 1.0) {
                // Determina qué ítem fue clickeado mediante paso lineal SoA
                c_idx = 0.0
                cur_item_y = popup_y + 4.0
                found_idx = -1.0
                while (c_idx < popup_item_count) {
                    if (click_y >= cur_item_y) {
                        if (click_y < (cur_item_y + popup_item_h)) {
                            found_idx = c_idx
                        }
                    }
                    cur_item_y = cur_item_y + popup_item_h
                    c_idx = c_idx + 1.0
                }

                if (found_idx >= 0.0) {
                    act = get_soa(popup_items_soa, 1, found_idx, 16)
                    popup_last_action = act
                    popup_is_open = 0.0
                    act
                } else {
                    popup_is_open = 0.0
                    0.0
                }
            } else {
                popup_is_open = 0.0
                0.0
            }
        } else {
            popup_is_open = 0.0
            0.0
        }
    } else {
        0.0
    }
}

// -------------------------------------------------------------------------------
// 4. RENDERIZADO VISUAL DEL MENÚ POPUP (ESTILO ANTIGRAVITY / VS CODE)
// -------------------------------------------------------------------------------
ui_popup.render(vw, vh, mouse_x, mouse_y) = {
    if (popup_is_open == 1.0) {
        if (popup_item_count > 0.0) {
            total_h = (popup_item_count * popup_item_h) + 8.0

            // Clamping Inteligente de Viewport
            draw_x = popup_x
            draw_y = popup_y
            if ((draw_x + popup_w) > (vw - 8.0)) {
                draw_x = vw - popup_w - 8.0
            }
            if (draw_x < 8.0) {
                draw_x = 8.0
            }
            if ((draw_y + total_h) > (vh - 28.0)) {
                draw_y = popup_y - total_h
            }
            if (draw_y < 32.0) {
                draw_y = 32.0
            }

            // Sombra perimetral y fondo flotante Dark Acrylic (#161B22)
            rect(draw_x - 1.0, draw_y - 1.0, popup_w + 2.0, total_h + 2.0, 0x30363D)
            rect(draw_x, draw_y, popup_w, total_h, 0x161B22)

            // Dibuja cada ítem del menú
            p_idx = 0.0
            while (p_idx < popup_item_count) {
                item_y = draw_y + 4.0 + (p_idx * popup_item_h)
                act_code = get_soa(popup_items_soa, 1, p_idx, 16)
                col_hex = get_soa(popup_items_soa, 3, p_idx, 16)

                // Detección de Hover
                is_hover = 0.0
                if (mouse_x >= draw_x) {
                    if (mouse_x <= (draw_x + popup_w)) {
                        if (mouse_y >= item_y) {
                            if (mouse_y < (item_y + popup_item_h)) {
                                is_hover = 1.0
                            }
                        }
                    }
                }

                if (is_hover == 1.0) {
                    rect(draw_x + 3.0, item_y, popup_w - 6.0, popup_item_h, 0x1F6FEB)
                    text_col = 0xFFFFFF
                } else {
                    text_col = col_hex
                }

                // Etiquetas descriptivas según action_code universal
                if (act_code == 1.0) {
                    text("⚡ Abrir en Editor", draw_x + 10.0, item_y + 7.0, 10, text_col)
                } else {
                    if (act_code == 2.0) {
                        text("📥 Copiar import \"...\"", draw_x + 10.0, item_y + 7.0, 10, text_col)
                    } else {
                        if (act_code == 3.0) {
                            text("📋 Copiar Ruta", draw_x + 10.0, item_y + 7.0, 10, text_col)
                        } else {
                            if (act_code == 4.0) {
                                text("✏ Renombrar", draw_x + 10.0, item_y + 7.0, 10, text_col)
                            } else {
                                if (act_code == 5.0) {
                                    text("🗑 Eliminar", draw_x + 10.0, item_y + 7.0, 10, text_col)
                                } else {
                                    if (act_code == 6.0) {
                                        text("➕ Nuevo Archivo", draw_x + 10.0, item_y + 7.0, 10, text_col)
                                    } else {
                                        if (act_code == 7.0) {
                                            text("📁 Nueva Carpeta", draw_x + 10.0, item_y + 7.0, 10, text_col)
                                        } else {
                                            text("• Accion #" + act_code, draw_x + 10.0, item_y + 7.0, 10, text_col)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                p_idx = p_idx + 1.0
            }
            1.0
        } else {
            0.0
        }
    } else {
        0.0
    }
}

// -------------------------------------------------------------------------------
// 5. GESTIÓN Y RENDERIZADO DE TOOLTIPS REUTILIZABLES
// -------------------------------------------------------------------------------
ui_tooltip.show(x, y, target_id) = {
    tooltip_x = x
    tooltip_y = y
    tooltip_target_id = target_id
    tooltip_is_visible = 1.0
    1.0
}

ui_tooltip.hide() = {
    tooltip_is_visible = 0.0
    tooltip_target_id = -1.0
    1.0
}

ui_tooltip.is_visible() = {
    tooltip_is_visible
}

ui_tooltip.get_target_id() = {
    tooltip_target_id
}

ui_tooltip.render(vw, vh, line_1, line_2) = {
    if (tooltip_is_visible == 1.0) {
        tx = tooltip_x + 14.0
        ty = tooltip_y + 14.0
        tw = tooltip_w
        th = tooltip_h

        if ((tx + tw) > (vw - 10.0)) {
            tx = tooltip_x - tw - 8.0
        }
        if (tx < 10.0) {
            tx = 10.0
        }
        if ((ty + th) > (vh - 10.0)) {
            ty = tooltip_y - th - 8.0
        }
        if (ty < 10.0) {
            ty = 10.0
        }

        rect(tx - 1.0, ty - 1.0, tw + 2.0, th + 2.0, 0x58A6FF)
        rect(tx, ty, tw, th, 0x0D1117)

        text(line_1, tx + 8.0, ty + 6.0, 9, 0xFFFFFF)
        text(line_2, tx + 8.0, ty + 18.0, 8, 0x8B949E)
        1.0
    } else {
        0.0
    }
}
