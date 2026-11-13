// Grado 2: Librería para abrir archivo local o carpeta de proyecto real
import "lib/fs/vfs_state.ph"

fs_abrir_archivo() = {
    vfs_last_op = 1.0
    vfs_bridge_cmd = 101.0
    1.0
}

fs_abrir_proyecto() = {
    vfs_last_op = 2.0
    vfs_bridge_cmd = 102.0
    1.0
}
