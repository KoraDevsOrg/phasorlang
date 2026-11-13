// Grado 2: Librería para crear archivo, crear carpeta, renombrar y eliminar
import "lib/fs/vfs_state.ph"

fs_nuevo_archivo() = {
    vfs_custom_visible = 1.0
    vfs_dir_ui = 1.0
    vfs_selected_id = 7.0
    editor_active_file_id = 7.0
    vfs_last_op = 3.0
    vfs_bridge_cmd = 103.0
    1.0
}

fs_nueva_carpeta() = {
    vfs_custom_dir_visible = 1.0
    vfs_last_op = 4.0
    vfs_bridge_cmd = 104.0
    1.0
}

fs_renombrar_activo(target_id) = {
    vfs_selected_id = target_id
    vfs_last_op = 6.0
    vfs_bridge_cmd = 106.0
    1.0
}

fs_eliminar_activo(target_id) = {
    if (target_id == 7.0) {
        vfs_custom_visible = 0.0
    } else { 1.0 }
    vfs_last_op = 7.0
    vfs_bridge_cmd = 107.0
    1.0
}
