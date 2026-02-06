`include "max30003_defs.vh"

module max30003_driver (

    input  wire clk,
    input  wire rst,

    ////////////////////////////////////////////////////////////
    // SPI pins to MAX30003
    ////////////////////////////////////////////////////////////
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs,

    ////////////////////////////////////////////////////////////
    // Control
    ////////////////////////////////////////////////////////////
    input  wire start_init,

    ////////////////////////////////////////////////////////////
    // Outputs
    ////////////////////////////////////////////////////////////
    output reg [23:0] ecg_sample,
    output reg [15:0] heart_rate,
    output reg [15:0] rr_interval,
    output reg init_done
);

//////////////////////////////////////////////////////////////
// SPI MASTER INSTANCE
//////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////
// DELAY COUNTER (for initialization timing)
//////////////////////////////////////////////////////////////

reg [27:0] delay_cnt;
wire delay_done = (delay_cnt == 0);

always @(posedge clk)
begin
    if (delay_cnt != 0)
        delay_cnt <= delay_cnt - 1;
end

//////////////////////////////////////////////////////////////
// FSM STATE DEFINITIONS
//////////////////////////////////////////////////////////////

localparam IDLE      = 0;
localparam RESET     = 1;
localparam WAIT1     = 2;
localparam GEN       = 3;
localparam WAIT2     = 4;
localparam CAL       = 5;
localparam WAIT3     = 6;
localparam EMUX      = 7;
localparam WAIT4     = 8;
localparam ECG_CFG   = 9;
localparam WAIT5     = 10;
localparam RTOR1     = 11;
localparam SYNC      = 12;
localparam INIT_DONE = 13;

//////////////////////////////////////////////////////////////
// RUN STATES (continuous acquisition)
//////////////////////////////////////////////////////////////

localparam READ_ECG_START = 14;
localparam READ_ECG_WAIT  = 15;
localparam READ_ECG_STORE = 16;

reg [4:0] state;

//////////////////////////////////////////////////////////////
// MAIN FSM
//////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin
if (rst)
begin
    state      <= IDLE;
    spi_start  <= 0;
    init_done  <= 0;
end
else
begin

    spi_start <= 0;   // default low

    case(state)

    //////////////////////////////////////////////////////////
    // IDLE
    //////////////////////////////////////////////////////////
    IDLE:
        if (start_init)
            state <= RESET;

    //////////////////////////////////////////////////////////
    // RESET DEVICE
    //////////////////////////////////////////////////////////
    RESET:
    begin
        spi_tx    <= {REG_SW_RST, 24'h000000};
        spi_start <= 1;

        if (spi_done)
        begin
            delay_cnt <= 28'd10_000_000; // 100 ms
            state <= WAIT1;
        end
    end

    WAIT1:
        if (delay_done)
            state <= GEN;

    //////////////////////////////////////////////////////////
    // CONFIGURATION SEQUENCE
    //////////////////////////////////////////////////////////

    GEN:
    begin
        spi_tx    <= {REG_CNFG_GEN, 24'h081007};
        spi_start <= 1;

        if (spi_done)
        begin
            delay_cnt <= 28'd5_000_000;
            state <= WAIT2;
        end
    end

    WAIT2:
        if (delay_done)
            state <= CAL;

    CAL:
    begin
        spi_tx    <= {REG_CNFG_CAL, 24'h720000};
        spi_start <= 1;

        if (spi_done)
        begin
            delay_cnt <= 28'd5_000_000;
            state <= WAIT3;
        end
    end

    WAIT3:
        if (delay_done)
            state <= EMUX;

    EMUX:
    begin
        spi_tx    <= {REG_CNFG_EMUX, 24'h0B0000};
        spi_start <= 1;

        if (spi_done)
        begin
            delay_cnt <= 28'd5_000_000;
            state <= WAIT4;
        end
    end

    WAIT4:
        if (delay_done)
            state <= ECG_CFG;

    ECG_CFG:
    begin
        spi_tx    <= {REG_CNFG_ECG, 24'h805000};
        spi_start <= 1;

        if (spi_done)
        begin
            delay_cnt <= 28'd5_000_000;
            state <= WAIT5;
        end
    end

    WAIT5:
        if (delay_done)
            state <= RTOR1;

    RTOR1:
    begin
        spi_tx    <= {REG_CNFG_RTOR1, 24'h3FC600};
        spi_start <= 1;

        if (spi_done)
            state <= SYNC;
    end

    SYNC:
    begin
        spi_tx    <= {REG_SYNCH, 24'h000000};
        spi_start <= 1;

        if (spi_done)
            state <= INIT_DONE;
    end

    //////////////////////////////////////////////////////////
    // INIT COMPLETE → START ACQUISITION
    //////////////////////////////////////////////////////////

    INIT_DONE:
    begin
        init_done <= 1;
        state <= READ_ECG_START;
    end

    //////////////////////////////////////////////////////////
    // CONTINUOUS ECG SAMPLING LOOP
    //////////////////////////////////////////////////////////

    READ_ECG_START:
    begin
        spi_tx    <= {REG_ECG_FIFO, 24'hFFFFFF};
        spi_start <= 1;
        state <= READ_ECG_WAIT;
    end

    READ_ECG_WAIT:
        if (spi_done)
            state <= READ_ECG_STORE;

    READ_ECG_STORE:
    begin
        ecg_sample <= spi_rx[23:0];

        // Optional simple HR placeholder
        heart_rate <= heart_rate;
        rr_interval <= rr_interval;

        state <= READ_ECG_START; // loop forever
    end

    //////////////////////////////////////////////////////////

    default:
        state <= IDLE;

    endcase
end
end

endmodule
