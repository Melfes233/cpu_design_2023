`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
    output wire [13:0]  inst_addr,
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_wen,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO: 完成你自己的单周期CPU设计
    //
    wire [31:0]pc,npc,pc4;
    wire [31:0]rD1,rD2,alu_c,rdo,ext;
    wire [1:0] npc_op,rf_wsel;
    wire rf_we,alub_sel,ram_we,alu_f;
    wire [2:0] sext_op;
    wire [3:0] alu_op;

    PC u_PC(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .din(npc),
        .pc(pc)
    );

    NPC u_NPC(
        .pc(pc),
        .br(alu_f),
        .offset(ext),
        .alu_c(alu_c),
        .npc_op(npc_op),
        .npc(npc),
        .pc4(pc4)
    );

    assign inst_addr = pc[15:2];
    
    RF u_RF(
        .clk(cpu_clk),
        .rR1(inst[19:15]),
        .rR2(inst[24:20]),
        .wR(inst[11:7]),  
        .pc4(pc4),
        .ext(ext),
        .alu_c(alu_c),
        .rdo(rdo),
        .we(rf_we),
        .rf_wsel(rf_wsel),
        .rD1(rD1),
        .rD2(rD2)
    );


    SEXT u_SEXT(
        .sext_op(sext_op),
        .din(inst[31:7]),
        .ext(ext)
    );

    ALU u_ALU(
        .alu_op(alu_op),
        .alub_sel(alub_sel),
        .alu_a(rD1),
        .rD2(rD2),
        .ext(ext),
        .alu_c(alu_c),
        .alu_f(alu_f)
    );

    // MYDRAM u_DRAM(
    //     .clk(cpu_clk),
    //     .ram_we(ram_we),
    //     .adr(alu_c),
    //     .wD(rD2),
    //     .rdo(rdo)
    // );
    assign Bus_addr = alu_c;
    assign rdo = Bus_rdata;
    assign Bus_wen = ram_we;
    assign Bus_wdata = rD2;

    Controller u_Controller(
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7(inst[31:25]),
        .npc_op(npc_op),
        .rf_we(rf_we),
        .rf_wsel(rf_wsel),
        .alub_sel(alub_sel),
        .sext_op(sext_op),
        .alu_op(alu_op),
        .ram_we(ram_we)
    );


`ifdef RUN_TRACE

    reg [31:0] wD;
    always @(*) begin
        if(rf_wsel == 2'd0) wD = pc4;
        else if(rf_wsel == 2'd1) wD = ext;
        else if(rf_wsel == 2'd2) wD = alu_c;
        else wD = rdo;
    end
    
    // Debug Interface
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc        = pc;
    assign debug_wb_ena       = rf_we;
    assign debug_wb_reg       = inst[11:7];
    assign debug_wb_value     = wD;
`endif

endmodule
