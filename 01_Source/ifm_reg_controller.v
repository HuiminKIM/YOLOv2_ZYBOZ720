`timescale 1ns / 1ps

module ifm_reg_controller#(
      parameter RAM_WIDTH = 64,                  
      parameter RAM_DEPTH = 11
      )
    (
    input [RAM_WIDTH*12-1:0]        ifm_bram_data,
    input [11:0]                    ifm_bram_full,
    input                           height_ifm_hs, rst_na, clk,
        
    output                          read_en0,
    output                          read_en1,
    output                          read_en2,
    output                          read_en3,
    output                          read_en4,
    output                          read_en5,
    output                          read_en6,
    output                          read_en7,
    output                          read_en8,
    output                          read_en9,
    output                          read_en10,
    output                          read_en11,
                        
    output              [16*44-1:0] temp_out,
    output reg                      temp_buf_valid
    );
    
    
    // reg, wire declaration
    wire [RAM_WIDTH*RAM_DEPTH-1:0]      buf_data [0:2];
    wire                                buf_full [0:2];
    wire                                hs_signal[0:2];
    reg [RAM_WIDTH*RAM_DEPTH-1:0]      temp_out_datap;     //data before turned into 16 bit 44 data.
    wire [11:0]                         read_en_wire;
    
    // ifm_height_hs signal state (total 2 state >> initial state, common state)
    reg  [1:0]     hs_state;
    reg  [1:0]     next_hs_state;
    
    
    // i think hs_signal needs to be stable >> lets make an edge detection signal
    
    
    // wire assignment
    assign hs_signal[0] = (hs_state == 2'b00) & height_ifm_hs;
    assign hs_signal[1] = (hs_state == 2'b01) & height_ifm_hs;
    assign hs_signal[2] = (hs_state == 2'b10) & height_ifm_hs;
    
    // temp_buf_valid assignment
    /*assign temp_buf_valid = (hs_state == 2'b01) ? buf_full[1] :
                            (hs_state == 2'b10) ? buf_full[2] :
                            buf_full[0];*/
    always@(*)begin
        temp_buf_valid = 0;
        case(hs_state)
            0: temp_buf_valid = buf_full[0];
            1: temp_buf_valid = buf_full[1];
            2: temp_buf_valid = buf_full[2];
        endcase
    end
                            
    // temp_out_datap 
    /*assign temp_out_datap = (hs_state == 2'b01) ? buf_data[1] :
                            (hs_state == 2'b10) ? buf_data[2] :
                            buf_data[0];*/
                            
    always@(*)begin
        temp_out_datap = 0;
        case(hs_state)
            0: temp_out_datap = buf_data[0];
            1: temp_out_datap = buf_data[1];
            2: temp_out_datap = buf_data[2];
        endcase
    end                  
    
    assign read_en0 = read_en_wire[0];
    assign read_en1 = read_en_wire[4];
    assign read_en2 = read_en_wire[8];
    assign read_en3 = read_en_wire[1];
    assign read_en4 = read_en_wire[5];
    assign read_en5 = read_en_wire[9];
    assign read_en6 = read_en_wire[2];
    assign read_en7 = read_en_wire[6];
    assign read_en8 = read_en_wire[10];
    assign read_en9 = read_en_wire[3];
    assign read_en10 = read_en_wire[7];
    assign read_en11 = read_en_wire[11];
    

    // temp_out assignment >>> concatenation 
    genvar i;
    generate
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin : temp_out_data
            assign temp_out[(i+1)*RAM_WIDTH-1:i*RAM_WIDTH] = {
                    temp_out_datap[(i+1)*16-1:i*16],
                    temp_out_datap[(i+12)*16-1:(i+11)*16],
                    temp_out_datap[(i+23)*16-1:(i+22)*16],
                    temp_out_datap[(i+34)*16-1:(i+33)*16]
                    };
        end
    endgenerate

    // ifm_reg_buf module instantiation
    
    ifm_reg_buf reg_buf_1 (
        .clk(clk),
        .rst_na(rst_na),
        .height_hs(hs_signal[0]),
        .ifm_bram_data(ifm_bram_data[RAM_WIDTH*4-1:0]),
        .ifm_bram_full(ifm_bram_full[3:0]),
        .read_en(read_en_wire[3:0]),
        .buf_data(buf_data[0]),
        .buf_full(buf_full[0])
    );
    
    ifm_reg_buf reg_buf_2 (
        .clk(clk),
        .rst_na(rst_na),
        .height_hs(hs_signal[1]),
        .ifm_bram_data(ifm_bram_data[RAM_WIDTH*8-1:RAM_WIDTH*4]),
        .ifm_bram_full(ifm_bram_full[7:4]),
        .read_en(read_en_wire[7:4]),
        .buf_data(buf_data[1]),
        .buf_full(buf_full[1])
    );
    
    ifm_reg_buf reg_buf_3 (
        .clk(clk),
        .rst_na(rst_na),
        .height_hs(hs_signal[2]),
        .ifm_bram_data(ifm_bram_data[RAM_WIDTH*12-1:RAM_WIDTH*8]),
        .ifm_bram_full(ifm_bram_full[11:8]),
        .read_en(read_en_wire[11:8]),
        .buf_data(buf_data[2]),
        .buf_full(buf_full[2])
    );
    
                                

    //hs_signal state changes
    always @(posedge clk) begin
        if (!rst_na)
             hs_state <= 2'b00;
        else begin
            hs_state <= next_hs_state;
       end
    end
    
    // state combi
    always @(*)begin
        next_hs_state = hs_state;
        case (hs_state)  
            2'b00:begin   // inital state 
                            if (height_ifm_hs) next_hs_state = 2'b01;
                            else next_hs_state = 2'b00;
               end
            2'b01:begin                           
                            if (height_ifm_hs) next_hs_state = 2'b10;       // second module
                            else next_hs_state = 2'b01;
               end
            2'b10:begin     
                            if (height_ifm_hs) next_hs_state = 2'b00;       // third module
                            else next_hs_state = 2'b10;  
               end 
        endcase  
    end

    
endmodule


