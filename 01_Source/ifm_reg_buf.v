`timescale 1ns / 1ps

module ifm_buffer
    #(
      parameter RAM_WIDTH = 64,                  
      parameter RAM_DEPTH = 11
      )
    (
        input [RAM_WIDTH-1:0]        ifm_bram_data,
        input               ifm_bram_full,
        input               hs_signal, rst_na, clk,
        
        output              read_en,        // turn to 1 when idle state >> can receive data from bram
        output              data_valid,       // buf_full path
        output              [RAM_WIDTH*RAM_DEPTH-1:0]  data_out    // export data at once..
        //output [15:0]temp_data0
    );
    

    
    wire reg_full;
    
    // state
    localparam S0 = 2'b00;       // idle
    localparam S1 = 2'b01;       // read state
    localparam S2 = 2'b10;       // write state
    
    reg    [clogb2(RAM_DEPTH-1)-1:0]     addra;                  // Port A address bus, width determined from RAM_DEPTH
    wire                                 wea;                    // Port A write enable
    //wire                                 ena;                    // Port A enable
    
            
    reg [1:0]   state, nextstate;
    reg [63:0]  bram_data;              // for latency.
    //wire [RAM_WIDTH*RAM_DEPTH-1:0]       data_out; // 
    
    
    // data_wire assignment
    assign read_en = ((state == S0) | (ifm_bram_full));     // idle state >> can load data from bram memory 
    //assign ena = (state == S1 | state == S2);               // 16bit memory control
    assign wea = (state == S1);                             // 16bit memory control when write data to memory.
    
    
    // state declaration & data latency & address control
    always @(posedge clk)
    begin
        if (!rst_na) begin
            state <= S0;
            addra <= 0;
            bram_data <= 0;
        end else begin
            state <= nextstate;
            bram_data <= ifm_bram_data;
            if (state == S1) begin // when read or write step. + address count
                addra <= addra + 1;
            end else begin
                if(hs_signal) addra <= 0;
            end
        end
    end
    
    assign reg_full = (addra !=0) && !ifm_bram_full;
    
    // state case 
    always @(*)begin
        nextstate = state;
        case (state)  
            S0: begin
                    if (ifm_bram_full)  nextstate = S1;  // idle >> when full signal comes, read start.
                   //else nextstate = S0;
               end
            S1: begin    // read data from bram 
                    if (reg_full)  nextstate = S2;   // if bram data end, just change state.
                    //else nextstate = S1;
               end
            S2: begin    
                    if (hs_signal) nextstate = S0; // hs_signal when S2 >> data transfer end so change wire
                    //else nextstate = S2;     // write, data flows at 1 cycle so no other condition is needed.
               end
            /*default:    begin
                        nextstate = S0;
                        end*/
        endcase  
    end
    
    // reg_full maintain values until data pass end.
    wire [175:0] data_out0;
    wire [175:0] data_out1;
    wire [175:0] data_out2;
    wire [175:0] data_out3;
    
    assign data_out = { 
                        data_out3[175:160],data_out2[175:160],data_out1[175:160],data_out0[175:160],
                        data_out3[159:144],data_out2[159:144],data_out1[159:144],data_out0[159:144],
                        data_out3[143:128],data_out2[143:128],data_out1[143:128],data_out0[143:128],
                        data_out3[127:112],data_out2[127:112],data_out1[127:112],data_out0[127:112],
                        data_out3[111:96],data_out2[111:96],data_out1[111:96],data_out0[111:96],
                        data_out3[95:80],data_out2[95:80],data_out1[95:80],data_out0[95:80],
                        data_out3[79:64],data_out2[79:64],data_out1[79:64],data_out0[79:64],
                        data_out3[63:48],data_out2[63:48],data_out1[63:48],data_out0[63:48],
                        data_out3[47:32],data_out2[47:32],data_out1[47:32],data_out0[47:32],
                        data_out3[31:16],data_out2[31:16],data_out1[31:16],data_out0[31:16],
                        data_out3[15:0],data_out2[15:0],data_out1[15:0],data_out0[15:0]};

    assign data_valid = (state == 2);

     
    bram_instance memory0(
    .addra(addra),
    .clka(clk),
    .wea(wea),
    .rst_na(rst_na),
    .dina(bram_data[15:0]),
    .douta(data_out0)
    );
    
    bram_instance memory1(
    .addra(addra),
    .clka(clk),
    .wea(wea),
    .rst_na(rst_na),
    .dina(bram_data[31:16]),
    .douta(data_out1)
    );
    
    bram_instance memory2(
    .addra(addra),
    .clka(clk),
    .wea(wea),
    .rst_na(rst_na),
    .dina(bram_data[47:32]),
    .douta(data_out2)
    );
    
    bram_instance memory3(
    .addra(addra),
    .clka(clk),
    .wea(wea),
    .rst_na(rst_na),
    .dina(bram_data[63:48]),
    .douta(data_out3)
    );
    
      //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction    


endmodule