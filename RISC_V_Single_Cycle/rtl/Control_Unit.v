module Control_Unit(
		    input wire [6:0]  op,
		    input wire [2:0]  funct3,
		    input wire	      funct7b5,  // function 7 is the 5th bit
            input             branch_condition,
		    output wire [1:0] ResultSrc,
		    output wire	      MemWrite, PCSrc, ALUSrc, RegWrite,Jump,
		    output wire [1:0] ImmSrc,
		    output wire [3:0] ALUControl,
			output wire [1:0] ALUop
		    );

   wire	Branch;
   wire [1:0] ALUop_c;
   Main_Decoder Main_Decoder(
  			     .op(op),
			     .ResultSrc(ResultSrc),
			     .MemWrite(MemWrite),
			     .Branch(Branch),
  			     .ALUSrc(ALUSrc),
			     .RegWrite(RegWrite),
  			     .Jump(Jump),
			     .ImmSrc(ImmSrc),
			     .ALUop(ALUop_c) );
   
   ALU_Decoder ALU_Decoder(
  			   .opb5(op[5]),
			   .funct3(funct3),
			   .funct7b5(funct7b5),
			   .ALUOp(ALUop_c),
			   .ALUControl(ALUControl) );
  
   assign PCSrc = Branch & branch_condition | Jump;
   assign ALUop = ALUop_c;
   
endmodule
