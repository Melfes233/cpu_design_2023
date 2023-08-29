module MEM_WB (
    input clk,
    input rst,

    input [31:0]pc_i,
    output reg [31:0]pc_o,
    input have_inst_i,
    output reg have_inst_o,

    input [1:0]rf_wsel_i,
    input rf_we_i,
    input [4:0]wR_i,
    input [31:0]rdo_i,
    input [31:0]wD_i,

    output reg [31:0]wD_o,
    output reg [1:0]rf_wsel_o,
    output reg rf_we_o,
    output reg [4:0]wR_o,
    output reg [31:0]rdo_o
);

    always @(posedge clk or posedge rst) begin
        if(rst) rf_wsel_o<=2'b0;
        // else if(pipeline_stop) rf_wsel_o<=rf_wsel_o;
        else    rf_wsel_o<=rf_wsel_i;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) rf_we_o<=1'b0;
        // else if(pipeline_stop) rf_we_o<=rf_we_o;
        else    rf_we_o<=rf_we_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wR_o<=5'b0;
        // else if(pipeline_stop) wR_o<=wR_o;
        else    wR_o<=wR_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) rdo_o<=32'b0;
        // else if(pipeline_stop) rdo_o<=rdo_o;
        else    rdo_o<=rdo_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wD_o<=32'b0;
        // else if(pipeline_stop) wR_o<=wR_o;
        else if(rf_wsel_i == 2'd3) wD_o <= rdo_i;
        else    wD_o<=wD_i;
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)      pc_o <= 32'b0;
        else            pc_o <= pc_i;
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)      have_inst_o <= 1'b0;
        else            have_inst_o <= have_inst_i;
    end

endmodule