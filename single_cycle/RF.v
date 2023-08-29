module RF (
    input clk,
    input [4:0] rR1,
    input [4:0] rR2,
    input [4:0] wR,
    
    input [31:0] pc4,
    input [31:0] ext,
    input [31:0] alu_c,
    input [31:0] rdo,

    input we,
    input [1:0]rf_wsel,

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
    reg [31:0] wD;
    always @(*) begin
        if(rf_wsel == 2'd0) wD = pc4;
        else if(rf_wsel == 2'd1) wD = ext;
        else if(rf_wsel == 2'd2) wD = alu_c;
        else wD = rdo;
    end

    always @(negedge clk) begin
        if(we)
            regs[wR] <= ((wR == 5'b0) ? 32'b0 : wD); 
    end

    
endmodule