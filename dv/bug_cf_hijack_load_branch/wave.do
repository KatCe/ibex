onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/clk
add wave -noupdate /tb_top/rstz
add wave -noupdate /tb_top/u_top/u_ibex_core/id_stage_i/clk_i
add wave -noupdate /tb_top/u_top/boot_addr_i
add wave -noupdate /tb_top/u_top/data_gnt_i
add wave -noupdate /tb_top/u_top/instr_rdata_i
add wave -noupdate /tb_top/u_top/instr_addr_o
add wave -noupdate /tb_top/u_top/u_ibex_core/id_stage_i/pc_id_i
add wave -noupdate /tb_top/u_top/u_ibex_core/if_stage_i/instr_out
add wave -noupdate /tb_top/u_top/u_ibex_core/id_stage_i/instr_rdata_i
add wave -noupdate /tb_top/u_top/u_ibex_core/if_stage_i/compressed_decoder_i/is_compressed_o
add wave -noupdate {/tb_top/u_top/gen_regfile_ff/register_file_i/g_rf_flops[7]/rf_reg_q}
add wave -noupdate {/tb_top/u_top/gen_regfile_ff/register_file_i/g_rf_flops[28]/rf_reg_q}
add wave -noupdate {/tb_top/u_top/gen_regfile_ff/register_file_i/g_rf_flops[29]/rf_reg_q}
add wave -noupdate /tb_top/u_top/lockstep_alert_major_internal
add wave -noupdate /tb_top/u_top/lockstep_alert_major_bus
add wave -noupdate /tb_top/u_top/lockstep_alert_minor
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36 ns} 0} {Trace {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 296
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {20 ns} {54 ns}
