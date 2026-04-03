module regfile (
    input  wire        clk,
    input  wire        we,   
    input  wire [4:0]  a1,   
    input  wire [4:0]  a2,   
    input  wire [4:0]  a3,   
    input  wire [31:0] wd3,  
    output wire [31:0] rd1,  
    output wire [31:0] rd2  
);

    reg [31:0] rf [31:0];

    // --- הוספת אתחול לרגיסטרים ---
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'b0;
        end
    end

    // --- Write Logic ---
    always @(posedge clk) begin
        if (we && (a3 != 5'b00000)) begin
            rf[a3] <= wd3;
        end
    end

    // --- Read Logic with Internal Forwarding ---
    assign rd1 = (a1 == 5'b00000) ? 32'b0 : 
                 ((a1 == a3) && we) ? wd3 : rf[a1];

    assign rd2 = (a2 == 5'b00000) ? 32'b0 : 
                 ((a2 == a3) && we) ? wd3 : rf[a2];

endmodule