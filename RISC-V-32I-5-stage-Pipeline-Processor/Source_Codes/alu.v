module alu(

    input signed      [31:0] SrcAE,SrcBE,             // ALU 32-bit Inputs
    input             [3:0]  ALUControlE,             // ALU Selection
    input             [2:0]  funct3E,
    input                    BranchE,
    output signed [31:0]     ALUResult,               // ALU 32-bit Output
    output reg               branch_condition         // branch condition

);
   parameter beq = 3'b000;
   parameter bne = 3'b001;
   parameter blt = 3'b100;
   parameter bge = 3'b101;
   parameter bltu = 3'b110;
   parameter bgeu = 3'b111;
   reg [31:0]		  ResultReg;
   wire [31:0]		temp,Sum;
   wire			      V,slt, sltu;

   assign temp = ALUControlE[0] ? ~SrcBE:SrcBE;
   //Sum is addition of SrcAE + SrcBE + 0 or
   //Sum is subtraction of SrcAE + ~SrcBE + 1 <2's complement>
   assign Sum = SrcAE + temp + ALUControlE[0]; 
   //checks for overflow if result has different sign than operands
  //  assign V = (ALUControlE[0]) ? 
  //             (~(SrcAE[31] ^ SrcBE[31]) & (SrcAE[31] ^ Sum[31])) : // check for addition 
  //             ((SrcAE[31] ^ SrcBE[31]) & (~(SrcAE[31] ^ Sum[31]))); // check for subtraction 
   assign slt = (SrcAE[31] == SrcBE[31]) ? (SrcAE < SrcBE) : SrcAE[31]; // compare bit sign of SrcAE and SrcBE, if SrcAE[31] = 0 -> SrcAE not less than SrcBE -> slt=0=SrcAE[31] 
                                                    // if SrcAE[31] = 1 -> SrcAE less thSrcAEn SrcBE -> slt=1=A[31]
   
   assign sltu = $unsigned(SrcAE) < $unsigned(SrcBE); 
   

   always@(*)
     case(ALUControlE)
       4'b0000: ResultReg <= Sum; //add
       4'b0001: ResultReg <= Sum; //sub
       4'b0010: ResultReg <= SrcAE&SrcBE; //and
       4'b0011: ResultReg <= SrcAE|SrcBE; //or
       4'b0100: ResultReg <= SrcAE^SrcBE; //xor
       
       4'b0101: ResultReg <= {31'b0,slt}; //slt
       4'b0110: ResultReg <= {31'b0,sltu}; // sltu
       4'b1000: ResultReg <= SrcAE + (SrcBE <<12); // AUIPC
       4'b1001: ResultReg <= SrcBE <<12; // LUI
       
       4'b1010: ResultReg <= SrcAE << SrcBE[4:0]; // sll, slli
       4'b1011: ResultReg <= SrcAE >>> SrcBE[4:0]; // sra
       4'b1100: ResultReg <= SrcAE >> SrcBE[4:0]; // srl
       
       default:  ResultReg <= 32'bx;

     endcase

   always @(*) begin
    if (BranchE == 1'b1) begin
      case (funct3E)
        beq: branch_condition = (SrcAE == SrcBE); 
        bne: branch_condition = (SrcAE != SrcBE);
        blt: branch_condition = (SrcAE < SrcBE);
        bge: branch_condition = (SrcAE >= SrcBE);         
        bltu: branch_condition = sltu;
        bgeu: branch_condition = !sltu;
        default: branch_condition = 0;
      endcase
    end
    else branch_condition = 0;
   end
   
  assign ALUResult = ResultReg;
    
endmodule
