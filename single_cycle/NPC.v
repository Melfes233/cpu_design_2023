module NPC (
    input [31:0] pc,
    input br,
    input [31:0] offset,
    input [31:0] alu_c,
    input [1:0] npc_op,
    output [31:0] pc4,
    output reg [31:0] npc
);
    assign pc4 = pc + 32'd4;
    always @(*)begin
        if(npc_op==2'd0) npc = pc + 32'd4;//NPC_PC4
        else if(npc_op == 2'd1) npc = alu_c;//NPC_ALU
        else if(npc_op == 2'd2) npc = pc + offset;//NPC_JUMP
        else begin//NPC_BR
            if(br)
                npc = pc + offset;
            else
                npc = pc + 32'd4;
        end
    end
    
endmodule