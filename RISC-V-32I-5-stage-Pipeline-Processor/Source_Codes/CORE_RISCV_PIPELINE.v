module riscv_core (
    input         clk,rst_n,
    input  [31:0] instr, //instr
    input  [31:0] ReadData, // ReadData
    output [31:0] PCF, // PCF
    output        MemWriteM,    // MemWriteM
    output [31:0] ALUResultM, //ALUResultM
    output [31:0] WriteDataM, //WriteDataM
    output [2:0]  funct3M
);
    wire       MemWriteD, ALUSrcD, RegWriteD,BranchD,JumpD;
    wire [1:0] ResultSrcD;
    wire [2:0] ImmSrcD;
    wire [3:0] ALUControlD;
    wire       StallF,StallD,FlushE,FlushD;
    wire [1:0] ForwardAE,ForwardBE;
    wire [4:0] Rs1E,Rs2E, RdM,RdW,Rs1D,Rs2D,RdE;
    wire [1:0] ResultSrcE;
    wire       RegWriteM, RegWriteW, PCSrcE;
    wire [31:0]instrD;
    Controller Controller_i (.OP(instrD[6:0]),
                             .funct3(instrD[14:12]),
                             .funct7b5(instrD[30]),
                             .MemWriteD(MemWriteD),
                             .ALUSrcD(ALUSrcD),
                             .RegWriteD(RegWriteD),
                             .BranchD(BranchD),
                             .JumpD(JumpD),
                             .ResultSrcD(ResultSrcD),
                             .ALUControlD(ALUControlD),
                             .ImmSrcD(ImmSrcD));
    
    datapath datapath_i (.clk(clk),
                         .rst_n(rst_n),
                         .instr(instr),
                         .MemWriteD(MemWriteD),
                         .ALUSrcD(ALUSrcD),
                         .RegWriteD(RegWriteD),
                         .BranchD(BranchD),
                         .JumpD(JumpD),
                         .ResultSrcD(ResultSrcD),
                         .ALUControlD(ALUControlD),
                         .ImmSrcD(ImmSrcD),
                         .ReadData(ReadData),
                         .StallF(StallF),
                         .StallD(StallD),
                         .FlushE(FlushE),
                         .FlushD(FlushD),
                         .ForwardAE(ForwardAE),
                         .ForwardBE(ForwardBE), 
                         .MemWriteM(MemWriteM),
                         .PCF(PCF),
                         .Rs1E(Rs1E),
                         .Rs2E(Rs2E),
                         .RdM(RdM),
                         .RdW(RdW),
                         .Rs1D(Rs1D),
                         .Rs2D(Rs2D),
                         .RdE(RdE),
                         .ResultSrcE(ResultSrcE),
                         .RegWriteM(RegWriteM),
                         .RegWriteW(RegWriteW),
                         .PCSrcE(PCSrcE),
                         .ALUResultM(ALUResultM),
                         .WriteDataM(WriteDataM),
                         .instrD(instrD),
                         .funct3M(funct3M));
                    
    hazard_unit hazard_unit_i ( .Rs1E(Rs1E),
                                .Rs2E(Rs2E),
                                .RdM(RdM),
                                .RdW(RdW),
                                .Rs1D(Rs1D),
                                .Rs2D(Rs2D),
                                .RdE(RdE),
                                .ResultSrcE(ResultSrcE),
                                .RegWriteM(RegWriteM),
                                .RegWriteW(RegWriteW),
                                .PCSrcE(PCSrcE),
                                .StallF(StallF),
                                .StallD(StallD),
                                .FlushE(FlushE),
                                .FlushD(FlushD),
                                .ForwardAE(ForwardAE),
                                .ForwardBE(ForwardBE));
endmodule