module spi_master (

    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [31:0] tx_data,
    output reg  [31:0] rx_data,
    output reg  done,

    output reg sclk,
    output reg mosi,
    input  wire miso,
    output reg cs

);

parameter CLK_DIV = 25; // ~2 MHz from 100 MHz

reg [7:0] clk_cnt;
reg [5:0] bit_cnt;
reg [31:0] shift_tx;
reg [31:0] shift_rx;
reg busy;

//////////////////////////////////////////////////
// Clock divider
//////////////////////////////////////////////////

always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_cnt <= 0;
        sclk <= 0;
    end
    else if (busy) begin
        if (clk_cnt == CLK_DIV) begin
            clk_cnt <= 0;
            sclk <= ~sclk;
        end
        else
            clk_cnt <= clk_cnt + 1;
    end
    else
        sclk <= 0;
end

//////////////////////////////////////////////////
// SPI FSM
//////////////////////////////////////////////////

localparam IDLE  = 0;
localparam SHIFT = 1;
localparam DONE  = 2;

reg [1:0] state;

always @(posedge sclk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        cs <= 1;
        done <= 0;
    end
    else begin
        case(state)

        IDLE: begin
            done <= 0;
            if (start) begin
                cs <= 0;
                shift_tx <= tx_data;
                bit_cnt <= 31;
                busy <= 1;
                state <= SHIFT;
            end
        end

        SHIFT: begin
            mosi <= shift_tx[bit_cnt];
            shift_rx[bit_cnt] <= miso;

            if (bit_cnt == 0)
                state <= DONE;
            else
                bit_cnt <= bit_cnt - 1;
        end

        DONE: begin
            cs <= 1;
            busy <= 0;
            rx_data <= shift_rx;
            done <= 1;
            state <= IDLE;
        end

        endcase
    end
end

endmodule
