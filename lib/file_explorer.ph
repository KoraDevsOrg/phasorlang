// ===============================================================================
// LIB/FILE_EXPLORER.PH — Módulo Universal y Reutilizable de Gestión de Archivos
// PhasorLang v1.0 [KoraDevs Autonomous Ecosystem]
// Árbol Jerárquico Expandible SoA (Zero-GC), Iconos Minimizados Estilo Antigravity,
// Menús Contextuales Popup de 3 Puntos (⋮), Tooltips Flotantes y Programación por Capas
// ===============================================================================

import "lib/color.ph"
import "lib/ui.ph"
import "lib/ui_popup.ph"

// -------------------------------------------------------------------------------
// 1. CONSTANTES Y ESTRUCTURAS DE MEMORIA PLANA SOA (10 CAMPOS X 128 NODOS)
// -------------------------------------------------------------------------------
MAX_EXPLORER_NODES = 128.0

struct FileItemNode {
    id: Float,          // Campo 0: ID único del nodo [0..127]
    parent_id: Float,   // Campo 1: ID de la carpeta padre (-1.0 = raíz)
    is_dir: Float,      // Campo 2: 1.0 = Carpeta, 0.0 = Archivo
    size_bytes: Float,  // Campo 3: Tamaño en bytes del archivo
    is_selected: Float, // Campo 4: 1.0 = Seleccionado actualmente
    line_count: Float,  // Campo 5: Cantidad de líneas de código
    is_expanded: Float, // Campo 6: 1.0 = Carpeta expandida, 0.0 = Colapsada
    depth: Float,       // Campo 7: Nivel de profundidad en el árbol (0, 1, 2...)
    has_children: Float,// Campo 8: 1.0 si es carpeta con nodos hijos
    icon_type: Float    // Campo 9: 1=.ph (⚡), 2=.fas (📄), 3=.toml (⚙), 4=.js (JS), 5=.md (M↓), 6=.git (⎇)
}

// Buffer Contiguo SoA en Memoria Plana
fe_tree_soa = alloc_soa(10, 128)
fe_node_count = 0.0
fe_selected_id = 0.0
fe_active_project_name = "SketchWarePro"
fe_dialog_action = 0.0 // 0=Ninguno, 1=Crear Archivo, 2=Crear Carpeta, 3=Renombrar, 4=Eliminar

// -------------------------------------------------------------------------------
// 2. INICIALIZACIÓN DEL GESTOR DE ARCHIVOS
// -------------------------------------------------------------------------------
file_explorer.init(capacity) = {
    cap = capacity
    if (cap > 128.0) { cap = 128.0 }
    
    // Reset completo de nodos SoA
    i = 0.0
    while (i < cap) {
        set_soa(fe_tree_soa, 0, i, 128, -1.0)
        set_soa(fe_tree_soa, 1, i, 128, -1.0)
        set_soa(fe_tree_soa, 2, i, 128, 0.0)
        set_soa(fe_tree_soa, 3, i, 128, 0.0)
        set_soa(fe_tree_soa, 4, i, 128, 0.0)
        set_soa(fe_tree_soa, 5, i, 128, 0.0)
        set_soa(fe_tree_soa, 6, i, 128, 1.0) // Expandido por defecto
        set_soa(fe_tree_soa, 7, i, 128, 0.0) // Profundidad raíz
        set_soa(fe_tree_soa, 8, i, 128, 0.0)
        set_soa(fe_tree_soa, 9, i, 128, 1.0)
        i = i + 1.0
    }
    
    fe_node_count = 0.0
    fe_selected_id = 0.0
    fe_hover_node_id = -1.0
    fe_scroll_y = 0.0
    ui_popup.init()
    1.0
}

// -------------------------------------------------------------------------------
// 3. OPERACIONES DEL ÁRBOL JERÁRQUICO (CRUD & TOGGLE EXPAND/COLLAPSE)
// -------------------------------------------------------------------------------

