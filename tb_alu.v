`timescale 1ns / 1ps

module tb_alu();

    // --- Signals ---
    // Inputs to DUT (must be reg)
    reg  [31:0] tb_A;
    reg  [31:0] tb_B;
    reg  [2:0]  tb_ALUControl;

    // Outputs from DUT (must be wire)
    wire [31:0] tb_Result;
    wire        tb_Zero;

    // --- DUT Instantiation ---
    alu uut (
        .A(tb_A),
        .B(tb_B),
        .ALUControl(tb_ALUControl),
        .Result(tb_Result),
        .Zero(tb_Zero)
    );

    // --- Stimulus ---
    initial begin
        $display("Starting ALU Simulation...");

        // Test 1: ADD (15 + 10 = 25)
        tb_A = 32'd15; tb_B = 32'd10; tb_ALUControl = 3'b000; 
        #10;

        // Test 2: SUB (20 - 8 = 12)
        tb_A = 32'd20; tb_B = 32'd8;  tb_ALUControl = 3'b001; 
        #10;

        // Test 3: SUB triggering the Zero flag (42 - 42 = 0 -> Zero=1)
        tb_A = 32'd42; tb_B = 32'd42; tb_ALUControl = 3'b001; 
        #10;

        // Test 4: Bitwise AND (1100 & 1010 = 1000)
        tb_A = 32'b1100; tb_B = 32'b1010; tb_ALUControl = 3'b010; 
        #10;

        $display("Simulation Finished.");
        $finish;
    end

endmodule