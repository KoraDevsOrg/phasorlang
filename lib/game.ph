// ===============================================================
// LIB/GAME.PH — Motor Grafico 2D/3D Ligero, Camara y Fisicas SoA Zero-GC
// PhasorLang v1.0 [Fase 11 Multi-Dominio — Chronos IDE]
// Sprite Batching Contiguo, Proyecciones Isometricas/Perspectiva,
// Deteccion AABB/Circulo y Bucle de Alta Tasa de Refresco (120 FPS)
// ===============================================================

// 1. Estructura SoA para Sprite Batching Vectorial
// 8 campos contiguos por sprite para streaming sin pausas de GC
struct SpriteBatchSoA {
    x: Float,     // Campo 0: Posicion horizontal en el mundo
    y: Float,     // Campo 1: Posicion vertical en el mundo
    z: Float,     // Campo 2: Profundidad / Capa de ordenamiento
    w: Float,     // Campo 3: Ancho del sprite
    h: Float,     // Campo 4: Alto del sprite
    u: Float,     // Campo 5: Coordenada de textura / Tile X
    v: Float,     // Campo 6: Coordenada de textura / Tile Y
    color: Float  // Campo 7: Color empaquetado en Hex (0xRRGGBB)
}

// 2. Estructura SoA para Cuerpos Rigidos y Particulas de Colision
struct RigidBodySoA {
    x: Float,      // Campo 0: Coordenada X
    y: Float,      // Campo 1: Coordenada Y
    vx: Float,     // Campo 2: Velocidad lineal X
    vy: Float,     // Campo 3: Velocidad lineal Y
    ax: Float,     // Campo 4: Aceleracion X
    ay: Float,     // Campo 5: Aceleracion Y (gravedad/fuerzas)
    radius: Float, // Campo 6: Radio de colision / Bounding circle
    flags: Float   // Campo 7: Flags (1=activo, 2=estatico, 4=colisionado)
}

// 3. Estructura SoA para Camara 2D/3D y Viewport
struct Camera2DSoA {
    x: Float,          // Campo 0: Posicion focal X
    y: Float,          // Campo 1: Posicion focal Y
    zoom: Float,       // Campo 2: Factor de ampliacion (1.0 = normal)
    rot: Float,        // Campo 3: Angulo de rotacion (radianes)
    target_x: Float,   // Campo 4: Objetivo X de interpolacion suave
    target_y: Float,   // Campo 5: Objetivo Y de interpolacion suave
    lerp_speed: Float, // Campo 6: Coeficiente de suavizado (0.05 a 0.2)
    aspect: Float      // Campo 7: Relacion de aspecto de pantalla
}

// ===============================================================
// 4. Gestion de Memoria Contigua Plana (Zero-GC) para Sprites
// ===============================================================

// Reserva memoria para Sprite Batching (8 campos contiguos)
game.alloc_sprites(capacity) = {
    alloc_soa(8, capacity)
}

// Inserta o actualiza un sprite individual en la tabla SoA
game.push_sprite(batch_soa, idx, x, y, z, w, h, u, v, color_val, cap) = {
    set_soa(batch_soa, 0, idx, cap, x)
    set_soa(batch_soa, 1, idx, cap, y)
    set_soa(batch_soa, 2, idx, cap, z)
    set_soa(batch_soa, 3, idx, cap, w)
    set_soa(batch_soa, 4, idx, cap, h)
    set_soa(batch_soa, 5, idx, cap, u)
    set_soa(batch_soa, 6, idx, cap, v)
    set_soa(batch_soa, 7, idx, cap, color_val)
    1.0
}

