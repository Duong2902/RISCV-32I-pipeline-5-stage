module first_register (
    input             clk,
    input             rst_n,
    input             StallD,
    input             FlushD,
    input      [31:0] instr,
    input      [31:0] PCF,
    input      [31:0] PCPlus4F,
    output reg [31:0] instrD, 
    output reg [31:0] PCD,
    output reg [31:0] PCPlus4D
);
    always @(posedge clk) begin
        if (!rst_n) begin
            instrD    <= 32'd0;
            PCD      <= 32'd0;
            PCPlus4D <= 32'd0;
        end
        else if (StallD) begin
            instrD   <= instrD;
            PCD      <= PCD;
            PCPlus4D <= PCPlus4D;
        end
        else if (FlushD) begin
            instrD   <= 32'd0;
            PCD      <= 32'd0;
            PCPlus4D <= 32'd0;
        end
        else begin
            instrD   <= instr;
            PCD      <= PCF;
            PCPlus4D <= PCPlus4F;
        end
        
    end
    
endmodule