module Core_Datapath(                                            
		     input	   clk,rst_n,
		     input [1:0]   ResultSrc,
		     input	   PCSrc,ALUSrc,
		     input	   RegWrite,
		     input [1:0]   ImmSrc,
		     input [3:0]   ALUControl,
		     input [31:0]  Instr,
		     input [31:0]  ReadData,
			 input [2:0]   funct3,
             input [1:0]   ALUop,
		     output        branch_condition,
		     output [31:0] PC,
		     output [31:0] ALUResult,WriteData
		     );

    wire [31:0]			   PCnext,PCplus4,PCtarget;
    wire [31:0]			   ImmExt;
    wire [31:0]			   SrcA,SrcB;
    wire [31:0]			   Result;
    reg  [31:0] 		   PCReg;
    reg  [31:0]            ImmExtReg;

ALU ALU_inst(
		.A(SrcA),
		.B(SrcB),
		.ALUControl(ALUControl),
		.funct3 (funct3),
		.ALUop (ALUop),
		.branch_condition(branch_condition),
		.Result(ALUResult)
		);
Register_File Register_inst(
			       .clk(clk),
			       .WE3(RegWrite),
			       .RA1(Instr[19:15]),
			       .RA2(Instr[24:20]),
			       .WA3((Instr[11:7])),
			       .WD3(Result),
			       .RD1(SrcA),
			       .RD2(WriteData)
			       );

    always@(posedge clk or negedge rst_n) begin
	if (!rst_n) PCReg <= 0;
	else PCReg <= PCnext;
    end	

    assign PC = PCReg;
	assign PCplus4 = PC + 32'd4;
	assign PCtarget= PC + ImmExt;
    assign PCnext = PCSrc ? PCtarget : PCplus4;

    always@(ImmSrc or Instr) begin
      case(ImmSrc)
        //I-type
        2'b00: ImmExtReg = {{20{Instr[31]}},Instr[31:20]};
        //S-type(stores)
        2'b01: ImmExtReg = {{20{Instr[31]}},Instr[31:25],Instr[11:7]};
        //B-type(branches)
        2'b10: ImmExtReg = {{20{Instr[31]}},Instr[7],Instr[30:25],Instr[11:8],1'b0};
        //J-type(jal)
        2'b11: ImmExtReg = {{12{Instr[31]}},Instr[19:12],Instr[20],Instr[30:21],1'b0};
        default: ImmExtReg = 32'bx; //undefined
      endcase
	end

    assign ImmExt = ImmExtReg;
	assign SrcB = ALUSrc ? ImmExt : WriteData;
    assign Result = ResultSrc[1] ? PCplus4 :(ResultSrc[0] ? ReadData : ALUResult);

endmodule


