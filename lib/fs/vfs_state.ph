// Grado 1: Estado plano en memoria SoA para el Explorador y puente con Editor S1
signal vfs_dir_core = 1.0
signal vfs_dir_ui = 1.0
signal vfs_dir_screens = 1.0
signal vfs_selected_id = 1.0
signal vfs_active_count = 6.0
signal vfs_custom_visible = 0.0
signal vfs_custom_dir_visible = 0.0
signal vfs_last_op = 0.0
signal vfs_bridge_cmd = 0.0

// Señal compartida que leerá Screen 1 (Editor) sin acoplamiento
signal editor_active_file_id = 1.0
