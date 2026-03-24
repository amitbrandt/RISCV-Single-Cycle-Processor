`timescale 1ns / 1ps

module dmem (
    input  wire        clk,
    input  wire        WE,      // Write Enable
    input  wire [31:0] A,       // Address
    input  wire [31:0] WD,      // Write Data
    output wire [31:0] RD       // Read Data
);

    // Define a memory array named 'RAM' with 64 elements, each 32 bits wide.
    reg [31:0] RAM [63:0];
    
    // Read the value from 'RAM' at the index A[31:2] and assign it to RD.
    assign RD = RAM[A[31:2]];
    

    // --- Synchronous Write ---
    always @(posedge clk) begin 
        // If WE, write the data (WD) into the RAM at the index A[31:2].
        if (WE) begin
            RAM [A[31:2]] <= WD;
       end 
        
    end

endmodule