module hazard_detection (
    input [4:0] rs1_id,        // rs1 from Decode stage
    input [4:0] rs2_id,        // rs2 from Decode stage
    input [4:0] rd_ex,         // rd from Execute stage
    input       mem_read_ex,   // Is the instruction in EX a Load?
    
    output reg  stall          // 1 = stop PC and IF/ID, insert NOP to ID/EX
);

    always @(*) begin
        // Default: no stall
        stall = 1'b0;
        
        // Load-Use Hazard Detection:
        // If instruction in EX is a LOAD and its destination is 
        // one of the source registers of the instruction in ID.
        if (mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall = 1'b1;
        end
    end
endmodule