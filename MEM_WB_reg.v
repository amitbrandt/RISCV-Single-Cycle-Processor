module MEM_WB_reg (
    input clk,
    input rst_n,
    input flush,
    input stall,

    // Data from Memory and ALU
    input [31:0] mem_read_data_in,
    input [31:0] alu_result_in,
    input [4:0]  rd_addr_in,

    // Control Signals for WB stage
    input        reg_write_in,
    input        mem_to_reg_in,

    // Outputs to Write Back stage
    output reg [31:0] mem_read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0]  rd_addr_out,
    output reg        reg_write_out,
    output reg        mem_to_reg_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            mem_read_data_out <= 0;
            alu_result_out    <= 0;
            rd_addr_out       <= 0;
            reg_write_out     <= 0;
            mem_to_reg_out    <= 0;
        end 
        else if (!stall) begin
            mem_read_data_out <= mem_read_data_in;
            alu_result_out    <= alu_result_in;
            rd_addr_out       <= rd_addr_in;
            reg_write_out     <= reg_write_in;
            mem_to_reg_out    <= mem_to_reg_in;
        end
    end
endmodule