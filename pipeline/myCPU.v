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

    wire IF_ID_pipeline_stop,PC_stop,IF_ID_pipeline_flush,ID_EX_pipeline_flush;
    wire [2:0]rR1_forward,rR2_forward;
    wire [1:0]pc_jump;

    wire [31:0]pc_ID,pc_EX,pc_MEM,pc_WB;
    wire have_inst_ID,have_inst_EX,have_inst_MEM,have_inst_WB;

    wire [31:0]pc4_ID,inst_ID;

    wire [1:0]rf_wsel_EX;
    wire rf_we_EX;
    wire alub_sel_EX;
    wire [3:0]alu_op_EX;
    wire ram_we_EX;
    wire [31:0]rD1_EX;
    wire [31:0]rD2_EX;
    wire [31:0]ext_EX;
    wire [4:0]wR_EX;
    wire [31:0]wD_EX;
    wire [1:0]npc_op_EX;

    wire [1:0]rf_wsel_MEM;
    wire rf_we_MEM;
    wire ram_we_MEM;
    wire [31:0]wdin_MEM;
    wire alu_f_MEM;
    wire [31:0]alu_c_MEM;
    wire [4:0]wR_MEM;
    wire [31:0]wD_MEM;

    wire [1:0]rf_wsel_WB;
    wire rf_we_WB;
    wire [4:0]wR_WB;
    wire [31:0]rdo_WB;
    wire [31:0]wD_WB;


    PC u_PC(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .pipeline_stop(PC_stop),
        .din(npc),
        .pc(pc)
    );

    NPC u_NPC(
        .pc(pc),
        .pc_EX(pc_EX),
        .jump(pc_jump),
        .offset(ext_EX),//ID
        .alu_c(alu_c),//EX
        .npc_op(npc_op),//ID
        .npc(npc),
        .pc4(pc4)
    );

    assign inst_addr = pc[15:2];
    
    IF_ID u_IF_ID(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .pipeline_stop(IF_ID_pipeline_stop),
        .pipeline_flush(IF_ID_pipeline_flush),
        .pc_i(pc),
        .pc_o(pc_ID),
        .pc4_i(pc4),
        .inst_i(inst),
        .pc4_o(pc4_ID),
        .inst_o(inst_ID)
    );

    RF u_RF(
        .clk(cpu_clk),
        .rR1(inst_ID[19:15]),
        .rR2(inst_ID[24:20]),
        .wR(wR_WB),  
        .wD(wD_WB),
        .we(rf_we_WB),
        .rD1(rD1),
        .rD2(rD2)
    );


    SEXT u_SEXT(
        .sext_op(sext_op),
        .din(inst_ID[31:7]),
        .ext(ext)
    );

    ID_EX u_ID_EX(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .pipeline_flush(ID_EX_pipeline_flush),
        .pc_i(pc_ID),
        .pc_o(pc_EX),
        .have_inst_i(have_inst_ID),
        .have_inst_o(have_inst_EX),
        .rf_wsel_i(rf_wsel),
        .rf_we_i(rf_we),
        .alub_sel_i(alub_sel),
        .alu_op_i(alu_op),
        .ram_we_i(ram_we),
        .rD1_i(rD1),
        .rD2_i(rD2),
        .ext_i(ext),
        .wR_i(inst_ID[11:7]),
        .pc4_i(pc4_ID),
        .npc_op_i(npc_op),
        .rf_wsel_o(rf_wsel_EX),
        .rf_we_o(rf_we_EX),
        .alub_sel_o(alub_sel_EX),
        .alu_op_o(alu_op_EX),
        .ram_we_o(ram_we_EX),
        .rD1_o(rD1_EX),
        .rD2_o(rD2_EX),
        .ext_o(ext_EX),
        .wR_o(wR_EX),
        .npc_op_o(npc_op_EX),
        .wD_o(wD_EX),
        .rD_EX(alu_c),
        .rD_MEM(alu_c_MEM),
        .rD_wB(wD_WB),
        .rdo_MEM(rdo),
        .rR1_forward(rR1_forward),
        .rR2_forward(rR2_forward)
    );

    ALU u_ALU(
        .alu_op(alu_op_EX),
        .alub_sel(alub_sel_EX),
        .alu_a(rD1_EX),
        .rD2(rD2_EX),
        .ext(ext_EX),
        .alu_c(alu_c),
        .alu_f(alu_f)
    );

    EX_MEM u_EX_MEM(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .pc_i(pc_EX),
        .pc_o(pc_MEM),
        .have_inst_i(have_inst_EX),
        .have_inst_o(have_inst_MEM),
        .rf_wsel_i(rf_wsel_EX),
        .rf_we_i(rf_we_EX),
        .ram_we_i(ram_we_EX),
        .wdin_i(rD2_EX),
        .alu_f_i(alu_f),
        .alu_c_i(alu_c),
        .wR_i(wR_EX),
        .wD_i(wD_EX),
        .wD_o(wD_MEM),
        .rf_wsel_o(rf_wsel_MEM),
        .rf_we_o(rf_we_MEM),
        .ram_we_o(ram_we_MEM),
        .wdin_o(wdin_MEM),
        .alu_c_o(alu_c_MEM),
        .alu_f_o(alu_f_MEM),
        .wR_o(wR_MEM)
    );

    MEM_WB u_MEM_WB(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .pc_i(pc_MEM),
        .pc_o(pc_WB),
        .have_inst_i(have_inst_MEM),
        .have_inst_o(have_inst_WB),
        .rf_wsel_i(rf_wsel_MEM),
        .rf_we_i(rf_we_MEM),
        .wR_i(wR_MEM),
        .rdo_i(rdo),
        .wD_i(wD_MEM),
        .wD_o(wD_WB),
        .rf_wsel_o(rf_wsel_WB),
        .rf_we_o(rf_we_WB),
        .wR_o(wR_WB),
        .rdo_o(rdo_WB)  
    );

    assign Bus_addr = alu_c_MEM;
    assign rdo = Bus_rdata;
    assign Bus_wen = ram_we_MEM;
    assign Bus_wdata = wdin_MEM;

    Controller u_Controller(
        .opcode(inst_ID[6:0]),
        .funct3(inst_ID[14:12]),
        .funct7(inst_ID[31:25]),
        .npc_op(npc_op),
        .rf_we(rf_we),
        .rf_wsel(rf_wsel),
        .alub_sel(alub_sel),
        .sext_op(sext_op),
        .alu_op(alu_op),
        .have_inst(have_inst_ID),
        .ram_we(ram_we)
    );

    Detector u_Detector(
        .rR1(inst_ID[19:15]),
        .rR2(inst_ID[24:20]),

        .ID_EX_wR(wR_EX),
        .ID_EX_rf_we(rf_we_EX),
        .ID_EX_rf_wsel(rf_wsel_EX),
        .EX_MEM_wR(wR_MEM),
        .EX_MEM_rf_we(rf_we_MEM),
        .EX_MEM_rf_wsel(rf_wsel_MEM),
        .MEM_WB_wR(wR_WB),
        .MEM_WB_rf_we(rf_we_WB),

        .npc_op_EX(npc_op_EX),
        .alu_f(alu_f),

        .IF_ID_pipeline_stop(IF_ID_pipeline_stop),
        .ID_EX_pipeline_flush(ID_EX_pipeline_flush),
        .IF_ID_pipeline_flush(IF_ID_pipeline_flush),
        .PC_stop(PC_stop),
        .rR1_forward(rR1_forward),
        .rR2_forward(rR2_forward),
        .jump(pc_jump)
    );


`ifdef RUN_TRACE    
    // Debug Interface
    assign debug_wb_have_inst = have_inst_WB;
    assign debug_wb_pc        = pc_WB;
    assign debug_wb_ena       = rf_we_WB;
    assign debug_wb_reg       = wR_WB;
    assign debug_wb_value     = wD_WB;
`endif

endmodule
