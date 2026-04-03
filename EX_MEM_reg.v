module EX_MEM_reg (
    input clk,
    input rst_n,
    input flush,
    input stall,

    // Data from Execute stage
    input [31:0] alu_result_in,
    input [31:0] rs2_data_in,    // For Store instructions
    input [4:0]  rd_addr_in,

    // Control Signals for MEM and WB stages
    input        mem_write_in,
    input        mem_read_in,
    input        reg_write_in,
    input        mem_to_reg_in,

    // Outputs to Memory stage
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [4:0]  rd_addr_out,
    output reg        mem_write_out,
    output reg        mem_read_out,
    output reg        reg_write_out,
    output reg        mem_to_reg_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            alu_result_out <= 0;
            rs2_data_out   <= 0;
            rd_addr_out    <= 0;
            mem_write_out  <= 0;
            mem_read_out   <= 0;
            reg_write_out  <= 0;
            mem_to_reg_out <= 0;
        end 
        else if (!stall) begin
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            rd_addr_out    <= rd_addr_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule