module Keypad4x4 (
    input wire clk,
    input wire rst,
    input wire [3:0] row,      // Rows (Inputs)
    output reg [3:0] col,      // Columns (Outputs)
    output reg [7:0] dataOut,  // ASCII Code
    output reg dataReady       // Pulse when key is pressed
);

    // Register Declarations
    reg [19:0] timer;          // Timer for scanning speed
    reg [1:0] colIndex;        // Current column being scanned
    reg [3:0] rowSync;         // Synchronizer for row inputs

    // Internal Signals
    wire key_detected;
    wire valid_press;          // One-shot from Debouncer
    wire rst_active_high;

    // Logic
    assign rst_active_high = ~rst; // Debouncer uses active high reset
    
    // Fix Ghosting: Only detect key after 10us (500 cycles) of settling time after column switch
    // Note: timer resets to 0 when it reaches 50,000. 
    // We want to ignore inputs when timer is small (just switched).
    assign key_detected = (rowSync != 4'b1111) && (timer > 20'd500);

    // Instantiate Debouncer
    Debouncer DB (
        .clk(clk),
        .rst(rst_active_high),
        .sw(key_detected),
        .one_shot(valid_press)
    );

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            col <= 4'b1110;
            colIndex <= 0;
            timer <= 0;
            dataReady <= 0;
            dataOut <= 8'h00;
            rowSync <= 4'b1111;
        end else begin
            // Synchronize Inputs
            rowSync <= row;

            // 1. Column Scanning
            // Freeze scanning if a key is detected to ensure stable reading
            if (!key_detected) begin
                if (timer == 20'd50_000) begin // Scan speed ~1ms
                    timer <= 0;
                    
                    // Rotate Zero (Active Low scanning)
                    case (colIndex)
                        0: col <= 4'b1101;
                        1: col <= 4'b1011;
                        2: col <= 4'b0111;
                        3: col <= 4'b1110;
                    endcase
                    colIndex <= colIndex + 1;
                end else begin
                    timer <= timer + 1;
                end
            end
            // If key_detected, we hold the current 'col' value stable

            // 2. Output Logic driven by Debouncer
            if (valid_press) begin
                dataReady <= 1;
                
                // Decode (col is stable because we froze it, rowSync is stable)
                case ({col, rowSync})
                    // Col 0 (4'b1110)
                    8'b1110_1110: dataOut <= 8'h31; // 1
                    8'b1110_1101: dataOut <= 8'h34; // 4
                    8'b1110_1011: dataOut <= 8'h37; // 7
                    8'b1110_0111: dataOut <= 8'h2A; // *
                    
                    // Col 1 (4'b1101)
                    8'b1101_1110: dataOut <= 8'h32; // 2
                    8'b1101_1101: dataOut <= 8'h35; // 5
                    8'b1101_1011: dataOut <= 8'h38; // 8
                    8'b1101_0111: dataOut <= 8'h30; // 0
                    
                    // Col 2 (4'b1011)
                    8'b1011_1110: dataOut <= 8'h33; // 3
                    8'b1011_1101: dataOut <= 8'h36; // 6
                    8'b1011_1011: dataOut <= 8'h39; // 9
                    8'b1011_0111: dataOut <= 8'h23; // #
                    
                    // Col 3 (4'b0111)
                    8'b0111_1110: dataOut <= 8'h41; // A
                    8'b0111_1101: dataOut <= 8'h42; // B
                    8'b0111_1011: dataOut <= 8'h43; // C
                    8'b0111_0111: dataOut <= 8'h44; // D
                    
                    default: begin
                        dataOut <= 8'h00; // Unknown
                    end
                endcase
            end else begin
                dataReady <= 0;
            end
        end
    end

endmodule
