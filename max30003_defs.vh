`ifndef MAX30003_DEFS_VH
`define MAX30003_DEFS_VH

// R/W flags
parameter WREG = 1'b0;
parameter RREG = 1'b1;

// Registers
parameter REG_SW_RST         = 8'h08;
parameter REG_SYNCH          = 8'h09;
parameter REG_INFO           = 8'h0F;
parameter REG_CNFG_GEN       = 8'h10;
parameter REG_CNFG_CAL       = 8'h12;
parameter REG_CNFG_EMUX      = 8'h14;
parameter REG_CNFG_ECG       = 8'h15;
parameter REG_CNFG_RTOR1     = 8'h1D;
parameter REG_ECG_FIFO       = 8'h21;
parameter REG_RTOR           = 8'h25;

`endif
