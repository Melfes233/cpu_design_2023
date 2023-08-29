module EX_MEM (
    input clk,
    input rst,
    // input pipeline_stop,

    input [31:0]pc_i,
    output reg [31:0]pc_o,
    input have_inst_i,
    output reg have_inst_o,

    input [1:0]rf_wsel_i,
    input rf_we_i,
    input ram_we_i,
    input [31:0]wdin_i,
    input alu_f_i,
    input [31:0]alu_c_i,
    input [4:0]wR_i,
    input [31:0]wD_i,

    output reg [31:0]wD_o,
    output reg [1:0]rf_wsel_o,
    output reg rf_we_o,
    output reg ram_we_o,
    output reg [31:0]wdin_o,
    output reg [31:0]alu_c_o,
    output reg alu_f_o,
    output reg [4:0]wR_o
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
        if(rst) ram_we_o<=1'b0;
        // else if(pipeline_stop) ram_we_o<=ram_we_o;
        else    ram_we_o<=ram_we_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wdin_o<=32'b0;
        // else if(pipeline_stop) wdin_o<=wdin_o;
        else    wdin_o<=wdin_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) alu_f_o<=1'b0;
        // else if(pipeline_stop) alu_f_o<=alu_f_o;
        else    alu_f_o<=alu_f_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) alu_c_o<=32'b0;
        // else if(pipeline_stop) alu_c_o<=alu_c_o;
        else    alu_c_o<=alu_c_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wR_o<=5'b0;
        // else if(pipeline_stop) wR_o<=wR_o;
        else    wR_o<=wR_i;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) wD_o<=32'b0;
        // else if(pipeline_stop) wR_o<=wR_o;
        else if(rf_wsel_i == 2'd2) wD_o <= alu_c_i;
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