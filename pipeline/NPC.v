module NPC (
    input [31:0] pc,
    input [31:0] pc_EX,
    input [1:0] jump,
    input [31:0] offset,
    input [31:0] alu_c,//jalr
    input [1:0] npc_op,
    output [31:0] pc4,
    output reg [31:0] npc
);
    assign pc4 = pc + 32'd4;
    
    always @(*) begin
        if(jump == 2'd1) npc = pc_EX + offset;//BRANCH
        else if(jump == 2'd2) npc = alu_c;//jalr 
        else npc = pc + 32'd4; 
    end

endmodule