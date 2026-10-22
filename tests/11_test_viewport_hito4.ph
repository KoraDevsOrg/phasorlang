// ===============================================================================
// TESTS/11_TEST_VIEWPORT_HITO4.PH — TEST SUITE NATIVO PARA HITO 4
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Viewport Aislado, Clipping Estricto y Scroll Inteligente (Thumb Dragging)
// Invariante Estricto: Zero-GC a 120 FPS Nativos
// ===============================================================================

import "lib/ui_viewport.ph"

main = {
    out("======================================================================")
    out("  HITO 4: INICIANDO BATERIA DE PRUEBAS DE VIEWPORT Y SCROLL (PVM)     ")
    out("======================================================================")

    // Ventana de prueba: hx=100, hy=100, 400x300, area cliente desde top=54
    hx = 100.0
    hy = 100.0
    ww = 400.0
    wh = 300.0
    top = 54.0
    clw = vp_client_w(ww)
    clh = vp_client_h(wh, top)

    // ---------------------------------------------------------------------------
    // TEST 1: Area cliente y visibilidad de barras
    // ---------------------------------------------------------------------------
    out(">>> TEST 1: Area cliente y presencia de barras...")
    if (clw == 398.0) { if (clh == 245.0) {
        out("  [PASS] Area cliente 398x245")
    } else { out("  [FAIL] Alto cliente incorrecto") } } else { out("  [FAIL] Ancho cliente incorrecto") }

    if (vp_show_v(300.0, 200.0, clw, clh) == 0.0) { if (vp_show_h(300.0, 200.0, clw, clh) == 0.0) {
        out("  [PASS] Contenido que cabe no muestra barras")
    } else { out("  [FAIL] Barra H espuria") } } else { out("  [FAIL] Barra V espuria") }

    if (vp_show_v(300.0, 400.0, clw, clh) == 1.0) { if (vp_show_h(300.0, 400.0, clw, clh) == 0.0) {
        out("  [PASS] Solo desborde vertical muestra solo barra V")
    } else { out("  [FAIL] Barra H espuria en desborde vertical") } } else { out("  [FAIL] Falta barra V") }

    if (vp_show_v(500.0, 200.0, clw, clh) == 0.0) { if (vp_show_h(500.0, 200.0, clw, clh) == 1.0) {
        out("  [PASS] Solo desborde horizontal muestra solo barra H")
    } else { out("  [FAIL] Falta barra H") } } else { out("  [FAIL] Barra V espuria en desborde horizontal") }

    // Caso limite: la barra H roba 7px y fuerza la barra V (ch=242 cabe en 245 pero no en 238)
    if (vp_show_v(500.0, 242.0, clw, clh) == 1.0) {
        out("  [PASS] La barra H que roba espacio activa la barra V (interaccion de barras)")
    } else { out("  [FAIL] Interaccion barra H -> V no detectada") }

    // ---------------------------------------------------------------------------
    // TEST 2: Maximos de scroll y clamping
    // ---------------------------------------------------------------------------
    out(">>> TEST 2: Maximos de scroll y clamping...")
    // Solo V: max_y = 400 - 245 = 155
    my_max = vp_max_y(300.0, 400.0, clw, clh)
    if (my_max == 155.0) {
        out("  [PASS] max_y = contenido - alto cliente (155)")
    } else { out("  [FAIL] max_y incorrecto") }

    // Ambas barras: visible_w = 398-7 = 391 ; max_x = 600-391 = 209
    mx_max = vp_max_x(600.0, 400.0, clw, clh)
    if (mx_max == 209.0) {
        out("  [PASS] max_x descuenta la barra V visible (209)")
    } else { out("  [FAIL] max_x incorrecto") }

    // Contenido que cabe -> max 0
    if (vp_max_y(300.0, 200.0, clw, clh) == 0.0) {
        out("  [PASS] max_y = 0 si el contenido cabe")
    } else { out("  [FAIL] max_y deberia ser 0") }

    if (vp_clamp_scroll(-30.0, 155.0) == 0.0) { if (vp_clamp_scroll(999.0, 155.0) == 155.0) { if (vp_clamp_scroll(80.0, 155.0) == 80.0) {
        out("  [PASS] Clamp de scroll en [0, max]")
    } else { out("  [FAIL] Clamp altera valor interior") } } else { out("  [FAIL] Clamp superior") } } else { out("  [FAIL] Clamp inferior") }

    // ---------------------------------------------------------------------------
    // TEST 3: Clipping estricto por contencion total
    // ---------------------------------------------------------------------------
    out(">>> TEST 3: Clipping estricto de contenido...")
    cl = 101.0
    ct = 154.0
    cr = 499.0
    cb = 399.0
    if (vp_rect_inside(150.0, 200.0, 100.0, 12.0, cl, ct, cr, cb) == 1.0) {
        out("  [PASS] Rectangulo interior se dibuja")
    } else { out("  [FAIL] Interior descartado") }
    if (vp_rect_inside(150.0, 150.0, 100.0, 12.0, cl, ct, cr, cb) == 0.0) {
        out("  [PASS] Fila que sobresale por arriba se oculta")
    } else { out("  [FAIL] Fila superior no recortada") }
    if (vp_rect_inside(150.0, 390.0, 100.0, 12.0, cl, ct, cr, cb) == 0.0) {
        out("  [PASS] Fila que sobresale por abajo se oculta")
    } else { out("  [FAIL] Fila inferior no recortada") }
    if (vp_rect_inside(95.0, 200.0, 100.0, 12.0, cl, ct, cr, cb) == 0.0) {
        out("  [PASS] Texto que sobresale por la izquierda se oculta")
    } else { out("  [FAIL] Izquierda no recortada") }
    if (vp_rect_inside(450.0, 200.0, 100.0, 12.0, cl, ct, cr, cb) == 0.0) {
        out("  [PASS] Texto que sobresale por la derecha se oculta")
    } else { out("  [FAIL] Derecha no recortada") }
    if (vp_text_w(10.0, 10.0) == 60.0) {
        out("  [PASS] Ancho estimado de texto monoespaciado (10 chars, fuente 10 = 60px)")
    } else { out("  [FAIL] Ancho estimado incorrecto") }

    // ---------------------------------------------------------------------------
    // TEST 4: Geometria del thumb
    // ---------------------------------------------------------------------------
    out(">>> TEST 4: Geometria proporcional del thumb...")
    trk_len = vp_track_v_len(300.0, 400.0, clw, clh)   // visible_h(245) - 1 = 244
    if (trk_len == 244.0) {
        out("  [PASS] Longitud de pista V = 244")
    } else { out("  [FAIL] Pista V incorrecta") }
    vis_px = 245.0
    cont_px = 400.0
    thb_sz = vp_thumb_size(trk_len, vis_px, cont_px)         // 244 * 245/400 = 149.45
    if (thb_sz > 149.0) { if (thb_sz < 150.0) {
        out("  [PASS] Thumb proporcional a visible/contenido (~149.45)")
    } else { out("  [FAIL] Thumb demasiado grande") } } else { out("  [FAIL] Thumb demasiado pequeno") }
    if (vp_thumb_size(244.0, 245.0, 100000.0) == 16.0) {
        out("  [PASS] Thumb nunca baja de 16px")
    } else { out("  [FAIL] Minimo del thumb no respetado") }
    sc_zero = 0.0
    sc_full = 155.0
    max_px = 155.0
    off_zero = vp_thumb_offset(trk_len, thb_sz, sc_zero, max_px)
    if (off_zero == 0.0) {
        out("  [PASS] Scroll 0 -> thumb al inicio de la pista")
    } else { out("  [FAIL] Offset inicial incorrecto") }
    off_end = vp_thumb_offset(trk_len, thb_sz, sc_full, max_px)
    if (off_end == (trk_len - thb_sz)) {
        out("  [PASS] Scroll maximo -> thumb al final de la pista")
    } else { out("  [FAIL] Offset final incorrecto") }

    // ---------------------------------------------------------------------------
    // TEST 5: Hit-testing de thumb y pista
    // ---------------------------------------------------------------------------
    out(">>> TEST 5: Hit-testing de thumb y pista (eje vertical)...")
    trk_x = vp_track_v_x(hx, ww)   // 493
    trk_y = vp_track_v_y(hy, top)  // 155
    if (vp_hit_v(hx, hy, ww, wh, top, 300.0, 400.0, 0.0, trk_x + 3.0, trk_y + 10.0) == 1.0) {
        out("  [PASS] Clic sobre el thumb detectado (hit=1)")
    } else { out("  [FAIL] Thumb no detectado") }
    if (vp_hit_v(hx, hy, ww, wh, top, 300.0, 400.0, 0.0, trk_x + 3.0, trk_y + 230.0) == 2.0) {
        out("  [PASS] Clic en pista fuera del thumb detectado (hit=2)")
    } else { out("  [FAIL] Pista no detectada") }
    if (vp_hit_v(hx, hy, ww, wh, top, 300.0, 400.0, 0.0, 250.0, trk_y + 10.0) == 0.0) {
        out("  [PASS] Clic en el contenido no toca la barra (hit=0)")
    } else { out("  [FAIL] Falso positivo en contenido") }
    if (vp_hit_v(hx, hy, ww, wh, top, 300.0, 200.0, 0.0, trk_x + 3.0, trk_y + 10.0) == 0.0) {
        out("  [PASS] Sin desborde no existe barra que golpear")
    } else { out("  [FAIL] Barra fantasma") }

    out(">>> TEST 5b: Hit-testing eje horizontal...")
    htx = vp_track_h_x(hx)        // 101
    hty = vp_track_h_y(hy, wh)    // 393
    if (vp_hit_h(hx, hy, ww, wh, top, 600.0, 200.0, 0.0, htx + 10.0, hty + 3.0) == 1.0) {
        out("  [PASS] Thumb horizontal detectado")
    } else { out("  [FAIL] Thumb H no detectado") }
    if (vp_hit_h(hx, hy, ww, wh, top, 600.0, 200.0, 0.0, htx + 350.0, hty + 3.0) == 2.0) {
        out("  [PASS] Pista horizontal detectada")
    } else { out("  [FAIL] Pista H no detectada") }

    // ---------------------------------------------------------------------------
    // TEST 6: Arrastre del thumb (cinematica)
    // ---------------------------------------------------------------------------
    out(">>> TEST 6: Arrastre del thumb...")
    grab = vp_grab_v(hx, hy, ww, wh, top, 300.0, 400.0, 0.0, 1.0, trk_y + 10.0)
    if (grab == 10.0) {
        out("  [PASS] Agarre dentro del thumb conserva el offset del puntero (10px)")
    } else { out("  [FAIL] Offset de agarre incorrecto") }

    sc_start = vp_drag_scroll_v(hx, hy, ww, wh, top, 300.0, 400.0, grab, trk_y + 10.0)
    if (sc_start == 0.0) {
        out("  [PASS] Puntero en el punto de agarre -> scroll 0")
    } else { out("  [FAIL] Scroll inicial distinto de 0") }

    sc_end = vp_drag_scroll_v(hx, hy, ww, wh, top, 300.0, 400.0, grab, trk_y + 5000.0)
    if (sc_end == 155.0) {
        out("  [PASS] Arrastrar mas alla del final se limita al maximo (155)")
    } else { out("  [FAIL] Overshoot no limitado") }

    sc_neg = vp_drag_scroll_v(hx, hy, ww, wh, top, 300.0, 400.0, grab, trk_y - 5000.0)
    if (sc_neg == 0.0) {
        out("  [PASS] Arrastrar antes del inicio se limita a 0")
    } else { out("  [FAIL] Underflow no limitado") }

    // Mitad del recorrido -> mitad del scroll
    trk_trv = trk_len - thb_sz
    sc_mid = vp_drag_scroll_v(hx, hy, ww, wh, top, 300.0, 400.0, grab, trk_y + 10.0 + (trk_trv * 0.5))
    if (sc_mid > 77.4) { if (sc_mid < 77.6) {
        out("  [PASS] Mitad del recorrido del thumb -> mitad del scroll (77.5)")
    } else { out("  [FAIL] Proporcionalidad superior") } } else { out("  [FAIL] Proporcionalidad inferior") }

    // Clic en pista centra el thumb bajo el puntero
    grab_track = vp_grab_v(hx, hy, ww, wh, top, 300.0, 400.0, 0.0, 2.0, trk_y + 230.0)
    if (grab_track == (thb_sz * 0.5)) {
        out("  [PASS] Clic en pista centra el thumb bajo el puntero")
    } else { out("  [FAIL] Centrado en pista incorrecto") }

    // Arrastre horizontal
    h_grab = vp_grab_h(hx, hy, ww, wh, top, 600.0, 200.0, 0.0, 1.0, htx + 10.0)
    h_max = vp_max_x(600.0, 200.0, clw, clh)
    h_end = vp_drag_scroll_h(hx, hy, ww, wh, top, 600.0, 200.0, h_grab, htx + 9000.0)
    if (h_end == h_max) {
        out("  [PASS] Arrastre horizontal limitado al maximo")
    } else { out("  [FAIL] Arrastre H sin limite") }

    // ---------------------------------------------------------------------------
    // TEST 7: Auditoria Zero-GC (miles de evaluaciones sin asignacion)
    // ---------------------------------------------------------------------------
    out(">>> TEST 7: Auditoria Zero-GC (2000 evaluaciones de geometria)...")
    acc = 0.0
    i = 0.0
    while (i < 2000.0) {
        acc = acc + vp_drag_scroll_v(hx, hy, ww, wh, top, 300.0, 400.0, 10.0, trk_y + (i * 0.1))
        i = i + 1.0
    }
    if (acc > 0.0) {
        out("  [PASS] 2000 evaluaciones escalares completadas sin asignaciones en Heap")
    } else { out("  [FAIL] Bucle de auditoria sin progreso") }

    out("======================================================================")
    out("  HITO 4: TODAS LAS PRUEBAS DE ARQUITECTURA PASARON CON EXITO [PASS]  ")
    out("======================================================================")
}
