module ID_EX (
    input clk,
    input rst,
    input pipeline_flush,

    input [31:0]pc_i,
    output reg [31:0]pc_o,
    input have_inst_i,
    output reg have_inst_o,

    input [1:0]rf_wsel_i,
    input rf_we_i,
    input alub_sel_i,
    input [3:0]alu_op_i,
    input ram_we_i,
    input [31:0]rD1_i,
    input [31:0]rD2_i,
    input [31:0]ext_i,
    input [4:0]wR_i,
    input [31:0]pc4_i,
    input [1:0]npc_op_i,

    output reg [1:0]rf_wsel_o,
    output reg rf_we_o,
    output reg alub_sel_o,
    output reg [3:0]alu_op_o,
    output reg ram_we_o,
    output reg [31:0]rD1_o,
    output reg [31:0]rD2_o,
    output reg [31:0]ext_o,
    output reg [4:0]wR_o,
    output reg [1:0]npc_op_o,
    output reg [31:0]wD_o,

    input [31:0]rD_EX,
    input [31:0]rD_MEM,
    input [31:0]rD_wB,
    input [31:0]rdo_MEM,
    input [2:0]rR1_forward,
    input [2:0]rR2_forward	
);

    always @(posedge clk or posedge rst) begin
        if(rst) rf_wsel_o<=2'b0;
        else if(pipeline_flush) rf_wsel_o <= 2'b0;
        else    rf_wsel_o<=rf_wsel_i;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) rf_we_o<=1'b0;
        else if(pipeline_flush) rf_we_o <= 1'b0;
        else    rf_we_o<=rf_we_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) alub_sel_o<=1'b0;
        else if(pipeline_flush) alub_sel_o <= 1'b0;
        else    alub_sel_o<=alub_sel_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) alu_op_o<=4'd0;
        else if(pipeline_flush) alu_op_o <= 4'b0;
        else    alu_op_o<=alu_op_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) ram_we_o<=1'b0;
        else if(pipeline_flush) ram_we_o <= 1'b0;
        else    ram_we_o<=ram_we_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) rD1_o<=32'b0;
        else if(pipeline_flush) rD1_o <= 32'b0;
        else if(rR1_forward==3'd1) rD1_o <= rD_EX;
        else if(rR1_forward==3'd2) rD1_o <= rD_MEM;
        else if(rR1_forward==3'd3) rD1_o <= rD_wB;
        else if(rR1_forward==3'd4) rD1_o <= rdo_MEM;
        else    rD1_o<=rD1_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) rD2_o<=32'b0;
        else if(pipeline_flush) rD2_o <= 32'b0;
        else if(rR2_forward==3'd1) rD2_o <= rD_EX;
        else if(rR2_forward==3'd2) rD2_o <= rD_MEM;
        else if(rR2_forward==3'd3) rD2_o <= rD_wB;
        else if(rR1_forward==3'd4) rD2_o <= rdo_MEM;
        else    rD2_o<=rD2_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) ext_o<=32'b0;
        else if(pipeline_flush) ext_o <= 32'b0;
        else    ext_o<=ext_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wR_o<=5'b0;
        else if(pipeline_flush) wR_o <= 5'b0;
        else    wR_o<=wR_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wD_o <= 32'd0;
        else if(pipeline_flush) wD_o <= 32'd0;
        else if(rf_wsel_i == 2'd0) wD_o <= pc4_i;
        else wD_o <= ext_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) npc_op_o<=2'b0;
        else if(pipeline_flush) npc_op_o <= 2'b0;
        else    npc_op_o<=npc_op_i;
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)      pc_o <= 32'b0;
        else if(pipeline_flush) pc_o <= 32'b0;
        else            pc_o <= pc_i;
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)      have_inst_o <= 1'b0;
        else if(pipeline_flush) have_inst_o <= 1'b0;
        else            have_inst_o <= have_inst_i;
    end

endmodule