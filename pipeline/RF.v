module RF (
    input clk,
    input [4:0] rR1,
    input [4:0] rR2,
    input [4:0] wR,
    input [31:0] wD,

    input we,

    output [31:0] rD1,
    output [31:0] rD2
);
    reg [31:0] regs[31:0];
    integer i;
    initial begin
        for (i = 0; i<32; i = i + 1) begin
            regs[i] = 32'd0;
        end
    end
    
    //read
    assign rD1 = (rR1 == 5'b0) ? 32'b0 : regs[rR1];
    assign rD2 = (rR2 == 5'b0) ? 32'b0 : regs[rR2];

    //write
    always @(posedge clk) begin
        if(we)
            regs[wR] <= ((wR == 5'b0) ? 32'b0 : wD); 
    end

    
endmodule