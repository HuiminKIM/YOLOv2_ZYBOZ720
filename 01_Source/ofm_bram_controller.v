`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/17 10:47:23
// Design Name: 
// Module Name: ofm_bram_controller
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


module ofm_bram_controller(
    input clk,
    input rst_n,
    input ofm_valid,
    input [63:0]ofm_data,
    output reg ofm_bram_valid,
    input ofm_axi_ready,
    output [63:0]ofm_bram_data,
    output reg ofm_bram_full,
    input [3:0] read_cnt
    );
    
    reg [3:0] r_cnt;
    reg [3:0] w_cnt;
    wire w_hs = ofm_bram_valid & ofm_axi_ready;
    
    wire wea =ofm_valid;
    wire [63:0] dina;
    reg [3:0] addra;
    wire [63:0] douta;
    
    assign dina = ofm_data;
    assign ofm_bram_data = douta;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            r_cnt <= 0;
            w_cnt <= 0;
            ofm_bram_full<=0;
            ofm_bram_valid <=0;
        end else begin
            if(ofm_bram_full ==1 & addra == read_cnt & w_hs) ofm_bram_valid<=0;
            else ofm_bram_valid <= ofm_bram_full;
            
            if(read_cnt-1 == r_cnt & ofm_valid)ofm_bram_full<=1;
            else if(ofm_bram_full ==1 & addra == read_cnt & w_hs) ofm_bram_full<=0;
            
            if(read_cnt-1 == r_cnt & ofm_valid)r_cnt <= 0;
            else if(ofm_valid) r_cnt <= r_cnt+1;
            
            if(ofm_bram_full ==1 & addra == read_cnt & w_hs) w_cnt<=0;
            else if(ofm_bram_full ==1 & w_hs) w_cnt<=w_cnt+1;
        end
    end
    
    always@(*)begin
        if(ofm_bram_full)begin
            if(w_hs)addra = w_cnt+1;
            else addra = w_cnt;
        end else begin
            addra = r_cnt;
        end
    end
    
    ofm_bram ofm_bram(
      .addra(addra),  // Port A address bus, width determined from RAM_DEPTH
      .dina(dina),           // Port A RAM input data
      .clka(clk),                           // Clock
      .wea(wea),                            // Port A write enable
      .ena('b1),                            // Port A RAM Enable, for additional power savings, disable port when not in use
      .douta(douta)         // Port A RAM output data
    );
    
endmodule
