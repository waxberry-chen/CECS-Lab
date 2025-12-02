`include "./include/config.sv"

// Lab4 TODO: implement the Exp_Commit module for ecall instruction
// you need to generate exception code for `syscall from machine mode`
module Exp_Commit(
    input  logic [ 0:0] exp_ecall_wb,
    input  logic [ 0:0] exp_mret_wb,
    output logic [ 0:0] exp_en_wb,
    output logic [31:0] ecause
);

    assign exp_en_wb = exp_ecall_wb;
    assign ecause = exp_ecall_wb ? 32'd11: 32'd0;

endmodule
