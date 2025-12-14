`timescale 1ns / 1ps

module bram_instance #(
  parameter RAM_WIDTH = 16,                  // Specify RAM data width
  parameter RAM_DEPTH = 11                  // Specify RAM depth (number of entries)
)
(
  input [clogb2(RAM_DEPTH-1)-1:0]   addra,   // Port A address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0]             dina,    // Port A RAM input data
  input                             clka,    // Clock
  input                             wea,     // Port A write enable
  input                             rst_na,  // Port A output reset (does not affect memory contents)
  
  output [RAM_WIDTH*RAM_DEPTH-1:0]  douta    // All data output in a single cycle
);

  // Define the memory array
  reg [RAM_WIDTH*RAM_DEPTH-1:0] bram_memory;

  
  always @(posedge clka) begin
    if (!rst_na) begin
        bram_memory <= 'b0;
    end else begin
        if (wea) begin
            case(addra)
                0: bram_memory[15:0] <= dina;
                1: bram_memory[31:16] <= dina;
                2: bram_memory[47:32] <= dina;
                3: bram_memory[63:48] <= dina;
                4: bram_memory[79:64] <= dina;
                5: bram_memory[95:80] <= dina;
                6: bram_memory[111:96] <= dina;
                7: bram_memory[127:112] <= dina;
                8: bram_memory[143:128] <= dina;
                9: bram_memory[159:144] <= dina;
                10: bram_memory[175:160] <= dina;
            endcase
        end 
    end
  end

  assign douta = bram_memory;

  // Function to calculate the address width
  function integer clogb2;
    input integer depth;
      for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
        depth = depth >> 1;
  endfunction

endmodule