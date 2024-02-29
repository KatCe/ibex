set LIB ./bug_mulh_reg_leakage_lib

set VOPTARGS "-voptargs=+acc"
set DEBUGDBARG "-debugdb"


rm -rf $LIB

set CURR_DIR [eval pwd]

vlog -64 -sv -work $LIB -f flist.f \
    -incdir $CURR_DIR/../../vendor/lowrisc_ip/dv/sv/dv_utils \
    -incdir $CURR_DIR/../../vendor/lowrisc_ip/ip/prim/rtl


vsim -64 -lib $LIB $DEBUGDBARG $VOPTARGS tb_top

log -r /*

# do wave.do
restart
run 1000ns

