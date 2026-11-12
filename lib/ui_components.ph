// ===============================================================================
// LIB/UI_COMPONENTS.PH — COMPONENTES UI REACTIVOS GEN-2 (ZERO-GC 120 FPS)
// ===============================================================================
ui_hit_box(ox, oy, ow, oh, mx, my) = {
    hit = 0.0
    if (mx >= ox) { if (mx <= (ox + ow)) {
        if (my >= oy) { if (my <= (oy + oh)) { hit = 1.0 } }
    } }
    hit
}

ui_card(ox, oy, ow, oh, bg, border) = {
    rect(ox, oy, ow, oh, bg)
    line(ox, oy, ox + ow, oy, border)
    line(ox, oy + oh, ox + ow, oy + oh, border)
    line(ox, oy, ox, oy + oh, border)
    line(ox + ow, oy, ox + ow, oy + oh, border)
    1.0
}

ui_badge_box(ox, oy, ow, bg) = {
    rect(ox, oy, ow, 16.0, bg)
    1.0
}

ui_badge(lbl, ox, oy, ow, bg, fg) = {
    rect(ox, oy, ow, 16.0, bg)
    text(lbl, ox + 6.0, oy + 3.0, 8, fg)
    1.0
}

ui_divider(ox, oy, ow, col) = {
    line(ox, oy, ox + ow, oy, col)
    1.0
}

ui_button(lbl, ox, oy, w, h, act, bg, mx, my) = {
    hov = ui_hit_box(ox, oy, w, h, mx, my)
    col = bg
    if (act == 1.0) { col = 0x1F6FEB } else { 1.0 }
    if (hov == 1.0) { col = 0x388BFD } else { 1.0 }
    rect(ox, oy, w, h, col)
    text(lbl, ox + 6.0, oy + 5.0, 8, 0xFFFFFF)
    hov
}

ui_tree_node(lbl, x, y, w, depth, is_dir, dir, sel, nw, mx, my) = {
    hov = ui_hit_box(x, y, w, 18.0, mx, my)
    if (sel == 1.0) {
        rect(x, y, w, 18.0, 0x162234)
    } else {
        if (hov == 1.0) { rect(x, y, w, 18.0, 0x161B22) } else { 1.0 }
    }
    ix = x + 6.0 + (depth * 12.0)
    if (is_dir == 1.0) {
        if (dir == 1.0) { text("v", ix, y + 3.0, 9, 0x8B949E) } else { text(">", ix, y + 3.0, 9, 0x8B949E) }
    } else {
        text("•", ix, y + 3.0, 9, nw)
    }
    text(lbl, ix + 12.0, y + 3.0, 9, nw)
    text(":", (x + w) - 12.0, y + 3.0, 9, 0x8B949E)
    res = 0.0
    if (hov == 1.0) {
        res = 1.0
        if (mx >= ((x + w) - 20.0)) { res = 2.0 } else { 1.0 }
    } else { 1.0 }
    res
}

ui_context_menu(lbl, ox, oy, ow, oh) = {
    ui_card(ox, oy, ow, oh, 0x161B22, 0x58A6FF)
    rect(ox + 1.0, oy + 1.0, ow - 2.0, 18.0, 0x1F2937)
    text(lbl, ox + 8.0, oy + 4.0, 8, 0x79C0FF)
    1.0
}

ui_menu_item(lbl, ox, oy, ow, fg, mx, my) = {
    hov = ui_hit_box(ox + 2.0, oy, ow - 4.0, 17.0, mx, my)
    if (hov == 1.0) { rect(ox + 2.0, oy, ow - 4.0, 17.0, 0x1F6FEB) } else { 1.0 }
    text(lbl, ox + 8.0, oy + 3.0, 8, fg)
    hov
}
