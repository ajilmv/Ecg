module top (

    input  wire clk,

    // SPI - MAX30003
    input  wire spi_miso,
    output wire spi_mosi,
    output wire spi_sclk,
    output wire spi_cs,
    input  wire ecg_int,

    // UART
    output wire uart_tx,
    input  wire uart_rx
);

////////////////////////////////////////////////////////////
// ECG Driver wires
////////////////////////////////////////////////////////////
wire [17:0] ecg_sample;
wire sample_valid;

////////////////////////////////////////////////////////////
// Instantiate MAX30003 Driver
////////////////////////////////////////////////////////////
max30003_driver ECG (

    .clk(clk),
    .rst(1'b0),

    .spi_miso(spi_miso),
    .spi_mosi(spi_mosi),
    .spi_sclk(spi_sclk),
    .spi_cs  (spi_cs),

    .ecg_sample(ecg_sample),
    .sample_valid(sample_valid)
);

////////////////////////////////////////////////////////////
// UART transmitter
////////////////////////////////////////////////////////////
uart_tx UART (

    .clk(clk),
    .data_in({14'b0, ecg_sample}), // 32-bit frame
    .start(sample_valid),
    .tx(uart_tx),
    .busy()
);

endmodule
