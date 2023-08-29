.data
    

.macro push %a
    addi sp,sp,-4
    sw %a,0(sp)
.end_macro

.macro pop %a
    lw %a,0(sp)
    addi sp,sp,4
.end_macro

.text


MAIN:
    lui s1,0xfffff #base addr
    # 00800103
    # 00c00404
    # lui t0,0x00600
    # addi t0,t0,0x501
    # sw t0,0x70(s1)
    
    lw s0,0x70(s1) #load switch
    andi a0,s0,0x0ff # op_B = sw[7:0] 
    jal ra,EXT # extent sign of op_B
    ori s4,a0,0 # save op_B to s4
    sw s0,0x60(s1) #write leds

    srli t0,s0,8 # t0 = sw[:8] 
    andi a0,t0,0x0ff # op_A = sw[15:8] 
    jal ra,EXT # extent sign of op_A
    ori s3,a0,0 # save op_A to s3

    srli t0,t0,13 # t0 = sw[:21]
    andi s2,t0,0x007 # s2 = operation = sw[23:21]

    jal ra,CALCULATE
    ori s0,a0,0
    # sw   s0, 0x60(s1)		# write digit_led	
    sw   s0, 0x00(s1)
    jal  zero,MAIN


EXT:# extent sign
    push t1
    srli t1,a0,7 
    andi t1,t1,1 # get sign 
    beq t1,zero,EXT_RETURN # sign == 0, return, otherwize do extension
    lui t1,0xfffff
    srai t1,t1,4
    add a0,t1,a0
    EXT_RETURN:
        pop t1
        jalr zero,0(ra)

CALCULATE:# do calculation
    push t1
    push t2
    push t3
    ori t1,zero,0
    beq s2,t1,OP_AND #000
    addi t1,t1,1
    beq s2,t1,OP_OR #001
    addi t1,t1,1
    beq s2,t1,OP_XOR #002
    addi t1,t1,1
    beq s2,t1,OP_SLL #003
    addi t1,t1,1
    beq s2,t1,OP_SRA #004
    addi t1,t1,1
    beq s2,t1,OP_FUNC1 #005
    addi t1,t1,1
    beq s2,t1,OP_DIV #006
    jal zero,CALCULATE_RETURN_2

    OP_AND:
        and a0,s3,s4
        jal zero,CALCULATE_RETURN_1
    OP_OR:
        or a0,s3,s4
        jal zero,CALCULATE_RETURN_1
    OP_XOR:
        xor a0,s3,s4
        jal zero,CALCULATE_RETURN_1
    OP_SLL:
        sll a0,s3,s4
        jal zero,CALCULATE_RETURN_2
    OP_SRA:
        sra a0,s3,s4
        jal zero,CALCULATE_RETURN_2
    
    OP_FUNC1: # (A==0)?B:B_com
        push t2
        push t3
        ori t2,s4,0 # t2 = op_B
        beq s3,zero,OP_FUNC1_RETURN # op_A==0, return, otherwise get com of op_B
        srli t3,t2,7 # t3 = sign of op_B
        beq t3,zero,OP_FUNC1_RETURN # sign of op_B == 0, return, otherwize op_B<0
        addi t3,zero,-1 # t3 = 0xffffffff
        xor t2,t2,t3 # t2 = ~t2
        addi t3,zero,1
        slli t3,t3,7
        addi t2,t2,1 # t2 = op_B_com
	add t2,t3,t2

        OP_FUNC1_RETURN:
            ori a0,t2,0
            pop t3
            pop t2
            jal zero,CALCULATE_RETURN_1

    OP_DIV: # A/B
        push t2 # i 
        push t3 # remainder
        push s5 # op_B*
        push t4 # tmp
        push t5 # tmp
        
        andi t3,s3,0x07f # t3 = remainder = op_A*
        andi s5,s4,0x07f # s5 = op_B*
        bge t3,s5,OP_DIV_AGEB
        ori a0,zero,0
        jal zero,OP_DIV_RETURN
        
        OP_DIV_AGEB:
        
        ori a0,zero,0 # a0 = 0
        ori t2,zero,0 # i = 0
        
	ori t5,zero,0
	ori t4,s5,0
	
	OP_DIV_1:
	blt t3,t4,OP_DIV_2 # op_A* < B<<t5 ? 
        slli t4,t4,1
        addi t5,t5,1
        jal zero,OP_DIV_1
        
        OP_DIV_2:
	srli t4,t4,1 # t4 = B<<t5 
	addi t5,t5,-1 # B<<t5 <= A && B<<(t5+1) > A
	
        OP_DIV_LOOP:
        blt t5,t2,OP_DIV_RETURN # i <= t5
        slli a0,a0,1
        blt t3,t4,OP_DIV_3 # remainder < t4
        addi a0,a0,1 # remiander >= t4 
        sub t3,t3,t4
        OP_DIV_3:
        srli t4,t4,1
        addi t2,t2,1
        jal zero,OP_DIV_LOOP
        

        OP_DIV_RETURN:
            srli t4,s3,7
            srli t5,s4,7
            xor t4,t5,t4
            andi t4,t4,1
            slli t4,t4,7
            add a0,a0,t4
            pop t5
            pop t4
            pop s6
            pop s5
            pop t3
            pop t2
            jal zero,CALCULATE_RETURN_2

    CALCULATE_RETURN_1: # show 2-bit num 
        ori t1,a0,0
        ori a0,zero,0
        ori t2,zero,7
        CALCULATE_1:
        beq t2,zero,CALCULATE_2
        srl t3,t1,t2
        andi t3,t3,1
        add a0,a0,t3
        slli a0,a0,4
        addi t2,t2,-1
        jal zero,CALCULATE_1
        

        CALCULATE_2:
        andi t3,t1,1
        add a0,a0,t3

        pop t3
        pop t2
        pop t1

        jalr zero,0(ra)
    
    CALCULATE_RETURN_2: # show signed int 
        pop t3
        pop t2
        pop t1
	andi a0,a0,0x0ff
        jalr zero,0(ra)

EXIT:
