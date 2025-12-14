`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2024 02:39:34 PM
// Design Name: 
// Module Name: axi4_bias_weight_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi4_bias_weight_controller(
    
    input clk,
    input rst_n,
    input en_bias,
    input convolution_3,
    input convolution_1,
    
    input ap_start,
    input ap_done,
    
    input [31:0] weight_address,
    input [31:0] bias_address,
    
    input [31:0] bias_transferbyte,
    input [31:0] weight_transferbyte,
    
    output reg [31:0] bias_or_weight_transferbyte,
    output reg [31:0] bias_or_weight_address,
    
    input bias_bram_full,
    
    output reg hp_0_ap_start,
    output is_bias
    );
    
    localparam idle = 2'b00;
    localparam bias = 2'b01;
    localparam weight = 2'b10;
    localparam weight1 = 2'b11;
    
    reg [1:0] n_state;
    reg [1:0] c_state;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            c_state <= idle;
        end else begin
            c_state <= n_state;
            
            if(n_state == idle)begin
                bias_or_weight_transferbyte <= 'b0;
                hp_0_ap_start <= 'b0;
                bias_or_weight_address <= 'b0;
            end else if(n_state == bias)begin
                hp_0_ap_start <= 'b1;
                bias_or_weight_transferbyte <= bias_transferbyte;
                bias_or_weight_address <= bias_address;
            end else if (n_state == weight)begin
                if(c_state == bias) hp_0_ap_start <= 'b0;
                else hp_0_ap_start <= 'b1;
                bias_or_weight_transferbyte <= weight_transferbyte;
                bias_or_weight_address <= weight_address;
            end else begin
                if(c_state == bias) hp_0_ap_start <= 'b0; 
                else hp_0_ap_start <= 'b1; 
                bias_or_weight_transferbyte <= weight_transferbyte;
                bias_or_weight_address <= weight_address;
            end
        end
    end
    
    always@(*)begin
        n_state = c_state;
        if(ap_start && (convolution_3||convolution_1))begin
            case(c_state)
                idle: if(en_bias)begin
                        n_state = bias;
                      end else begin
                        n_state = weight;
                      end
                bias: begin 
                        if(bias_bram_full & convolution_3 ) n_state = weight;
                        else if(bias_bram_full & convolution_1 ) n_state = weight1;
                end
                weight: if(ap_done) n_state = idle;
                weight1 :if(ap_done) n_state = idle;
            endcase
        end else n_state = idle;
            
        //define state_machine
        
        
    end

assign is_bias = (n_state == bias);
    


endmodule
