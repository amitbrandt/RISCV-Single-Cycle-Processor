`timescale 1ns / 1ps

module riscv_core (
    input  wire clk,
    input  wire reset
);

    // 1. Fetch Stage Wires Declaration
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] instruction;

    // The PC is a simple register (Flip-Flop) that holds the current address.
    // On reset, it clears to 0. Otherwise, it gets the next address on every clock edge.
    reg [31:0] PC_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_reg <= 32'b0;
        else
            PC_reg <= pc_next; 
    end
    
    // Connect the PC register to our wire
    assign pc_current = PC_reg;
    
    // Calculate the regular next address (PC + 4)
    assign pc_plus_4 = pc_current + 32'd4;


    imem instruction_memory (
        .A(pc_current),       // Connect current PC address to memory input
        .RD(instruction)      // The fetched 32-bit instruction goes into our wire
    );

    // Decode Stage Wires Declaration
    wire       Branch;
    wire       MemRead;
    wire       MemtoReg;
    wire [1:0] ALUOp;
    wire       MemWrite;
    wire       ALUSrc;
    wire       RegWrite;
    // Data Wires from Register File and ImmGen
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] imm_out;
    // Write Back wire 
    wire [31:0] write_data;

    // Main Control Unit Instantiation
    // Extracting opcode directly from the instruction wire: instruction[6:0]
    main_control ctrl_unit (
        .opcode   (instruction[6:0]),
        .Branch   (Branch),
        .MemRead  (MemRead),
        .MemtoReg (MemtoReg),
        .ALUOp    (ALUOp),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .RegWrite (RegWrite)
    );


    // Extracting register numbers from the instruction wire:
    // rs1 = instruction[19:15]
    // rs2 = instruction[24:20]
    // rd  = instruction[11:7]
    regfile reg_file (
        .clk        (clk),
        .we         (RegWrite),           // Write Enable controlled by Main Control
        .a1  (instruction[19:15]),
        .a2  (instruction[24:20]),
        .a3 (instruction[11:7]),
        .wd3 (write_data),         // Placeholder: will be connected in Write Back stage
        .rd1 (read_data1),
        .rd2 (read_data2)
    );

    //Immediate Generator Instantiation
    imm_gen imm_generator (
        .inst     (instruction),
        .imm_out  (imm_out)
    );
    
    // Stage Wires Declaration
    wire [3:0]  alu_operation;
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire        alu_zero;

    // ALU Control Instantiation
    // Extracting funct3 (bits 14:12) and funct7_bit5 (bit 30) from the instruction.
    alu_control alu_ctrl (
        .ALUOp       (ALUOp),
        .funct3      (instruction[14:12]),
        .funct7_bit5 (instruction[30]),
        .Operation   (alu_operation)
    );

    // ALU Input B Multiplexer (MUX)
    // This MUX chooses between register data 2 and the immediate value.
    // If ALUSrc == 1, choose immediate. If ALUSrc == 0, choose register 2.
    assign alu_input_b = (ALUSrc) ? imm_out : read_data2;

    //  ALU Instantiation
    alu main_alu (
        .A       (read_data1),
        .B       (alu_input_b),    // The output from our MUX
        .ALUControl  (alu_operation),  // The 4-bit command from ALU Control
        .Result  (alu_result),
        .Zero    (alu_zero)
    );
    // Memory Stage Wires
    wire [31:0] mem_read_data;

    // Data Memory (DMEM) Instantiation
    dmem data_memory (
        .clk (clk),
        .WE  (MemWrite),
        .A   (alu_result),
        .WD  (read_data2),
        .RD  (mem_read_data)
    );

    // Write Back MUX: Choose between Memory Data and ALU Result
    assign write_data = (MemtoReg) ? mem_read_data : alu_result;

    // Branch Logic & PC Next Calculation
    wire [31:0] branch_target;
    wire        branch_taken;

    assign branch_target = pc_current + (imm_out << 1);
    assign branch_taken  = Branch & alu_zero;

    // PC Next MUX: Choose between Branch Target and PC+4
    assign pc_next = (branch_taken) ? branch_target : pc_plus_4;

endmodule