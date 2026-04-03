`timescale 1ns / 1ps

module main_control (
    input  wire [6:0] opcode,
    output reg        Branch,
    output reg        MemRead,
    output reg        MemtoReg,
    output reg [1:0]  ALUOp,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        RegWrite
);

    always @(*) begin
        // By default, turn everything OFF. 
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp    = 2'b00;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;

        // --- Decode the Opcode ---
        case (opcode)
            7'b0110011: begin // R-Type (add, sub, etc.)
                // ALU takes two registers (ALUSrc = 0)
                // Writes ALU result to register (RegWrite = 1, MemtoReg = 0)
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end

            7'b0000011: begin // Load Word (lw)
                // ALU adds address + immediate (ALUSrc = 1, ALUOp = 00)
                // Reads memory and writes to register (MemRead = 1, MemtoReg = 1, RegWrite = 1)
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
            end

            7'b0100011: begin // Store Word (sw)
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;            
            end

            7'b1100011: begin // Branch Equal (beq)
                // It compares two registers (ALUSrc = 0) using subtraction (ALUOp = 01).
                 ALUOp    = 2'b01;
                 Branch   = 1'b1;            
            end
            
            7'b0010011: begin // I-Type (addi)
                ALUSrc   = 1'b1; 
                RegWrite = 1'b1; 
                ALUOp    = 2'b00; 
            end
            
            

            default: begin
                // If the opcode is unknown, defaults apply (everything 0).
            end
        endcase
    end

endmodule