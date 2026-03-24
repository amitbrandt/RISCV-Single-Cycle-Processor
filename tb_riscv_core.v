`timescale 1ns / 1ps

module tb_riscv_core();

    reg clk;
    reg reset;

    // Instantiate the Top-Level CPU
    riscv_core uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: flip every 5ns (10ns period -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Starting CPU Integration Test...");
        
        // Initialize inputs
        clk = 0;
        reset = 1;
        
        // Hold reset for a few cycles
        #15;
        reset = 0;
        
        // Let the CPU run for 5 clock cycles
        // (Enough time to fetch and execute our 4 instructions)
        #50;
        
        $display("Test finished.");
        $finish;
    end

endmodule