`timescale 1ns / 1ps

module Pipeline_TB();

localparam integer N          = 5;                 
localparam [31:0] DONE_PC = 32'h00000058;      
localparam integer WATCHDOG_CYCLES = 1_000;       

reg clk ,rst_n;
wire [31:0] WriteDataM, ALUResultM;
wire MemWriteM;
integer i;
integer ok;
integer cyc;
reg [31:0] golden [N-1:0];

always #10 clk = ~clk;

 initial begin
   $readmemh("C:/Users/user/EDABK/digital_design/RiscV/RISC-V-32I-5-stage-Pipeline-Processor/Test_Code_and_Simulation_Result/instruction.txt", DUT.Instr_Memory.instructions_Value);
   $readmemh("C:/Users/user/EDABK/digital_design/RiscV/RISC-V-32I-5-stage-Pipeline-Processor/Test_Code_and_Simulation_Result/Data_mem.txt",DUT.Data_Memory_i.Data_Mem);
   $readmemh("C:/Users/user/EDABK/digital_design/RiscV/RISC-V-32I-5-stage-Pipeline-Processor/Test_Code_and_Simulation_Result/golden_bubble_sort.txt",golden);
 end
top DUT(
	.clk(clk),
	.rst_n(rst_n),
	.WriteDataM(WriteDataM),
	.ALUResultM(ALUResultM),
	.MemWriteM(MemWriteM)
);

initial begin
    clk = 0;
    #20 rst_n = 0; 
    #20 rst_n = 1; 
    // for (i=0;i<100;i=i+1) begin
    //   @(posedge clk);
    // end
    // $stop;
end

//bỏ comment nếu chạy test2,3,4 ; comment nếu chạy test1
// always@(posedge clk)  begin
//     if(MemWriteM) begin
//       if(ALUResultM == 100 & WriteDataM == 25) begin
//         $display("PASSED: Data 25 written when Data Address is 100");
//         $stop;
//       end else if (ALUResultM != 96) begin
//         $display("FAILED");
//        $stop;
//       end
//     end 
// end



initial begin
    cyc = 0;
    wait (rst_n === 1'b1);
    // Đợi CPU chạy tới 'done' hoặc hết watchdog
    while (DUT.PCF !== DONE_PC && cyc < WATCHDOG_CYCLES) begin
      @(posedge clk);
      cyc = cyc + 1;
    end

    if (cyc >= WATCHDOG_CYCLES) begin
      $display("[TB] WATCHDOG TIMEOUT (%0d cycles). PCF=0x%08x", WATCHDOG_CYCLES, DUT.PCF);
      $finish;
    end

    // Cho 3 nhịp để đảm bảo mọi ghi nhớ đã hoàn tất
    repeat (3) @(posedge clk);

    // So sánh mảng kết quả với GOLDEN
    ok = 1;
    for (i = 0; i < N; i = i + 1) begin
      if (DUT.Data_Memory_i.Data_Mem[i] !== golden[i]) begin
        ok = 0;
        $display("Mismatch @[%0d]: got=%0d , expect=%0d ",
                 i, DUT.Data_Memory_i.Data_Mem[i], golden[i]);
      end
    end

    if (ok) $display("PASS Bubble sort ");
    else    $display("FAIL Bubble sort ");

    $finish;
end
endmodule

module tb_R_type;

    reg clk, rst_n;
    wire [31:0] WriteDataM, ALUResultM;
    wire MemWriteM;

    // Instruction memory cho test
    reg [31:0] imem [0:255];

    // DUT
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .WriteDataM(WriteDataM),
        .ALUResultM(ALUResultM),
        .MemWriteM(MemWriteM)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n = 0;
        #15 rst_n = 1;
    end

    // Instruction fetch: gán instr vào imem của CPU
    always @(*) begin
        dut.Instr_Memory.instructions_Value[dut.core_top.PCF[9:2]] = imem[dut.core_top.PCF[9:2]];
    end

    // Load chương trình test
    initial begin
        $readmemh("C:/Users/user/EDABK/digital_design/RiscV/RISC-V-32I-5-stage-Pipeline-Processor/Test_Code_and_Simulation_Result/all_instr.txt",imem);
        // imem[0]  = 32'ha00093;
        // imem[1]  = 32'hffb00113;
        // imem[2]  = 32'h2081b3;
        // imem[3]  = 32'h40208233;
        // imem[4]  = 32'h3092b3;
        // imem[5]  = 32'h32d333;
        // imem[6]  = 32'h403153b3;
        // imem[7]  = 32'h20f433;
        // imem[8]  = 32'h20e4b3;
        // imem[9]  = 32'h20c533;
        // imem[10] = 32'h1125b3;
        // imem[11] = 32'h20b633;
        // imem[12] = 32'h12693;
        // imem[13] = 32'hfff0b713;
        // imem[14] = 32'hfff0c793;
        // imem[15] = 32'h10e813;
        // imem[16] = 32'h70f893;
        // imem[17] = 32'h409913;
        // imem[18] = 32'h495993;
        // imem[19] = 32'h40215a13;
        // imem[20] = 32'h1ab7;
        // imem[21] = 32'h1b17;
        // imem[22] = 32'h102023;
        // imem[23] = 32'h2b83;
        // imem[24] = 32'h101223;
        // imem[25] = 32'h401c03;
        // imem[26] = 32'h405c83;
        // imem[27] = 32'h200423;
        // imem[28] = 32'h800d03;
        // imem[29] = 32'h804d83;
        // imem[30] = 32'he13;
        // imem[31] = 32'h1708463;
        // imem[32] = 32'h1e0e13;
        // imem[33] = 32'h209463;
        // imem[34] = 32'h1e0e13;
        // imem[35] = 32'h114463;
        // imem[36] = 32'h1e0e13;
        // imem[37] = 32'h20d463;
        // imem[38] = 32'h1e0e13;
        // imem[39] = 32'h20e463;
        // imem[40] = 32'h1e0e13;
        // imem[41] = 32'h117463;
        // imem[42] = 32'h1e0e13;
        // imem[43] = 32'h800eef;
        // imem[44] = 32'h1e0e13;
        // imem[45] = 32'hf17;
        // imem[46] = 32'hcf0fe7;
        // imem[47] = 32'h1e0e13;
    end

    // Run and check results
    initial begin
        #15;    // chờ reset
        #2000;  // chạy đủ lâu

        // Arithmetic and logical
        if (dut.core_top.datapath_i.RF.Registers[3] == 32'h5) $display("ADD passed");
        else $display("ADD failed: expected 5, got %h", dut.core_top.datapath_i.RF.Registers[3]);
        
        if (dut.core_top.datapath_i.RF.Registers[4] == 32'hf) $display("SUB passed");
        else $display("SUB failed: expected 15, got %h", dut.core_top.datapath_i.RF.Registers[4]);
        
        if (dut.core_top.datapath_i.RF.Registers[5] == 32'h140) $display("SLL passed");
        else $display("SLL failed: expected 320, got %h", dut.core_top.datapath_i.RF.Registers[5]);
        
        if (dut.core_top.datapath_i.RF.Registers[6] == 32'ha) $display("SRL passed");
        else $display("SRL failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[6]);
        if (dut.core_top.datapath_i.RF.Registers[7] == 32'hffffffff) $display("SRA passed");
        else $display("SRA failed: expected -1, got %h", dut.core_top.datapath_i.RF.Registers[7]);
        
        if (dut.core_top.datapath_i.RF.Registers[8] == 32'ha) $display("AND passed");
        else $display("AND failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[8]);
        
        if (dut.core_top.datapath_i.RF.Registers[9] == 32'hfffffffb) $display("OR passed");
        else $display("OR failed: expected -5, got %h", dut.core_top.datapath_i.RF.Registers[9]);
        
        if (dut.core_top.datapath_i.RF.Registers[10] == 32'hfffffff1) $display("XOR passed");
        else $display("XOR failed: expected -15, got %h", dut.core_top.datapath_i.RF.Registers[10]);
        
        if (dut.core_top.datapath_i.RF.Registers[11] == 32'h1) $display("SLT passed");
        else $display("SLT failed: expected 1, got %h", dut.core_top.datapath_i.RF.Registers[11]);
        
        if (dut.core_top.datapath_i.RF.Registers[12] == 32'h1) $display("SLTU passed");
        else $display("SLTU failed: expected 1, got %h", dut.core_top.datapath_i.RF.Registers[12]);
        
        // Immediate instructions
        if (dut.core_top.datapath_i.RF.Registers[1] == 32'ha) $display("ADDI passed");
        else $display("ADDI failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[1]);
        
        if (dut.core_top.datapath_i.RF.Registers[13] == 32'h1) $display("SLTI passed");
        else $display("SLTI failed: expected 1, got %h", dut.core_top.datapath_i.RF.Registers[13]);
        
        if (dut.core_top.datapath_i.RF.Registers[14] == 32'h1) $display("SLTIU passed");
        else $display("SLTIU failed: expected 1, got %h", dut.core_top.datapath_i.RF.Registers[14]);
        
        if (dut.core_top.datapath_i.RF.Registers[15] == 32'hfffffff5) $display("XORI passed");
        else $display("XORI failed: expected -11, got %h", dut.core_top.datapath_i.RF.Registers[15]);
        
        if (dut.core_top.datapath_i.RF.Registers[16] == 32'hb) $display("ORI passed");
        else $display("ORI failed: expected 11, got %h", dut.core_top.datapath_i.RF.Registers[16]);
        
        if (dut.core_top.datapath_i.RF.Registers[17] == 32'h2) $display("ANDI passed");
        else $display("ANDI failed: expected 2, got %h", dut.core_top.datapath_i.RF.Registers[17]);
        
        if (dut.core_top.datapath_i.RF.Registers[18] == 32'ha0) $display("SLLI passed");
        else $display("SLLI failed: expected 160, got %h", dut.core_top.datapath_i.RF.Registers[18]);
        
        if (dut.core_top.datapath_i.RF.Registers[19] == 32'ha) $display("SRLI passed");
        else $display("SRLI failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[19]);
        
        if (dut.core_top.datapath_i.RF.Registers[20] == 32'hfffffffe) $display("SRAI passed");
        else $display("SRAI failed: expected -2, got %h", dut.core_top.datapath_i.RF.Registers[20]);
        
        // U-type
        if (dut.core_top.datapath_i.RF.Registers[21] == 32'h1000) $display("LUI passed");
        else $display("LUI failed: expected 4096, got %h", dut.core_top.datapath_i.RF.Registers[21]);
        
        if (dut.core_top.datapath_i.RF.Registers[22] == 32'h1054) $display("AUIPC passed");
        else $display("AUIPC failed: expected 4180, got %h", dut.core_top.datapath_i.RF.Registers[22]);
        
        // Load/Store
        if (dut.core_top.datapath_i.RF.Registers[23] == 32'ha) $display("LW/SW passed");
        else $display("LW/SW failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[23]);
        
        if (dut.core_top.datapath_i.RF.Registers[24] == 32'ha) $display("LH/SH passed");
        else $display("LH/SH failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[24]);
        
        if (dut.core_top.datapath_i.RF.Registers[25] == 32'ha) $display("LHU passed");
        else $display("LHU failed: expected 10, got %h", dut.core_top.datapath_i.RF.Registers[25]);
        
        if (dut.core_top.datapath_i.RF.Registers[26] == 32'hfffffffb) $display("LB/SB passed");
        else $display("LB/SB failed: expected -5, got %h", dut.core_top.datapath_i.RF.Registers[26]);
        
        if (dut.core_top.datapath_i.RF.Registers[27] == 32'hfb) $display("LBU passed");
        else $display("LBU failed: expected 251, got %h", dut.core_top.datapath_i.RF.Registers[27]);
        
        // Branches & Jumps
        if (dut.core_top.datapath_i.RF.Registers[28] == 32'h0) 
            $display("All branches (BEQ, BNE, BLT, BGE, BLTU, BGEU) and jumps (JAL, JALR) passed");
        else 
            $display("Branches/Jumps failed: x28 = %h (expected 0)", dut.core_top.datapath_i.RF.Registers[28]);
        
        if (dut.core_top.datapath_i.RF.Registers[29] == 32'hb0) $display("JAL return address passed");
        else $display("JAL return address failed: expected 176, got %h", dut.core_top.datapath_i.RF.Registers[29]);
        
        if (dut.core_top.datapath_i.RF.Registers[31] == 32'hbc) $display("JALR return address passed");
        else $display("JALR return address failed: expected 188, got %h", dut.core_top.datapath_i.RF.Registers[31]);

        $finish;
    end

endmodule