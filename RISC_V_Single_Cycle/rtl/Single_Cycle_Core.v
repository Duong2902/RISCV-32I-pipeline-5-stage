module Single_Cycle_Core(
			 input wire 	    clk,rst_n,
			 input wire [31:0]  Instr,
			 input wire [31:0]  ReadData,
			 output wire [31:0] PC,
			 output wire 	    MemWrite,
			 output wire [31:0] ALUResult ,WriteData
			 );

   wire ALUSrc, RegWrite, Jump, branch_condition, PCSrc;
   wire [1:0] ResultSrc,ImmSrc,ALUop;
   wire [3:0] ALUControl;

   Control_Unit Control(
			.op(Instr[6:0]),
			.funct3(Instr[14:12]),
			.funct7b5(Instr[30]),
			.branch_condition(branch_condition),
			.ResultSrc(ResultSrc),
			.MemWrite(MemWrite),
			.PCSrc(PCSrc),
			.ALUSrc(ALUSrc),
			.RegWrite(RegWrite),
			.ImmSrc(ImmSrc),
			.ALUControl(ALUControl),
			.ALUop(ALUop)

			);

   Core_Datapath Datapath(
			  .clk(clk),
			  .rst_n(rst_n),
			  .ResultSrc(ResultSrc),
			  .PCSrc(PCSrc),
			  .ALUSrc(ALUSrc),
			  .RegWrite(RegWrite),
			  .ImmSrc(ImmSrc),
			  .ALUControl(ALUControl),
			  .Instr(Instr),
			  .ReadData(ReadData),
			  .funct3(Instr[14:12]),
			  .ALUop(ALUop),
			  .branch_condition(branch_condition),
			  .PC(PC),
			  .ALUResult(ALUResult),
			  .WriteData(WriteData)
			  );	

endmodule








