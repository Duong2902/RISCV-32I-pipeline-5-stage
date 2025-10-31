module Data_Memory(
		   input wire 	      clk, WE,
		   input wire [31:0]  A, WD,
		   output wire [31:0] RD
		   );

   reg [31:0] RAM[63:0];

   assign RD = RAM[A[31:2]]; // divide by 4 to take index RAM


initial begin
   RAM[0]  = 32'h00000005;
   RAM[1]  = 32'h00000001; 
   RAM[2]  = 32'h00000004; 
   RAM[3] =  32'h00000002;
   RAM[4] =  32'h00000008;
end


   always @(posedge clk)
     if (WE)
       RAM[A[31:2]] <= WD;

endmodule
