`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/17 22:17:57
// Design Name: 
// Module Name: CNN_Maxpooling
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


module CNN_Maxpooling#(parameter MP_Width = 16)(
    clk, rst_n, mp_valid, 
    input_data_0, input_data_1, input_data_2, input_data_3,
    mp_out_0, mp_out_valid
    );
    
    input clk, rst_n, mp_valid;
    input signed [MP_Width -1:0] input_data_0, input_data_1, input_data_2, input_data_3;
    output reg signed [MP_Width -1:0] mp_out_0;
    output reg mp_out_valid;
    wire signed [MP_Width -1:0] mp_reg1, mp_reg2;
    
    assign mp_reg1 = (input_data_0 >= input_data_1)?input_data_0:input_data_1;
    assign mp_reg2 = (input_data_2 >= input_data_3)?input_data_2:input_data_3;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            mp_out_0 <= 0;
            mp_out_valid <= 0;
        end
        else if(mp_valid)begin
            if(mp_reg1 >= mp_reg2)begin
                mp_out_0 <= mp_reg1;
            end
            else begin
                mp_out_0 <= mp_reg2;
            end
            mp_out_valid <= 1;
        end else begin
            mp_out_valid <= 0;
        end
    end

endmodule
