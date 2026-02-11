`include "max30003_defs.vh"

module top (

    ///////////////////////////////////////////////////////
    // FPGA BOARD PINS (match XDC)
    ///////////////////////////////////////////////////////

    input  wire clk,

    // SPI → MAX30003
    input  wire spi_miso,
    output wire spi_mosi,
    output wire spi_sclk,
    output wire spi_cs,

    // Interrupt
    input  wire ecg_int,

    // UART → PC
    output wire uart_tx,
    input  wire uart_rx
);

///////////////////////////////////////////////////////////
// Internal Signals
///////////////////////////////////////////////////////////

wire [23:0] ecg_sample;
wire [15:0] heart_rate;
wire [15:0] rr_interval;
wire init_done;

///////////////////////////////////////////////////////////
// MAX30003 Driver
///////////////////////////////////////////////////////////

max30003_driver ECG_DRIVER (

    .clk(clk),
    .rst(1'b0),

    .sclk(spi_sclk),
    .mosi(spi_mosi),
    .miso(spi_miso),
    .cs(spi_cs),

    .start_init(1'b1),

    .ecg_sample(ecg_sample),
    .heart_rate(heart_rate),
    .rr_interval(rr_interval),
    .init_done(init_done)
);

///////////////////////////////////////////////////////////
// UART — send ECG samples to PC
///////////////////////////////////////////////////////////

uart_tx UART_TX (

    .clk(clk),
    .data(ecg_sample[7:0]),  // send LSB first (basic)
    .start(init_done),
    .tx(uart_tx),
    .busy()
);

endmodule
