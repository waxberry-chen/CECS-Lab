`include "./include/config.sv"
module CSR(
    input  logic [ 0:0] clk,
    input  logic [ 0:0] rstn,
    input  logic [11:0] raddr,
    input  logic [11:0] waddr,
    input  logic [ 0:0] we,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    // Lab4 TODO: you need to add some input or output pors to implement CSRs' special functions
    input  logic [31:0] pc_wb,      // write in mepc
    input  logic [31:0] ecause_wb,  // write in mcause
    input  logic [ 2:0] priv_vec_wb,
    
    output logic [31:0] mtvec_global, 
    output logic [31:0] mepc_global
);
    import "DPI-C" function void set_csr_ptr(input logic [31:0] m1 [], input logic [31:0] m2 [], input logic [31:0] m3 [], input logic [31:0] m4 []);

    // CSR::mstatus
    reg [31:0] mstatus;
    always_ff @(posedge clk) begin
        if(!rstn) begin
            mstatus <= 32'h0;
        end else if ((waddr == 12'h300) && we) begin
            mstatus <= wdata;
        end else if (priv_vec_wb[`ECALL]) begin
            mstatus <= {mstatus[31:12], mstatus[8:0], 3'b110};
        end else if (priv_vec_wb[`MRET]) begin
            mstatus <= {mstatus[31:12], 3'b001, mstatus[11:3]};
        end else begin
            mstatus <= mstatus;
        end
    end

    // CSR::mtvec
    reg [31:0] mtvec;
    always_ff @(posedge clk) begin
        if(!rstn) begin
            mtvec <= 32'h0;
        end else if (waddr == 12'h305 && we) begin
            mtvec <= wdata;
        end else begin
            mtvec <= mtvec;
        end
    end

    // CSR::mepc
    reg [31:0] mepc;
    always_ff @(posedge clk) begin
        if(!rstn) begin
            mepc <= 32'h0;
        end else if (waddr == 12'h341 && we) begin
            mepc <= wdata;
        end else if (priv_vec_wb[`ECALL]) begin
            mepc <= pc_wb;
        end else begin
            mepc <= mepc;
        end
    end

    // CSR::mcause
    reg [31:0] mcause;
    always_ff @(posedge clk) begin
        if(!rstn) begin
            mcause <= 32'h0;
        end else if (waddr == 12'h342 && we) begin
            mcause <= wdata;
        end else if (priv_vec_wb[`ECALL]) begin
            mcause <= ecause_wb;
        end else begin
            mcause <= mcause;
        end
    end

    // read
    always_comb begin
        case(raddr)
            `CSR_MSTATUS: rdata = mstatus;
            `CSR_MTVEC  : rdata = mtvec;
            `CSR_MCAUSE : rdata = mcause;
            `CSR_MEPC   : rdata = mepc;
            default     : rdata = 32'h0;
        endcase
        mtvec_global = mtvec;
        mepc_global  = mepc;
    end

    initial begin
        set_csr_ptr(mstatus, mtvec, mepc, mcause);
    end

endmodule