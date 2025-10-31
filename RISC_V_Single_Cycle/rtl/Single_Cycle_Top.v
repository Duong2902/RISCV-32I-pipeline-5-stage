
module Single_Cycle_Top(
			input 	      clk,rst_n,
			output [31:0] WriteData,DataAddr,
			output 	      MemWrite );

   wire [31:0] 	 PC, Instr, ReadData;

   Single_Cycle_Core core_top (
			       .clk(clk),
			       .rst_n(rst_n),
			       .Instr(Instr),
			       .ReadData(ReadData),
			       .PC(PC),
			       .MemWrite(MemWrite),
			       .ALUResult(DataAddr),
			       .WriteData(WriteData) );

   Instruction_Memory Instr_Memory ( 
				     .A(PC),
				     .RD(Instr) );

   Data_Memory Data_Memory (
			    .clk(clk), 
			    .WE(MemWrite),
			    .A(DataAddr), 
			    .WD(WriteData),
			    .RD(ReadData) );

endmodule
