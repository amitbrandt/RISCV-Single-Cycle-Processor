module ID_EX_reg (
    input clk,
    input rst_n,
    input flush,
    input stall,

    // Data from Decode stage
    input [31:0] pc_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] imm_in,
    input [4:0]  rd_addr_in,
    input [3:0]  alu_ctrl_in,
    
    // Register addresses for Forwarding Unit
    input [4:0]  rs1_in,
    input [4:0]  rs2_in,

    // Control Signals from Main Control
    input        alu_src_in,
    input        mem_write_in,
    input        mem_read_in,
    input        reg_write_in,
    input        mem_to_reg_in,

    // Outputs to Execute stage
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rd_addr_out,
    output reg [3:0]  alu_ctrl_out,
    
    // Register addresses to Forwarding Unit
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    
    output reg        alu_src_out,
    output reg        mem_write_out,
    output reg        mem_read_out,
    output reg        reg_write_out,
    output reg        mem_to_reg_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out         <= 32'b0;
            rs1_data_out   <= 32'b0;
            rs2_data_out   <= 32'b0;
            imm_out        <= 32'b0;
            rd_addr_out    <= 5'b0;
            alu_ctrl_out   <= 4'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            alu_src_out    <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end 
        else if (!stall) begin
            pc_out         <= pc_in;
            rs1_data_out   <= rs1_data_in;
            rs2_data_out   <= rs2_data_in;
            imm_out        <= imm_in;
            rd_addr_out    <= rd_addr_in;
            alu_ctrl_out   <= alu_ctrl_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            alu_src_out    <= alu_src_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule