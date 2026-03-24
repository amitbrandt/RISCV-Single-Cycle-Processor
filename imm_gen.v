`timescale 1ns / 1ps

module imm_gen (
    input  wire [31:0] inst,
    output wire [31:0] imm_out
);
    // --- I-Type Immediate Extraction and Sign Extension ---
    assign imm_out = { {20{inst[31]}}, inst[31:20]};
endmodule