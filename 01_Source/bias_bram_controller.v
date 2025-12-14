`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2024 04:10:24 PM
// Design Name: 
// Module Name: bias_bram_controller
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


module bias_bram_controller(

    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] din,
    input  wire        write_en,
    output wire        full_n, // out_r_full_n rdma rready
    output reg [63:0]  dout,
    input  wire        read_en,
    input  wire [31:0] transfer_byte,
    output  wire        full
);

parameter ADDR_WIDTH = 9; 
parameter DATA_WIDTH = 64;

localparam DEPTH = (1 << ADDR_WIDTH)-1;
reg [ADDR_WIDTH:0]   w_data_count = 0;  // Only assigned in the always block
reg [ADDR_WIDTH:0]   r_data_count = 0;
reg [ADDR_WIDTH:0]   wait_cnt = 0;

reg [31:0] w_transfer_byte = 0;
wire wea;

reg [ADDR_WIDTH-1:0] addra; 
reg [DATA_WIDTH-1:0] dina; 
wire [DATA_WIDTH-1:0] douta;
reg finish;

assign wea = !full&&write_en? 'b1: 'b0;

assign full_n = (!full);

assign full = (w_data_count > DEPTH || finish);


//write to BRAM
always@(posedge clk)begin
    if(!rst_n)begin
        w_data_count <= 0;
        w_transfer_byte <= 0;
        r_data_count <= 0;
    end else begin
        if(finish && w_data_count == r_data_count)begin
            w_data_count <= 0;
        end else if (write_en && !full)begin
            w_data_count <= w_data_count + 'b1;
        end
        
        if(finish && w_data_count == r_data_count)begin
            w_transfer_byte <= 0;
        end else if (write_en && !full)begin
            w_transfer_byte <= w_transfer_byte + 1;
        end  
        //define read_en state
        if(full && r_data_count == w_data_count)begin
            r_data_count <= 0;
        end else if(full && read_en)begin
            r_data_count <= r_data_count + 1;
        end
    end
end


always@(*)begin
    finish = (transfer_byte != 0) && ((transfer_byte >> 3) == w_transfer_byte);
    if(write_en && !full) begin
        addra = w_data_count;
        dina = din;
        dout = 0;
    end else if(read_en && full)begin
        dina = 0;
        addra = r_data_count;
        dout = douta;
    end else begin
        if(write_en)addra = w_data_count;
        else addra = r_data_count;
        dout = douta;
        dina = din;
    end
end

    true_sync_dpbram  #(
    .DWIDTH (64),
    .MEM_SIZE (320)
    )
    BRAM_bias(
    .clk(clk),
    .addr(addra),
    .ce('b1),
    .we(wea),
    .dout(douta),
    .din(dina)
    );

endmodule