// Añadir nodo con tipo de icono específico
file_explorer.add_node_ext(parent_id, is_dir, size_bytes, lines, icon_type) = {
    if (fe_node_count >= 128.0) {
        -1.0
    } else {
        new_id = fe_node_count
        node_depth = 0.0
        if (parent_id >= 0.0) {
            if (parent_id < fe_node_count) {
                p_depth = get_soa(fe_tree_soa, 7, parent_id, 128)
                node_depth = p_depth + 1.0
                set_soa(fe_tree_soa, 8, parent_id, 128, 1.0)
            }
        }

        set_soa(fe_tree_soa, 0, new_id, 128, new_id)
        set_soa(fe_tree_soa, 1, new_id, 128, parent_id)
        set_soa(fe_tree_soa, 2, new_id, 128, is_dir)
        set_soa(fe_tree_soa, 3, new_id, 128, size_bytes)
        set_soa(fe_tree_soa, 4, new_id, 128, 0.0)
        set_soa(fe_tree_soa, 5, new_id, 128, lines)
        set_soa(fe_tree_soa, 6, new_id, 128, 1.0) // Por defecto expandido
        set_soa(fe_tree_soa, 7, new_id, 128, node_depth)
        set_soa(fe_tree_soa, 8, new_id, 128, 0.0)
        set_soa(fe_tree_soa, 9, new_id, 128, icon_type)

        fe_node_count = fe_node_count + 1.0
        new_id
    }
}

// Sobrecarga estándar para compatibilidad hacia atrás
file_explorer.add_node(parent_id, is_dir, size_bytes, lines) = {
    ic = 1.0
    if (is_dir == 1.0) {
        ic = 0.0
    }
    file_explorer.add_node_ext(parent_id, is_dir, size_bytes, lines, ic)
}

// Alternar expansión (plegar / desplegar carpeta)
file_explorer.toggle_expand(node_id) = {
    if (node_id >= 0.0) {
        if (node_id < fe_node_count) {
            is_d = get_soa(fe_tree_soa, 2, node_id, 128)
            if (is_d == 1.0) {
                cur_exp = get_soa(fe_tree_soa, 6, node_id, 128)
                new_exp = 1.0 - cur_exp
                set_soa(fe_tree_soa, 6, node_id, 128, new_exp)
                new_exp
            } else {
                0.0
            }
        } else {
            0.0
        }
    } else {
        0.0
    }
}

// Comprobar si un nodo es visible (si todos sus ancestros están expandidos)
file_explorer.is_visible(node_id) = {
    if (node_id < 0.0) {
        0.0
    } else {
        if (node_id >= fe_node_count) {
            0.0
        } else {
            is_act = get_soa(fe_tree_soa, 0, node_id, 128)
            if (is_act < 0.0) {
                0.0
            } else {
                p_id = get_soa(fe_tree_soa, 1, node_id, 128)
                vis = 1.0
                guard = 0.0
                while (p_id >= 0.0) {
                    if (guard < 16.0) {
                        guard = guard + 1.0
                        if (vis == 1.0) {
                            p_exp = get_soa(fe_tree_soa, 6, p_id, 128)
                            if (p_exp == 0.0) {
                                vis = 0.0
                            }
                            next_p = get_soa(fe_tree_soa, 1, p_id, 128)
                            if (next_p == p_id) {
                                p_id = -1.0
                            } else {
                                p_id = next_p
                            }
                        } else {
                            p_id = -1.0
                        }
                    } else {
                        p_id = -1.0
                    }
                }
                vis
            }
        }
    }
}

// Seleccionar nodo
file_explorer.select_node(node_id) = {
    if (node_id >= 0.0) {
        if (node_id < fe_node_count) {
            // Deseleccionar previos
            k = 0.0
            while (k < fe_node_count) {
                set_soa(fe_tree_soa, 4, k, 128, 0.0)
                k = k + 1.0
            }
            set_soa(fe_tree_soa, 4, node_id, 128, 1.0)
            fe_selected_id = node_id
            1.0
        } else {
            0.0
        }
    } else {
        0.0
    }
}

