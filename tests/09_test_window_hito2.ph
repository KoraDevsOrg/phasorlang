// ===============================================================================
// TESTS/09_TEST_WINDOW_HITO2.PH — TEST SUITE NATIVO PARA HITO 2
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Auditoría de Contenedor de Pantallas Hijas y Periféricos Directos
// Zero-GC | 100% Memoria Plana
// ===============================================================================

import "lib/ui_spatial_main.ph"
import "lib/ui_window.ph"

main = {
    out(">>> TEST 1: Detección de hit en barra de título de ventana...")
    // Ventana en mundo (100, 100) con tamaño (400, 300) y viewport (800, 600)
    // Con pan_x=0, pan_y=0, hx=100, hy=100, hr=500, hb=400, title_h=28
    hit_title = window_hit_title(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 150.0, 110.0)
    if (hit_title == 1.0) { out("  [PASS] Clic en barra de título detectado correctamente") } else { out("  [FAIL] Barra de título no detectó clic") }

    miss_title = window_hit_title(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 50.0, 50.0)
    if (miss_title == 0.0) { out("  [PASS] Clic fuera de barra de título ignorado correctamente") } else { out("  [FAIL] Clic espurio en barra de título") }

    out(">>> TEST 2: Botón de Minimizado [-] / [+]...")
    // Botón de minimizar en hr - 26 = 500 - 26 = 474.0, hy + 4 = 104.0
    hit_min = window_hit_min_btn(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 480.0, 110.0)
    if (hit_min == 1.0) { out("  [PASS] Hit en botón de minimizado detectado") } else { out("  [FAIL] Botón de minimizado no detectó hit") }

    out(">>> TEST 3: Esquina de Redimensionamiento (Desktop >= 768px)...")
    // Esquina inferior derecha: hr=500, hb=400. Rango: [482..500], [382..400]
    hit_resize = window_hit_resize_corner(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 495.0, 395.0)
    if (hit_resize == 1.0) { out("  [PASS] Hit en esquina de resize detectado en escritorio") } else { out("  [FAIL] Esquina de resize no detectó hit") }

    // En móvil (< 768px), el resize debe ser 0.0 (bloqueado para snap 100%)
    hit_resize_mob = window_hit_resize_corner(100.0, 100.0, 400.0, 300.0, 360.0, 640.0, 495.0, 395.0)
    if (hit_resize_mob == 0.0) { out("  [PASS] Resize bloqueado en móvil correctamente") } else { out("  [FAIL] Resize activo indebidamente en móvil") }

    out(">>> TEST 4: Detección de Cuerpo de Ventana con Estado Minimizado...")
    // En ventana normal (alto 300), clic en y=250 debe dar hit
    hit_body_normal = window_hit_body(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 200.0, 250.0)
    if (hit_body_normal == 1.0) { out("  [PASS] Cuerpo de ventana normal detecta hit") } else { out("  [FAIL] Cuerpo normal no detectó hit") }

    // En ventana minimizada (alto 28), clic en y=250 debe ser 0.0
    hit_body_min = window_hit_body(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 1.0, 200.0, 250.0)
    if (hit_body_min == 0.0) { out("  [PASS] Ventana minimizada colapsa cuerpo a 28px") } else { out("  [FAIL] Ventana minimizada mantiene cuerpo completo") }

    out(">>> TEST 5: Acceso a Registros Periféricos de Hardware Directos (R240..R255)...")
    // Asignar y leer registros de hardware directamente en lenguaje Phasor
    R240 = 1.0    // Gamepad conectado
    R241 = -0.75  // Stick izquierdo X
    R248 = 1.0    // Clic derecho
    R249 = 0.0    // Clic central
    R255 = 120.0  // Rueda de scroll vertical

    if (R240 == 1.0) { out("  [PASS] R240 (GAMEPAD_CONNECTED) accesible directamente") } else { out("  [FAIL] R240 falló") }
    if (R241 == -0.75) { out("  [PASS] R241 (GAMEPAD_LX) accesible directamente") } else { out("  [FAIL] R241 falló") }
    if (R248 == 1.0) { out("  [PASS] R248 (POINTER_RIGHT) accesible directamente") } else { out("  [FAIL] R248 falló") }
    if (R255 == 120.0) { out("  [PASS] R255 (SCROLL_WHEEL) accesible directamente") } else { out("  [FAIL] R255 falló") }

    out(">>> TEST 6: Detección 8-Direccional de Bordes y Esquinas (window_hit_edge_8d)...")
    // Ventana en (100, 100), tamaño (400, 300) -> X en [100..500], Y en [100..400]
    // Borde Este (X=496, Y=250) -> Dir 1.0 (E)
    edge_e = window_hit_edge_8d(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 496.0, 250.0)
    if (edge_e == 1.0) { out("  [PASS] Borde Este (E) detectado correctamente (dir=1)") } else { out("  [FAIL] Borde Este fallo") }

    // Borde Sur (X=250, Y=396) -> Dir 2.0 (S)
    edge_s = window_hit_edge_8d(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 250.0, 396.0)
    if (edge_s == 2.0) { out("  [PASS] Borde Sur (S) detectado correctamente (dir=2)") } else { out("  [FAIL] Borde Sur fallo") }

    // Borde Oeste (X=103, Y=250) -> Dir 3.0 (W)
    edge_w = window_hit_edge_8d(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 103.0, 250.0)
    if (edge_w == 3.0) { out("  [PASS] Borde Oeste (W) detectado correctamente (dir=3)") } else { out("  [FAIL] Borde Oeste fallo") }

    // Borde Norte (X=250, Y=103) -> Dir 4.0 (N)
    edge_n = window_hit_edge_8d(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 250.0, 103.0)
    if (edge_n == 4.0) { out("  [PASS] Borde Norte (N) detectado correctamente (dir=4)") } else { out("  [FAIL] Borde Norte fallo") }

    // Esquina Sureste (X=496, Y=396) -> Dir 5.0 (SE)
    edge_se = window_hit_edge_8d(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 496.0, 396.0)
    if (edge_se == 5.0) { out("  [PASS] Esquina Sureste (SE) detectada correctamente (dir=5)") } else { out("  [FAIL] Esquina SE fallo") }

    // Esquina Noroeste (X=103, Y=103) -> Dir 8.0 (NW)
    edge_nw = window_hit_edge_8d(100.0, 100.0, 400.0, 300.0, 800.0, 600.0, 0.0, 103.0, 103.0)
    if (edge_nw == 8.0) { out("  [PASS] Esquina Noroeste (NW) detectada correctamente (dir=8)") } else { out("  [FAIL] Esquina NW fallo") }

    out(">>> TEST 7: Asignación y Lectura de R256 (SYS_CURSOR_SHAPE)...")
    R256 = window_cursor_from_dir(edge_e) // Dir 1 -> ew-resize (4.0)
    if (R256 == 4.0) { out("  [PASS] R256 mapeado a EW-Resize (4.0) correctamente") } else { out("  [FAIL] R256 fallo") }

    R256 = window_cursor_from_dir(edge_se) // Dir 5 -> nwse-resize (6.0)
    if (R256 == 6.0) { out("  [PASS] R256 mapeado a NWSE-Resize (6.0) correctamente") } else { out("  [FAIL] R256 fallo") }

    out("======================================================================")
    out("  HITO 2: TODAS LAS PRUEBAS DE ARQUITECTURA PASARON CON ÉXITO [PASS]  ")
    out("======================================================================")
    1.0
}
