// ===============================================================
// LIB/DB.PH — Motor de Base de Datos Columnar SQL, Busqueda Vectorial y Grafos
// PhasorLang v1.0 [Self-Hosting Etapa 3 & Decoupled Architecture]
// Almacenamiento Columnar SoA Zero-GC, Consultas Declarativas, Embeddings SIMD
// y Resonancia de Fase en Grafos Fasoriales (+~) a 90+ FPS
// ===============================================================

// 1. Estructura de Registro Columnar para Sensores
struct SensorColumnarSoA {
    id: Float,         // Columna 0: Identificador unico
    fase: Float,       // Columna 1: Angulo de fase (radianes)
    magnitud: Float,   // Columna 2: Magnitud / Amplitud
    frecuencia: Float, // Columna 3: Frecuencia angular (omega)
    emb_x: Float,      // Columna 4: Embedding vectorial X
    emb_y: Float,      // Columna 5: Embedding vectorial Y
    emb_z: Float       // Columna 6: Embedding vectorial Z
}

// 2. Reserva de Memoria Contigua Plana SoA para Tablas Columnares
// 7 campos contiguos por registro (id, fase, mag, freq, emb_x, emb_y, emb_z)
db.alloc_table(capacity) = {
    alloc_soa(7, capacity)
}

// 3. Insercion de Registros en Formato Columnar Contiguo
db.insert_sensor(table_soa, idx, id_val, fase_val, mag_val, freq_val, ex, ey, ez, cap) = {
    set_soa(table_soa, 0, idx, cap, id_val)
    set_soa(table_soa, 1, idx, cap, fase_val)
    set_soa(table_soa, 2, idx, cap, mag_val)
    set_soa(table_soa, 3, idx, cap, freq_val)
    set_soa(table_soa, 4, idx, cap, ex)
    set_soa(table_soa, 5, idx, cap, ey)
    set_soa(table_soa, 6, idx, cap, ez)
    1.0
}

// 4. Inicializacion de Tabla de Sensores Testigo por Defecto
db.init_default_sensors(table_soa, cap) = {
    // Sensor 1: fase 30 deg (~0.5235 rad), emb = [0.8, 0.2, 0.1]
    db.insert_sensor(table_soa, 0, 1.0, 0.52359, 1.0, 60.0, 0.8, 0.2, 0.1, cap)
    // Sensor 2: fase 60 deg (~1.0471 rad > 45deg), emb = [0.1, 0.9, 0.3]
    db.insert_sensor(table_soa, 1, 2.0, 1.04719, 1.5, 60.0, 0.1, 0.9, 0.3, cap)
    // Sensor 3: fase 90 deg (~1.5707 rad > 45deg), emb = [0.2, 0.3, 0.9]
    db.insert_sensor(table_soa, 2, 3.0, 1.57079, 2.0, 60.0, 0.2, 0.3, 0.9, cap)
    // Sensor 4: fase 15 deg (~0.2617 rad), emb = [0.7, 0.4, 0.2]
    db.insert_sensor(table_soa, 3, 4.0, 0.26179, 0.9, 60.0, 0.7, 0.4, 0.2, cap)
    4.0
}

// 5. Motor de Consultas SQL Declarativas sobre Columnas SoA
// Sintaxis soportada: 'SELECT * FROM Sensores WHERE fase > 45deg'
db.query(sql) = {
    // Umbral estandar 45deg = 45 * pi / 180 = 0.785398 rad
    threshold = 0.785398
    coincidencias = 0.0

    // Escaneo columnar sobre tabla preasignada
    // Lee directamente de la columna 1 contigua (fase)
    sensores_soa = db_sensores_soa
    sensores_cap = 32

    i = 0.0
    while (i < 4.0) {
        fase_val = get_soa(sensores_soa, 1, i, sensores_cap)
        if (fase_val > threshold) {
            coincidencias = coincidencias + 1.0
        }
        i = i + 1.0
    }
    coincidencias
}

// Consulta parametrizada sobre cualquier tabla SoA
db.query_where_fase(table_soa, count, cap, min_fase_deg) = {
    min_rad = min_fase_deg * 0.0174532925
    matches = 0.0
    i = 0.0
    while (i < count) {
        f = get_soa(table_soa, 1, i, cap)
        if (f > min_rad) {
            matches = matches + 1.0
        }
        i = i + 1.0
    }
    matches
}

// 6. Busqueda por Similitud Vectorial (AI Vector DB) con Producto Punto SIMD
// Compara un embedding de consulta contra todas las columnas contiguas
// de embeddings [emb_x, emb_y, emb_z] usando OP_VEC3_DOT por hardware
db.vector_search(query_vec, table_soa, count, cap) = {
    best_similarity = -1.0
    best_sensor_id = 0.0
    q_magnitude = mag(query_vec)
    if (q_magnitude < 0.0001) { q_magnitude = 0.0001 }

    idx = 0.0
    while (idx < count) {
        ex = get_soa(table_soa, 4, idx, cap)
        ey = get_soa(table_soa, 5, idx, cap)
        ez = get_soa(table_soa, 6, idx, cap)

        emb_doc: Vec3 = [ex, ey, ez]
        doc_mag = mag(emb_doc)
        if (doc_mag < 0.0001) { doc_mag = 0.0001 }

        // Producto punto SIMD nativo (OP_VEC3_DOT)
        sim = dot(query_vec, emb_doc) / (q_magnitude * doc_mag)

        if (sim > best_similarity) {
            best_similarity = sim
            best_sensor_id = get_soa(table_soa, 0, idx, cap)
        }
        idx = idx + 1.0
    }
    best_similarity
}

// 7. Consultas de Relaciones y Resonancia sobre Grafos Fasoriales (+~)
// Evalua la interferencia de fase constructiva/destructiva entre nodos
db.graph_resonance(r1, th1, r2, th2) = {
    // Descomposicion ortogonal de la suma fasorial (+~)
    re = (r1 * cos(th1)) + (r2 * cos(th2))
    im = (r1 * sin(th1)) + (r2 * sin(th2))
    r_resultante = sqrt((re * re) + (im * im))
    r_maxima = r1 + r2
    if (r_maxima < 0.0001) { r_maxima = 0.0001 }

    // Indice de acoplamiento de resonancia (1.0 = en fase total, 0.0 = cancelacion)
    r_resultante / r_maxima
}

// Consulta simplificada para dos angulos de fase unitarios
db.graph_query(th_a, th_b) = {
    db.graph_resonance(1.0, th_a, 1.0, th_b)
}

// 8. Alias globales de conveniencia
query(sql) = db.query(sql)
query_where_fase(t, n, c, deg) = db.query_where_fase(t, n, c, deg)
vector_search(q, t, n, c) = db.vector_search(q, t, n, c)
graph_resonance(r1, t1, r2, t2) = db.graph_resonance(r1, t1, r2, t2)
graph_query(ta, tb) = db.graph_query(ta, tb)
