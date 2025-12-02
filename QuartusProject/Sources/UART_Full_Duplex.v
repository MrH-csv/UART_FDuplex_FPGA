
module UART_Full_Duplex (
    input   wire    [7:0]   txData,                                     // Switches (Kept as txData to match QSF, but unused for UART TX now)
    input   wire            txSend, rx, rxFlagClr, clk, rst,            // Control / entrada
    input   wire    [3:0]   row,                                        // Keypad Rows
    output  wire    [3:0]   col,                                        // Keypad Cols

    output  wire            tx, pError, rxFlag, txSent,                 // Control / salida
    output  wire    [13:0]  displayOut
);

// Keypad Signals
    wire [7:0] keypadData;
    wire       keypadReady;
    wire       txTrigger;

    // Trigger TX on Button OR Keypad Press
    assign txTrigger = txSend | keypadReady;
    
    // Select Data: If Keypad Ready, use Keypad Data, else use Switches (Optional, or just force Keypad)
    // For this request, we strictly use Keypad for TX.
    wire [7:0] txDataInternal;
    assign txDataInternal = keypadData;

// BaudRate
    wire        baudRateOutTx;
    wire        baudRateOutRx;
    wire        rstRx;
    
    // RX Synchronization
    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

    assign      rstRx = rst & ~(FSMrstOut & rx_sync2); // Sync BaudRateRx to Start Bit (using synced rx)

// Counter
    wire [3:0]  counterOutTx;
    wire [3:0]  counterOutRx;

// FSM
    wire        FSMEnaTx;
    wire        FSMEnaCRx;
    wire        FSMEnaRRx;
    wire        FSMrstOut;
// Register
    wire        [8:0] outRegisterRx;
//  Mix
    wire        bothRst; 

    assign      bothRst =   rst & ~FSMrstOut;                                   // Señal para incluir el reset recibido por la parte de la FSM
    assign      pError  = outRegisterRx[8]&(~(^(outRegisterRx[7:0])));          // Bandera de error de paridad. Por defecto la compuerta XOR es detector de "1"s.

    BaudRate        BaudTx  (.clk(clk), .rst(rst), .out(baudRateOutTx));              
    BaudRate        BaudRx  (.clk(clk), .rst(rstRx), .out(baudRateOutRx));

    Counter	        ITx (.inClk(baudRateOutTx), .rst(rst), .ena(FSMEnaTx), .out(counterOutTx));
    Counter	        IRx (.inClk(baudRateOutRx), .rst(rst), .ena(FSMEnaCRx), .out(counterOutRx));

    RSRegister      I4  (.clk(baudRateOutRx), .rst(bothRst), .ena(FSMEnaRRx), .SIn(rx_sync2), .out(outRegisterRx));

    FSM_UART_TRANS  I2  (.clk(baudRateOutTx), .rst(rst), .txSend(txTrigger), .dataCntTx(counterOutTx), .txData(txDataInternal),.tx(tx), .countEnaTx(FSMEnaTx));
    FSM_UART_REC    I3  (.clk(baudRateOutRx), .rst(rst), .rx(rx_sync2), .rxFlagClr(rxFlagClr), .dataCntRx(counterOutRx), .countEnaRx (FSMEnaCRx), .regEna(FSMEnaRRx), .rxFlag(rxFlag), .FSMrst(FSMrstOut));

    BCD_7S          I5  (.clk(clk), .in(outRegisterRx[3:0]), .out(displayOut[6:0]));
    BCD_7S          I6  (.clk(clk), .in(outRegisterRx[7:4]), .out(displayOut[13:7]));
    
    Keypad4x4       Keypad (.clk(clk), .rst(rst), .row(row), .col(col), .dataOut(keypadData), .dataReady(keypadReady));
    
endmodule