// Renderiza el lote de sprites con transformacion de camara y culling 2D
game.render_batch(batch_soa, count, cap, cam_x, cam_y, cam_zoom, view_w, view_h) = {
    rendered = 0.0
    half_vw = view_w * 0.5
    half_vh = view_h * 0.5
    i = 0.0

    while (i < count) {
        wx = get_soa(batch_soa, 0, i, cap)
        wy = get_soa(batch_soa, 1, i, cap)
        sw = get_soa(batch_soa, 3, i, cap) * cam_zoom
        sh = get_soa(batch_soa, 4, i, cap) * cam_zoom
        color_val = get_soa(batch_soa, 7, i, cap)

        // Proyeccion de Coordenadas de Mundo a Pantalla
        sx = ((wx - cam_x) * cam_zoom) + half_vw
        sy = ((wy - cam_y) * cam_zoom) + half_vh

        // Frustum Culling 2D: Solo dibujar si esta dentro del viewport visible
        if (sx + sw >= 0.0) {
            if (sx <= view_w) {
                if (sy + sh >= 0.0) {
                    if (sy <= view_h) {
                        rect(sx, sy, sw, sh, color_val)
                        rendered = rendered + 1.0
                    }
                }
            }
        }
        i = i + 1.0
    }
    rendered
}

// ===============================================================
// 5. Motor de Camara 2D/3D y Proyecciones de Perspectiva
// ===============================================================

// Reserva e inicializacion del buffer de camara
game.alloc_camera() = {
    alloc_soa(8, 4)
}

game.camera_init(cam_soa, init_x, init_y, init_zoom) = {
    set_soa(cam_soa, 0, 0, 4, init_x)
    set_soa(cam_soa, 1, 0, 4, init_y)
    set_soa(cam_soa, 2, 0, 4, init_zoom)
    set_soa(cam_soa, 3, 0, 4, 0.0)
    set_soa(cam_soa, 4, 0, 4, init_x)
    set_soa(cam_soa, 5, 0, 4, init_y)
    set_soa(cam_soa, 6, 0, 4, 0.12)
    set_soa(cam_soa, 7, 0, 4, 1.7777)
    1.0
}

// Actualizacion continua de la camara con interpolacion Lerp suave hacia el objetivo
game.camera_update(cam_soa, dt) = {
    cx = get_soa(cam_soa, 0, 0, 4)
    cy = get_soa(cam_soa, 1, 0, 4)
    tx = get_soa(cam_soa, 4, 0, 4)
    ty = get_soa(cam_soa, 5, 0, 4)
    speed = get_soa(cam_soa, 6, 0, 4)

    factor = speed * (dt * 60.0)
    if (factor > 1.0) { factor = 1.0 }

    nx = cx + ((tx - cx) * factor)
    ny = cy + ((ty - cy) * factor)

    set_soa(cam_soa, 0, 0, 4, nx)
    set_soa(cam_soa, 1, 0, 4, ny)
    nx
}

// Establece el objetivo de seguimiento de la camara
game.camera_set_target(cam_soa, tx, ty) = {
    set_soa(cam_soa, 4, 0, 4, tx)
    set_soa(cam_soa, 5, 0, 4, ty)
    1.0
}

// Transformaciones de Coordenadas
game.world_to_screen_x(wx, cx, zoom, screen_w) = {
    ((wx - cx) * zoom) + (screen_w * 0.5)
}

game.world_to_screen_y(wy, cy, zoom, screen_h) = {
    ((wy - cy) * zoom) + (screen_h * 0.5)
}

game.screen_to_world_x(sx, cx, zoom, screen_w) = {
    ((sx - (screen_w * 0.5)) / zoom) + cx
}

game.screen_to_world_y(sy, cy, zoom, screen_h) = {
    ((sy - (screen_h * 0.5)) / zoom) + cy
}

// Proyeccion Isometrica 3D Vectorial
// Transforma coordenadas espaciales (x, y, z) al plano de pantalla 2D
game.project_iso_x(x, y, z) = {
    (x - y) * 0.866025
}

game.project_iso_y(x, y, z) = {
    ((x + y) * 0.5) - z
}

// Proyeccion de Perspectiva 3D con Focal FOV
game.project_persp_x(x, y, z, fov) = {
    denom = z + fov
    if (denom < 0.001) { denom = 0.001 }
    (x * fov) / denom
}

game.project_persp_y(x, y, z, fov) = {
    denom = z + fov
    if (denom < 0.001) { denom = 0.001 }
    (y * fov) / denom
}

// ===============================================================
// 6. Motor de Fisicas de Colision Contiguas SoA (Zero-GC)
// ===============================================================

