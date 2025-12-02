

module FSM_UART_REC (
    input   wire                        clk, rst, rx, rxFlagClr,        // Señales de control
    input   wire    [3:0]               dataCntRx,                      // Señal de monitoreo

    output  reg                         countEnaRx, regEna, rxFlag, FSMrst        // Señales de salida de la FSM
); 
    
    (* syn_encoding = "user" *) reg [2:0] state;                            // Variable para control de estados
                                                                            // Definición de los estados
    localparam [2:0]IDDLE       = 3'b000;                                   // Estado iddle
    localparam [2:0]RECEPT     = 3'b001;                                    // Estado para comenzar la transición de datos
    localparam [2:0]PARITY     = 3'b010;                                    // Estado para calcular el bit de paridad par
    localparam [2:0]READ      = 3'b011;                                     // Estado para mantener lectura mientras no se active el boton

    always @(posedge clk, negedge rst) begin
        if (!rst)
            state = IDDLE;

        else
            case (state)                                                // Movimiento de estados 
                IDDLE:
                    if (!rx)                                            // Botón presionado
                        state = RECEPT;

                    else
                        state = IDDLE;

                RECEPT: 
                    if (dataCntRx < 7)                                  // La condición de cambio de estado a PARITY es que se hayan transmitido los 8 bits de información
                        state = RECEPT;
                    
                    else
                        state = PARITY;

                PARITY:
                    state = READ;

                READ:
                    if (!rxFlagClr)                                     // Nos aseguramos de que la bandera ya haya sido borrada 
                        state = IDDLE;
                    
                    else
                        state = READ;

                default: 
                    state = IDDLE;

            endcase
        
    end

    always @(state) begin                                               // Banderas de los estados
        case (state)
            IDDLE:  begin
                countEnaRx = 1'b0;                                      // Bandera para activar el conteo de los bits de información
                regEna = 1'b0;                                          // Bandera para activar la captura de datos en el registro serial
                rxFlag = 1'b0;                                          // Bandera para indicar que todos los datos se han mandado correctamente
                FSMrst = 1'b1;                                          // Reset del registro por medio de la máquina de estados
            end

            RECEPT: begin
                countEnaRx = 1'b1;                                      
                regEna = 1'b1;
                rxFlag = 1'b0;
                FSMrst = 1'b0;

            end

            PARITY: begin
                countEnaRx = 1'b1;
                regEna = 1'b1;
                rxFlag = 1'b0;
                FSMrst = 1'b0;
            end

            READ: begin
                countEnaRx = 1'b0;
                regEna = 1'b0;
                rxFlag = 1'b1;
                FSMrst = 1'b0;
            end

            default: begin
                countEnaRx = 1'b0;
                regEna = 1'b0;
                rxFlag = 1'b0;
                FSMrst = 1'b1;
            end

        endcase

    end

endmodule

