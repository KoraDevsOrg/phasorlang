MAX_AST_NODES = 1024
flat_ast = alloc_soa(4, MAX_AST_NODES)
MAX_INSTRUCTIONS = 1024
bytecode_stream = alloc_soa(4, MAX_INSTRUCTIONS)
pc_ptr = 0.0
ast_node_count = 0.0

emit_instruction(stream, op, r_dest, r_src1, r_src2) = {
    set_soa(stream, 0, pc_ptr, MAX_INSTRUCTIONS, op)
    set_soa(stream, 1, pc_ptr, MAX_INSTRUCTIONS, r_dest)
    set_soa(stream, 2, pc_ptr, MAX_INSTRUCTIONS, r_src1)
    set_soa(stream, 3, pc_ptr, MAX_INSTRUCTIONS, r_src2)
    pc_ptr = pc_ptr + 1.0
    pc_ptr
}

compile_ast_to_bytecode(ast_buf, stream) = {
    ast_idx = 0.0
    while (ast_idx < ast_node_count) {
        node_op    = get_soa(ast_buf, 0, ast_idx, MAX_AST_NODES)
        node_left  = get_soa(ast_buf, 1, ast_idx, MAX_AST_NODES)
        node_right = get_soa(ast_buf, 2, ast_idx, MAX_AST_NODES)
        node_meta  = get_soa(ast_buf, 3, ast_idx, MAX_AST_NODES)

        out("Loop idx:", ast_idx, "node_op:", node_op)

        if (node_op == 96.0) {
            emit_instruction(stream, 96.0, node_left, node_right, node_meta)
        }
        if (node_op == 97.0) {
            emit_instruction(stream, 97.0, node_left, node_right, node_meta)
        }
        ast_idx = ast_idx + 1.0
    }
    emit_instruction(stream, 255.0, 0.0, 0.0, 0.0)
    pc_ptr
}

set_soa(flat_ast, 0, 0, MAX_AST_NODES, 96.0)
set_soa(flat_ast, 1, 0, MAX_AST_NODES, 1.0)
set_soa(flat_ast, 2, 0, MAX_AST_NODES, 10.0)
set_soa(flat_ast, 3, 0, MAX_AST_NODES, 20.0)

set_soa(flat_ast, 0, 1, MAX_AST_NODES, 97.0)
set_soa(flat_ast, 1, 1, MAX_AST_NODES, 3.0)
set_soa(flat_ast, 2, 1, MAX_AST_NODES, 1.0)
set_soa(flat_ast, 3, 1, MAX_AST_NODES, 2.0)

ast_node_count = 2.0

res = compile_ast_to_bytecode(flat_ast, bytecode_stream)
out("compile_ast returned:", res)

ins0_op = get_soa(bytecode_stream, 0, 0, MAX_INSTRUCTIONS)
ins1_op = get_soa(bytecode_stream, 0, 1, MAX_INSTRUCTIONS)
ins2_op = get_soa(bytecode_stream, 0, 2, MAX_INSTRUCTIONS)

out("ins0_op:", ins0_op)
out("ins1_op:", ins1_op)
out("ins2_op:", ins2_op)
