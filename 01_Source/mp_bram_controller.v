`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/18 19:18:55
// Design Name: 
// Module Name: mp_bram_controller
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


module mp_bram_controller(
    input clk,
    input rst_n,
    input [8:0]ifm_width,
    input din_valid,
    input [31:0] din,
    output din_full,
    input dout_valid,
    output [31:0] dout,
    output dout_full,
    output next
    );
    
    reg buf_din_full;
    reg [3:0] r_finish_cnt;
    reg [3:0] r_cnt;
    reg [3:0] w_cnt;
    wire [3:0] addr = (!din_full)? r_cnt : w_cnt;
    wire r_hs = (!din_full) & din_valid;
    
    assign din_full = (r_cnt == r_finish_cnt) & (r_cnt != w_cnt);
    assign next = (r_cnt == r_finish_cnt-1) & (r_cnt != w_cnt) & din_valid;
    assign dout_full = buf_din_full;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            r_finish_cnt <= 0;
        end else begin
            case(ifm_width)
                26: r_finish_cnt <= 7;
                default : r_finish_cnt <= 13;
            endcase
        end
    end

    always@(posedge clk)begin
        if(!rst_n)begin
            r_cnt <= 0;
            w_cnt <= 0;
            buf_din_full <= 0;
        end else begin
            buf_din_full <= din_full;
            if( dout_valid & din_full & r_cnt-1 == w_cnt )begin
                r_cnt <= 0;
                w_cnt <= 0;
            end else if(din_valid & !din_full)begin
                r_cnt <= r_cnt + 1;
            end else if(din_full & dout_valid)begin
                w_cnt <= w_cnt + 1;
            end
        end
    end
    
    mp_bram mp_bram(
    .addra(addr),  // Port A address bus, width determined from RAM_DEPTH
    .dina(din),    // Port A RAM input data
    .clka(clk),    // Clock
    .wea(r_hs),    // Port A write enable
    .ena('b1),     // Port A RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_n),  // Port A output reset (does not affect memory contents)
    .regcea('b0),  // Port A output register enable
    .douta(dout)   // Port A RAM output data
    );
endmodule
