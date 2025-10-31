module Instruction_Memory (
    input      [31:0] A,
    output     [31:0] instr
);
    reg [31:0] instructions_Value [255:0];  //maximum 256 instruction 

    assign instr = instructions_Value[A[31:2]];

    
endmodule