

module BCD_7S (
// Entradas
    input   wire    [3:0]   in,
    input   wire            clk,

// Salidas
    output  reg     [6:0]   out
);

    always @(posedge clk) begin

        case (in[3:0])              //  gfe_dcba (Active High representation, inverted by ~)
            4'd0:       out[6:0] = ~(7'b0111111); // 0
            4'd1:       out[6:0] = ~(7'b0000110); // 1
            4'd2:       out[6:0] = ~(7'b1011011); // 2
            4'd3:       out[6:0] = ~(7'b1001111); // 3
            4'd4:       out[6:0] = ~(7'b1100110); // 4
            4'd5:       out[6:0] = ~(7'b1101101); // 5
            4'd6:       out[6:0] = ~(7'b1111101); // 6
            4'd7:       out[6:0] = ~(7'b0000111); // 7
            4'd8:       out[6:0] = ~(7'b1111111); // 8
            4'd9:       out[6:0] = ~(7'b1101111); // 9
            
            // Hexadecimal
            4'd10:      out[6:0] = ~(7'b1110111); // A
            4'd11:      out[6:0] = ~(7'b1111100); // b
            4'd12:      out[6:0] = ~(7'b0111001); // C
            4'd13:      out[6:0] = ~(7'b1011110); // d
            4'd14:      out[6:0] = ~(7'b1111001); // E
            4'd15:      out[6:0] = ~(7'b1110001); // F

            default:    out[6:0] = ~(7'b0000000); // Off

        endcase

    end
    
endmodule