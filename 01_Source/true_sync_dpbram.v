`timescale 1ns / 1ps

module true_sync_dpbram #(
parameter DWIDTH = 64,
parameter MEM_SIZE = 2048
)(
    input clk,
    input [clogb2(MEM_SIZE-1)-1:0] addr,
    input ce,
    input we,
    output reg[DWIDTH-1:0] dout,
    input[DWIDTH-1:0] din
);

(* ram_style = "block" *)reg [DWIDTH-1:0] ram[0:MEM_SIZE-1];

always @(posedge clk)  
begin 
    if (ce) begin
        if (we) 
            ram[addr] <= din;
		else
        	dout <= ram[addr];
    end
end

function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule