module SEXT (
    input [2:0] sext_op,
    input [24:0] din,
    output reg [31:0] ext
);
    wire sign = din[24];
    always @(*) begin
        case (sext_op)
            3'b000: ext = {{20{sign}} ,  din[24:13]};   //EXT_I
            3'b001: ext = {27'b0, din[17:13]};//EXT_I2
            3'b010: ext = {{20{sign}}, din[24:18], din[4:0]} ;//EXT_S
            3'b011: ext = {din[24:5], 12'b0};//EXT_U
            3'b100: ext = {{19{sign}}, din[24], din[0], din[23:18], din[4:1], 1'b0};//EXT_B
            3'b101: ext = {{11{sign}}, din[24], din[12:5], din[13], din[23:14], 1'b0};//EXT_J
            default: ext = 32'd0;
        endcase
    end
    
endmodule