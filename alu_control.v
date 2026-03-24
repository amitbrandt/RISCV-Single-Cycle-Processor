`timescale 1ns / 1ps

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_bit5, // This is inst[30]
    output reg  [3:0] Operation
);

    // ALU Operation codes recall:
    // 4'b0010 = ADD
    // 4'b0110 = SUB
    // 4'b0000 = AND
    // 4'b0001 = OR

    always @(*) begin
        case (ALUOp)
            2'b00: begin
                // lw / sw / addi -> Need to ADD
                Operation = 4'b0010;
            end
            
            2'b01: begin
                // beq -> Need to SUBTRACT
                Operation = 4'b0110;
            end
            
            2'b10: begin
                // R-Type -> Check funct3 and funct7_bit5
                case (funct3)
                    3'b000: begin
                        if (funct7_bit5 == 1'b1)
                            Operation = 4'b0110; // SUB
                        else
                            Operation = 4'b0010; // ADD
                    end
                    3'b111: begin
                        Operation = 4'b0000; //AND
                    end
                    3'b110: begin
                        Operation = 4'b0001; //OR
                    end
                    default: Operation = 4'b0000;
                endcase
            end
            
            default: Operation = 4'b0000;
        endcase
    end

endmodule