`timescale 1ns / 1ps



module ifm_reg_buf 
    #(
      parameter RAM_WIDTH = 64,                  
      parameter RAM_DEPTH = 11
      )
(
        input [RAM_WIDTH*4-1:0]         ifm_bram_data,             // 4 bram_data signal 
        input [3:0]                     ifm_bram_full,
        input               height_hs, rst_na, clk,             // no any other hs_signal assignment is needed.
        
        output reg   [3:0]       read_en,                            // 4 read_en signal >>> 4 bit bus signal change
        output  [RAM_WIDTH*RAM_DEPTH-1:0]   buf_data,
        output                              buf_full
    );
    
    // state >> which bram to be connected ??
    reg     [1:0]   bram_num, bram_next;
    
    localparam R0 = 2'b00;       // bram // 4 = 0
    localparam R1 = 2'b01;       // bram // 4 = 1
    localparam R2 = 2'b10;       // bram // 4 = 2
    localparam R3 = 2'b11;       // bram // 4 = 3
    
    
    // bram input mun wire 
    reg    [RAM_WIDTH-1:0]     data_wire;
    wire                       read_enwire;
    reg                        full_wire;
    
    // read & write module instantiation
    
    ifm_buffer fsm_read_write (
        .ifm_bram_data(data_wire),
        .ifm_bram_full(full_wire),
        .hs_signal(height_hs),
        .rst_na(rst_na),
        .clk(clk),
        .read_en(read_enwire),
        .data_valid(buf_full),
        .data_out(buf_data)
        );
            
                        
    // state case - bram
    always @(*)
    begin
        case (bram_num)  
            R0:begin    
                        if (height_hs) 
                            bram_next = R1;
                        else bram_next = R0;
                        data_wire = ifm_bram_data[RAM_WIDTH-1:0];
                        full_wire = ifm_bram_full[0];
                        read_en = {3'b0, read_enwire};
               end
            R1:begin    if (height_hs) 
                            bram_next = R2;    
                        else bram_next = R1;
                        data_wire = ifm_bram_data[2*RAM_WIDTH-1:RAM_WIDTH];
                        full_wire = ifm_bram_full[1];
                        read_en = {2'b0, read_enwire, 1'b0};
               end
            R2:begin    if (height_hs) 
                            bram_next = R3;    
                        else bram_next = R2;
                        data_wire = ifm_bram_data[3*RAM_WIDTH-1:2*RAM_WIDTH];
                        full_wire = ifm_bram_full[2];
                        read_en = {1'b0, read_enwire, 2'b0};
               end
            R3:begin    if (height_hs) 
                            bram_next = R0;
                        else bram_next = R3; 
                        data_wire = ifm_bram_data[4*RAM_WIDTH-1:3*RAM_WIDTH];
                        full_wire = ifm_bram_full[3];
                        read_en = {read_enwire, 3'b0};
               end
            default:begin    bram_next = R0;
                            data_wire = ifm_bram_data[RAM_WIDTH-1:0];
                            full_wire = ifm_bram_full[0];
                            read_en = {3'b0, read_enwire};
               end
        endcase  
    end
    
    // state transition
    always @(posedge clk) begin
        if (!rst_na)
            bram_num <= R0;
        else 
            bram_num <= bram_next;
        end
    
        
endmodule
