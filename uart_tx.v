module uart_tx #

(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)

(
    input  wire clk,
    input  wire [31:0] data_in,
    input  wire start,
    output reg  tx,
    output reg  busy
);

////////////////////////////////////////////////////////////
// Baud generator
////////////////////////////////////////////////////////////
localparam BAUD_DIV = CLK_FREQ / BAUD;

reg [31:0] baud_cnt = 0;
reg baud_tick = 0;

always @(posedge clk) begin
    if (baud_cnt == BAUD_DIV-1) begin
        baud_cnt  <= 0;
        baud_tick <= 1;
    end else begin
        baud_cnt  <= baud_cnt + 1;
        baud_tick <= 0;
    end
end

////////////////////////////////////////////////////////////
// TX state machine
////////////////////////////////////////////////////////////
reg [5:0] bit_cnt = 0;
reg [31:0] shift_reg = 0;

always @(posedge clk) begin

    if (start && !busy) begin
        busy      <= 1;
        shift_reg <= data_in;
        bit_cnt   <= 0;
    end

    if (busy && baud_tick) begin

        case (bit_cnt)

            0:  tx <= 0; // Start bit

            1  : tx <= shift_reg[0];
            2  : tx <= shift_reg[1];
            3  : tx <= shift_reg[2];
            4  : tx <= shift_reg[3];
            5  : tx <= shift_reg[4];
            6  : tx <= shift_reg[5];
            7  : tx <= shift_reg[6];
            8  : tx <= shift_reg[7];
            9  : tx <= shift_reg[8];
            10 : tx <= shift_reg[9];
            11 : tx <= shift_reg[10];
            12 : tx <= shift_reg[11];
            13 : tx <= shift_reg[12];
            14 : tx <= shift_reg[13];
            15 : tx <= shift_reg[14];
            16 : tx <= shift_reg[15];
            17 : tx <= shift_reg[16];
            18 : tx <= shift_reg[17];
            19 : tx <= shift_reg[18];
            20 : tx <= shift_reg[19];
            21 : tx <= shift_reg[20];
            22 : tx <= shift_reg[21];
            23 : tx <= shift_reg[22];
            24 : tx <= shift_reg[23];
            25 : tx <= shift_reg[24];
            26 : tx <= shift_reg[25];
            27 : tx <= shift_reg[26];
            28 : tx <= shift_reg[27];
            29 : tx <= shift_reg[28];
            30 : tx <= shift_reg[29];
            31 : tx <= shift_reg[30];
            32 : tx <= shift_reg[31];

            33: tx <= 1; // Stop bit

            default: begin
                tx   <= 1;
                busy <= 0;
            end
        endcase

        bit_cnt <= bit_cnt + 1;
    end
end

endmodule