// Eliminar nodo
file_explorer.delete_node(node_id) = {
    if (node_id >= 0.0) {
        if (node_id < fe_node_count) {
            set_soa(fe_tree_soa, 0, node_id, 128, -1.0)
            set_soa(fe_tree_soa, 4, node_id, 128, 0.0)
            if (fe_selected_id == node_id) {
                fe_selected_id = 0.0
            }
            1.0
        } else {
            0.0
        }
    } else {
        0.0
    }
}

// Apertura del Menú Contextual Popup de 3 Puntos (⋮)
file_explorer.open_node_menu(node_id, btn_x, btn_y) = {
    if (node_id >= 0.0) {
        if (node_id < fe_node_count) {
            file_explorer.select_node(node_id)
            ui_popup.open(btn_x - 140.0, btn_y + 18.0, 160.0, node_id)
            is_d = file_explorer.is_dir(node_id)

            if (is_d == 1.0) {
                // Acciones para Directorio
                ui_popup.add_item(6.0, 0x3FB950) // ➕ Nuevo Archivo
                ui_popup.add_item(7.0, 0x79C0FF) // 📁 Nueva Carpeta
                ui_popup.add_item(3.0, 0x8B949E) // 📋 Copiar Ruta
                ui_popup.add_item(4.0, 0xD29922) // ✏ Renombrar
                ui_popup.add_item(5.0, 0xF85149) // 🗑 Eliminar
            } else {
                // Acciones para Archivo
                ui_popup.add_item(1.0, 0x58A6FF) // ⚡ Abrir en Editor
                ui_popup.add_item(2.0, 0x3FB950) // 📥 Copiar import "..."
                ui_popup.add_item(3.0, 0x8B949E) // 📋 Copiar Ruta
                ui_popup.add_item(4.0, 0xD29922) // ✏ Renombrar
                ui_popup.add_item(5.0, 0xF85149) // 🗑 Eliminar
            }
            1.0
        } else {
            0.0
        }
    } else {
        0.0
    }
}

// Getters de inspección
file_explorer.get_selected_id() = { fe_selected_id }
file_explorer.get_node_count()   = { fe_node_count }
file_explorer.is_dir(node_id)    = { get_soa(fe_tree_soa, 2, node_id, 128) }
file_explorer.get_size(node_id)   = { get_soa(fe_tree_soa, 3, node_id, 128) }
file_explorer.get_lines(node_id)  = { get_soa(fe_tree_soa, 5, node_id, 128) }
file_explorer.is_expanded(node_id)= { get_soa(fe_tree_soa, 6, node_id, 128) }
file_explorer.get_depth(node_id)  = { get_soa(fe_tree_soa, 7, node_id, 128) }
file_explorer.has_children(n_id)  = { get_soa(fe_tree_soa, 8, n_id, 128) }
file_explorer.get_icon(node_id)   = { get_soa(fe_tree_soa, 9, node_id, 128) }

// -------------------------------------------------------------------------------
// 4. ACCIONES DE BARRA SUPERIOR (FUNCIONES ESTÁNDAR ZERO-GC)
// -------------------------------------------------------------------------------
file_explorer.act_new_file()   = { fe_dialog_action = 1.0; 1.0 }
file_explorer.act_new_folder() = { fe_dialog_action = 2.0; 1.0 }
file_explorer.act_rename()     = { fe_dialog_action = 3.0; 1.0 }
file_explorer.act_delete()     = { file_explorer.delete_node(fe_selected_id); 1.0 }
file_explorer.act_open_dir()   = { fe_dialog_action = 0.0; 1.0 }

