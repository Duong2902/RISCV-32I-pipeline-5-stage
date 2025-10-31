module Data_Memory (
    input             clk,
    input             rst_n,
    input      [31:0] ALUResultM,   
    input      [31:0] WriteDataM,  
    input             MemWriteM,    
    input      [2:0]  funct3M,      

    output     [31:0] ReadData
);
    parameter SB = 3'b000;
    parameter LB = 3'b000;
    parameter SH = 3'b001;
    parameter LH = 3'b001;
    parameter SW = 3'b010;
    parameter LW = 3'b010;
    parameter LBU    = 3'b100;
    parameter LHU    = 3'b101;


    reg [31:0] Data_Mem [0:255];

    wire [1:0] byte_off = ALUResultM[1:0];

    wire [31:0] rword = Data_Mem[ALUResultM[31:2]];

    wire [7:0]  rbyte = (byte_off == 2'b00) ? rword[7:0]   :
                        (byte_off == 2'b01) ? rword[15:8]  :
                        (byte_off == 2'b10) ? rword[23:16] :
                                             rword[31:24];

    wire [15:0] rhalf = (ALUResultM[1] == 1'b0) ? rword[15:0] : rword[31:16];

    reg [31:0] rdata_ext;
    always @(rbyte or rhalf or rword or funct3M) begin
        case (funct3M)
            LB: rdata_ext = {{24{rbyte[7]}},  rbyte};   // LB
            LH: rdata_ext = {{16{rhalf[15]}}, rhalf};   // LH 
            LW: rdata_ext = rword;                      // LW 
            LBU: rdata_ext = {24'b0, rbyte};             // LBU
            LHU: rdata_ext = {16'b0, rhalf};             // LHU
            default: rdata_ext = rword;                     // default safe
        endcase
    end

    assign ReadData = rdata_ext ;

    reg [31:0] wmask;
    reg [31:0] wdata_aligned;

    always @(funct3M or WriteDataM or ALUResultM[1] or byte_off) begin
        wmask         = 32'b0;
        wdata_aligned = 32'b0;

        case (funct3M )
            SW: begin // SW
                wmask         = 32'hFFFF_FFFF;
                wdata_aligned = WriteDataM;
            end
            SH: begin // SH 
                if (ALUResultM[1] == 1'b0) begin
                    wmask         = 32'h0000_FFFF;
                    wdata_aligned = {16'b0, WriteDataM[15:0]};
                end else begin
                    wmask         = 32'hFFFF_0000;
                    wdata_aligned = {WriteDataM[15:0], 16'b0};
                end
            end
            SB: begin // SB
                case (byte_off)
                    2'b00: begin
                        wmask         = 32'h0000_00FF;
                        wdata_aligned = {24'b0, WriteDataM[7:0]};
                    end
                    2'b01: begin
                        wmask         = 32'h0000_FF00;
                        wdata_aligned = {16'b0, WriteDataM[7:0], 8'b0};
                    end
                    2'b10: begin
                        wmask         = 32'h00FF_0000;
                        wdata_aligned = {8'b0, WriteDataM[7:0], 16'b0};
                    end
                    default: begin // 2'b11
                        wmask         = 32'hFF00_0000;
                        wdata_aligned = {WriteDataM[7:0], 24'b0};
                    end
                endcase
            end
            default: begin
                wmask         = 32'b0;
                wdata_aligned = 32'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        if (MemWriteM) begin
            Data_Mem[ALUResultM[31:2]] <= (Data_Mem[ALUResultM[31:2]] & ~wmask) |
                                          (wdata_aligned & wmask);
        end
    end

endmodule
