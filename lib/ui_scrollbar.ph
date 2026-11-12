// ===============================================================================
// LIB/UI_SCROLLBAR.PH — ENVOLTORIO DE SCROLLBARS 2D Y SCISSOR CLIPPING
// ===============================================================================
sb_client_w(w) = { vp_client_w(w) }
sb_client_h(h, top) = { vp_client_h(h, top) }
sb_max_scroll_x(cw, clw) = {
    v = cw - clw
    if (v < 0.0) { v = 0.0 } else { 1.0 }
    v
}
sb_max_scroll_y(ch, clh) = {
    v = ch - clh
    if (v < 0.0) { v = 0.0 } else { 1.0 }
    v
}
sb_clamp(sc, max_sc) = { vp_clamp_scroll(sc, max_sc) }

sb_begin_clip(hx, hy, w, h, top, cw, ch) = {
    clip(hx + 1.0, hy + top, w - 2.0, (h - top) - 1.0)
    1.0
}
sb_end_clip() = {
    unclip()
    1.0
}

sb_hit_test_v(hx, hy, w, h, top, cw, ch, sc, mx, my) = {
    vp_hit_v(hx, hy, w, h, top, cw, ch, sc, mx, my)
}
sb_hit_test_h(hx, hy, w, h, top, cw, ch, sc, mx, my) = {
    vp_hit_h(hx, hy, w, h, top, cw, ch, sc, mx, my)
}
sb_calc_grab_v(hx, hy, w, h, top, cw, ch, sc, hit, my) = {
    vp_grab_v(hx, hy, w, h, top, cw, ch, sc, hit, my)
}
sb_calc_grab_h(hx, hy, w, h, top, cw, ch, sc, hit, mx) = {
    vp_grab_h(hx, hy, w, h, top, cw, ch, sc, hit, mx)
}
sb_apply_drag_v(hx, hy, w, h, top, cw, ch, grab, my) = {
    vp_drag_scroll_v(hx, hy, w, h, top, cw, ch, grab, my)
}
sb_apply_drag_h(hx, hy, w, h, top, cw, ch, grab, mx) = {
    vp_drag_scroll_h(hx, hy, w, h, top, cw, ch, grab, mx)
}

ui_subscreen_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act, en) = {
    render_viewport_scrollbars(hx, hy, w, h, top, cw, ch, dx, dy, act)
}
