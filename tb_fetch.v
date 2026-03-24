`timescale 1ns / 1ps

module tb_fetch();

    // --- Signals ---
    reg         clk;
    reg         reset;
    
    // Wires to connect the modules together
    wire [31:0] current_pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;

    // --- The PC + 4 Adder ---
    // This combinational logic calculates the next sequential address
    assign next_pc = current_pc + 32'd4;

    // --- Module Instantiations ---
    
    // 1. Instantiate the PC Register
    pc_register u_pc (
        .clk(clk),
        .reset(reset),
        .PC_Next(next_pc),   // Input: the calculated next address
        .PC(current_pc)      // Output: the current address
    );

    // 2. Instantiate the Instruction Memory
    imem u_imem (
        .A(current_pc),      // Input: address from the PC
        .RD(instruction)     // Output: the 32-bit machine code
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Stimulus ---
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1; // Start with reset HIGH to initialize PC to 0
        
        $display("Starting Fetch Simulation...");

        // Wait a bit, then turn off reset to let the PC run
        #15;
        reset = 0;

        // Let the simulation run for a few clock cycles 
        // to fetch our 4 instructions
        #50;

        $display("Simulation Finished.");
        $finish;
    end

endmodule