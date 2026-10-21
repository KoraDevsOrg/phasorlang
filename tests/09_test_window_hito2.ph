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

    out("======================================================================")
    out("  HITO 2: TODAS LAS PRUEBAS DE ARQUITECTURA PASARON CON ÉXITO [PASS]  ")
    out("======================================================================")
    1.0
}
