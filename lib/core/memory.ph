// ============================================================================
// PHASORLANG STORE - GRADO 0: ARREGLOS PLANOS ZERO-GC (MEMORY ARENA SoA)
// Elimina cadenas de if/else al indexar tableros, listas o tablas en O(1)
// ============================================================================
mem_get(base, idx) = {
    get_soa(base, 0.0, idx, 1.0)
}

mem_set(base, idx, val) = {
    set_soa(base, 0.0, idx, 1.0, val)
}

mem_fill(base, count, val) = {
    i = 0.0
    while (i < count) {
        set_soa(base, 0.0, i, 1.0, val)
        i = i + 1.0
    }
    1.0
}

mem_count(base, count, target) = {
    c = 0.0
    i = 0.0
    while (i < count) {
        if (get_soa(base, 0.0, i, 1.0) == target) {
            c = c + 1.0
        } else { 0.0 }
        i = i + 1.0
    }
    c
}