// Reserva memoria para Cuerpos Rigidos (8 campos contiguos)
game.alloc_bodies(capacity) = {
    alloc_soa(8, capacity)
}

// Instancia un cuerpo rigido en la tabla SoA
game.spawn_body(bodies_soa, idx, x, y, vx, vy, radius, flags, cap) = {
    set_soa(bodies_soa, 0, idx, cap, x)
    set_soa(bodies_soa, 1, idx, cap, y)
    set_soa(bodies_soa, 2, idx, cap, vx)
    set_soa(bodies_soa, 3, idx, cap, vy)
    set_soa(bodies_soa, 4, idx, cap, 0.0)
    set_soa(bodies_soa, 5, idx, cap, 0.0)
    set_soa(bodies_soa, 6, idx, cap, radius)
    set_soa(bodies_soa, 7, idx, cap, flags)
    1.0
}

// Integrador de Fisicas Euler Semiexplicito en Memoria Contigua
game.integrate_physics(bodies_soa, count, cap, dt, grav_y, drag) = {
    i = 0.0
    while (i < count) {
        flags = get_soa(bodies_soa, 7, i, cap)
        // Solo integrar entidades activas y no estaticas (flags == 1)
        if (flags == 1.0) {
            vx = get_soa(bodies_soa, 2, i, cap)
            vy = get_soa(bodies_soa, 3, i, cap)
            x  = get_soa(bodies_soa, 0, i, cap)
            y  = get_soa(bodies_soa, 1, i, cap)

            // Actualizacion de velocidad con gravedad y amortiguamiento aerodinamico
            nvy = (vy + (grav_y * dt)) * drag
            nvx = vx * drag

            // Actualizacion de posicion contigua
            nx = x + (nvx * dt)
            ny = y + (nvy * dt)

            set_soa(bodies_soa, 2, i, cap, nvx)
            set_soa(bodies_soa, 3, i, cap, nvy)
            set_soa(bodies_soa, 0, i, cap, nx)
            set_soa(bodies_soa, 1, i, cap, ny)
        }
        i = i + 1.0
    }
    count
}

// Resolucion de Limites de Pantalla y Rebote Elastico
game.resolve_boundary(bodies_soa, count, cap, min_x, max_x, min_y, max_y, bounce) = {
    bounces = 0.0
    i = 0.0
    while (i < count) {
        x = get_soa(bodies_soa, 0, i, cap)
        y = get_soa(bodies_soa, 1, i, cap)
        vx = get_soa(bodies_soa, 2, i, cap)
        vy = get_soa(bodies_soa, 3, i, cap)
        rad = get_soa(bodies_soa, 6, i, cap)

        // Rebote en pared izquierda
        if (x - rad < min_x) {
            set_soa(bodies_soa, 0, i, cap, min_x + rad)
            set_soa(bodies_soa, 2, i, cap, -vx * bounce)
            bounces = bounces + 1.0
        }
        // Rebote en pared derecha
        if (x + rad > max_x) {
            set_soa(bodies_soa, 0, i, cap, max_x - rad)
            set_soa(bodies_soa, 2, i, cap, -vx * bounce)
            bounces = bounces + 1.0
        }
        // Rebote en techo
        if (y - rad < min_y) {
            set_soa(bodies_soa, 1, i, cap, min_y + rad)
            set_soa(bodies_soa, 3, i, cap, -vy * bounce)
            bounces = bounces + 1.0
        }
        // Rebote en suelo
        if (y + rad > max_y) {
            set_soa(bodies_soa, 1, i, cap, max_y - rad)
            set_soa(bodies_soa, 3, i, cap, -vy * bounce)
            bounces = bounces + 1.0
        }

        i = i + 1.0
    }
    bounces
}

// Algoritmo de Deteccion de Colision AABB (Axis-Aligned Bounding Box)
game.check_aabb(x1, y1, w1, h1, x2, y2, w2, h2) = {
    hit = 1.0
    if (x1 + w1 < x2) { hit = 0.0 }
    if (x1 > x2 + w2) { hit = 0.0 }
    if (y1 + h1 < y2) { hit = 0.0 }
    if (y1 > y2 + h2) { hit = 0.0 }
    hit
}

