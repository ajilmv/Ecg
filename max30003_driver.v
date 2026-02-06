`include "max30003_defs.vh"

module max30003_driver (

    input  wire clk,
    input  wire rst,

    // SPI pins
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs,

    // Control
    input  wire start_init,
    input  wire start_read,

    // Outputs
    output reg [23:0] ecg_sample,
    output reg [15:0] heart_rate,
    output reg [15:0] rr_interval,
    output reg init_done

);

////////////////////////////////////////////////////////////
// SPI Instance
////////////////////////////////////////////////////////////

reg        spi_start;
reg [31:0] spi_tx;
wire [31:0] spi_rx;
wire       spi_done;

spi_master SPI0 (
    .clk(clk),
    .rst(rst),
    .start(spi_start),
    .tx_data(spi_tx),
    .rx_data(spi_rx),
    .done(spi_done),
    .sclk(sclk),
    .mosi(mosi),
    .miso(miso),
    .cs(cs)
);

////////////////////////////////////////////////////////////
// Delay Counter (replaces delay())
////////////////////////////////////////////////////////////

reg [23:0] delay_cnt;
reg delay_done;

always @(posedge clk) begin
    if (delay_cnt == 24'd5_000_000) begin
        delay_done <= 1;
        delay_cnt <= 0;
    end
    else begin
        delay_cnt <= delay_cnt + 1;
        delay_done <= 0;
    end
end

////////////////////////////////////////////////////////////
// Initialization FSM  (Converted begin())
////////////////////////////////////////////////////////////

localparam IDLE  = 0;
localparam RESET = 1;
localparam GEN   = 2;
localparam CAL   = 3;
localparam EMUX  = 4;
localparam ECG   = 5;
localparam RTOR1 = 6;
localparam SYNC  = 7;
localparam DONE  = 8;

reg [3:0] state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        init_done <= 0;
        spi_start <= 0;
    end
    else begin
        case(state)

        IDLE:
            if (start_init)
                state <= RESET;

        RESET: begin
            spi_tx <= {REG_SW_RST, 24'h000000};
            spi_start <= 1;
            if (spi_done) state <= GEN;
        end

        GEN: begin
            spi_tx <= {REG_CNFG_GEN, 24'h081007};
            spi_start <= 1;
            if (spi_done) state <= CAL;
        end

        CAL: begin
            spi_tx <= {REG_CNFG_CAL, 24'h720000};
            spi_start <= 1;
            if (spi_done) state <= EMUX;
        end

        EMUX: begin
            spi_tx <= {REG_CNFG_EMUX, 24'h0B0000};
            spi_start <= 1;
            if (spi_done) state <= ECG;
        end

        ECG: begin
            spi_tx <= {REG_CNFG_ECG, 24'h805000};
            spi_start <= 1;
            if (spi_done) state <= RTOR1;
        end

        RTOR1: begin
            spi_tx <= {REG_CNFG_RTOR1, 24'h3FC600};
            spi_start <= 1;
            if (spi_done) state <= SYNC;
        end

        SYNC: begin
            spi_tx <= {REG_SYNCH, 24'h000000};
            spi_start <= 1;
            if (spi_done) state <= DONE;
        end

        DONE: begin
            init_done <= 1;
            state <= IDLE;
        end

        endcase
    end
end

////////////////////////////////////////////////////////////
// ECG Sample Read  (readEcgSample)
////////////////////////////////////////////////////////////

always @(posedge clk) begin
    if (start_read) begin
        spi_tx <= {REG_ECG_FIFO, 24'hFFFFFF};
        spi_start <= 1;
    end

    if (spi_done) begin
        ecg_sample <= spi_rx[23:0];
    end
end

////////////////////////////////////////////////////////////
// Heart Rate Calculation  (updateHeartRate)
////////////////////////////////////////////////////////////

reg [15:0] rtor;

always @(posedge clk) begin

    if (start_read) begin
        spi_tx <= {REG_RTOR, 24'hFFFFFF};
        spi_start <= 1;
    end

    if (spi_done) begin

        rtor <= (spi_rx[23:8] >> 2) & 16'h3FFF;

        if (rtor != 0) begin
            heart_rate <= 16'd7680 / rtor;
            rr_interval <= rtor * 8;
        end
    end

end

endmodule
