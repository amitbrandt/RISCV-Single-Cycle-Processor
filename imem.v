`timescale 1ns / 1ps

module imem (
    input  wire [31:0] A,
    output wire [31:0] RD
);

    // --- Memory Array ---
    reg [31:0] RAM [63:0];
  
    integer i;
    initial begin
        // Initialize memory with NOPs (addi x0, x0, 0)
        for (i = 0; i < 64; i = i + 1) begin
            RAM[i] = 32'h00000013; 
        end

        // Test instructions
        RAM[0] = 32'h00a00093; // addi x1, x0, 10
        RAM[1] = 32'h00508113; // addi x2, x1, 5
        RAM[2] = 32'h001101b3; // add  x3, x2, x1
        RAM[3] = 32'h00302023; // sw   x3, 0(x0)
        RAM[4] = 32'h00002203; // lw   x4, 0(x0)
        RAM[5] = 32'h00120293; // addi x5, x4, 1
        RAM[6] = 32'h00b58463; // beq  x1, x1, 8
        RAM[7] = 32'h06300313; // addi x6, x0, 99
        RAM[8] = 32'h00100393; // addi x7, x0, 1
    end // Added missing end for initial block

    // --- Combinational Read ---
    assign RD = RAM[A[31:2]];

endmodule