module tb_top;

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



logic test_en;

logic [31:0]                  hart_id;
logic [31:0]                  boot_addr;



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


// --RV32E=0 --RV32M=ibex_pkg::RV32MSlow --RV32B=ibex_pkg::RV32BNone --RegFile=ibex_pkg::RegFileFF --BranchTargetALU=0 --WritebackStage=1 --ICache=0 --ICacheECC=0 --ICacheScramble=0 --BranchPredictor=1 --DbgTriggerEn=0 --SecureIbex=1 --PMPEnable=0 --PMPGranularity=0 --PMPNumRegions=4 --MHPMCounterNum=0 --MHPMCounterWidth=40


ibex_top #(
      // We have modified the default config
      // .SecureIbex      ( 1       ),
      // .ICacheScramble  ( 0   ),
      // .PMPEnable       ( 0        ),
      // .PMPGranularity  ( 0   ),
      // .PMPNumRegions   ( 4    ),
      // .MHPMCounterNum  ( 0   ),
      // .MHPMCounterWidth( 40 ),
      // .RV32E           ( 0            ),
      // .RV32M           ( ibex_pkg::RV32MSlow            ),
      // .RV32B           ( ibex_pkg::RV32BNone            ),
      // .RegFile         ( ibex_pkg::RegFileFF          ),
      // .BranchTargetALU ( 0  ),
      // .ICache          ( 0           ),
      // .ICacheECC       ( 0        ),
      // .WritebackStage  ( 1   ),
      // .BranchPredictor ( 1  ),
      // .DbgTriggerEn    ( 0     ),

    ) u_top (
      .clk_i                  (clk),
      .rst_ni                 (rstz),

      .test_en_i              (test_en),
      .scan_rst_ni            (1'b1), // relevant for lockstep core only
      .ram_cfg_i              (0), // CEX: 10'h0

      .hart_id_i              (hart_id),
      // First instruction executed is at 0x0 + 0x80
      .boot_addr_i            (boot_addr), // CEX: 32'hffffff00;

      .instr_req_o            (instr_req),
      .instr_gnt_i            (instr_gnt),
      .instr_rvalid_i         (instr_rvalid),
      .instr_addr_o           (instr_addr),
      .instr_rdata_i          (instr_rdata),
      .instr_rdata_intg_i     (instr_rdata_intg_tb_calc),
      .instr_err_i            (instr_err),

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
      .data_err_i             (data_err),

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
    instr_rdata_intg <= 0;

    ##3

    rstz <= 1'h1;

    test_en <= 1'h0;

    hart_id <= 32'h0;
    boot_addr <= 32'h0;
    instr_gnt <= 1'h0;
    instr_rvalid <= 1'h0;
    instr_rdata <= 32'h00000013; // NOP
    instr_err <= 1'h0;
    data_gnt <= 1'h0;
    data_rvalid <= 1'h0;
    data_err <= 1'h0;
    data_rdata <= 32'h0;
    ##1
    ##1
    instr_rvalid <= 1'h1;
    instr_rdata <= 32'h00000013; // NOP
    ##1
    // Changing the value loaded into gp, results in a different final value of t1 and t5. (Un)comment the following line for demonstration.
    //instr_rdata <= 32'hfffff1b7; //          	lui	gp,0xfffff
    instr_rdata <= 32'haaaaa1b7; //          	lui	gp,0xaaaaa
    ##1
    instr_rdata <= 32'h7ff18193; //         	addi	gp,gp,2047 # fffff7ff <randdata0+0x7ffff72f>
	  ##1
    // Changing the value loaded into t4, results in a different final value of t1 and t5. Switch between one of the thow instructions below for demonstration.
    instr_rdata <= 32'h2aae8e93;    //   	addi	t4,t4,682 # aaaaa2aa <randdata0+0x2aaaa1ea>;
    //instr_rdata <= 32'h000e8e93;  //    addi
    ##1
    instr_rdata <= 32'h023e93b3; // mulh	t2,t4,gp
    ##1
    ##1
    ##1
    // Now, or a few clock cycles later during mulh's execution, we see a data_err and data_rvalid being high at the same time
    // ##1
    // ##1
    data_err <= 1'h1;    // NECESSARY for the bug to happen
    data_rvalid <= 1'h1; // NECESSARY for the bug to happen
    ##1
    data_err <= 1'h0;
    ##1
    instr_rvalid <= 1'h1;
    instr_rdata <= 32'h00000013; // NOP
    data_err <= 1'h0;
    ##1
    // t3 is still 0 after reset
    instr_rdata <= 32'h03ce0f33; // mul     t5, t3, t3    <<<<<< stores a bad value into t5 (reg 30)
    ##1
    instr_rdata <= 32'h000f0333; //        	add	t1,t5,zero ... t1 = reg 06                 <<<<<< reads the bad value from t5
    test_done <= 1'h1;
  end

end




endmodule
