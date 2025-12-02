

module RSRegister (  
// Inputs
    input   wire            clk, rst, ena,                  // Señales de control del registro
    input   wire            SIn,                            // Entrada del bit serial
// Outputs
    output  reg     [8:0] out                             // Salida del registro
);
    
    always @(posedge clk) begin
        if (!rst)                                           // Condición de reset
            out <= 9'b0;                               

        else
            if (ena)                                       // Desplazamiento a la derecha con entrada del dato serial en el MSB
                out <= {SIn, out[8:1]};
            
            else                               
                out <= out;                                 // Memoria
    end

endmodule