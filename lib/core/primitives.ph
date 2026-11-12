// Grado 0: Primitivas puras y utilidades matemáticas Zero-GC

prim_clamp(v, min_v, max_v) = {
    res = v
    if (res < min_v) { res = min_v } else { 1.0 }
    if (res > max_v) { res = max_v } else { 1.0 }
    res
}

prim_abs(v) = {
    res = v
    if (res < 0.0) { res = 0.0 - res } else { 1.0 }
    res
}

// Wraparound toroidal estricto en [0, span) sin saltos de borde
prim_wrap(val, span) = {
    s = span
    if (s < 1.0) { s = 1.0 } else { 1.0 }
    m = val % s
    if (m < 0.0) { m = m + s } else { 1.0 }
    m
}

prim_box(x, y, w, h, color) = {
    rect(x, y, w, h, color)
}

prim_stroke(x, y, w, h, color) = {
    line(x, y, x + w, y, color)
    line(x + w, y, x + w, y + h, color)
    line(x + w, y + h, x, y + h, color)
    line(x, y + h, x, y, color)
}

prim_glyph(str_id, x, y, sz, color) = {
    text(str_id, x, y, sz, color)
}
