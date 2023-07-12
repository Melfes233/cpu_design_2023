module digit_display(
    input wire       cpuclk   ,
	input wire       rst   ,
	input wire [31:0] display_led, 
    input wire       dig_wen,
	output reg        led0_en,
	output reg        led1_en,
    output reg        led2_en,
    output reg        led3_en,
    output reg        led4_en,
    output reg        led5_en,
    output reg        led6_en,
    output reg        led7_en,
	output reg        led_ca,
	output reg        led_cb,
    output reg        led_cc,
	output reg        led_cd,
	output reg        led_ce,
	output reg        led_cf,
	output reg        led_cg,
	output wire       led_dp
//	output reg [23:0] 
);

//    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en} = 8'b11111111;
//    reg [7:0] led_en = 8'b11111111;//位码
    reg [3:0] disp_dat = 0;  //要显示的数据
    reg [7:0] disp_bit = 0;  //要显示的位
    
    assign led_dp = 1'b1;

    reg [31:0] led_save;
    always @(posedge cpuclk or posedge rst) begin
        if(rst)
            led_save <= 32'd0;
        else if(dig_wen)
            led_save <= display_led;
        else 
            led_save <= led_save;
    end

    reg [31:0]div_cnt;
    reg divclk;
    assign div_flag = (div_cnt >= 32'd1000);
    always @(posedge cpuclk or posedge rst)begin
        if(rst)
            div_cnt <= 32'd0;
        else if(div_flag)
            div_cnt <= 32'd0;
        else
            div_cnt <= div_cnt + 32'd1;
    end

    always @(posedge cpuclk or posedge rst) begin
        if(rst)
            divclk <= 0;
        else if(div_flag)
            divclk <= ~divclk;
        else 
            divclk <= divclk;
    end

    // 确定当前要显示的位
    always @(posedge divclk or posedge rst)    begin
        if(rst) begin     
           // disp_bit<=3'b0;
           {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11111111;
           disp_dat<=4'd0;
        end
        else begin
            if(disp_bit>=7)     disp_bit<=3'b0;
            else    disp_bit<= disp_bit+3'd1;
        
            case(disp_bit)
                3'd0:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11111110;  //显示第1位，低有效
                    disp_dat<=led_save[3:0];
                end
                3'd1:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11111101;  //显示第2位，低有效
                    disp_dat<=led_save[7:4];
                end
                3'd2:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11111011;  //显示第3位，低有效
                    disp_dat<=led_save[11:8];
                end
                3'd3:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11110111;  //显示第4位，低有效
                    disp_dat<=led_save[15:12];
                end
                3'd4:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11101111;  //显示第5位，低有效
                    disp_dat<=led_save[19:16];
                end
                3'd5:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11011111;  //显示第6位，低有效
                    disp_dat<=led_save[23:20];
                end
                3'd6:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b10111111;  //显示第7位，低有效
                    disp_dat<=led_save[27:24];
                end
                3'd7:   begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b01111111;  //显示第8位，低有效
                    disp_dat<=led_save[31:28];
                end
                default:    begin
                    {led7_en, led6_en, led5_en, led4_en, led3_en, led2_en, led1_en, led0_en}<=8'b11111111;
                    disp_dat<=4'd0;
                end
            endcase
        end
    end
    
    //修改段码，组合逻辑
    always @(*)      begin
        case(disp_dat)
            4'h0:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0000001;
            4'h1:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b1001111;
            4'h2:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0010010;
            4'h3:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0000110;
            4'h4:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b1001100;
            4'h5:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0100100;
            4'h6:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0100000;
            4'h7:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0001111;
            4'h8:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0000000;
            4'h9:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0001100;
            4'ha:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0001000;
            4'hb:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b1100000;
            4'hc:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b1110010;
            4'hd:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b1000010;
            4'he:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0110000;
            4'hf:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b0111000;
            default:{led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = 7'b1111111;
        endcase
    end
    
endmodule
