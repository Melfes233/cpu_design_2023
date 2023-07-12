module PC (
    input clk,
    input rst,
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
        else
            pc_tmp <= din;
    end
    
    always @(negedge clk or posedge rst)begin
        if(rst || last_rst)
            pc <= 32'b0;
        else
            //pc <= din;
            pc <= pc_tmp;
    end
    
endmodule