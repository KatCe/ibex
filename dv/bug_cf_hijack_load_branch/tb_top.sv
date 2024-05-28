// tb_top_cfi_bug
module tb_top import ibex_pkg::*; ();

logic clk, rstz;

logic [31:0] instr_addr;

logic instr_req, instr_gnt, instr_rvalid, instr_err;
logic instr_ack;
logic [31:0] data_addr;
logic [31:0] data_rdata;
logic [3:0] data_mask;
logic data_wr_en;
logic data_req;
logic data_err;
logic data_ack, data_gnt, data_rvalid;
logic [31:0] instr_rdata;
logic [6:0] instr_rdata_intg;

logic [6:0] data_rdata_intg;

logic                         irq_software;
logic                         irq_timer;
logic                         irq_external;
logic [14:0]                  irq_fast;
logic                         irq_nm;

logic test_en;

logic [31:0]                  hart_id;
logic [31:0]                  boot_addr;

wire _0493_;

logic [31:0] unused_instr;
logic [6:0] instr_rdata_intg_tb_calc;

prim_secded_inv_39_32_enc calc_ecc(
  .data_i(instr_rdata),
  .data_o({instr_rdata_intg_tb_calc, unused_instr})
);

logic [31:0] unused_data;
logic [6:0] data_rdata_intg_tb_calc;

prim_secded_inv_39_32_enc calc_ecc2(
  .data_i(data_rdata),
  .data_o({data_rdata_intg_tb_calc, unused_data})
);

