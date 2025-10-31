module top (
    input clk,rst_n,
    output [31:0] WriteDataM,ALUResultM,
    output 	      MemWriteM
);
    wire [31:0] 	 PCF, instr, ReadData;
	wire [2:0]       funct3M;
    riscv_core core_top (
			       .clk(clk),
			       .rst_n(rst_n),
			       .instr(instr),
			       .ReadData(ReadData),
			       .PCF(PCF),   
			       .MemWriteM(MemWriteM),
			       .ALUResultM(ALUResultM),
			       .WriteDataM(WriteDataM),
				   .funct3M(funct3M) );
    
    Instruction_Memory Instr_Memory ( 
				     .A(PCF),
				     .instr(instr) );
    Data_Memory Data_Memory_i (
			    .clk(clk), 
                .rst_n(rst_n),
			    .MemWriteM(MemWriteM),
			    .ALUResultM(ALUResultM), 
			    .WriteDataM(WriteDataM),
				.funct3M(funct3M),
			    .ReadData(ReadData) );
endmodule