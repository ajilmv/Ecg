`include "max30003_defs.vh"

module max30003_driver (

    input  wire clk,
    input  wire rst,

    // SPI
    input  wire spi_miso,
    output reg  spi_mosi,
    output reg  spi_sclk,
    output reg  spi_cs,

    // ECG Data
    output reg [17:0] ecg_sample,
    output reg sample_valid
);

////////////////////////////////////////////////////////////
// Simple clock divider for SPI
////////////////////////////////////////////////////////////
reg [7:0] clk_div;
always @(posedge clk) clk_div <= clk_div + 1;
wire spi_clk = clk_div[2];

////////////////////////////////////////////////////////////
// FSM States
////////////////////////////////////////////////////////////
localparam IDLE  = 0;
localparam RESET = 1;
localparam CONFIG= 2;
localparam READ  = 3;

reg [1:0] state = IDLE;

////////////////////////////////////////////////////////////
// SPI shift
////////////////////////////////////////////////////////////
reg [31:0] shift_reg;
reg [5:0]  bit_cnt;

////////////////////////////////////////////////////////////
// FSM
////////////////////////////////////////////////////////////
always @(posedge clk) begin

    case(state)

    ////////////////////////////////////////////////////////
    IDLE:
    begin
        spi_cs <= 1;
        state  <= RESET;
    end

    ////////////////////////////////////////////////////////
    RESET:
    begin
        spi_cs   <= 0;
        shift_reg<= {`REG_SW_RST,24'h000000};
        state    <= CONFIG;
    end

    ////////////////////////////////////////////////////////
    CONFIG:
    begin
        spi_cs   <= 0;
        shift_reg<= {`REG_CNFG_GEN,24'h081007};
        state    <= READ;
    end

    ////////////////////////////////////////////////////////
    READ:
    begin
        spi_cs <= 0;

        // Fake ECG sample for now (until FIFO read added)
        ecg_sample   <= ecg_sample + 1;
        sample_valid <= 1;

        state <= READ;
    end

    endcase
end

endmodule