// Algoritmo de Deteccion de Colision entre Circulos / Esferas 2D
game.check_circle_collision(x1, y1, r1, x2, y2, r2) = {
    dx = x2 - x1
    dy = y2 - y1
    dist_sq = (dx * dx) + (dy * dy)
    rad_sum = r1 + r2
    rad_sq = rad_sum * rad_sum

    if (dist_sq <= rad_sq) {
        1.0
    } else {
        0.0
    }
}

// Renderizado directo de cuerpos de fisica como circulos vectoriales
game.render_bodies(bodies_soa, count, cap, cam_x, cam_y, cam_zoom, view_w, view_h, color) = {
    half_w = view_w * 0.5
    half_h = view_h * 0.5
    i = 0.0
    while (i < count) {
        bx = get_soa(bodies_soa, 0, i, cap)
        by = get_soa(bodies_soa, 1, i, cap)
        rad = get_soa(bodies_soa, 6, i, cap) * cam_zoom

        sx = ((bx - cam_x) * cam_zoom) + half_w
        sy = ((by - cam_y) * cam_zoom) + half_h

        if (sx + rad >= 0.0) {
            if (sx - rad <= view_w) {
                if (sy + rad >= 0.0) {
                    if (sy - rad <= view_h) {
                        circle(sx, sy, rad, color)
                    }
                }
            }
        }
        i = i + 1.0
    }
    count
}

// ===============================================================
// 7. Bucle de Juego de Alta Tasa de Refresco (90+ / 120 FPS)
// ===============================================================

// Delta time para 120 FPS fijos: 1.0 / 120.0 = 0.008333 segundos
game.dt_120fps() = {
    0.00833333
}

// Delta time para 90 FPS fijos: 1.0 / 90.0 = 0.011111 segundos
game.dt_90fps() = {
    0.01111111
}

// Acota el paso de tiempo para prevenir caidas de tunneling por stutter
game.clamp_dt(dt) = {
    res = dt
    if (res > 0.0333) { res = 0.0333 }
    if (res < 0.001)  { res = 0.001 }
    res
}

// ===============================================================
// 8. Alias Globales de Conveniencia
// ===============================================================
alloc_sprites(cap) = game.alloc_sprites(cap)
push_sprite(b, i, x, y, z, w, h, u, v, c, cap) = game.push_sprite(b, i, x, y, z, w, h, u, v, c, cap)
render_batch(b, n, cap, cx, cy, cz, vw, vh) = game.render_batch(b, n, cap, cx, cy, cz, vw, vh)

alloc_camera() = game.alloc_camera()
camera_init(c, x, y, z) = game.camera_init(c, x, y, z)
camera_update(c, dt) = game.camera_update(c, dt)
camera_set_target(c, tx, ty) = game.camera_set_target(c, tx, ty)

project_iso_x(x, y, z) = game.project_iso_x(x, y, z)
project_iso_y(x, y, z) = game.project_iso_y(x, y, z)
project_persp_x(x, y, z, fov) = game.project_persp_x(x, y, z, fov)
project_persp_y(x, y, z, fov) = game.project_persp_y(x, y, z, fov)

alloc_bodies(cap) = game.alloc_bodies(cap)
spawn_body(b, i, x, y, vx, vy, r, f, cap) = game.spawn_body(b, i, x, y, vx, vy, r, f, cap)
integrate_physics(b, n, cap, dt, gy, drag) = game.integrate_physics(b, n, cap, dt, gy, drag)
resolve_boundary(b, n, cap, minx, maxx, miny, maxy, bounce) = game.resolve_boundary(b, n, cap, minx, maxx, miny, maxy, bounce)
check_aabb(x1, y1, w1, h1, x2, y2, w2, h2) = game.check_aabb(x1, y1, w1, h1, x2, y2, w2, h2)
check_circle_collision(x1, y1, r1, x2, y2, r2) = game.check_circle_collision(x1, y1, r1, x2, y2, r2)
render_bodies(b, n, cap, cx, cy, cz, vw, vh, color_val) = game.render_bodies(b, n, cap, cx, cy, cz, vw, vh, color_val)

dt_120fps() = game.dt_120fps()
clamp_dt(dt) = game.clamp_dt(dt)
