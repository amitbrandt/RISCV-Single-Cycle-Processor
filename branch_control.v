module branch_control (
    input        branch_id,    // Branch signal from Control Unit
    input [31:0] rd1_id,       // Value of rs1 (after potential internal forwarding)
    input [31:0] rd2_id,       // Value of rs2
    
    output reg   branch_taken, // 1 = jump to target
    output reg   if_id_flush   // 1 = clear the instruction in IF/ID
);

    always @(*) begin
        // Simple equality check for BEQ (you can expand this for BLT/BNE)
        if (branch_id && (rd1_id == rd2_id)) begin
            branch_taken = 1'b1;
            if_id_flush  = 1'b1; // We jumped, so the instruction fetched in IF is wrong
        end else begin
            branch_taken = 1'b0;
            if_id_flush  = 1'b0;
        end
    end
endmodule