`timescale 1ns / 1ps

module matrix_multiply(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    input reset,execute, clk,
    input [2:0]sel_in,
    input [7:0]input_val,
    input [1:0]sel_out,
    output [16:0]out
    );
    reg [7:0]A[0:1][0:1];
    reg [7:0]B[0:1][0:1];
    reg [16:0]C[0:1][0:1];
    
    integer i,j,k; 
    wire [0:7]D;
    decoder_3x8 select_in (D, sel_in, !execute);
    
    always @(posedge clk, negedge reset)    
    begin
        if(!reset) begin
            {A[0][0],A[0][1],A[1][0],A[1][1]} <= 32'd0;
            {B[0][0],B[0][1],B[1][0],B[1][1]} <= 32'd0;
        end
        else begin
            A[0][0] <= D[0] ? input_val : A[0][0];
            A[0][1] <= D[1] ? input_val : A[0][1];
            A[1][0] <= D[2] ? input_val : A[1][0];
            A[1][1] <= D[3] ? input_val : A[1][1];
            B[0][0] <= D[4] ? input_val : B[0][0];
            B[0][1] <= D[5] ? input_val : B[0][1];
            B[1][0] <= D[6] ? input_val : B[1][0];
            B[1][1] <= D[7] ? input_val : B[1][1];
        end

    end
    always @(*)
        begin
            {C[0][0],C[0][1],C[1][0],C[1][1]} = 68'd0;
            
            for(i=0;i <2;i=i+1)
              for(j=0;j <2;j=j+1)
                for(k=0;k <2;k=k+1)
                C[i][j] = C[i][j] + (A[i][k] * B[k][j]);
               
        end
        
    reg [16:0] out1; 
    always @(*)
    begin case(sel_out)
       2'b00:   out1 <=C[0][0];
       2'b01:   out1 <=C[0][1];
       2'b10:   out1 <=C[1][0];
       2'b11:   out1 <=C[1][1];
       endcase
    end     
    assign out = {17{execute}}&out1;

endmodule

module decoder_3x8(
    output [0:7] D,
    input [2:0] S,
    input en
    );
    
    assign D[0] = !S[2] && !S[1] && !S[0] && en;
    assign D[1] = !S[2] && !S[1] && S[0] && en;
    assign D[2] = !S[2] && S[1] && !S[0] && en;
    assign D[3] = !S[2] && S[1] && S[0] && en;
    assign D[4] = S[2] && !S[1] && !S[0] && en;
    assign D[5] = S[2] && !S[1] && S[0] && en;
    assign D[6] = S[2] && S[1] && !S[0] && en;
    assign D[7] = S[2] && S[1] && S[0] && en;
    
endmodule
`default_nettype wire
