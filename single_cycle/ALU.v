module ALU (
    input [3:0] alu_op,
    input alub_sel,

    input [31:0] alu_a,
    input [31:0] ext,
    input [31:0] rD2,

    output reg [31:0] alu_c,
    output reg alu_f
);
    wire [31:0]alu_b;
    assign alu_b = (alub_sel==1'b0)?rD2:ext;

    wire [4:0] shift_bit = alu_b[4:0]; 
    wire [31:0] algor_right = $signed(alu_a) >>> shift_bit;
    reg a_ge_b;
    always @(*)begin
        if(alu_a[31]==1'b0 && alu_b[31]==1'b1)
            a_ge_b = 1'b1;
        else if(alu_a[31]==1'b1 && alu_b[31]==1'b0)
            a_ge_b = 1'b0;
        else
            a_ge_b = (alu_a>=alu_b);
    end

    always @(*) begin
        case (alu_op)
            4'd0: alu_c = alu_a + alu_b;//ADD
            4'd1: alu_c = alu_a - alu_b;//SUB
            4'd2: alu_c = alu_a & alu_b;//AND
            4'd3: alu_c = alu_a | alu_b;//OR
            4'd4: alu_c = alu_a ^ alu_b;//XOR
            4'd5: alu_c = alu_a << shift_bit;//SLL
            4'd6: alu_c = alu_a >> shift_bit;//SRL
            4'd7: alu_c = algor_right;//SRA
            4'd8: alu_c = alu_b;//LUI
            default: alu_c = 32'd0;
        endcase

        case (alu_op)
            4'd9: alu_f = (alu_a==alu_b);//EQ     
            4'd10: alu_f = ~(alu_a==alu_b);//NE
            4'd11: alu_f = ~a_ge_b;//LT
            4'd12: alu_f = a_ge_b;//GE
            default: alu_f = 0;
        endcase
    end
    
endmodule