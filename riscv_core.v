`timescale 1ns / 1ps

module riscv_core (
    input  wire clk,
    input  wire reset
);

    // --- Control & Hazard Wires ---
    wire stall, if_id_flush, branch_taken;
    wire [1:0] forward_a, forward_b;

    // -------------------------------------------------------------------------
    // 1. FETCH STAGE (IF)
    // -------------------------------------------------------------------------
    wire [31:0] pc_current, pc_next, pc_plus_4, instr_raw;
    reg  [31:0] PC_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset) PC_reg <= 32'b0;
        else if (!stall) PC_reg <= pc_next; 
    end
    
    assign pc_current = PC_reg;
    assign pc_plus_4 = pc_current + 32'd4;
    assign pc_next = (branch_taken) ? (pc_id + (imm_id << 1)) : pc_plus_4;

    imem instruction_memory (
        .A(pc_current),
        .RD(instr_raw)
    );

    // IF/ID REGISTER
    wire [31:0] instr_id, pc_id;
    IF_ID_reg if_id_inst (
        .clk(clk), .rst_n(!reset), 
        .flush(if_id_flush), .stall(stall),
        .pc_in(pc_current), .instr_in(instr_raw),
        .pc_out(pc_id), .instr_out(instr_id)
    );

    // -------------------------------------------------------------------------
    // 2. DECODE STAGE (ID)
    // -------------------------------------------------------------------------
    wire Branch_id, MemRead_id, MemtoReg_id, MemWrite_id, ALUSrc_id, RegWrite_id;
    wire [1:0] ALUOp_id;
    wire [3:0] alu_ctrl_id;
    wire [31:0] rd1_id, rd2_id, imm_id;

    main_control ctrl_unit (
        .opcode(instr_id[6:0]), .Branch(Branch_id), .MemRead(MemRead_id),
        .MemtoReg(MemtoReg_id), .ALUOp(ALUOp_id), .MemWrite(MemWrite_id),
        .ALUSrc(ALUSrc_id), .RegWrite(RegWrite_id)
    );

    regfile reg_file (
        .clk(clk), .we(reg_write_wb), 
        .a1(instr_id[19:15]), .a2(instr_id[24:20]),
        .a3(rd_addr_wb), .wd3(write_data_wb),
        .rd1(rd1_id), .rd2(rd2_id)
    );

    imm_gen imm_generator (
        .inst(instr_id), .imm_out(imm_id)
    );

    branch_control br_unit (
        .branch_id(Branch_id), .rd1_id(rd1_id), .rd2_id(rd2_id),
        .branch_taken(branch_taken), .if_id_flush(if_id_flush)
    );

    alu_control alu_ctrl_unit (
        .ALUOp(ALUOp_id), .funct3(instr_id[14:12]), 
        .funct7_bit5(instr_id[30]), .Operation(alu_ctrl_id)
    );

    hazard_detection hazard_unit (
        .rs1_id(instr_id[19:15]), .rs2_id(instr_id[24:20]),
        .rd_ex(rd_addr_ex), .mem_read_ex(mem_read_ex),
        .stall(stall)
    );

    // ID/EX REGISTER
    wire [31:0] pc_ex, rd1_ex, rd2_ex, imm_ex;
    wire [4:0]  rd_addr_ex, rs1_ex, rs2_ex;
    wire [3:0]  alu_ctrl_ex;
    wire        alu_src_ex, mem_write_ex, mem_read_ex, reg_write_ex, mem_to_reg_ex;

    ID_EX_reg id_ex_inst (
        .clk(clk), .rst_n(!reset), 
        .flush(stall), .stall(1'b0),
        .pc_in(pc_id), 
        .rs1_data_in(rd1_id), 
        .rs2_data_in(rd2_id),
        .imm_in(imm_id), 
        .rd_addr_in(instr_id[11:7]), 
        .alu_ctrl_in(alu_ctrl_id),
        .rs1_in(instr_id[19:15]),
        .rs2_in(instr_id[24:20]),
        .alu_src_in(ALUSrc_id), .mem_write_in(MemWrite_id), .mem_read_in(MemRead_id),
        .reg_write_in(RegWrite_id), .mem_to_reg_in(MemtoReg_id),
        
        .pc_out(pc_ex), .rs1_data_out(rd1_ex), .rs2_data_out(rd2_ex),
        .imm_out(imm_ex), .rd_addr_out(rd_addr_ex), .alu_ctrl_out(alu_ctrl_ex),
        .rs1_out(rs1_ex), .rs2_out(rs2_ex),
        .alu_src_out(alu_src_ex), .mem_write_out(mem_write_out_ex), .mem_read_out(mem_read_out_ex),
        .reg_write_out(reg_write_out_ex), .mem_to_reg_out(mem_to_reg_out_ex)
    );

    // Internal mapping for control signals out of ID_EX
    assign mem_write_ex = mem_write_out_ex;
    assign mem_read_ex = mem_read_out_ex;
    assign reg_write_ex = reg_write_out_ex;
    assign mem_to_reg_ex = mem_to_reg_out_ex;

    // -------------------------------------------------------------------------
    // 3. EXECUTE STAGE (EX)
    // -------------------------------------------------------------------------
    wire [31:0] forward_a_mux_out, forward_b_mux_out, alu_input_b, alu_result_ex;

    assign forward_a_mux_out = (forward_a == 2'b10) ? alu_result_mem :
                               (forward_a == 2'b01) ? write_data_wb  : rd1_ex;

    assign forward_b_mux_out = (forward_b == 2'b10) ? alu_result_mem :
                               (forward_b == 2'b01) ? write_data_wb  : rd2_ex;

    assign alu_input_b = (alu_src_ex) ? imm_ex : forward_b_mux_out;

    alu main_alu (
        .A(forward_a_mux_out), .B(alu_input_b), .ALUControl(alu_ctrl_ex),
        .Result(alu_result_ex), .Zero()
    );

    forwarding_unit fwd_unit (
        .rs1_ex(rs1_ex), .rs2_ex(rs2_ex), .rd_mem(rd_addr_mem), .rd_wb(rd_addr_wb),
        .reg_write_mem(reg_write_mem), .reg_write_wb(reg_write_wb),
        .forward_a(forward_a), .forward_b(forward_b)
    );

    // EX/MEM REGISTER
    wire [31:0] alu_result_mem, rd2_mem;
    wire [4:0]  rd_addr_mem;
    wire        mem_write_mem, mem_read_mem, reg_write_mem, mem_to_reg_mem;

    EX_MEM_reg ex_mem_inst (
        .clk(clk), .rst_n(!reset), .flush(1'b0), .stall(1'b0),
        .alu_result_in(alu_result_ex), .rs2_data_in(forward_b_mux_out), .rd_addr_in(rd_addr_ex),
        .mem_write_in(mem_write_ex), .mem_read_in(mem_read_ex),
        .reg_write_in(reg_write_ex), .mem_to_reg_in(mem_to_reg_ex),
        .alu_result_out(alu_result_mem), .rs2_data_out(rd2_mem), .rd_addr_out(rd_addr_mem),
        .mem_write_out(mem_write_mem), .mem_read_out(mem_read_mem),
        .reg_write_out(reg_write_mem), .mem_to_reg_out(mem_to_reg_mem)
    );

    // -------------------------------------------------------------------------
    // 4. MEMORY STAGE (MEM)
    // -------------------------------------------------------------------------
    wire [31:0] mem_data_mem;

    dmem data_memory (
        .clk(clk), .WE(mem_write_mem), .A(alu_result_mem),
        .WD(rd2_mem), .RD(mem_data_mem)
    );

    // MEM/WB REGISTER
    wire [31:0] alu_result_wb, mem_data_wb;
    wire [4:0]  rd_addr_wb;
    wire        reg_write_wb, mem_to_reg_wb;

    MEM_WB_reg mem_wb_inst (
        .clk(clk), .rst_n(!reset), .flush(1'b0), .stall(1'b0),
        .alu_result_in(alu_result_mem), .mem_read_data_in(mem_data_mem), .rd_addr_in(rd_addr_mem),
        .reg_write_in(reg_write_mem), .mem_to_reg_in(mem_to_reg_mem),
        .alu_result_out(alu_result_wb), .mem_read_data_out(mem_data_wb), .rd_addr_out(rd_addr_wb),
        .reg_write_out(reg_write_wb), .mem_to_reg_out(mem_to_reg_wb)
    );

    // -------------------------------------------------------------------------
    // 5. WRITE BACK STAGE (WB)
    // -------------------------------------------------------------------------
    wire [31:0] write_data_wb;
    assign write_data_wb = (mem_to_reg_wb) ? mem_data_wb : alu_result_wb;

endmodule