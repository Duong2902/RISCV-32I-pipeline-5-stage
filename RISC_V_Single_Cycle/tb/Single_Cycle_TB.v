`timescale 1ns / 1ps

module Single_Cycle_TB();

reg clk ,rst_n;
wire [31:0] WriteData, DataAddr;
wire MemWrite;
integer i;

always #10 clk = ~clk;

Single_Cycle_Top DUT(
	.clk(clk),
	.rst_n(rst_n),
	.WriteData(WriteData),
	.DataAddr(DataAddr),
	.MemWrite(MemWrite)
);

initial begin
    clk = 0;
    #20 rst_n = 0; 
    #20 rst_n = 1; 
    for (i=0;i<200;i=i+1) begin
      @(posedge clk);
    end
    $stop;
end


// always@(posedge clk)  begin
//     // if(MemWrite) begin
//     //   if(DataAddr == 100 & WriteData == 25) begin
//     //     $display("PASSED: Data 18 written when Data Address is 8");
//     //     $stop;
//     //   end else if (DataAddr != 96) begin
//     //     $display("FAILED");
//     //    $stop;
//     //   end
//     // end 
// end

endmodule