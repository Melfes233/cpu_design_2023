module Controller (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [1:0] npc_op,
    output rf_we,
    output reg [1:0] rf_wsel,
    output alub_sel,
    output reg [2:0] sext_op,
    output reg [3:0] alu_op,
    output reg have_inst,
    output ram_we

);
    //npc_op
    always @(*) begin
        if(opcode == 7'b1100111) npc_op = 2'd1;//NPC_ALU
        else if(opcode == 7'b1100011) npc_op = 2'd3;//NPC_BR
        else if(opcode == 7'b1101111) npc_op = 2'd2;//NPC_JUMP
        else npc_op = 2'd0;//NPC_PC4
    end

    assign rf_we = ~((opcode == 7'b1100011) | (opcode == 7'b0100011));

    //rf_wsel
    always @(*) begin
        if(opcode == 7'b0000011) rf_wsel = 2'd3;//WB_DRAM
        else if(opcode == 7'b1100111 || opcode == 7'b1101111) rf_wsel = 2'd0;//WB_PC4
        else if(opcode == 7'b0110111) rf_wsel = 2'd1;//WB_SEXT
        else rf_wsel = 2'd2;//WB_ALU
    end

    always @(*)begin
        //if((opcode == 7'b0110011) || (opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b1100111) 
        //|| (opcode == 7'b0100011) || (opcode == 7'b1100011) || (opcode == 7'b0110111) || (opcode == 7'b1101111))
        if(opcode != 7'd0)
            have_inst = 1'b1;
        else 
            have_inst = 1'b0;
    end

    //sext_op
    always @(*) begin
        case(opcode)
            7'b0010011: begin // I
                if(funct3 == 3'b001 || funct3 == 3'b101)   // EXT_I2
                    sext_op = 3'd1;
                else sext_op = 3'd0;//EXT_I
            end
            7'b0000011: sext_op = 3'd0; // lw
            7'b1100111: sext_op = 3'd0; // jalr
            7'b0100011: sext_op = 3'd2; // EXT_S
            7'b0110111: sext_op = 3'd3; // EXT_U
            7'b1100011: sext_op = 3'd4; // EXT_B
            7'b1101111: sext_op = 3'd5; // EXT_J
            default:    sext_op = 3'd0;
        endcase
    end

    assign alub_sel = ~((opcode == 7'b0110011) | (opcode == 7'b1100011));

    //alu_op
    always @(*) begin
        if (opcode == 7'b0110011)  begin   //R型
            case({funct7, funct3})  
                10'b0000000000:     alu_op = 4'd0;    // +
                10'b0100000000:     alu_op = 4'd1;    // -
                10'b0000000111:     alu_op = 4'd2;    // &
                10'b0000000110:     alu_op = 4'd3;    // |
                10'b0000000100:     alu_op = 4'd4;    // ^
                10'b0000000001:     alu_op = 4'd5;    // 左移
                10'b0000000101:     alu_op = 4'd6;    // 逻辑右移
                10'b0100000101:     alu_op = 4'd7;    // 算数右移
                default:            alu_op = 4'd15;
            endcase
        end
        else if (opcode == 7'b0010011)  begin   // I型
            case({funct3})  
                3'b000:     alu_op = 4'd0;    // +
                3'b111:     alu_op = 4'd2;    // &
                3'b110:     alu_op = 4'd3;    // |
                3'b100:     alu_op = 4'd4;    // ^
                3'b001:     alu_op = 4'd5;    // 左移
                3'b101:     begin
                    case(funct7)
                        7'b0000000: alu_op = 4'd6;    // 逻辑右移
                        7'b0100000: alu_op = 4'd7;    // 算数右移
                        default:    alu_op = 4'd6;    
                    endcase
                end
                default:            alu_op = 4'd15;
            endcase
        end
        else if (opcode == 7'b0000011 && funct3==3'b010)  begin   // lw
            alu_op = 4'd0;    // +
        end
        else if (opcode == 7'b1100111 && funct3==3'b000)  begin   // jalr
            alu_op = 4'd0;    // +
        end
        else if (opcode == 7'b0100011 && funct3==3'b010)  begin   // sw
            alu_op = 4'd0;    // +
        end
        else if (opcode == 7'b0110111)  begin
            alu_op = 4'd8; //lui
        end
        else if (opcode == 7'b1100011) begin
            case (funct3)
                3'b000:alu_op = 4'd9;//EQ
                3'b001:alu_op = 4'd10;//NE
                3'b100:alu_op = 4'd11;//LT
                3'b101:alu_op = 4'd12;//GE 
                default: alu_op = 4'd9;
            endcase
        end
        else    alu_op = 4'd15;
    end
    
    assign ram_we = (opcode == 7'b0100011) & (funct3 == 3'b010);//sw

endmodule