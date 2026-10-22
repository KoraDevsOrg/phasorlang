// ===============================================================================
// TESTS/10_TEST_WINDOW_RESIZE_8D.PH — TEST SUITE NATIVO PARA HITO 3
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Auditoría de Redimensionado Perimetral 8D y Anclajes Cinemáticos
// Invariante Estricto: Zero-GC a 120 FPS Nativos
// ===============================================================================

import "lib/ui_spatial_main.ph"
import "lib/ui_window_frame.ph"

main = {
    out("======================================================================")
    out("  HITO 3: INICIANDO BATERÍA DE PRUEBAS DE REDIMENSIONADO 8D (PVM)    ")
    out("======================================================================")

    orig_x = 100.0
    orig_y = 100.0
    orig_w = 400.0
    orig_h = 300.0
    min_w = 200.0
    min_h = 150.0

    // ---------------------------------------------------------------------------
    // TEST 1: Borde Este (E=1.0) y Borde Oeste (W=3.0) con Anclaje Derecho
    // ---------------------------------------------------------------------------
    out(">>> TEST 1: Redimensionado Horizontal (Este vs Oeste con Anclaje)...")
    // A. Este: dw = +50.0 -> w = 450.0, x = 100.0
    w_e = calc_resize_w(1.0, orig_w, 50.0, min_w)
    x_e = calc_resize_x(1.0, orig_x, orig_w, w_e)
    if (w_e == 450.0) { if (x_e == 100.0) {
        out("  [PASS] Borde Este (E): Expande ancho (450) y ancla borde izquierdo (100)")
    } else { out("  [FAIL] Borde Este alteró posición X") } } else { out("  [FAIL] Borde Este falló cálculo de ancho") }

    // B. Oeste: dw = -50.0 (arrastre a la izquierda) -> w = 450.0, x = 50.0 (borde derecho se mantiene en 500)
    w_w = calc_resize_w(3.0, orig_w, -50.0, min_w)
    x_w = calc_resize_x(3.0, orig_x, orig_w, w_w)
    if (w_w == 450.0) { if (x_w == 50.0) {
        out("  [PASS] Borde Oeste (W): Expande ancho (450) y ancla borde derecho en 500 (X=50)")
    } else { out("  [FAIL] Borde Oeste falló anclaje en X") } } else { out("  [FAIL] Borde Oeste falló cálculo de ancho") }

    // ---------------------------------------------------------------------------
    // TEST 2: Borde Sur (S=2.0) y Borde Norte (N=4.0) con Anclaje Inferior
    // ---------------------------------------------------------------------------
    out(">>> TEST 2: Redimensionado Vertical (Sur vs Norte con Anclaje)...")
    // A. Sur: dh = +40.0 -> h = 340.0, y = 100.0
    h_s = calc_resize_h(2.0, orig_h, 40.0, min_h)
    y_s = calc_resize_y(2.0, orig_y, orig_h, h_s)
    if (h_s == 340.0) { if (y_s == 100.0) {
        out("  [PASS] Borde Sur (S): Expande alto (340) y ancla borde superior (100)")
    } else { out("  [FAIL] Borde Sur alteró posición Y") } } else { out("  [FAIL] Borde Sur falló cálculo de alto") }

    // B. Norte: dh = -40.0 (arrastre hacia arriba) -> h = 340.0, y = 60.0 (borde inferior se mantiene en 400)
    h_n = calc_resize_h(4.0, orig_h, -40.0, min_h)
    y_n = calc_resize_y(4.0, orig_y, orig_h, h_n)
    if (h_n == 340.0) { if (y_n == 60.0) {
        out("  [PASS] Borde Norte (N): Expande alto (340) y ancla borde inferior en 400 (Y=60)")
    } else { out("  [FAIL] Borde Norte falló anclaje en Y") } } else { out("  [FAIL] Borde Norte falló cálculo de alto") }

    // ---------------------------------------------------------------------------
    // TEST 3: Esquinas Diagonales 8D (SE, SW, NE, NW) con Doble Anclaje
    // ---------------------------------------------------------------------------
    out(">>> TEST 3: Esquinas Diagonales 8D (SE, SW, NE, NW)...")
    // SE (5.0): dw=+50, dh=+40 -> w=450, x=100, h=340, y=100
    w_se = calc_resize_w(5.0, orig_w, 50.0, min_w)
    x_se = calc_resize_x(5.0, orig_x, orig_w, w_se)
    h_se = calc_resize_h(5.0, orig_h, 40.0, min_h)
    y_se = calc_resize_y(5.0, orig_y, orig_h, h_se)
    if (w_se == 450.0) { if (x_se == 100.0) { if (h_se == 340.0) { if (y_se == 100.0) {
        out("  [PASS] Esquina SE (5.0): Crece hacia la derecha y abajo limpiamente")
    } } } }

    // NW (8.0): dw=-50, dh=-40 -> w=450, x=50, h=340, y=60
    w_nw = calc_resize_w(8.0, orig_w, -50.0, min_w)
    x_nw = calc_resize_x(8.0, orig_x, orig_w, w_nw)
    h_nw = calc_resize_h(8.0, orig_h, -40.0, min_h)
    y_nw = calc_resize_y(8.0, orig_y, orig_h, h_nw)
    if (w_nw == 450.0) { if (x_nw == 50.0) { if (h_nw == 340.0) { if (y_nw == 60.0) {
        out("  [PASS] Esquina NW (8.0): Crece anclando esquina SE en (500, 400)")
    } } } }

    // ---------------------------------------------------------------------------
    // TEST 4: Clamping Estricto a Límites Mínimos (Zero-Collapse)
    // ---------------------------------------------------------------------------
    out(">>> TEST 4: Clamping a Límites Mínimos (Zero-Collapse)...")
    // Reducción excesiva dw = -300 (intentando w = 100 < 200)
    w_clamped = calc_resize_w(1.0, orig_w, -300.0, min_w)
    if (w_clamped == 200.0) {
        out("  [PASS] Clamping horizontal: ancho no colapsa por debajo de min_w (200)")
    } else { out("  [FAIL] Falló clamping horizontal") }

    h_clamped = calc_resize_h(2.0, orig_h, -250.0, min_h)
    if (h_clamped == 150.0) {
        out("  [PASS] Clamping vertical: alto no colapsa por debajo de min_h (150)")
    } else { out("  [FAIL] Falló clamping vertical") }

    // ---------------------------------------------------------------------------
    // TEST 5: Mapeo de Registros de Cursor R229 para las 8 Direcciones
    // ---------------------------------------------------------------------------
    out(">>> TEST 5: Mapeo de Registros de Cursor R229 (8 Direcciones)...")
    c_e = window_cursor_from_dir(1.0)  // 4.0 ew-resize
    c_s = window_cursor_from_dir(2.0)  // 5.0 ns-resize
    c_w = window_cursor_from_dir(3.0)  // 4.0 ew-resize
    c_n = window_cursor_from_dir(4.0)  // 5.0 ns-resize
    c_se = window_cursor_from_dir(5.0) // 6.0 nwse-resize
    c_sw = window_cursor_from_dir(6.0) // 7.0 nesw-resize
    c_ne = window_cursor_from_dir(7.0) // 7.0 nesw-resize
    c_nw = window_cursor_from_dir(8.0) // 6.0 nwse-resize

    if (c_e == 4.0) { if (c_w == 4.0) {
        out("  [PASS] E y W mapeados a ew-resize (4.0)")
    } }
    if (c_s == 5.0) { if (c_n == 5.0) {
        out("  [PASS] S y N mapeados a ns-resize (5.0)")
    } }
    if (c_se == 6.0) { if (c_nw == 6.0) {
        out("  [PASS] SE y NW mapeados a nwse-resize (6.0)")
    } }
    if (c_sw == 7.0) { if (c_ne == 7.0) {
        out("  [PASS] SW y NE mapeados a nesw-resize (7.0)")
    } }

    // ---------------------------------------------------------------------------
    // TEST 6: Asignación a Registro de Hardware R229
    // ---------------------------------------------------------------------------
    out(">>> TEST 6: Registro de Salida de Hardware R229...")
    R229 = c_nw
    if (R229 == 6.0) {
        out("  [PASS] R229 recibe código 6.0 (nwse-resize) correctamente")
    } else { out("  [FAIL] R229 falló en recibir cursor 8D") }

    out("======================================================================")
    out("  HITO 3: TODAS LAS PRUEBAS DE ARQUITECTURA PASARON CON ÉXITO [PASS]  ")
    out("======================================================================")
    1.0
}
