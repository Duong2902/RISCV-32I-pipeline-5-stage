module third_register (
    input      [31:0] WriteDataE,
    input      [31:0] ALUResult,
    input      [31:0] PCPlus4E,
    input      [4:0]  RdE,
    input             clk,
    input             rst_n,
    input             RegWriteE,
    input             MemWriteE,
    input      [1:0]  ResultSrcE,
    input      [2:0]  funct3E,
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [31:0] PCPlus4M,
    output reg [4:0]  RdM,
    output reg        RegWriteM,
    output reg        MemWriteM,
    output reg [1:0]  ResultSrcM,
    output reg [2:0]  funct3M
);
    always @(posedge clk) begin
        if (!rst_n) begin
           RegWriteM  <= 0;
           MemWriteM  <= 0;
           ResultSrcM <= 2'b00;
           ALUResultM <= 32'd0;
           WriteDataM <= 32'd0;
           RdM        <= 5'd0;
           PCPlus4M   <= 32'd0;
           funct3M    <= 3'b0;
        end
        else begin
           RegWriteM  <= RegWriteE;
           MemWriteM  <= MemWriteE;
           ResultSrcM <= ResultSrcE;
           ALUResultM <= ALUResult;
           WriteDataM <= WriteDataE;
           RdM        <= RdE;
           PCPlus4M   <= PCPlus4E;
           funct3M    <= funct3E;
        end
    end
    
endmodule