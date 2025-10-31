module Controller (
    input      [6:0] OP,
    input      [2:0] funct3,
    input            funct7b5,
    output           MemWriteD,
    output           ALUSrcD,
    output           RegWriteD,
    output           BranchD,
    output           JumpD,
    output     [1:0] ResultSrcD,
    output reg [3:0] ALUControlD,
    output     [2:0] ImmSrcD
);
    parameter op_LW_SW   = 2'b00 ;
    parameter op_Btype   = 2'b01 ;
    parameter op_R_Itype = 2'b10 ;
    parameter op_Utype   = 2'b11 ;

    reg [11:0] control_signals;
    wire [1:0]   ALUOP;
    always @ (OP) begin
        case (OP)
            7'b0000011: control_signals = 12'b1_000_1_0_01_0_00_0;//lw 

            7'b0100011: control_signals = 12'b0_001_1_1_00_0_00_0;//sw

            7'b0110011: control_signals = 12'b1_000_0_0_00_0_10_0;//R-type

            7'b1100011: control_signals = 12'b0_010_0_0_00_1_01_0;//B-type Branch

            7'b0010011: control_signals = 12'b1_000_1_0_00_0_10_0;//I-type

            7'b1101111: control_signals = 12'b1_011_0_0_10_0_00_1;//jal
            7'b1100111: control_signals = 12'b1_000_1_0_10_0_00_1;//jalr

            7'b0110111: control_signals = 12'b1_100_1_0_00_0_11_0;//U-type lui
            7'b0010111: control_signals = 12'b1_100_1_0_00_0_11_0;//U-type auipc

            7'b0000000: control_signals = 12'b0_000_0_0_00_0_00_0;//reset conditionm

            default: control_signals = 12'bx_xxx_x_x_xx_x_xx_x;

        endcase
        
    end
    assign {RegWriteD,ImmSrcD,ALUSrcD,MemWriteD,
	   ResultSrcD,BranchD,ALUOP,JumpD} = control_signals;
    
    wire RtypeSub = funct7b5 & OP[5]; //TRUE for R-type substract

    always@(ALUOP or funct3 or RtypeSub or funct7b5 or OP) begin
	    case(ALUOP)
          op_LW_SW:  ALUControlD = 4'b0000; //addition -> load/store
          op_Btype:  ALUControlD = 4'b0001; //subtraction -> xác định điều kiện nhảy
          op_R_Itype:  
            case(funct3)//R-type or I-type ALU
                3'b000:    
                    if (RtypeSub) ALUControlD = 4'b0001; //sub
                    else ALUControlD = 4'b0000; //add,addi
                3'b001: ALUControlD = 4'b1010; // sll, slli;
                3'b010: ALUControlD = 4'b0101; //slt,slti
                3'b011: ALUControlD = 4'b0110; //sltu, sltiu
                3'b100: ALUControlD = 4'b0100; //xor
                3'b101: 
                    if (funct7b5) ALUControlD = 4'b1011; //sra
                    else ALUControlD = 4'b1100; // srl
                
                3'b110: ALUControlD = 4'b0011; //or,ori
                3'b111: ALUControlD = 4'b0010; //and,andi
                default: ALUControlD = 4'bxxx; 
                endcase
            op_Utype: //ALUOp = 2'b11 -> U-type
                case(OP[5])
                1'b0: ALUControlD = 4'b1000; // AUIPC
                1'b1: ALUControlD = 4'b1001; // LUI  
                default: ALUControlD = 4'bxxxx;
                endcase
            default: ALUControlD = 4'bxxxx;
          
	    endcase
     end
endmodule