// -------------------------------------------------------------------------------
// 5. RENDERIZADO VISUAL RESPONSIVE DEL EXPLORADOR EN ÁRBOL
// -------------------------------------------------------------------------------
file_explorer.render(vx, vy, vw, vh) = {
    // Fondo principal del explorador
    rect(vx, vy, vw, vh, 0x0D1117)

    // 1. Barra de Herramientas Superior (40px)
    rect(vx, vy, vw, 40.0, 0x161B22)
    line(vx, vy + 40.0, vx + vw, vy + 40.0, 0x30363D)

    is_mob = vw < 600.0

    if (is_mob == 1.0) {
        // Disposición móvil ergonómica
        bw = vw * 0.2
        rect(vx, vy + 4.0, bw - 2.0, 32.0, 0x1F6FEB)
        text("📂", vx + 8.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + bw, vy + 4.0, bw - 2.0, 32.0, 0x238636)
        text("+📄", vx + bw + 8.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + (bw * 2.0), vy + 4.0, bw - 2.0, 32.0, 0x79C0FF)
        text("+📁", vx + (bw * 2.0) + 8.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + (bw * 3.0), vy + 4.0, bw - 2.0, 32.0, 0xD29922)
        text("✏", vx + (bw * 3.0) + 8.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + (bw * 4.0), vy + 4.0, bw - 2.0, 32.0, 0xF85149)
        text("🗑", vx + (bw * 4.0) + 8.0, vy + 12.0, 10, 0xFFFFFF)
    } else {
        // Disposición escritorio con nombres claros
        rect(vx + 8.0, vy + 4.0, 126.0, 32.0, 0x1F6FEB)
        text("📂 Abrir Carpeta", vx + 16.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + 140.0, vy + 4.0, 126.0, 32.0, 0x238636)
        text("+ Nuevo Archivo", vx + 148.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + 272.0, vy + 4.0, 126.0, 32.0, 0x30363D)
        text("+ Nueva Carpeta", vx + 280.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + 404.0, vy + 4.0, 105.0, 32.0, 0xD29922)
        text("✏ Renombrar", vx + 412.0, vy + 12.0, 10, 0xFFFFFF)
        rect(vx + 515.0, vy + 4.0, 95.0, 32.0, 0xF85149)
        text("🗑 Eliminar", vx + 523.0, vy + 12.0, 10, 0xFFFFFF)
    }

    // 2. Área de Trabajo: Split View (Árbol a la izquierda, Inspector a la derecha en escritorio)
    area_y = vy + 40.0
    area_h = vh - 40.0 - 24.0

    tree_w = vw
    if (vw >= 768.0) {
        tree_w = vw * 0.52
        line(vx + tree_w, area_y, vx + tree_w, area_y + area_h, 0x30363D)

        // Panel derecho: Inspector de Nodo y Programación por Capas
        insp_x = vx + tree_w
        insp_w = vw - tree_w
        rect(insp_x, area_y, insp_w, area_h, 0x090D13)

        rect(insp_x + 12.0, area_y + 12.0, insp_w - 24.0, 30.0, 0x161B22)
        text("INSPECTOR DE ARCHIVO & CAPAS (IMPORT)", insp_x + 20.0, area_y + 22.0, 10, 0x58A6FF)

        sel_id = fe_selected_id
        is_d = file_explorer.is_dir(sel_id)
        sz = file_explorer.get_size(sel_id)
        lns = file_explorer.get_lines(sel_id)

        text("Nodo ID Activo   : #" + sel_id, insp_x + 20.0, area_y + 60.0, 10, 0xFFFFFF)
        if (is_d == 1.0) {
            text("Tipo de Elemento : 📁 Directorio / Paquete Modular", insp_x + 20.0, area_y + 82.0, 10, 0x79C0FF)
            if (file_explorer.is_expanded(sel_id) == 1.0) {
                text("Estado en Árbol  : Expandido (v)", insp_x + 20.0, area_y + 104.0, 10, 0x8B949E)
            } else {
                text("Estado en Árbol  : Colapsado (>)", insp_x + 20.0, area_y + 104.0, 10, 0x8B949E)
            }
        } else {
            text("Tipo de Elemento : ⚡ Archivo PhasorLang (.ph / .fas)", insp_x + 20.0, area_y + 82.0, 10, 0x3FB950)
            text("Tamaño en Memoria: " + sz + " Bytes", insp_x + 20.0, area_y + 104.0, 10, 0x8B949E)
            text("Líneas de Código : " + lns + " líneas", insp_x + 20.0, area_y + 126.0, 10, 0x8B949E)
            
            // Tarjeta de sintaxis para import
            rect(insp_x + 16.0, area_y + 155.0, insp_w - 32.0, 75.0, 0x161B22)
            rect(insp_x + 16.0, area_y + 155.0, 4.0, 75.0, 0x3FB950)
            text("DIRECTIVA DE IMPORTACIÓN MODULAR:", insp_x + 26.0, area_y + 170.0, 10, 0xD29922)
            text("Para usar este módulo en otros archivos, añade:", insp_x + 26.0, area_y + 190.0, 9, 0x8B949E)
            text("import \"lib/archivo.ph\"", insp_x + 26.0, area_y + 208.0, 10, 0x58A6FF)
        }
    }

    // 3. Panel Izquierdo: Árbol Jerárquico de Archivos
    rect(vx, area_y, tree_w, area_h, 0x0D1117)

    // Cabecera del Proyecto raíz estilo Antigravity
    rect(vx, area_y, tree_w, 26.0, 0x161B22)
    line(vx, area_y + 26.0, vx + tree_w, area_y + 26.0, 0x30363D)
    text("EXPLORER", vx + 12.0, area_y + 7.0, 10, 0x8B949E)
    text("v 📁 " + fe_active_project_name, vx + 12.0, area_y + 36.0, 10, 0x58A6FF)

    // 4. Renderizado Jerárquico de Nodos (Expandibles con Guías de Indentación)
    row_h = 24.0
    cur_y = area_y + 56.0

    // Si no se han añadido nodos SoA, poblar con el catálogo representativo
    if (fe_node_count == 0.0) {
        // Nodos Raíz
        d_res = file_explorer.add_node_ext(-1.0, 1.0, 0.0, 0.0, 0.0)    // 0: resources
        d_rt  = file_explorer.add_node_ext(-1.0, 1.0, 0.0, 0.0, 0.0)    // 1: runtime
        d_smp = file_explorer.add_node_ext(-1.0, 1.0, 0.0, 0.0, 0.0)    // 2: samples
        d_src = file_explorer.add_node_ext(-1.0, 1.0, 0.0, 0.0, 0.0)    // 3: lib
        f_gt  = file_explorer.add_node_ext(-1.0, 0.0, 693.0, 24.0, 6.0) // 4: .gitignore
        f_gm  = file_explorer.add_node_ext(-1.0, 0.0, 7161.0, 180.0, 5.0)// 5: GEMINI.md
        f_mf  = file_explorer.add_node_ext(-1.0, 0.0, 540.0, 32.0, 2.0)  // 6: main.fas
        f_pr  = file_explorer.add_node_ext(-1.0, 0.0, 148689.0, 3563.0, 4.0)// 7: phasor_runtime.js
        f_tm  = file_explorer.add_node_ext(-1.0, 0.0, 992.0, 45.0, 3.0) // 8: phasor.toml

        // Hijos dentro de lib/ (d_src = 3)
        file_explorer.add_node_ext(d_src, 0.0, 8892.0, 247.0, 1.0) // file_explorer.ph
        file_explorer.add_node_ext(d_src, 0.0, 28391.0, 861.0, 1.0) // ui.ph
        file_explorer.add_node_ext(d_src, 0.0, 4200.0, 130.0, 1.0) // ui_popup.ph
    }

    // Iteración de dibujo de los nodos del árbol
    n_idx = 0.0
    while (n_idx < fe_node_count) {
        if (cur_y < (area_y + area_h - 10.0)) {
            is_vis = file_explorer.is_visible(n_idx)
            if (is_vis == 1.0) {
                dp = file_explorer.get_depth(n_idx)
                is_d = file_explorer.is_dir(n_idx)
                is_sel = (n_idx == fe_selected_id)
                node_x = vx + 16.0 + (dp * 14.0)

                // Fila activa resaltada
                if (is_sel == 1.0) {
                    rect(vx + 4.0, cur_y - 2.0, tree_w - 8.0, row_h, 0x1F2937)
                }

                // Guía vertical de nivel
                if (dp > 0.0) {
                    line(node_x - 8.0, cur_y - 2.0, node_x - 8.0, cur_y + row_h - 2.0, 0x21262D)
                }

                // Chevron y Mini-Icono
                if (is_d == 1.0) {
                    is_exp = file_explorer.is_expanded(n_idx)
                    if (is_exp == 1.0) {
                        text("v", node_x, cur_y + 3.0, 9, 0x8B949E)
                    } else {
                        text(">", node_x, cur_y + 3.0, 9, 0x8B949E)
                    }
                    text("📁", node_x + 12.0, cur_y + 3.0, 9, 0x79C0FF)
                } else {
                    ic_t = file_explorer.get_icon(n_idx)
                    ic_str = "📄"
                    ic_col = 0x58A6FF
                    if (ic_t == 1.0) { ic_str = "⚡"; ic_col = 0x3FB950 } // PhasorLang
                    if (ic_t == 2.0) { ic_str = "📄"; ic_col = 0x58A6FF } // Bytecode .fas
                    if (ic_t == 3.0) { ic_str = "⚙"; ic_col = 0xD29922 } // Config .toml
                    if (ic_t == 4.0) { ic_str = "JS"; ic_col = 0xE5C07B } // JavaScript
                    if (ic_t == 5.0) { ic_str = "M↓"; ic_col = 0x58A6FF } // Markdown
                    if (ic_t == 6.0) { ic_str = "⎇"; ic_col = 0xF85149 } // Git
                    text(ic_str, node_x + 10.0, cur_y + 3.0, 9, ic_col)
                }

                // Etiqueta del Nodo
                txt_x = node_x + 26.0
                lbl_col = 0xC9D1D9
                if (is_sel == 1.0) {
                    lbl_col = 0xFFFFFF
                }
                if (n_idx == 0.0) { text("resources/", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 1.0) { text("runtime/", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 2.0) { text("samples/", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 3.0) { text("lib/", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 4.0) { text(".gitignore", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 5.0) { text("GEMINI.md", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 6.0) { text("main.fas", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 7.0) { text("phasor_runtime.js", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 8.0) { text("phasor.toml", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 9.0) { text("file_explorer.ph", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 10.0) { text("ui.ph", txt_x, cur_y + 3.0, 10, lbl_col) }
                if (n_idx == 11.0) { text("ui_popup.ph", txt_x, cur_y + 3.0, 10, lbl_col) }

                // Botón de 3 Puntos (⋮) al frente de cada archivo / directorio
                btn_dots_x = vx + tree_w - 24.0
                rect(btn_dots_x - 2.0, cur_y, 18.0, 16.0, 0x161B22)
                text("⋮", btn_dots_x + 4.0, cur_y + 2.0, 10, 0x8B949E)

                cur_y = cur_y + row_h
            }
        }
        n_idx = n_idx + 1.0
    }

    // 5. Barra de Estado Inferior
    rect(vx, vy + vh - 24.0, vw, 24.0, 0x161B22)
    line(vx, vy + vh - 24.0, vx + vw, vy + vh - 24.0, 0x30363D)
    text("Árbol Jerárquico Expandible | Menú Contextual (⋮) | Tooltip Activo | Zero-GC", vx + 10.0, vy + vh - 17.0, 9.5, 0x8B949E)

    // 6. Renderizado de Menú Popup Flotante (Z-Index Superior)
    ui_popup.render(vw, vh, R252, R253)

    // 7. Renderizado de Tooltip si está activo
    if (ui_tooltip.is_visible() == 1.0) {
        ui_tooltip.render(vw, vh, "Archivo: " + fe_selected_id, "Presiona (⋮) para acciones rápidas")
    }
    1.0
}


