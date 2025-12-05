`include "./include/config.sv"

// Lab4 TODO: implement the Exp_Commit module for ecall instruction
// you need to generate exception code for `syscall from machine mode`
module Exp_Commit(
    input  logic [ 2:0] priv_vec_wb,
    output logic [31:0] ecause
);

    assign ecause = priv_vec_wb[`ECALL] ? 32'd11: 32'd0;

endmodule
