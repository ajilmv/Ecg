`ifndef MAX30003_DEFS_VH
`define MAX30003_DEFS_VH

// Read / Write
`define WREG 1'b0
`define RREG 1'b1

// Registers
`define REG_STATUS        8'h01
`define REG_SW_RST        8'h08
`define REG_FIFO_RST      8'h0A

`define REG_CNFG_GEN      8'h10
`define REG_CNFG_CAL      8'h12
`define REG_CNFG_EMUX     8'h14
`define REG_CNFG_ECG      8'h15

`define REG_ECG_FIFO      8'h21

`endif
