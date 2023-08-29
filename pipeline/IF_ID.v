module IF_ID (
    input clk,
    input rst,
    input pipeline_stop,
    input pipeline_flush,

    input [31:0]pc_i,
    output reg [31:0]pc_o,
    input [31:0]pc4_i,
    output reg [31:0]pc4_o,
    input [31:0]inst_i,
    output reg [31:0]inst_o
);
    reg last_rst;
    always @(posedge clk)  begin
        last_rst <= rst;
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)      pc4_o <= 32'b0;
        else if(pipeline_stop) pc4_o <= pc4_o;
        else if(pipeline_flush) pc4_o <= 32'b0;
        else            pc4_o <= pc4_i;
    end
    
    always @ (posedge clk or posedge rst) begin
        if(rst)      inst_o <= 32'b0;
        else if(last_rst)    inst_o <= 32'b0;
        else if(pipeline_stop) inst_o <= inst_o;
        else if(pipeline_flush) inst_o <= 32'b0;
        else            inst_o <= inst_i;
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)      pc_o <= 32'b0;
        else if(pipeline_stop) pc_o <= pc_o;
        else if(pipeline_flush) pc_o <= 32'b0;
        else            pc_o <= pc_i;
    end
    
endmodule