`timescale 1ns / 1ps

module pc_register (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] PC_Next,
    output reg  [31:0] PC
);

    // --- Synchronous PC Update ---
    always @(posedge clk) begin
        if (reset) begin
            // Reset is active: clear PC to 0
            PC <= 32'b0;
        end else begin
            // Reset is inactive: update PC normally
            PC <= PC_Next;
        end
    end

endmodule