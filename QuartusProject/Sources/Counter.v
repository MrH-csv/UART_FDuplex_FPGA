

module Counter #(parameter N = 4) (
// Inputs
    input   wire            inClk, rst, ena,         // Señales de control
// Outputs
    output  reg     [N-1:0] out                     // Salida del contador
);

    always @(posedge inClk, negedge rst) begin
        if (!rst)                                   // Condición de reset
            out <= {N{1'b0}};                       

        else
            if (out < 4'b1000)
                if (ena)
                    out <= out + 1'b1;                      // Aumento del contador en función de clk (en este caso cuenta Shifts)
                
                else 
                    out <= out;                             // Aumento del contador en función de clk (en este caso cuenta Shifts)

            else
                out <= 1'b0;
                
    end
    
endmodule