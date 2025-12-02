

module FSM_UART_TRANS #(parameter FRAMEWIDTH = 8, N = $clog2(FRAMEWIDTH)) (
    input   wire                        clk, rst, txSend,         // Señales de control
    input   wire    [3:0]               dataCntTx,               // Señal de monitoreo
    input   wire    [7:0]   txData,                             // Dato introducido en los switches

    output  reg                         tx, countEnaTx        // Señales de salida de la FSM
); 
    
    (* syn_encoding = "user" *) reg [2:0] state;                           //\\ Variable para control de estados

    localparam [2:0]IDDLE       = 3'b000;                                   // Estado de reposo
    localparam [2:0]START       = 3'b001;                                   // Estado de inicio, se inicializan módulos auxiliares
    localparam [2:0]TRANS0      = 3'b010;                                   // Estado de transiciones
    localparam [2:0]TRANS1      = 3'b011;                                   // Se generan 2 para provocar un cambio en las salidas
    localparam [2:0]PARITY      = 3'b100;                                   // Estado de cálculo de paridad
    localparam [2:0]STOP        = 3'b101;                                   // Estado transmición de bit stop

    always @(posedge clk, negedge rst) begin
        if (!rst)
            state = IDDLE;

        else
            case (state)                                                    // Transición de los estados
                IDDLE:
                    if (!txSend)                                            // Botón presionado
                        state = START;

                    else
                        state = IDDLE;

                START: 
                    state = TRANS1;

                TRANS0:
                    if (dataCntTx < 8)                                      // Condición de terminar la transmisión de datos 
                        state = TRANS1;
                    
                    else
                        state = PARITY;

                TRANS1:
                    state = TRANS0;

                PARITY:
                    state = STOP;

                STOP: 
                    if (txSend)                                             // Verificamos que el boton ya haya sido soltado
                        state = IDDLE;
                    else
                        state = STOP;

                default: 
                    state = IDDLE;

            endcase
        
    end

    always @(state) begin
        case (state)                                                // Banderas de los estados
            IDDLE:  begin
                tx = 1'b1;                                          // Línea de transmisión de datos
                countEnaTx = 1'b0;                                  // Bandera habilitadora de contador de datos transmitidos
            end

            START: begin
                tx = 1'b0;
                countEnaTx = 1'b1;
            end 

            TRANS0: begin
                tx = txData[dataCntTx-1'b1];                
                countEnaTx = 1'b1;
            end

            TRANS1: begin
                tx = txData[dataCntTx-1'b1];                
                countEnaTx = 1'b1;
            end

            PARITY: begin
                tx = (^txData);                
                countEnaTx = 1'b0;
            end

            STOP: begin
                tx = 1'b1;
                countEnaTx = 1'b0;
            end 

            default: begin
                tx = 1'b1;
                countEnaTx = 1'b0;
            end

        endcase

    end

endmodule

