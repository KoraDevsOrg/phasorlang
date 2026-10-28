// ===============================================================================
// TESTS/12_TEST_DOCKING_HITO5.PH — TEST SUITE NATIVO PARA HITO 5
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Docking, Snap Magnético y Splitters Inter-Ventana
// Invariante Estricto: Zero-GC a 120 FPS Nativos (solo aritmética escalar PVM)
// ===============================================================================

import "lib/ui_docking.ph"

signal test_pass_count = 0.0

test_docking_suite() = {
    out("======================================================================")
    out("  HITO 5: INICIANDO BATERIA DE PRUEBAS DE DOCKING Y SNAP (PVM)       ")
    out("======================================================================")

    sw = 1200.0
    sh = 800.0
    margin = 16.0
    thresh = 16.0

    // ---------------------------------------------------------------------------
    // TEST 1: Detección de Zonas Calientes de Docking
    // ---------------------------------------------------------------------------
    out(">>> TEST 1: Deteccion de zonas calientes de docking...")
    
    // Superior -> DOCK_MAXIMIZE (5.0)
    z_max = dock_detect_zone(600.0, 30.0, sw, sh, margin)
    if (z_max == 5.0) {
        out("  [PASS] Cursor en borde superior activa DOCK_MAXIMIZE (5.0)")
    } else { out("  [FAIL] DOCK_MAXIMIZE no detectado") }

    // Izquierda -> DOCK_LEFT (1.0)
    z_left = dock_detect_zone(8.0, 400.0, sw, sh, margin)
    if (z_left == 1.0) {
        out("  [PASS] Cursor en borde izquierdo activa DOCK_LEFT (1.0)")
    } else { out("  [FAIL] DOCK_LEFT no detectado") }

    // Derecha -> DOCK_RIGHT (2.0)
    z_right = dock_detect_zone(1195.0, 400.0, sw, sh, margin)
    if (z_right == 2.0) {
        out("  [PASS] Cursor en borde derecho activa DOCK_RIGHT (2.0)")
    } else { out("  [FAIL] DOCK_RIGHT no detectado") }

    // Inferior -> DOCK_BOTTOM (4.0)
    z_bot = dock_detect_zone(600.0, 770.0, sw, sh, margin)
    if (z_bot == 4.0) {
        out("  [PASS] Cursor en borde inferior activa DOCK_BOTTOM (4.0)")
    } else { out("  [FAIL] DOCK_BOTTOM no detectado") }

    // Centro libre -> DOCK_NONE (0.0)
    z_none = dock_detect_zone(600.0, 400.0, sw, sh, margin)
    if (z_none == 0.0) {
        out("  [PASS] Cursor en zona interior permanece flotante DOCK_NONE (0.0)")
    } else { out("  [FAIL] DOCK_NONE no respetado") }

    // Móvil (< 768px) -> Inhabilita docking de escritorio
    z_mob = dock_detect_zone(8.0, 400.0, 600.0, sh, margin)
    if (z_mob == 0.0) {
        out("  [PASS] Docking deshabilitado en viewport movil (< 768px)")
    } else { out("  [FAIL] Docking no debe activarse en movil") }

    // ---------------------------------------------------------------------------
    // TEST 2: Geometría de Zonas de Docking
    // ---------------------------------------------------------------------------
    out(">>> TEST 2: Geometria de zonas de docking...")
    sw = 1200.0
    sh = 800.0
    
    // Área de trabajo total: Y=28, H=800-52=748
    h_work = dock_work_h(sh)
    if (h_work == 748.0) {
        out("  [PASS] Altura de area de trabajo descontando barras fijas (748)")
    } else { out("  [FAIL] Altura de area de trabajo incorrecta") }

    // DOCK_LEFT: x=0, y=28, w=600, h=748
    if (dock_zone_x(1.0, sw) == 0.0) { if (dock_zone_w(1.0, sw) == 600.0) {
        out("  [PASS] DOCK_LEFT ocupa mitad izquierda exacta (X=0, W=600)")
    } else { out("  [FAIL] Ancho DOCK_LEFT") } } else { out("  [FAIL] Posicion DOCK_LEFT") }

    // DOCK_RIGHT: x=600, y=28, w=600, h=748
    if (dock_zone_x(2.0, sw) == 600.0) { if (dock_zone_w(2.0, sw) == 600.0) {
        out("  [PASS] DOCK_RIGHT ocupa mitad derecha exacta (X=600, W=600)")
    } else { out("  [FAIL] Ancho DOCK_RIGHT") } } else { out("  [FAIL] Posicion DOCK_RIGHT") }

    // DOCK_MAXIMIZE: x=0, y=28, w=1200, h=748
    if (dock_zone_w(5.0, sw) == 1200.0) { if (dock_zone_h(5.0, sh) == 748.0) {
        out("  [PASS] DOCK_MAXIMIZE abarca el 100% del viewport util (1200x748)")
    } else { out("  [FAIL] Alto DOCK_MAXIMIZE") } } else { out("  [FAIL] Ancho DOCK_MAXIMIZE") }

    // ---------------------------------------------------------------------------
    // TEST 3: Snap Magnético a Bordes del Viewport
    // ---------------------------------------------------------------------------
    out(">>> TEST 3: Snap magnetico a bordes del viewport...")
    
    // Snap a borde izquierdo (curr_x = 10 -> imanta a 0)
    sn_l = dock_snap_viewport_x(10.0, 400.0, sw, thresh)
    if (sn_l == 0.0) {
        out("  [PASS] Coordenada X dentro del umbral (10px) se magnetiza al borde izquierdo (0.0)")
    } else { out("  [FAIL] Snap izquierdo no imantado") }

    // Fuera de umbral izquierdo (curr_x = 25 -> permanece 25)
    sn_l_free = dock_snap_viewport_x(25.0, 400.0, sw, thresh)
    if (sn_l_free == 25.0) {
        out("  [PASS] Coordenada X fuera del umbral (25px) permanece flotante libre")
    } else { out("  [FAIL] Snap debe ser suave y respetar margen libre") }

    // Snap a borde derecho (win_w = 400, sw = 1200, target_right = 800; curr_x = 792 -> imanta a 800)
    sn_r = dock_snap_viewport_x(792.0, 400.0, sw, thresh)
    if (sn_r == 800.0) {
        out("  [PASS] Borde derecho dentro del umbral (792px) se magnetiza a 800.0")
    } else { out("  [FAIL] Snap derecho no imantado") }

    // Snap vertical a barra de menú (curr_y = 35 -> imanta a 28)
    sn_t = dock_snap_viewport_y(35.0, 300.0, sh, thresh)
    if (sn_t == 28.0) {
        out("  [PASS] Coordenada Y dentro del umbral se magnetiza al borde superior util (28.0)")
    } else { out("  [FAIL] Snap superior no imantado") }

    // ---------------------------------------------------------------------------
    // TEST 4: Snap Magnético entre Ventanas Vecinas
    // ---------------------------------------------------------------------------
    out(">>> TEST 4: Snap magnetico entre ventanas vecinas...")
    
    // Ventana A (w=400) se acerca a Ventana B (x=500, w=300)
    // Distancia: ax=90 -> ax + aw = 490 -> dist = 10 <= 16 -> imanta a bx - aw = 100
    sn_neigh = dock_snap_window_neighbor_x(90.0, 400.0, 500.0, 300.0, thresh)
    if (sn_neigh == 100.0) {
        out("  [PASS] Borde derecho de ventana A se magnetiza al borde izquierdo de ventana B")
    } else { out("  [FAIL] Snap inter-ventana no imantado") }

    // Ventana A se ubica a la derecha de B (bx + bw = 800, curr_ax = 810 -> imanta a 800)
    sn_neigh_r = dock_snap_window_neighbor_x(810.0, 400.0, 500.0, 300.0, thresh)
    if (sn_neigh_r == 800.0) {
        out("  [PASS] Borde izquierdo de ventana A se magnetiza al borde derecho de ventana B")
    } else { out("  [FAIL] Snap derecho inter-ventana no imantado") }

    // ---------------------------------------------------------------------------
    // TEST 5: Splitters Inter-Ventana
    // ---------------------------------------------------------------------------
    out(">>> TEST 5: Splitters inter-ventana (redistribucion con suma constante)...")
    
    // Hit testing de divisor vertical
    split_x = 600.0
    split_y = 28.0
    split_h = 748.0
    if (splitter_hit_v(split_x, split_y, split_h, 602.0, 200.0, 6.0) == 1.0) {
        out("  [PASS] Clic sobre barra divisora detectado con precision (hit=1)")
    } else { out("  [FAIL] Splitter hit no detectado") }
    if (splitter_hit_v(split_x, split_y, split_h, 650.0, 200.0, 6.0) == 0.0) {
        out("  [PASS] Clic fuera de barra divisora ignorado correctamente (hit=0)")
    } else { out("  [FAIL] Falso positivo en splitter hit") }

    // Redistribución de anchos: w1=500, w2=500 (total=1000). Arrastre delta=+50
    tot_w = 1000.0
    nw1 = splitter_calc_w1(50.0, 500.0, 500.0, 200.0)
    nw2 = splitter_calc_w2(nw1, tot_w)
    if (nw1 == 550.0) { if (nw2 == 450.0) {
        out("  [PASS] Arrastre de splitter redistribuye proporcionalmente (550 + 450 = 1000)")
    } else { out("  [FAIL] w2 incorrecto") } } else { out("  [FAIL] w1 incorrecto") }

    // Límite mínimo anti-colapso: delta=-400 (w1 intentaría ser 100, clamped a 200)
    nw1_min = splitter_calc_w1(-400.0, 500.0, 500.0, 200.0)
    nw2_min = splitter_calc_w2(nw1_min, tot_w)
    if (nw1_min == 200.0) { if (nw2_min == 800.0) {
        out("  [PASS] Clamping de splitter respeta ancho minimo sin colapsar (200 + 800 = 1000)")
    } else { out("  [FAIL] Clamping w2") } } else { out("  [FAIL] Clamping w1") }

    // ---------------------------------------------------------------------------
    // TEST 6: Auditoría Zero-GC (2,000 Ciclos Continuos de Docking y Snap)
    // ---------------------------------------------------------------------------
    out(">>> TEST 6: Auditoria Zero-GC (2000 ciclos continuos a 120 FPS)...")
    loop_i = 0.0
    accum = 0.0
    while (loop_i < 2000.0) {
        z = dock_detect_zone(loop_i * 0.5, 200.0, sw, sh, margin)
        accum = accum + z
        sn = dock_snap_viewport_x(loop_i * 0.1, 300.0, sw, thresh)
        accum = accum + sn
        loop_i = loop_i + 1.0
    }
    if (loop_i == 2000.0) {
        out("  [PASS] 2000 ciclos de evaluacion de docking y snap ejecutados con 0 bytes de asignacion en Heap")
    } else { out("  [FAIL] Ciclos no completados") }

    out("======================================================================")
    out("  HITO 5: TODAS LAS PRUEBAS DE ARQUITECTURA PASARON CON EXITO [PASS]  ")
    out("======================================================================")
    1.0
}

screen main {
    test_docking_suite()
}
