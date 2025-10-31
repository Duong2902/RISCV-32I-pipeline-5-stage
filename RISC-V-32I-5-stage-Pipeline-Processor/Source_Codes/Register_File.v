module Register_File (
    input             clk,
    input             rst_n,
    input      [4:0]  A1,
    input      [4:0]  A2,
    input      [4:0]  RdW,
    input      [31:0] ResultW,
    input             RegWriteW,
    output  [31:0] RD1,
    output  [31:0] RD2
);
    reg [31:0] Registers[31:0];
    assign RD1 = (A1 == 0) ? 32'd0: (RegWriteW && RdW == A1)? ResultW:Registers[A1];
    assign RD2 = (A2 == 0) ? 32'd0: (RegWriteW && RdW == A2)? ResultW:Registers[A2];
    
    //INIT FOR SIMULATION
    // `ifndef SYNTHESIS
    //     integer k;
    //     initial begin
    //         for (k = 0; k < 32; k = k + 1) Registers[k] = 32'd0;
    //     end
    // `endif

    always @(posedge clk) begin
        if (RegWriteW && (|RdW)) begin    //|RdW, avoid writing at x0
            Registers[RdW] <= ResultW;
        end
    end
    
endmodule