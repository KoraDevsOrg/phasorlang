// ===============================================================
// LIB/TEST.PH — Framework de Testing Unitario e Integracion Zero-GC
// PhasorLang v1.0 [Fase 12 Consolidacion Multiplataforma — Chronos IDE]
// Aserciones Matematicas, Tolerancia de Fase/Fasores, SIMD 3D y SoA Contiguo
// Evaluacion Ultra-Rapida en Microsegundos sin Pausas de GC
// ===============================================================

// 1. Estructura SoA para Metricas y Estadisticas del Suite de Pruebas
// 5 campos continuos en memoria plana Zero-GC
struct TestStatsSoA {
    total: Float,       // Campo 0: Total de suites / pruebas ejecutadas
    passed: Float,      // Campo 1: Conteo de aserciones pasadas exitosas
    failed: Float,      // Campo 2: Conteo de aserciones fallidas
    assertions: Float,  // Campo 3: Conteo acumulado de aserciones evaluadas
    last_status: Float  // Campo 4: 1.0 si la ultima asercion paso, 0.0 si fallo
}

// 2. Preasignacion Contigua de Memoria Plana SoA para Estadisticas Globales
TEST_SUITE_CAP = 32
test_stats_soa = alloc_soa(5, TEST_SUITE_CAP)

// 3. Inicializacion del Entorno de Pruebas
test.init() = {
    set_soa(test_stats_soa, 0, 0, TEST_SUITE_CAP, 0.0) // total
    set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, 0.0) // passed
    set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, 0.0) // failed
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, 0.0) // assertions
    set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0) // last_status
    1.0
}

// Reserva de buffer de pruebas personalizado
test.alloc_suite(cap) = {
    alloc_soa(5, cap)
}

// ===============================================================
// 4. ASERCIONES NATIVAS DE ALTA VELOCIDAD (ZERO-ALLOCATION)
// ===============================================================

// Asercion de Igualdad Exacta: val1 == val2
test.assert_eq(val1, val2, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    if (val1 == val2) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS]", msg, "val:", val1)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL]", msg, "esperado:", val2, "obtenido:", val1)
        0.0
    }
}

// Asercion de Proximidad / Tolerancia (para fasores, angulos, floats): |val1 - val2| <= tol
test.assert_near(val1, val2, tolerance, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    diff = abs(val1 - val2)
    if (diff <= tolerance) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS NEAR]", msg, "diff:", diff)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL NEAR]", msg, "diff:", diff, "tol:", tolerance)
        0.0
    }
}

// Asercion Vectorial SIMD 3D: |vec1 - vec2| <= 0.0001
test.assert_simd_eq(vec1, vec2, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    diff_v = vec1 - vec2
    dist = abs(diff_v)
    if (dist <= 0.0001) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS SIMD]", msg, "dist:", dist)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL SIMD]", msg, "dist:", dist)
        0.0
    }
}

// Asercion Booleana Verdadera: cond != 0.0
test.assert_true(cond, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    if (cond != 0.0) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS]", msg)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL]", msg)
        0.0
    }
}

// Asercion Booleana Falsa: cond == 0.0
test.assert_false(cond, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    if (cond == 0.0) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS]", msg)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL]", msg)
        0.0
    }
}

// Asercion de Campo Exacto en Tabla SoA
test.assert_soa_eq(table_soa, field, idx, cap, expected, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    val = get_soa(table_soa, field, idx, cap)
    if (val == expected) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS SOA]", msg, "val:", val)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL SOA]", msg, "esperado:", expected, "obtenido:", val)
        0.0
    }
}

// Asercion de Campo con Tolerancia en Tabla SoA
test.assert_soa_near(table_soa, field, idx, cap, expected, tol, msg) = {
    total_a = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP) + 1.0
    set_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP, total_a)

    val = get_soa(table_soa, field, idx, cap)
    diff = abs(val - expected)
    if (diff <= tol) {
        pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP, pass_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 1.0)
        out("[PASS SOA NEAR]", msg, "diff:", diff)
        1.0
    } else {
        fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP) + 1.0
        set_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP, fail_cnt)
        set_soa(test_stats_soa, 4, 0, TEST_SUITE_CAP, 0.0)
        out("[FAIL SOA NEAR]", msg, "diff:", diff, "tol:", tol)
        0.0
    }
}

// ===============================================================
// 5. INSPECCION DE RESULTADOS Y REPORTE ESTADISTICO
// ===============================================================

test.get_passed() = {
    get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP)
}

test.get_failed() = {
    get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP)
}

test.get_total_assertions() = {
    get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP)
}

// Reporte Consolidado del Suite de Pruebas Zero-GC
test.report() = {
    pass_cnt = get_soa(test_stats_soa, 1, 0, TEST_SUITE_CAP)
    fail_cnt = get_soa(test_stats_soa, 2, 0, TEST_SUITE_CAP)
    total_a  = get_soa(test_stats_soa, 3, 0, TEST_SUITE_CAP)

    out("==================================================")
    out("  PHASORLANG ZERO-GC TEST SUITE REPORT")
    out("==================================================")
    out("Aserciones Totales :", total_a)
    out("Aserciones Pasadas :", pass_cnt)
    out("Aserciones Fallidas:", fail_cnt)

    if (fail_cnt == 0.0) {
        out("Resultado Global   : TODOS LOS TESTS PASARON [OK]")
    } else {
        out("Resultado Global   : HAY TESTS FALLIDOS [ERROR]")
    }
    out("==================================================")

    fail_cnt
}
