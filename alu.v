`timescale 1ns / 1ps
/* ------------------------------------------------------------------------
 * Module Name: alu
 * Description: Arithmetic Logic Unit (ALU) for a 32-bit RISC-V processor.
 * Supports basic arithmetic and logical operations required 
 * for the RV32I base integer instruction set.
 * ------------------------------------------------------------------------ */

module alu(
    input  wire [31:0] A,// First operand (usually from rs1)
    input  wire [31:0] B, // Second operand (from rs2 or immediate value)
    input  wire [2:0]  ALUControl,// Operation selector:
                                 // 000 = ADD, 001 = SUB, 010 = AND, 011 = OR
    output reg  [31:0] Result,// 32-bit computation result
    output wire        Zero // 1 if Result is exactly zero
 );
   always @(*) begin
        case (ALUControl)
            3'b010: Result = A + B; // 2 = ADD
            3'b110: Result = A - B; // 6 = SUB
            3'b000: Result = A & B; // 0 = AND
            3'b001: Result = A | B; // 1 = OR
            default: Result = 32'b0;
        endcase
    end
    assign Zero = (Result == 32'b0);
    
endmodule
