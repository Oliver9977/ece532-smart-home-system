
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# ADXL362Ctrl

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: myRange
proc create_hier_cell_myRange { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_myRange() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 jb

  # Create pins
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir I -type clk aclk_0
  create_bd_pin -dir I -type rst aresetn_0
  create_bd_pin -dir O range_status_0

  # Create instance: PmodMAXSONAR_0, and set properties
  set PmodMAXSONAR_0 [ create_bd_cell -type ip -vlnv digilentinc.com:IP:PmodMAXSONAR:1.0 PmodMAXSONAR_0 ]
  set_property -dict [ list \
   CONFIG.PMOD {jb} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $PmodMAXSONAR_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_0

  # Create instance: driver_ip_0, and set properties
  set driver_ip_0 [ create_bd_cell -type ip -vlnv utoronto.ca:user:driver_ip:1.0 driver_ip_0 ]
  set_property -dict [ list \
   CONFIG.C_M_TARGET_SLAVE_BASE_ADDR {0x44A00000} \
   CONFIG.DEBUG_MODE {false} \
 ] $driver_ip_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins jb] [get_bd_intf_pins PmodMAXSONAR_0/Pmod_out]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins PmodMAXSONAR_0/AXI_LITE_GPIO] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net driver_ip_0_M_AXI_0 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins driver_ip_0/M_AXI_0]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins axi_interconnect_0/ARESETN]
  connect_bd_net -net aclk_0_1 [get_bd_pins aclk_0] [get_bd_pins PmodMAXSONAR_0/s00_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins driver_ip_0/aclk]
  connect_bd_net -net aresetn_0_1 [get_bd_pins aresetn_0] [get_bd_pins PmodMAXSONAR_0/s00_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins driver_ip_0/aresetn]
  connect_bd_net -net driver_ip_0_range_status_0 [get_bd_pins range_status_0] [get_bd_pins driver_ip_0/range_status_0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: myALS
proc create_hier_cell_myALS { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_myALS() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 ja

  # Create pins
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir I -type clk ext_spi_clk
  create_bd_pin -dir I mals_axi_init_axi_txn
  create_bd_pin -dir O pmod_data_ready_out
  create_bd_pin -dir O -from 7 -to 0 result_0_test
  create_bd_pin -dir O -from 7 -to 0 result_2_test
  create_bd_pin -dir I -type clk s00_axi_aclk
  create_bd_pin -dir I -type rst s00_axi_aresetn

  # Create instance: PmodALS_0, and set properties
  set PmodALS_0 [ create_bd_cell -type ip -vlnv digilentinc.com:IP:PmodALS:1.0 PmodALS_0 ]
  set_property -dict [ list \
   CONFIG.PMOD {ja} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $PmodALS_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_0

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {5} \
   CONFIG.C_PROBE0_WIDTH {1} \
   CONFIG.C_PROBE10_WIDTH {1} \
   CONFIG.C_PROBE11_WIDTH {1} \
   CONFIG.C_PROBE12_WIDTH {1} \
   CONFIG.C_PROBE13_WIDTH {1} \
   CONFIG.C_PROBE14_WIDTH {1} \
   CONFIG.C_PROBE15_WIDTH {1} \
   CONFIG.C_PROBE16_WIDTH {1} \
   CONFIG.C_PROBE17_WIDTH {1} \
   CONFIG.C_PROBE18_WIDTH {1} \
   CONFIG.C_PROBE1_WIDTH {8} \
   CONFIG.C_PROBE20_WIDTH {1} \
   CONFIG.C_PROBE22_WIDTH {1} \
   CONFIG.C_PROBE23_WIDTH {1} \
   CONFIG.C_PROBE2_WIDTH {8} \
   CONFIG.C_PROBE3_WIDTH {8} \
   CONFIG.C_PROBE4_WIDTH {1} \
   CONFIG.C_PROBE5_WIDTH {1} \
   CONFIG.C_PROBE6_WIDTH {1} \
   CONFIG.C_PROBE7_WIDTH {1} \
 ] $ila_0

  # Create instance: myALSMaster_0, and set properties
  set myALSMaster_0 [ create_bd_cell -type ip -vlnv user.org:user:myALSMaster:1.0 myALSMaster_0 ]
  set_property -dict [ list \
   CONFIG.C_MALS_AXI_TARGET_SLAVE_BASE_ADDR {0x00010000} \
   CONFIG.DEBUG_MODE {false} \
 ] $myALSMaster_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins ja] [get_bd_intf_pins PmodALS_0/Pmod_out]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins PmodALS_0/AXI_LITE_SPI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net myALSMaster_0_MALS_AXI [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins myALSMaster_0/MALS_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins axi_interconnect_0/ARESETN]
  connect_bd_net -net decision_main_block_0_light_sensor_rd_en_out [get_bd_pins mals_axi_init_axi_txn] [get_bd_pins myALSMaster_0/mals_axi_init_axi_txn]
  connect_bd_net -net ext_spi_clk_1 [get_bd_pins ext_spi_clk] [get_bd_pins PmodALS_0/ext_spi_clk]
  connect_bd_net -net myALSMaster_0_error_out [get_bd_pins ila_0/probe0] [get_bd_pins myALSMaster_0/error_out]
  connect_bd_net -net myALSMaster_0_pmod_data_ready_out [get_bd_pins pmod_data_ready_out] [get_bd_pins ila_0/probe4] [get_bd_pins myALSMaster_0/pmod_data_ready_out]
  connect_bd_net -net myALSMaster_0_result_0_test [get_bd_pins result_0_test] [get_bd_pins ila_0/probe1] [get_bd_pins myALSMaster_0/result_0_test]
  connect_bd_net -net myALSMaster_0_result_1_test [get_bd_pins ila_0/probe2] [get_bd_pins myALSMaster_0/result_1_test]
  connect_bd_net -net myALSMaster_0_result_2_test [get_bd_pins result_2_test] [get_bd_pins ila_0/probe3] [get_bd_pins myALSMaster_0/result_2_test]
  connect_bd_net -net s00_axi_aclk_1 [get_bd_pins s00_axi_aclk] [get_bd_pins PmodALS_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins ila_0/clk] [get_bd_pins myALSMaster_0/mals_axi_aclk]
  connect_bd_net -net s00_axi_aresetn_1 [get_bd_pins s00_axi_aresetn] [get_bd_pins PmodALS_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins myALSMaster_0/mals_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: MyDecisionMakingBlock
proc create_hier_cell_MyDecisionMakingBlock { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_MyDecisionMakingBlock() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI1

  # Create pins
  create_bd_pin -dir I acc_vld
  create_bd_pin -dir I -from 11 -to 0 acc_x
  create_bd_pin -dir I -from 11 -to 0 acc_y
  create_bd_pin -dir I -from 11 -to 0 acc_z
  create_bd_pin -dir I -from 7 -to 0 light_sensor_rd_data_0
  create_bd_pin -dir I -from 7 -to 0 light_sensor_rd_data_1
  create_bd_pin -dir O light_sensor_rd_en_out
  create_bd_pin -dir I light_sensor_rd_vld
  create_bd_pin -dir O -from 1 -to 0 o_climate_control
  create_bd_pin -dir O -from 7 -to 0 o_climate_control_temperature
  create_bd_pin -dir O o_distance_sensor_val
  create_bd_pin -dir O -from 2 -to 0 o_enable_light
  create_bd_pin -dir O -from 7 -to 0 o_light_sensor_val
  create_bd_pin -dir O o_open_door
  create_bd_pin -dir O -from 15 -to 0 o_temperature_val
  create_bd_pin -dir O -from 5 -to 0 o_weather_val
  create_bd_pin -dir I range_status
  create_bd_pin -dir I -type clk s00_axi_aclk
  create_bd_pin -dir I -type rst s00_axi_aresetn
  create_bd_pin -dir I -from 12 -to 0 temperature
  create_bd_pin -dir I temperature_vld
  create_bd_pin -dir O -from 7 -to 0 weather_temperature

  # Create instance: decision_ip_0, and set properties
  set decision_ip_0 [ create_bd_cell -type ip -vlnv user.org:user:decision_ip:1.0 decision_ip_0 ]

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {18} \
   CONFIG.C_PROBE0_WIDTH {8} \
   CONFIG.C_PROBE10_WIDTH {32} \
   CONFIG.C_PROBE11_WIDTH {32} \
   CONFIG.C_PROBE13_WIDTH {26} \
   CONFIG.C_PROBE14_WIDTH {16} \
   CONFIG.C_PROBE16_WIDTH {32} \
   CONFIG.C_PROBE17_WIDTH {32} \
   CONFIG.C_PROBE2_WIDTH {6} \
   CONFIG.C_PROBE3_WIDTH {1} \
   CONFIG.C_PROBE4_WIDTH {32} \
   CONFIG.C_PROBE5_WIDTH {32} \
   CONFIG.C_PROBE6_WIDTH {32} \
   CONFIG.C_PROBE7_WIDTH {32} \
   CONFIG.C_PROBE8_WIDTH {32} \
   CONFIG.C_PROBE9_WIDTH {32} \
 ] $ila_0

  # Create instance: ila_2, and set properties
  set ila_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_2 ]
  set_property -dict [ list \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {5} \
   CONFIG.C_PROBE0_WIDTH {13} \
   CONFIG.C_PROBE1_WIDTH {16} \
   CONFIG.C_PROBE3_WIDTH {8} \
   CONFIG.C_PROBE4_WIDTH {8} \
 ] $ila_2

  # Create instance: mydecisionslave_0, and set properties
  set mydecisionslave_0 [ create_bd_cell -type ip -vlnv user.org:user:mydecisionslave:2.0 mydecisionslave_0 ]

  # Create instance: mydecisionslave_2_0, and set properties
  set mydecisionslave_2_0 [ create_bd_cell -type ip -vlnv user.org:user:mydecisionslave_2:1.0 mydecisionslave_2_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins mydecisionslave_0/S00_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins S00_AXI1] [get_bd_intf_pins mydecisionslave_2_0/S00_AXI]

  # Create port connections
  connect_bd_net -net acc_vld_1 [get_bd_pins acc_vld] [get_bd_pins decision_ip_0/acc_vld]
  connect_bd_net -net acc_x_1 [get_bd_pins acc_x] [get_bd_pins decision_ip_0/acc_x]
  connect_bd_net -net acc_y_1 [get_bd_pins acc_y] [get_bd_pins decision_ip_0/acc_y]
  connect_bd_net -net acc_z_1 [get_bd_pins acc_z] [get_bd_pins decision_ip_0/acc_z]
  connect_bd_net -net decision_ip_0_acc_mag_test [get_bd_pins decision_ip_0/acc_mag_test] [get_bd_pins ila_0/probe14]
  connect_bd_net -net decision_ip_0_acc_mag_vld_test [get_bd_pins decision_ip_0/acc_mag_vld_test] [get_bd_pins ila_0/probe15]
  connect_bd_net -net decision_ip_0_light_sensor_rd_en_out [get_bd_pins light_sensor_rd_en_out] [get_bd_pins decision_ip_0/light_sensor_rd_en_out]
  connect_bd_net -net decision_ip_0_o_climate_control [get_bd_pins o_climate_control] [get_bd_pins decision_ip_0/o_climate_control]
  connect_bd_net -net decision_ip_0_o_climate_control_temperature [get_bd_pins o_climate_control_temperature] [get_bd_pins decision_ip_0/o_climate_control_temperature] [get_bd_pins ila_2/probe4]
  connect_bd_net -net decision_ip_0_o_distance_sensor_val [get_bd_pins o_distance_sensor_val] [get_bd_pins decision_ip_0/o_distance_sensor_val]
  connect_bd_net -net decision_ip_0_o_enable_light [get_bd_pins o_enable_light] [get_bd_pins decision_ip_0/o_enable_light]
  connect_bd_net -net decision_ip_0_o_light_sensor_val [get_bd_pins o_light_sensor_val] [get_bd_pins decision_ip_0/o_light_sensor_val]
  connect_bd_net -net decision_ip_0_o_open_door [get_bd_pins o_open_door] [get_bd_pins decision_ip_0/o_open_door]
  connect_bd_net -net decision_ip_0_o_temperature_val [get_bd_pins o_temperature_val] [get_bd_pins decision_ip_0/o_temperature_val] [get_bd_pins ila_2/probe1]
  connect_bd_net -net decision_ip_0_o_weather_val [get_bd_pins o_weather_val] [get_bd_pins decision_ip_0/o_weather_val]
  connect_bd_net -net decision_ip_0_sensor_msg_intrpt [get_bd_pins decision_ip_0/sensor_msg_intrpt] [get_bd_pins mydecisionslave_0/sensor_msg_intrpt]
  connect_bd_net -net decision_ip_0_xyz_sum_test [get_bd_pins decision_ip_0/xyz_sum_test] [get_bd_pins ila_0/probe13]
  connect_bd_net -net light_sensor_rd_data_0_1 [get_bd_pins light_sensor_rd_data_0] [get_bd_pins decision_ip_0/light_sensor_rd_data_0] [get_bd_pins ila_0/probe1]
  connect_bd_net -net light_sensor_rd_data_1_1 [get_bd_pins light_sensor_rd_data_1] [get_bd_pins decision_ip_0/light_sensor_rd_data_1] [get_bd_pins ila_0/probe0]
  connect_bd_net -net light_sensor_rd_vld_1 [get_bd_pins light_sensor_rd_vld] [get_bd_pins decision_ip_0/light_sensor_rd_vld]
  connect_bd_net -net mydecisionslave_0_sensor_intrpt_en [get_bd_pins decision_ip_0/sensor_intrpt_en] [get_bd_pins ila_0/probe16] [get_bd_pins mydecisionslave_0/sensor_intrpt_en]
  connect_bd_net -net mydecisionslave_0_sensor_intrpt_rst [get_bd_pins decision_ip_0/sensor_intrpt_rst] [get_bd_pins ila_0/probe17] [get_bd_pins mydecisionslave_0/sensor_intrpt_rst]
  connect_bd_net -net mydecisionslave_0_slv_reg0_test [get_bd_pins ila_0/probe4] [get_bd_pins mydecisionslave_0/slv_reg0_test]
  connect_bd_net -net mydecisionslave_0_slv_reg1_test [get_bd_pins ila_0/probe5] [get_bd_pins mydecisionslave_0/slv_reg1_test]
  connect_bd_net -net mydecisionslave_0_slv_reg2_test [get_bd_pins ila_0/probe6] [get_bd_pins mydecisionslave_0/slv_reg2_test]
  connect_bd_net -net mydecisionslave_0_slv_reg3_test [get_bd_pins ila_0/probe7] [get_bd_pins mydecisionslave_0/slv_reg3_test]
  connect_bd_net -net mydecisionslave_0_slv_reg4_test [get_bd_pins ila_0/probe8] [get_bd_pins mydecisionslave_0/slv_reg4_test]
  connect_bd_net -net mydecisionslave_0_slv_reg5_test [get_bd_pins decision_ip_0/acc_max] [get_bd_pins ila_0/probe9] [get_bd_pins mydecisionslave_0/slv_reg5_test]
  connect_bd_net -net mydecisionslave_0_slv_reg6_test [get_bd_pins decision_ip_0/temp_max] [get_bd_pins ila_0/probe10] [get_bd_pins mydecisionslave_0/slv_reg6_test]
  connect_bd_net -net mydecisionslave_0_slv_reg7_test [get_bd_pins decision_ip_0/temp_min] [get_bd_pins ila_0/probe11] [get_bd_pins mydecisionslave_0/slv_reg7_test]
  connect_bd_net -net mydecisionslave_0_tx_init [get_bd_pins decision_ip_0/light_sensor_rd_en] [get_bd_pins ila_0/probe12] [get_bd_pins mydecisionslave_0/tx_init]
  connect_bd_net -net mydecisionslave_0_weather_data [get_bd_pins decision_ip_0/weather_data_in] [get_bd_pins ila_0/probe2] [get_bd_pins mydecisionslave_0/weather_data]
  connect_bd_net -net mydecisionslave_2_0_ac_high [get_bd_pins decision_ip_0/ac_high] [get_bd_pins mydecisionslave_2_0/ac_high]
  connect_bd_net -net mydecisionslave_2_0_ac_low [get_bd_pins decision_ip_0/ac_low] [get_bd_pins mydecisionslave_2_0/ac_low]
  connect_bd_net -net mydecisionslave_2_0_ac_temp [get_bd_pins decision_ip_0/ac_temp] [get_bd_pins mydecisionslave_2_0/ac_temp]
  connect_bd_net -net mydecisionslave_2_0_light_dark [get_bd_pins decision_ip_0/light_dark] [get_bd_pins mydecisionslave_2_0/light_dark]
  connect_bd_net -net mydecisionslave_2_0_weather_temperature [get_bd_pins weather_temperature] [get_bd_pins ila_2/probe3] [get_bd_pins mydecisionslave_2_0/weather_temperature]
  connect_bd_net -net range_status_1 [get_bd_pins range_status] [get_bd_pins decision_ip_0/range_status] [get_bd_pins ila_0/probe3]
  connect_bd_net -net s00_axi_aclk_1 [get_bd_pins s00_axi_aclk] [get_bd_pins decision_ip_0/aclk] [get_bd_pins ila_0/clk] [get_bd_pins ila_2/clk] [get_bd_pins mydecisionslave_0/s00_axi_aclk] [get_bd_pins mydecisionslave_2_0/s00_axi_aclk]
  connect_bd_net -net s00_axi_aresetn_1 [get_bd_pins s00_axi_aresetn] [get_bd_pins decision_ip_0/aresetn] [get_bd_pins mydecisionslave_0/s00_axi_aresetn] [get_bd_pins mydecisionslave_2_0/s00_axi_aresetn]
  connect_bd_net -net temperature_1 [get_bd_pins temperature] [get_bd_pins decision_ip_0/temperature] [get_bd_pins ila_2/probe0]
  connect_bd_net -net temperature_vld_1 [get_bd_pins temperature_vld] [get_bd_pins decision_ip_0/temperature_vld] [get_bd_pins ila_2/probe2]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR2_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR2_0 ]
  set eth_mdio_mdc [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 eth_mdio_mdc ]
  set eth_rmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rmii_rtl:1.0 eth_rmii ]
  set ja [ create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 ja ]
  set jb [ create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 jb ]
  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]

  # Create ports
  set ACL_CSN [ create_bd_port -dir O ACL_CSN ]
  set ACL_MISO [ create_bd_port -dir I ACL_MISO ]
  set ACL_MOSI [ create_bd_port -dir O ACL_MOSI ]
  set ACL_SCLK [ create_bd_port -dir O ACL_SCLK ]
  set VGA_B [ create_bd_port -dir O -from 3 -to 0 VGA_B ]
  set VGA_G [ create_bd_port -dir O -from 3 -to 0 VGA_G ]
  set VGA_HS [ create_bd_port -dir O VGA_HS ]
  set VGA_R [ create_bd_port -dir O -from 3 -to 0 VGA_R ]
  set VGA_VS [ create_bd_port -dir O VGA_VS ]
  set eth_ref_clk [ create_bd_port -dir O -type clk eth_ref_clk ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   CONFIG.PHASE {0.000} \
 ] $sys_clock
  set temp_clk [ create_bd_port -dir O -type clk temp_clk ]
  set temp_reset [ create_bd_port -dir O -from 0 -to 0 -type rst temp_reset ]
  set temperature [ create_bd_port -dir I -from 12 -to 0 temperature ]
  set temperature_vld [ create_bd_port -dir I temperature_vld ]

  # Create instance: ADXL362Ctrl_0, and set properties
  set block_name ADXL362Ctrl
  set block_cell_name ADXL362Ctrl_0
  if { [catch {set ADXL362Ctrl_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ADXL362Ctrl_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.SCLK_FREQUENCY_HZ {100000} \
   CONFIG.SYSCLK_FREQUENCY_HZ {100000000} \
 ] $ADXL362Ctrl_0

  # Create instance: MyDecisionMakingBlock
  create_hier_cell_MyDecisionMakingBlock [current_bd_instance .] MyDecisionMakingBlock

  # Create instance: axi_ethernetlite_0, and set properties
  set axi_ethernetlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernetlite:3.0 axi_ethernetlite_0 ]
  set_property -dict [ list \
   CONFIG.MDIO_BOARD_INTERFACE {eth_mdio_mdc} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_ethernetlite_0

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {3} \
 ] $axi_smc

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]

  # Create instance: axi_timer_1, and set properties
  set axi_timer_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_1 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKOUT2_JITTER {114.829} \
   CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {151.636} \
   CONFIG.CLKOUT3_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_JITTER {175.402} \
   CONFIG.CLKOUT4_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {25.000} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {20} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {40} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {4} \
   CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_1

  # Create instance: ila_1, and set properties
  set ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_1 ]
  set_property -dict [ list \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {5} \
   CONFIG.C_PROBE0_WIDTH {12} \
   CONFIG.C_PROBE1_WIDTH {12} \
   CONFIG.C_PROBE2_WIDTH {12} \
   CONFIG.C_PROBE3_WIDTH {12} \
 ] $ila_1

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:10.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_CACHE_BYTE_SIZE {16384} \
   CONFIG.C_DCACHE_BYTE_SIZE {16384} \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
   CONFIG.C_USE_DCACHE {1} \
   CONFIG.C_USE_ICACHE {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_intc, and set properties
  set microblaze_0_axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 microblaze_0_axi_intc ]
  set_property -dict [ list \
   CONFIG.C_HAS_FAST {1} \
 ] $microblaze_0_axi_intc

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {8} \
   CONFIG.NUM_SI {2} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: microblaze_0_xlconcat, and set properties
  set microblaze_0_xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 microblaze_0_xlconcat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $microblaze_0_xlconcat

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.1 mig_7series_0 ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $mig_7series_0

  # Create instance: mii_to_rmii_0, and set properties
  set mii_to_rmii_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mii_to_rmii:2.0 mii_to_rmii_0 ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.RMII_BOARD_INTERFACE {eth_rmii} \
 ] $mii_to_rmii_0

  # Create instance: myALS
  create_hier_cell_myALS [current_bd_instance .] myALS

  # Create instance: myRange
  create_hier_cell_myRange [current_bd_instance .] myRange

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_100M ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $rst_clk_wiz_1_100M

  # Create instance: rst_mig_7series_0_81M, and set properties
  set rst_mig_7series_0_81M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_81M ]

  # Create instance: vga_top_wrapper_0, and set properties
  set vga_top_wrapper_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:vga_top_wrapper:1.0 vga_top_wrapper_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ethernetlite_0_MDIO [get_bd_intf_ports eth_mdio_mdc] [get_bd_intf_pins axi_ethernetlite_0/MDIO]
  connect_bd_intf_net -intf_net axi_ethernetlite_0_MII [get_bd_intf_pins axi_ethernetlite_0/MII] [get_bd_intf_pins mii_to_rmii_0/MII]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DC [get_bd_intf_pins axi_smc/S00_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DC]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_IC [get_bd_intf_pins axi_smc/S01_AXI] [get_bd_intf_pins microblaze_0/M_AXI_IC]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins axi_ethernetlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins MyDecisionMakingBlock/S00_AXI1] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins axi_timer_1/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins MyDecisionMakingBlock/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins microblaze_0_axi_intc/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins microblaze_0/INTERRUPT] [get_bd_intf_pins microblaze_0_axi_intc/interrupt]
  connect_bd_intf_net -intf_net mig_7series_0_DDR2 [get_bd_intf_ports DDR2_0] [get_bd_intf_pins mig_7series_0/DDR2]
  connect_bd_intf_net -intf_net mii_to_rmii_0_RMII_PHY_M [get_bd_intf_ports eth_rmii] [get_bd_intf_pins mii_to_rmii_0/RMII_PHY_M]
  connect_bd_intf_net -intf_net myALS_ja [get_bd_intf_ports ja] [get_bd_intf_pins myALS/ja]
  connect_bd_intf_net -intf_net myRange_jb [get_bd_intf_ports jb] [get_bd_intf_pins myRange/jb]

  # Create port connections
  connect_bd_net -net ADXL362Ctrl_0_ACCEL_TMP [get_bd_pins ADXL362Ctrl_0/ACCEL_TMP] [get_bd_pins ila_1/probe3]
  connect_bd_net -net ADXL362Ctrl_0_ACCEL_X [get_bd_pins ADXL362Ctrl_0/ACCEL_X] [get_bd_pins MyDecisionMakingBlock/acc_x] [get_bd_pins ila_1/probe0]
  connect_bd_net -net ADXL362Ctrl_0_ACCEL_Y [get_bd_pins ADXL362Ctrl_0/ACCEL_Y] [get_bd_pins MyDecisionMakingBlock/acc_y] [get_bd_pins ila_1/probe1]
  connect_bd_net -net ADXL362Ctrl_0_ACCEL_Z [get_bd_pins ADXL362Ctrl_0/ACCEL_Z] [get_bd_pins MyDecisionMakingBlock/acc_z] [get_bd_pins ila_1/probe2]
  connect_bd_net -net ADXL362Ctrl_0_Data_Ready [get_bd_pins ADXL362Ctrl_0/Data_Ready] [get_bd_pins MyDecisionMakingBlock/acc_vld] [get_bd_pins ila_1/probe4]
  connect_bd_net -net ADXL362Ctrl_0_MOSI [get_bd_ports ACL_MOSI] [get_bd_pins ADXL362Ctrl_0/MOSI]
  connect_bd_net -net ADXL362Ctrl_0_SCLK [get_bd_ports ACL_SCLK] [get_bd_pins ADXL362Ctrl_0/SCLK]
  connect_bd_net -net ADXL362Ctrl_0_SS [get_bd_ports ACL_CSN] [get_bd_pins ADXL362Ctrl_0/SS]
  connect_bd_net -net MISO_0_1 [get_bd_ports ACL_MISO] [get_bd_pins ADXL362Ctrl_0/MISO]
  connect_bd_net -net MyDecisionMakingBlock_o_climate_control [get_bd_pins MyDecisionMakingBlock/o_climate_control] [get_bd_pins vga_top_wrapper_0/i_climate_control]
  connect_bd_net -net MyDecisionMakingBlock_o_climate_control_temperature [get_bd_pins MyDecisionMakingBlock/o_climate_control_temperature] [get_bd_pins vga_top_wrapper_0/i_climate_control_temperature]
  connect_bd_net -net MyDecisionMakingBlock_o_distance_sensor_val [get_bd_pins MyDecisionMakingBlock/o_distance_sensor_val] [get_bd_pins vga_top_wrapper_0/i_distance_sensor_val]
  connect_bd_net -net MyDecisionMakingBlock_o_enable_light [get_bd_pins MyDecisionMakingBlock/o_enable_light] [get_bd_pins vga_top_wrapper_0/i_enable_light]
  connect_bd_net -net MyDecisionMakingBlock_o_light_sensor_val [get_bd_pins MyDecisionMakingBlock/o_light_sensor_val] [get_bd_pins vga_top_wrapper_0/i_light_sensor_val]
  connect_bd_net -net MyDecisionMakingBlock_o_open_door [get_bd_pins MyDecisionMakingBlock/o_open_door] [get_bd_pins vga_top_wrapper_0/i_open_door]
  connect_bd_net -net MyDecisionMakingBlock_o_temperature_val [get_bd_pins MyDecisionMakingBlock/o_temperature_val] [get_bd_pins vga_top_wrapper_0/i_temperature_sensor_val]
  connect_bd_net -net MyDecisionMakingBlock_o_weather_val [get_bd_pins MyDecisionMakingBlock/o_weather_val] [get_bd_pins vga_top_wrapper_0/i_weather_val]
  connect_bd_net -net MyDecisionMakingBlock_weather_temperature [get_bd_pins MyDecisionMakingBlock/weather_temperature] [get_bd_pins vga_top_wrapper_0/i_weather_temperature]
  connect_bd_net -net axi_ethernetlite_0_ip2intc_irpt [get_bd_pins axi_ethernetlite_0/ip2intc_irpt] [get_bd_pins microblaze_0_xlconcat/In1]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
  connect_bd_net -net axi_timer_1_interrupt [get_bd_pins axi_timer_1/interrupt] [get_bd_pins microblaze_0_xlconcat/In2]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_pins clk_wiz_1/clk_out2] [get_bd_pins mig_7series_0/sys_clk_i]
  connect_bd_net -net clk_wiz_1_clk_out3 [get_bd_ports eth_ref_clk] [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins mii_to_rmii_0/ref_clk] [get_bd_pins myALS/ext_spi_clk]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
  connect_bd_net -net light_sensor_rd_vld_1 [get_bd_pins MyDecisionMakingBlock/light_sensor_rd_vld] [get_bd_pins myALS/pmod_data_ready_out]
  connect_bd_net -net mals_axi_init_axi_txn_1 [get_bd_pins MyDecisionMakingBlock/light_sensor_rd_en_out] [get_bd_pins myALS/mals_axi_init_axi_txn]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_ports temp_clk] [get_bd_pins ADXL362Ctrl_0/SYSCLK] [get_bd_pins MyDecisionMakingBlock/s00_axi_aclk] [get_bd_pins axi_ethernetlite_0/s_axi_aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins axi_timer_1/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins ila_1/clk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_intc/processor_clk] [get_bd_pins microblaze_0_axi_intc/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_axi_periph/S01_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins myALS/s00_axi_aclk] [get_bd_pins myRange/aclk_0] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net microblaze_0_intr [get_bd_pins microblaze_0_axi_intc/intr] [get_bd_pins microblaze_0_xlconcat/dout]
  connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins mig_7series_0/mmcm_locked] [get_bd_pins rst_mig_7series_0_81M/dcm_locked]
  connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins axi_smc/aclk1] [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins rst_mig_7series_0_81M/slowest_sync_clk]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins mig_7series_0/ui_clk_sync_rst] [get_bd_pins rst_mig_7series_0_81M/ext_reset_in]
  connect_bd_net -net myALS_result_0_test [get_bd_pins MyDecisionMakingBlock/light_sensor_rd_data_1] [get_bd_pins myALS/result_0_test]
  connect_bd_net -net myALS_result_2_test [get_bd_pins MyDecisionMakingBlock/light_sensor_rd_data_0] [get_bd_pins myALS/result_2_test]
  connect_bd_net -net range_status_1 [get_bd_pins MyDecisionMakingBlock/range_status] [get_bd_pins myRange/range_status_0]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins clk_wiz_1/resetn] [get_bd_pins mig_7series_0/sys_rst] [get_bd_pins mii_to_rmii_0/rst_n] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in] [get_bd_pins vga_top_wrapper_0/CPU_RESETN]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins myALS/ARESETN] [get_bd_pins myRange/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins microblaze_0_axi_intc/processor_rst] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins MyDecisionMakingBlock/s00_axi_aresetn] [get_bd_pins axi_ethernetlite_0/s_axi_aresetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins axi_timer_1/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_intc/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins microblaze_0_axi_periph/S01_ARESETN] [get_bd_pins myALS/s00_axi_aresetn] [get_bd_pins myRange/aresetn_0] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_reset [get_bd_ports temp_reset] [get_bd_pins ADXL362Ctrl_0/RESET] [get_bd_pins rst_clk_wiz_1_100M/peripheral_reset]
  connect_bd_net -net rst_mig_7series_0_81M_peripheral_aresetn [get_bd_pins axi_smc/aresetn] [get_bd_pins mig_7series_0/aresetn] [get_bd_pins rst_mig_7series_0_81M/peripheral_aresetn]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_1/clk_in1] [get_bd_pins vga_top_wrapper_0/CLK100MHZ]
  connect_bd_net -net temperature_0_1 [get_bd_ports temperature] [get_bd_pins MyDecisionMakingBlock/temperature]
  connect_bd_net -net temperature_vld_0_1 [get_bd_ports temperature_vld] [get_bd_pins MyDecisionMakingBlock/temperature_vld]
  connect_bd_net -net vga_top_wrapper_0_VGA_B [get_bd_ports VGA_B] [get_bd_pins vga_top_wrapper_0/VGA_B]
  connect_bd_net -net vga_top_wrapper_0_VGA_G [get_bd_ports VGA_G] [get_bd_pins vga_top_wrapper_0/VGA_G]
  connect_bd_net -net vga_top_wrapper_0_VGA_HS [get_bd_ports VGA_HS] [get_bd_pins vga_top_wrapper_0/VGA_HS]
  connect_bd_net -net vga_top_wrapper_0_VGA_R [get_bd_ports VGA_R] [get_bd_pins vga_top_wrapper_0/VGA_R]
  connect_bd_net -net vga_top_wrapper_0_VGA_VS [get_bd_ports VGA_VS] [get_bd_pins vga_top_wrapper_0/VGA_VS]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x40E00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernetlite_0/S_AXI/Reg] SEG_axi_ethernetlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_1/S_AXI/Reg] SEG_axi_timer_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00008000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00008000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_axi_intc/S_AXI/Reg] SEG_microblaze_0_axi_intc_Reg
  create_bd_addr_seg -range 0x08000000 -offset 0x80000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x08000000 -offset 0x80000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs MyDecisionMakingBlock/mydecisionslave_0/S00_AXI/S00_AXI_reg] SEG_mydecisionslave_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs MyDecisionMakingBlock/mydecisionslave_2_0/S00_AXI/S00_AXI_reg] SEG_mydecisionslave_2_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00010000 [get_bd_addr_spaces myALS/myALSMaster_0/MALS_AXI] [get_bd_addr_segs myALS/PmodALS_0/AXI_LITE_SPI/Reg0] SEG_PmodALS_0_Reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x44A00000 [get_bd_addr_spaces myRange/driver_ip_0/M_AXI_0] [get_bd_addr_segs myRange/PmodMAXSONAR_0/AXI_LITE_GPIO/Reg0] SEG_PmodMAXSONAR_0_Reg0


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


