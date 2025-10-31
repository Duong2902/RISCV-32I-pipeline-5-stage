module ALU(
	   input wire signed [31:0]  A,B, 
	   input wire signed [3:0]   ALUControl,
     input wire        [2:0]   funct3,
     input wire        [1:0]   ALUop,
	   output reg 	             branch_condition,
	   output wire signed [31:0] Result );

   reg [31:0]		      ResultReg;
   wire [31:0]		      temp,Sum;
   wire			      V,slt, sltu; //overflow

   assign temp = ALUControl[0] ? ~B:B;
   //Sum is addition of A + B + 0 or
   //Sum is subtraction of A + ~B + 1 <2's complement>
   assign Sum = A + temp + ALUControl[0]; 
   //checks for overflow if result has different sign than operands
   assign V = (ALUControl[0]) ? 
              (~(A[31] ^ B[31]) & (A[31] ^ Sum[31])) : // check for addition 
              ((A[31] ^ B[31]) & (~(A[31] ^ Sum[31]))); // check for subtraction 
   assign slt = (A[31] == B[31]) ? (A < B) : A[31]; // compare bit sign of A and B, if A[31] = 0 -> A not less than B -> slt=0=A[31] 
                                                    // if A[31] = 1 -> A less than B -> slt=1=A[31]
   
   assign sltu = $unsigned(A) < $unsigned(B); 
   

   always@(*)
     case(ALUControl)
       4'b0000: ResultReg <= Sum; //add
       4'b0001: ResultReg <= Sum; //sub
       4'b0010: ResultReg <= A&B; //and
       4'b0011: ResultReg <= A|B; //or
       4'b0100: ResultReg <= A^B; //xor
       
       4'b0101: ResultReg <= {31'b0,slt}; //slt
       4'b0110: ResultReg <= {31'b0,sltu}; // sltu
       4'b0111: ResultReg <= {A[31:12],12'b0}; //lui
       4'b1000: ResultReg <= A + {B[31:12],12'b0}; // AUIPC
       4'b1001: ResultReg <= {B[31:12],12'b0}; // LUI
       
       4'b1010: ResultReg <= A << B; // sll, slli
       4'b1011: ResultReg <= A >>> B; // sra
       4'b1100: ResultReg <= A >> B; // srl
       
       default:  ResultReg <= 'bx;

     endcase

   always @(*) begin
    if (ALUop == 2'b01) begin
      case (funct3)
        3'd0: branch_condition = (ResultReg == 32'd0); 
        3'd1: branch_condition = (ResultReg != 32'd0);
        3'd4: branch_condition = (ResultReg < 32'd0);
        3'd5: branch_condition = (ResultReg >= 32'd0);         
        3'd6: branch_condition = sltu;
        3'd7: branch_condition = !sltu | (ResultReg == 32'd0);
        default: branch_condition = 0;
      endcase
    end
    else branch_condition = 0;
   end
   assign Result = ResultReg;

endmodule
