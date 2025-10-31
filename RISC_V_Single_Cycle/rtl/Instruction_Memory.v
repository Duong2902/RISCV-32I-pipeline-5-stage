module Instruction_Memory(
			  input [31:0] 	A,
			  output [31:0] RD
			  );
   reg [31:0] I_MEM_BLOCK[63:0];
   initial
     begin
	$readmemh("C:/Users/user/EDABK/RiscV/RISC_V_Single_Cycle/instructions.txt",I_MEM_BLOCK);
     end
   assign RD = I_MEM_BLOCK[A[31:2]]; 
endmodule
