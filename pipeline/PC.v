module PC (
    input clk,
    input rst,
    input pipeline_stop,
    input [31:0] din,
    output reg [31:0] pc
);
    reg last_rst;//上个周期是否复位
    always @(negedge clk)   begin
        last_rst <= rst;
    end

    reg [31:0]pc_tmp;

    always @(posedge clk or posedge rst)begin
        if(rst || last_rst)
            pc_tmp <= 32'b0;
        else if(pipeline_stop)
            pc_tmp <= pc_tmp;
        else
            pc_tmp <= din;
    end
    
    always @(negedge clk or posedge rst)begin
        if(rst || last_rst)
            pc <= 0;
        else
            pc <= pc_tmp;
    end


endmodule