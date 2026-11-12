// Grado 1: Etiqueta de texto con alineación y truncado seguro
import "lib/core/primitives.ph"

ui_label(str_id, x, y, sz, color) = {
    prim_glyph(str_id, x, y, sz, color)
}
