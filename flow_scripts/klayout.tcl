exec klayout -zz -rd design_name= i2c_master_top \
  -rd in_def= "/home/nzheludkov/phd/runs/sky130/i2c_master_top/CLK_30.0_IO_0.33_CU_20_AR_1.0_HW_8_HS_8_HP_80_VW_3_VS_3_VP_30/route/def/def.def" \
  -rd in_files="/home/nzheludkov/phd/lambdapdk/lambdapdk/sky130/libs/sky130hd/gds/sky130_fd_sc_hd.gds" \
  -rd out_file="/home/nzheludkov/phd/runs/sky130/i2c_master_top/CLK_30.0_IO_0.33_CU_20_AR_1.0_HW_8_HS_8_HP_80_VW_3_VS_3_VP_30/route/gds.gds" \
  -rd tech_file=$::env(OBJECTS_DIR)/klayout.lyt \
  -rm $::env(UTILS_DIR)/def2stream.py
