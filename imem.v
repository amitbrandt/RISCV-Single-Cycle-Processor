`timescale 1ns / 1ps

module imem (
    input  wire [31:0] A,
    output wire [31:0] RD
);

    // --- Memory Array ---
    // Define a memory array named 'RAM'. 
    reg [31:0] RAM [63:0];
    
  initial begin
RAM[0] = 32'h00500093; // addi x1, x0, 5  (כתובת 0)
RAM[1] = 32'h00500113; // addi x2, x0, 5  (כתובת 4)
RAM[2] = 32'h00208463; // beq x1, x2, 8   (כתובת 8 - קופץ 8 בתים קדימה לכתובת 16)
RAM[3] = 32'h00900193; // addi x3, x0, 9  (כתובת 12 / c בהקסה - המעבד *אמור לדלג* על זה!)
RAM[4] = 32'h00208233; // add x4, x1, x2  (כתובת 16 / 10 בהקסה - פקודת המטרה! מתבצעת לאחר הקפיצה)
 
    end
    

    // --- Combinational Read ---
    // Read the value from 'RAM' at the index specified by A[31:2] 
    // and assign it continuously to the output RD.
    assign RD = RAM[A[31:2]];
    

endmodule