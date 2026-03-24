`timescale 1ns / 1ps

module regfile (
    input  wire        clk,
    input  wire        we,       // Write Enable (1 = write, 0 = read only)
    input  wire [4:0]  a1,        // Read address 1 (rs1)
    input  wire [4:0]  a2,        // Read address 2 (rs2)
    input  wire [4:0]  a3,        // Write address (rd)
    input  wire [31:0] wd3,       // Write data
    output wire [31:0] rd1,       // Read data 1
    output wire [31:0] rd2        // Read data 2
);

    // --- Internal Memory Array ---
    // Array of 32 registers, each 32 bits wide
    reg [31:0] rf [31:0];

    always @(posedge clk) begin
        // Write only if Write Enable is TRUE AND address is not 0 (x0 is read-only)
        if (we && (a3 != 5'b00000)) begin
            rf[a3] <= wd3;
        end
    end

    // If address is 0, force output to 0. Otherwise, output register value.
    assign rd1 = (a1 == 5'b00000) ? 32'b0 : rf[a1];
    assign rd2 = (a2 == 5'b00000) ? 32'b0 : rf[a2];

endmodule