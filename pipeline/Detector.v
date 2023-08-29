module Detector (
    input [4:0] rR1,
    input [4:0] rR2,

    input [4:0]ID_EX_wR,
    input ID_EX_rf_we,
    input [1:0]ID_EX_rf_wsel,
    input [4:0]EX_MEM_wR,
    input EX_MEM_rf_we,
    input [1:0]EX_MEM_rf_wsel,
    input [4:0]MEM_WB_wR,
    input MEM_WB_rf_we,

    input alu_f,
    input [1:0]npc_op_EX,

    output reg IF_ID_pipeline_stop,
    output reg PC_stop,
    output reg ID_EX_pipeline_flush,
    output reg IF_ID_pipeline_flush,
    output reg [2:0] rR1_forward,
    output reg [2:0] rR2_forward,
    output reg [1:0] jump
);
    initial begin
        IF_ID_pipeline_stop = 0;
        PC_stop = 0;
        ID_EX_pipeline_flush = 0;
        IF_ID_pipeline_flush = 0 ;
        rR1_forward = 3'd0;
        rR2_forward = 3'd0;
    end

    always @(*) begin
        if(ID_EX_rf_we && (ID_EX_wR!=5'd0) && (ID_EX_wR == rR1))begin
            if(ID_EX_rf_wsel == 2'd3)//dram
                rR1_forward = 3'd4;
            else
                rR1_forward = 3'd1;
        end
        else if(EX_MEM_rf_we && (EX_MEM_wR!=5'd0) && (EX_MEM_wR == rR1))begin
            if(EX_MEM_rf_wsel == 2'd3)//dram
                rR1_forward = 3'd4;
            else
                rR1_forward = 3'd2;
        end
        else if(MEM_WB_rf_we && (MEM_WB_wR!=5'd0) && (MEM_WB_wR == rR1))
            rR1_forward = 3'd3;
        else 
            rR1_forward = 3'd0;
    end

    always @(*) begin
        if(ID_EX_rf_we && (ID_EX_wR!=5'd0) && (ID_EX_wR == rR2))begin
            if(ID_EX_rf_wsel == 2'd3)//dram
                rR2_forward = 3'd4;
            else
                rR2_forward = 3'd1;
        end
        else if(EX_MEM_rf_we && (EX_MEM_wR!=5'd0) && (EX_MEM_wR == rR2))begin
            if(EX_MEM_rf_wsel == 2'd3)//dram
                rR2_forward = 3'd4;
            else
                rR2_forward = 3'd2;
        end
        else if(MEM_WB_rf_we && (MEM_WB_wR!=5'd0) && (MEM_WB_wR == rR2))
            rR2_forward = 3'd3;
        else 
            rR2_forward = 3'd0;
    end

    always @(*) begin
        if(ID_EX_rf_we && (ID_EX_wR!=5'd0) && ((ID_EX_wR == rR1)||(ID_EX_wR == rR2)) && (ID_EX_rf_wsel == 2'd3))begin
            //load_use
            ID_EX_pipeline_flush = 1;
            IF_ID_pipeline_stop = 1;
            PC_stop = 1;
            IF_ID_pipeline_flush = 0;
            jump = 2'd0;
        end
        else if(npc_op_EX == 2'd1)begin
            //jalr stop
            ID_EX_pipeline_flush = 1;
            IF_ID_pipeline_stop = 0;
            PC_stop = 0;
            IF_ID_pipeline_flush = 1;
            jump = 2'd2;
        end
        else if((npc_op_EX == 2'd2) || alu_f)begin
            ID_EX_pipeline_flush = 1;
            IF_ID_pipeline_stop = 0;
            PC_stop = 0;
            IF_ID_pipeline_flush = 1;
            jump = 2'd1;
        end
        else begin
            IF_ID_pipeline_stop = 0;
            PC_stop = 0;
            ID_EX_pipeline_flush = 0;
            IF_ID_pipeline_flush = 0;
            jump = 2'd0;
        end
    end

endmodule