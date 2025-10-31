module datapath (
    input             clk,rst_n,
    input      [31:0] instr,
    input             MemWriteD,
    input             ALUSrcD,
    input             RegWriteD,
    input             BranchD,
    input             JumpD,
    input      [1:0]  ResultSrcD,
    input      [3:0]  ALUControlD,
    input      [2:0]  ImmSrcD,
    input      [31:0] ReadData,
    input             StallF,
    input             StallD,
    input             FlushE,
    input             FlushD,
    input      [1:0]  ForwardAE,
    input      [1:0]  ForwardBE,
    output            MemWriteM,
    output reg [31:0] PCF,
    output     [4:0]  Rs1E,
    output     [4:0]  Rs2E,
    output     [4:0]  RdM,
    output     [4:0]  RdW,
    output     [4:0]  Rs1D,
    output     [4:0]  Rs2D,
    output     [4:0]  RdE,
    output     [1:0]  ResultSrcE,
    output            RegWriteM,
    output            RegWriteW,
    output            PCSrcE,
    output     [31:0] ALUResultM, WriteDataM,
    output     [31:0] instrD,
    output     [2:0]  funct3M

);
    wire [31:0] PCPlus4F,PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
    wire [31:0] PCD, ResultW, RD1, RD2;
    wire        branch_condition;
    wire        RegWriteE,MemWriteE,JumpE,BranchE,ALUSrcE;
    wire [31:0] PCE,ImmExtE, RD1E,RD2E;
    wire [2:0]  funct3E, ImmSrcE;
    wire [31:0] SrcAE,SrcBE,WriteDataE,ALUResult,ALUResultW;
    wire [3:0]  ALUControlE;
    wire [31:0] PCTargetE;
    wire [31:0] ImmExtD;
    wire [1:0]  ResultSrcM;
    wire [31:0] ReadDataW;
    wire [1:0]  ResultSrcW;
    reg  [31:0] ImmExtD_reg;

    assign      PCPlus4F = PCF + 32'd4;
    assign      PCTargetE = ALUSrcE ? (RD1E+ImmExtE):(PCE + ImmExtE);
    assign      ImmExtD = ImmExtD_reg;
    assign      Rs1D = instrD[19:15];
    assign      Rs2D = instrD[24:20];
    assign      SrcAE = ForwardAE[1] ? ALUResultM : (ForwardAE[0] ? ResultW : ((ImmSrcE == 3'b100)?PCE: RD1E));
    assign      WriteDataE = ForwardBE[1] ? ALUResultM : (ForwardBE[0] ? ResultW : RD2E);
    assign      SrcBE = ALUSrcE ?  ImmExtE:WriteDataE;

    always @(posedge clk) begin 
        if (!rst_n) begin
            PCF <= 32'd0;
        end

        else if(StallF) begin
             PCF <= PCF;   
        end

        else begin
            PCF <= PCSrcE ? PCTargetE : PCPlus4F;
        end
    end 

    first_register first_register_i (.clk(clk),
                                     .rst_n(rst_n),
                                     .StallD(StallD),
                                     .FlushD(FlushD),
                                     .instr(instr),
                                     .PCF(PCF),
                                     .PCPlus4F(PCPlus4F),
                                     .instrD(instrD),
                                     .PCD(PCD),
                                     .PCPlus4D(PCPlus4D)
                                     );

    //sign_extend
    always@(ImmSrcD or instrD) begin
      case(ImmSrcD)
        
        3'b000: ImmExtD_reg = {{20{instrD[31]}},instrD[31:20]};//I-type
        
        3'b001: ImmExtD_reg = {{20{instrD[31]}},instrD[31:25],instrD[11:7]};//S-type(stores)
        
        3'b010: ImmExtD_reg = {{20{instrD[31]}},instrD[7],instrD[30:25],instrD[11:8],1'b0};//B-type(branches)
        
        3'b011: ImmExtD_reg = {{12{instrD[31]}},instrD[19:12],instrD[20],instrD[30:21],1'b0};//J-type

        3'b100: ImmExtD_reg = {{12{instrD[31]}},instrD[31:12]};//U-type

        default: ImmExtD_reg = 32'bx; //undefined
      endcase
	end
    
    //Register File
    Register_File RF (.clk(clk),
                      .rst_n(rst_n),
                      .A1(instrD[19:15]),
                      .A2(instrD[24:20]),
                      .RdW(RdW),
                      .ResultW(ResultW),
                      .RegWriteW(RegWriteW),
                      .RD1(RD1),
                      .RD2(RD2)
                      );

    //second register
    Second_register Second_register_i (.PCD(PCD),
                                       .ImmExtD(ImmExtD),
                                       .PCPlus4D(PCPlus4D),
                                       .RD1(RD1),
                                       .RD2(RD2),
                                       .RdD(instrD[11:7]),
                                       .Rs1D(Rs1D),
                                       .Rs2D(Rs2D),
                                       .funct3(instrD[14:12]),
                                       .rst_n(rst_n),
                                       .clk(clk),
                                       .RegWriteD(RegWriteD),
                                       .MemWriteD(MemWriteD),
                                       .JumpD(JumpD),
                                       .BranchD(BranchD),
                                       .ALUSrcD(ALUSrcD),
                                       .branch_condition(branch_condition),
                                       .FlushE(FlushE),
                                       .ResultSrcD(ResultSrcD),
                                       .ALUControlD(ALUControlD),
                                       .ImmSrcD(ImmSrcD),
                                       .RegWriteE(RegWriteE),
                                       .MemWriteE(MemWriteE),
                                       .JumpE(JumpE),
                                       .BranchE(BranchE),
                                       .ALUSrcE(ALUSrcE),
                                       .PCSrcE(PCSrcE),
                                       .ResultSrcE(ResultSrcE),
                                       .ALUControlE(ALUControlE),
                                       .PCE(PCE),
                                       .ImmExtE(ImmExtE),
                                       .PCPlus4E(PCPlus4E),
                                       .RD1E(RD1E),
                                       .RD2E(RD2E),
                                       .funct3E(funct3E),
                                       .RdE(RdE),
                                       .Rs1E(Rs1E),
                                       .Rs2E(Rs2E),
                                       .ImmSrcE(ImmSrcE)
                                       );

    
    alu alu_i (.SrcAE(SrcAE),
               .SrcBE(SrcBE),
               .ALUControlE(ALUControlE),
               .funct3E(funct3E),
               .BranchE(BranchE),
               .ALUResult(ALUResult),
               .branch_condition(branch_condition)
               );
    
    //Third register
    third_register third_register_i (.WriteDataE(WriteDataE),
                                     .ALUResult(ALUResult),
                                     .PCPlus4E(PCPlus4E),
                                     .RdE(RdE),
                                     .clk(clk),
                                     .rst_n(rst_n),
                                     .RegWriteE(RegWriteE),
                                     .MemWriteE(MemWriteE),
                                     .ResultSrcE(ResultSrcE),
                                     .funct3E(funct3E),
                                     .ALUResultM(ALUResultM),
                                     .WriteDataM(WriteDataM),
                                     .PCPlus4M(PCPlus4M),
                                     .RdM(RdM),
                                     .RegWriteM(RegWriteM),
                                     .MemWriteM(MemWriteM),
                                     .ResultSrcM(ResultSrcM),
                                     .funct3M(funct3M)
                                     );
    //4th register
    fourth_register fourth_register_i (.ALUResultM(ALUResultM),
                                       .ReadData(ReadData),
                                       .PCPlus4M(PCPlus4M),
                                       .RdM(RdM),
                                       .rst_n(rst_n),
                                       .clk(clk),
                                       .RegWriteM(RegWriteM),
                                       .ResultSrcM(ResultSrcM),
                                       .ALUResultW(ALUResultW),
                                       .ReadDataW(ReadDataW),
                                       .PCPlus4W(PCPlus4W),
                                       .RdW(RdW),
                                       .ResultSrcW(ResultSrcW),
                                       .RegWriteW(RegWriteW)
                                       );

     assign ResultW = ResultSrcW[1] ? PCPlus4W : (ResultSrcW[0] ? ReadDataW : ALUResultW);

endmodule