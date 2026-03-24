`timescale 1ns / 1ps

module tb_regfile();

    // --- Signals ---
    reg         tb_clk;
    reg         tb_we;     // Changed from we3 to we
    reg  [4:0]  tb_a1, tb_a2, tb_a3;
    reg  [31:0] tb_wd3;
    wire [31:0] tb_rd1, tb_rd2;

    // --- DUT Instantiation ---
    regfile uut (
        .clk(tb_clk),
        .we(tb_we),        
        .a1(tb_a1),
        .a2(tb_a2),
        .a3(tb_a3),
        .wd3(tb_wd3),
        .rd1(tb_rd1),
        .rd2(tb_rd2)
    );

    // --- Clock Generation ---
    // Toggles the clock every 5ns (10ns period)
    always #5 tb_clk = ~tb_clk;

    // --- Stimulus ---
    initial begin
        // Initialize signals
        tb_clk = 0; tb_we = 0; 
        tb_a1 = 0; tb_a2 = 0; tb_a3 = 0; tb_wd3 = 0;
        
        $display("Starting Register File Simulation...");

        // Test 1: Write 100 to register x5
        #10;
        tb_we = 1; tb_a3 = 5'd5; tb_wd3 = 32'd100;
        
        // Test 2: Read register x5 (expecting 100 on rd1)
        #10;
        tb_we = 0; tb_a1 = 5'd5;
        
        // Test 3: The x0 trap - Attempt to write 999 to x0
        #10;
        tb_we = 1; tb_a3 = 5'd0; tb_wd3 = 32'd999;
        
        // Test 4: Read x0 (expecting 0 on rd2, NOT 999)
        #10;
        tb_we = 0; tb_a2 = 5'd0;

        // Test 5: Write to x8, then read x5 and x8 simultaneously
        #10;
        tb_we = 1; tb_a3 = 5'd8; tb_wd3 = 32'd200;
        #10;
        tb_we = 0; tb_a1 = 5'd5; tb_a2 = 5'd8;
        #10;

        $display("Simulation Finished.");
        $finish;
    end

endmodule