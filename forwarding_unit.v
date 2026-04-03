module forwarding_unit (
    input [4:0] rs1_ex,
    input [4:0] rs2_ex,
    input [4:0] rd_mem,
    input [4:0] rd_wb,
    input       reg_write_mem,
    input       reg_write_wb,
    
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
        // Default: No forwarding (use register file value)
        forward_a = 2'b00;
        forward_b = 2'b00;

        // Hazard MEM: Forward from EX/MEM pipe register
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex)) forward_a = 2'b10;
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex)) forward_b = 2'b10;

        // Hazard WB: Forward from MEM/WB pipe register
        // We add an extra check: only forward if MEM hazard didn't already trigger
        if (reg_write_wb && (rd_wb != 0) && (forward_a != 2'b10) && (rd_wb == rs1_ex)) forward_a = 2'b01;
        if (reg_write_wb && (rd_wb != 0) && (forward_b != 2'b10) && (rd_wb == rs2_ex)) forward_b = 2'b01;
    end
endmodule