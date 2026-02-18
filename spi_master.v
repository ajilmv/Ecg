module spi_master (

    input  wire        clk,        // System clock (100 MHz)
    input  wire        rst,        // Reset

    input  wire        start,      // Start SPI transfer
    input  wire [31:0] tx_data,    // Data to transmit
    output reg  [31:0] rx_data,    // Data received
    output reg         done,       // Transfer complete

    // SPI Pins
    output reg  sclk,
    output reg  mosi,
    input  wire miso,
    output reg  cs

);

////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////

parameter CLK_DIV = 25;  
// 100 MHz / (2*25) = 2 MHz SPI clock (safe for MAX30003)

////////////////////////////////////////////////////////////
// Internal Registers
////////////////////////////////////////////////////////////

reg [7:0]  clk_cnt;
reg        spi_clk_en;
reg [5:0]  bit_cnt;
reg [31:0] shift_tx;
reg [31:0] shift_rx;

////////////////////////////////////////////////////////////
// Clock Divider → Generate SCLK
////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_cnt <= 0;
        sclk <= 0;
    end
    else if (spi_clk_en) begin
        if (clk_cnt == CLK_DIV-1) begin
            clk_cnt <= 0;
            sclk <= ~sclk;
        end
        else
            clk_cnt <= clk_cnt + 1;
    end
    else begin
        clk_cnt <= 0;
        sclk <= 0;
    end
end

////////////////////////////////////////////////////////////
// SPI State Machine
////////////////////////////////////////////////////////////

localparam IDLE  = 0;
localparam LOAD  = 1;
localparam SHIFT = 2;
localparam DONE  = 3;

reg [1:0] state;

always @(posedge clk or posedge rst) begin

    if (rst) begin
        state   <= IDLE;
        cs      <= 1;
        done    <= 0;
        spi_clk_en <= 0;
        bit_cnt <= 0;
        mosi    <= 0;
    end

    else begin

        done <= 0;

        case(state)

        //////////////////////////////////////////////////////
        // IDLE
        //////////////////////////////////////////////////////
        IDLE: begin
            cs <= 1;
            spi_clk_en <= 0;

            if (start) begin
                shift_tx <= tx_data;
                bit_cnt  <= 31;
                cs <= 0;                 // Activate chip
                spi_clk_en <= 1;
                state <= LOAD;
            end
        end

        //////////////////////////////////////////////////////
        // LOAD FIRST BIT
        //////////////////////////////////////////////////////
        LOAD: begin
            mosi <= shift_tx[31];
            state <= SHIFT;
        end

        //////////////////////////////////////////////////////
        // SHIFT DATA
        //////////////////////////////////////////////////////
        SHIFT: begin

            if (sclk == 0 && clk_cnt == 0) begin
                // Sample MISO
                shift_rx[bit_cnt] <= miso;

                if (bit_cnt == 0) begin
                    spi_clk_en <= 0;
                    state <= DONE;
                end
                else begin
                    bit_cnt <= bit_cnt - 1;
                    shift_tx <= shift_tx << 1;
                    mosi <= shift_tx[30];
                end
            end
        end

        //////////////////////////////////////////////////////
        // DONE
        //////////////////////////////////////////////////////
        DONE: begin
            cs <= 1;
            rx_data <= shift_rx;
            done <= 1;
            state <= IDLE;
        end

        endcase
    end
end

endmodule
