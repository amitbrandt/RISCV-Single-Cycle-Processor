module IF_ID_reg (
    input clk,
    input rst_n,
    input flush,
    input stall,
    input [31:0] pc_in,
    input [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);

    // RISC-V NOP: addi x0, x0, 0
    localparam NOP = 32'h00000013;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Hardware reset
            pc_out    <= 0;
            instr_out <= NOP;
        end 
        else if (flush) begin
            // Control hazard: clear instruction
            pc_out    <= 0;
            instr_out <= NOP;
        end 
        else if (!stall) begin
            // Normal flow: update values
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
        // If stall: hold current values
    end

endmodule