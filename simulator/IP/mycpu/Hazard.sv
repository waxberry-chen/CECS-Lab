`include "./include/config.sv"
module Hazard(
    // forwarding 
    input  logic [ 4:0] rf_rd_ls,
    input  logic [ 4:0] rf_rd_wb,
    input  logic [ 0:0] rf_we_ls,
    input  logic [ 0:0] rf_we_wb,
    input  logic [ 4:0] rf_rs1_ex,
    input  logic [ 4:0] rf_rs2_ex,
    input  logic [31:0] rf_wdata_tmp_ls,
    input  logic [31:0] rf_wdata_wb,

    output logic [ 0:0] forward1_en,
    output logic [ 0:0] forward2_en,
    output logic [31:0] forward1_data,
    output logic [31:0] forward2_data,

    // load-use
    input  logic [ 4:0] mem_access_ex,
    input  logic [ 4:0] rf_rd_ex,
    input  logic [ 4:0] rf_rs1_id,
    input  logic [ 4:0] rf_rs2_id,

    // privilege commands
    input  logic [ 0:0] is_priv_ex,
    input  logic [31:0] pc_ex,

    // control hazard
    input  logic [ 0:0] jump,
    input  logic [31:0] jump_target,

    input  logic [ 0:0] exp_ecall_ex ,         // exp
    input  logic [ 0:0] exp_en_wb    ,         // exp
    input  logic [ 0:0] exp_mret_ex  ,
    input  logic [31:0] mtvec_global ,         // addr jump ecall
    input  logic [31:0] mepc_global  ,
    // Lab4 TODO: you may need to add some signals to cope with CSR, ecall and mret

    output logic [ 0:0] pc_set,
    output logic [ 0:0] IF1_IF2_flush,
    output logic [ 0:0] IF2_ID_flush,
    output logic [ 0:0] ID_EX_flush,
    output logic [ 0:0] EX_LS_flush,
    output logic [ 0:0] LS_WB_flush,

    output logic [ 0:0] pc_stall,
    output logic [ 0:0] IF1_IF2_stall,
    output logic [ 0:0] IF2_ID_stall,
    output logic [ 0:0] ID_EX_stall,
    output logic [ 0:0] EX_LS_stall,
    output logic [ 0:0] LS_WB_stall,

    output logic [31:0] pc_set_target
);
    // forwarding
    always_comb begin
        forward1_en = 0;
        forward2_en = 0;
        forward1_data = 0;
        forward2_data = 0;
        if (rf_we_ls && rf_rd_ls == rf_rs1_ex) begin
            forward1_en = 1'b1;
            forward1_data = rf_wdata_tmp_ls;
        end
        else if (rf_we_wb && rf_rd_wb == rf_rs1_ex) begin
            forward1_en = 1'b1;
            forward1_data = rf_wdata_wb;
        end
        if (rf_we_ls && rf_rd_ls == rf_rs2_ex) begin
            forward2_en = 1'b1;
            forward2_data = rf_wdata_tmp_ls;
        end
        else if (rf_we_wb && rf_rd_wb == rf_rs2_ex) begin
            forward2_en = 1'b1;
            forward2_data = rf_wdata_wb;
        end
    end

    // load-use
    logic stall_by_load_use, flush_by_load_use;
    wire is_load_ex = mem_access_ex[`LOAD_BIT];     // mem_access  = {2'b01, funct3}
    always_comb begin
        // Lab3 TODO: generate stall_by_load_use and flush_by_load_use
        stall_by_load_use = ((rf_rd_ex == rf_rs1_id) || (rf_rd_ex == rf_rs2_id)) && is_load_ex;
        flush_by_load_use = stall_by_load_use;
    end

    // control hazard
    wire flush_by_jump = jump;
    // Lab4 TODO: generate CSR related flush signal
    wire flush_by_csr = is_priv_ex & ~exp_ecall_ex & ~exp_mret_ex;
    // Lab4 TODO: generate ecall and mret flush signal
    wire flush_by_ecall_ex = exp_ecall_ex;
    wire flush_by_ecall    = exp_en_wb;
    wire flush_by_mret_ex  = exp_mret_ex;

    // Lab3 TODO: generate pc_set, IF1_IF2_flush, IF2_ID_flush, ID_EX_flush, EX_LS_flush, LS_WB_flush
    assign pc_set           = flush_by_csr || jump || flush_by_ecall || flush_by_mret_ex;
    assign IF1_IF2_flush    = flush_by_csr || jump || flush_by_ecall_ex || flush_by_ecall || flush_by_mret_ex;
    assign IF2_ID_flush     = flush_by_csr || jump || flush_by_ecall_ex || flush_by_ecall || flush_by_mret_ex;
    assign ID_EX_flush      = flush_by_csr || flush_by_load_use || jump || flush_by_ecall_ex || flush_by_ecall || flush_by_mret_ex;
    assign EX_LS_flush      = flush_by_ecall;
    assign LS_WB_flush      = flush_by_ecall;    // affect top->pc_cur

    // Lab3 TODO: generate pc_stall, IF1_IF2_stall, IF2_ID_stall, ID_EX_stall, EX_LS_stall, LS_WB_stall
    assign pc_stall         = stall_by_load_use;
    assign IF1_IF2_stall    = stall_by_load_use;
    assign IF2_ID_stall     = stall_by_load_use;
    assign ID_EX_stall      = 0;
    assign EX_LS_stall      = 0;
    assign LS_WB_stall      = 0;

    always_comb begin
        pc_set_target = jump_target;
        if (flush_by_jump) begin
            pc_set_target = jump_target;
        end else if (flush_by_csr) begin
            pc_set_target = pc_ex + 4;
        end else if (flush_by_ecall) begin
            pc_set_target = mtvec_global;
        end else if (flush_by_mret_ex) begin
            pc_set_target = mepc_global;
        end
        // Lab4 TODO: generate CSR, ecall and mret related pc_set_target
    end

endmodule