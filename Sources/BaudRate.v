

module BaudRate (
// Inputs
    input   wire            clk, rst,               // Señales de control
// Outputs
    output  reg             out                     // Salida del contador
);

    reg [12:0]   count;

    always @(posedge clk, negedge rst) begin
        if (!rst)   begin                                   // Condición de reset
            count <= 9'b0; 
            out   <= 1'b0;
        end                      

        else
            if (count<2604)
                count   <=  count + 1'b1;                      // Aumento del contador en función de clk (en este caso cuenta Shifts)

            else    begin
                count   <=  8'b0;                      // Aumento del contador en función de clk (en este caso cuenta Shifts)
                out <= ~out;
            end

    end
    
endmodule