ibex_top #(
    .PMPEnable        ( 1'b0),
    .PMPGranularity   ( 0),
    .PMPNumRegions    ( 4),
    .MHPMCounterNum   ( 0),
    .MHPMCounterWidth ( 40),
    .RV32E            ( 1'b0),
    .RV32M            ( RV32MSlow),
    .RV32B            ( RV32BNone),
    .RegFile          ( RegFileFF),
    .BranchTargetALU  ( 1'b0),
    .WritebackStage   ( 1'b1),
    .ICache           ( 1'b0),
    .ICacheECC        ( 1'b0),
    .BranchPredictor  ( 1'b1),
    .DbgTriggerEn     ( 1'b0),
    .DbgHwBreakNum    ( 1),
    .SecureIbex       ( 1'b1),
    .ICacheScramble   ( 1'b0),
    .RndCnstLfsrSeed  ( RndCnstLfsrSeedDefault),
    .RndCnstLfsrPerm  ( RndCnstLfsrPermDefault),
    .DmHaltAddr       ( 32'h1A110800),
    .DmExceptionAddr  ( 32'h1A110808)
    ) u_top (
      .clk_i                  (clk),
      .rst_ni                 (rstz),

      .test_en_i              (0),
      .scan_rst_ni            (1'b1), // relevant for lockstep core only
      .ram_cfg_i              (0), // CEX: 10'h0

      .hart_id_i              (0),
      // First instruction executed is at 0x0 + 0x80
      .boot_addr_i            (boot_addr),

      .instr_req_o            (instr_req),
      .instr_gnt_i            (instr_gnt),
      .instr_rvalid_i         (instr_rvalid),
      .instr_addr_o           (instr_addr),
      .instr_rdata_i          (instr_rdata),
      .instr_rdata_intg_i     (instr_rdata_intg_tb_calc),
      .instr_err_i            (0),

      .data_req_o             (),
      .data_gnt_i             (data_gnt),
      .data_rvalid_i          (data_rvalid),
      .data_we_o              (),
      .data_be_o              (),
      .data_addr_o            (),
      .data_wdata_o           (),
      .data_wdata_intg_o      (),
      .data_rdata_i           (data_rdata),
      .data_rdata_intg_i      (data_rdata_intg_tb_calc),
      .data_err_i             (0),

      .irq_software_i         (1'b0),
      .irq_timer_i            (0),
      .irq_external_i         (1'b0),
      .irq_fast_i             (15'b0),
      .irq_nm_i               (1'b0),

      .scramble_key_valid_i   ('0),
      .scramble_key_i         ('0),
      .scramble_nonce_i       ('0),
      .scramble_req_o         (),

      .debug_req_i            (1'b0),
      .crash_dump_o           (),
      .double_fault_seen_o    (),

      .fetch_enable_i         (4'b0101),
      .alert_minor_o          (),
      .alert_major_internal_o (),
      .alert_major_bus_o      (),
      .core_sleep_o           ()

    );


initial begin
  clk = 0;
  rstz = 0;

  fork
    forever #1ns clk = ~clk;
  join_none

end

default clocking cb @(posedge clk); endclocking

reg test_done;

initial begin
  test_done <= 1'h0;
end

always @(posedge clk) begin

  if (!test_done) begin

    rstz <= 1'h0;
    instr_rdata <= 0;
    boot_addr <= 32'hff800300;
    data_gnt <= 1'h0;
    data_rvalid <= 1'h0;
    data_rdata <= 32'h0;
    ##3

    rstz <= 1'h1;

    instr_gnt <= 1'h0;
    instr_rvalid <= 1'h1;
    instr_rdata <= 32'h13; // NOP
    // data_gnt <= 1'h1;    // Do we see the bug if gnt is always 1? YES

    data_gnt <= 1'h0;
    data_rvalid <= 1'h0;
    data_rdata <= 32'hffffffff;

    ##1

    instr_rvalid <= 1'h0;
    instr_rdata<= 32'h13; // NOP

    ##1

    // Set up some test data values

    instr_rvalid <= 1'h1;

    instr_rdata <= 32'h777773b7; //          	lui	t2,0x77777
    ##1
    instr_rdata <= 32'h77738393; //          	addi	t2,t2,1911 # 77777777 <randdata0+0x7777769f>
    ##1
    instr_rdata <= 32'h28282e37; //          	lui	t3,0x28282
    ##1
    instr_rdata <= 32'h111e0e13; //          	addi	t3,t3,273 # 28282111 <randdata0+0x28282039>
    ##1
    instr_rdata <= 32'habcdaeb7; //          	lui	t4,0xabcda
    ##1

    // Choose this value to get an illegal instruction exception (will cause a misaligned PC)
    // instr_rdata <= 32'h222e8e93; //          	addi	t4,t4,546 # abcda222 <randdata0+0xabcda14a>

    // Choose this value to get a control flow hijack
    instr_rdata <= 32'h220e8e93; //          	addi	t4,t4,546 # abcda220 <randdata0+0xabcda14a>
    ##1

    boot_addr <= 32'hff800300;
    instr_rdata <= 32'h13; // NOP

    ##1

    boot_addr <= 32'h25ff3c00;
    instr_gnt <= 1'h1;
    instr_rvalid <= 1'h1;
    instr_rdata <= 32'h13; // NOP

    ##1
    // The sequence that causes the bug:
    boot_addr <= 32'h8049400;
    instr_rdata <= 32'hf44b0203; // lb      tp, -188(s6) // some load instruction is necessary here to cause the bug
    data_gnt <= 1'h1;            // The unsolicited grant here causes the bug <---
    data_rvalid <= 1'h0;
    ##1
    // data_gnt <= 1'h0;         // Does the bug appear if we set data_gnt to 0 here? NO
    boot_addr <= 32'h0;
    instr_rdata <= 32'h201ece63; // blt     t4, ra, pc + 540 <--- the problematic one. t4 = 29, ra = 1. Fetch address will be set to comparison result.
    ##1

    // Some random instructions to get longer trace
    boot_addr <= 32'hd2bef000;
    instr_rdata <= 32'h13; // NOP
    data_rdata <= 32'hf700ff7f;
    ##1

    boot_addr <= 32'h0;
    instr_rdata <= 32'h13; // NOP
    data_gnt <= 1'h0;
    data_rvalid <= 1'h1;
    data_rdata <= 32'hff00ff23;
    ##1
    data_rvalid <= 1'h0;
    hart_id <= 32'h20;
    instr_rdata <= 32'h13; // NOP
    data_rdata <= 32'hfa826f7f;
    ##1
    ##1
    instr_rdata <= 32'h13;
    ##1

    ##1
    instr_rdata <= 32'h00b540b3; //          	xor	ra,a0,a1
    ##1
    instr_rdata <= 32'h13;
    ##1

    instr_rdata <= 32'h13;
    ##1

    instr_rdata<=  32'h00138393; //         	addi	t2,t2,1
    ##1

    test_done <= 1'h1;

    end

  end


endmodule