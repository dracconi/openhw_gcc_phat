
################################################################
# This is a generated script based on design: gcc
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
set scripts_vivado_version 2025.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source gcc_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# samples_interleave, fft_config, fft_config, status_sink, status_sink

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7s50csga324-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name gcc

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
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xfft:9.1\
polsl:gcc_internal:crosscorr:1.0\
polsl:gcc_internal:findmax:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
samples_interleave\
fft_config\
fft_config\
status_sink\
status_sink\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



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
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set S_AXIS_DATA [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS_DATA

  set M_AXIS_DELAYS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DELAYS ]


  # Create ports
  set clk [ create_bd_port -dir I -type clk -freq_hz 100000000 clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS_DATA:M_AXIS_DELAYS} \
 ] $clk
  set rst_n [ create_bd_port -dir I -type rst rst_n ]

  # Create instance: xfft_forward, and set properties
  set xfft_forward [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 xfft_forward ]
  set_property -dict [list \
    CONFIG.channels {4} \
    CONFIG.data_format {fixed_point} \
    CONFIG.implementation_options {automatically_select} \
    CONFIG.input_width {16} \
    CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
    CONFIG.rounding_modes {convergent_rounding} \
    CONFIG.scaling_options {block_floating_point} \
    CONFIG.super_sample_rates {1} \
    CONFIG.target_clock_frequency {100} \
    CONFIG.target_data_throughput {1} \
    CONFIG.transform_length {16384} \
  ] $xfft_forward


  # Create instance: samples_interleave_0, and set properties
  set block_name samples_interleave
  set block_cell_name samples_interleave_0
  if { [catch {set samples_interleave_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $samples_interleave_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.CHANNELS {4} \
    CONFIG.INPUT_WIDTH {64} \
    CONFIG.OUTPUT_WIDTH {128} \
  ] $samples_interleave_0


  # Create instance: fft_config_forward, and set properties
  set block_name fft_config
  set block_cell_name fft_config_forward
  if { [catch {set fft_config_forward [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fft_config_forward eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.CHANNELS {16} $fft_config_forward


  # Create instance: cross_correlate, and set properties
  set cross_correlate [ create_bd_cell -type ip -vlnv polsl:gcc_internal:crosscorr:1.0 cross_correlate ]

  # Create instance: xfft_backward, and set properties
  set xfft_backward [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 xfft_backward ]
  set_property -dict [list \
    CONFIG.channels {3} \
    CONFIG.data_format {fixed_point} \
    CONFIG.implementation_options {automatically_select} \
    CONFIG.input_width {16} \
    CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
    CONFIG.rounding_modes {convergent_rounding} \
    CONFIG.scaling_options {block_floating_point} \
    CONFIG.super_sample_rates {1} \
    CONFIG.target_clock_frequency {100} \
    CONFIG.target_data_throughput {1} \
    CONFIG.transform_length {16384} \
  ] $xfft_backward


  # Create instance: fft_config_backward, and set properties
  set block_name fft_config
  set block_cell_name fft_config_backward
  if { [catch {set fft_config_backward [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fft_config_backward eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.CHANNELS {16} \
    CONFIG.FWDINV {"0"} \
  ] $fft_config_backward


  # Create instance: findmax_0, and set properties
  set findmax_0 [ create_bd_cell -type ip -vlnv polsl:gcc_internal:findmax:1.0 findmax_0 ]

  # Create instance: status_sink_0, and set properties
  set block_name status_sink
  set block_cell_name status_sink_0
  if { [catch {set status_sink_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $status_sink_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: status_sink_1, and set properties
  set block_name status_sink
  set block_cell_name status_sink_1
  if { [catch {set status_sink_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $status_sink_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.WIDTH {32} $status_sink_1


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_DATA_1 [get_bd_intf_ports S_AXIS_DATA] [get_bd_intf_pins samples_interleave_0/s_axis_simple]
  connect_bd_intf_net -intf_net crosscorr_0_stream_out [get_bd_intf_pins cross_correlate/stream_out] [get_bd_intf_pins xfft_backward/S_AXIS_DATA]
  connect_bd_intf_net -intf_net fft_config_0_m_axis_config [get_bd_intf_pins fft_config_forward/m_axis_config] [get_bd_intf_pins xfft_forward/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net fft_config_1_m_axis_config [get_bd_intf_pins fft_config_backward/m_axis_config] [get_bd_intf_pins xfft_backward/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net findmax_0_stream_out [get_bd_intf_ports M_AXIS_DELAYS] [get_bd_intf_pins findmax_0/stream_out]
  connect_bd_intf_net -intf_net samples_interleave_0_m_axis_complex [get_bd_intf_pins samples_interleave_0/m_axis_complex] [get_bd_intf_pins xfft_forward/S_AXIS_DATA]
  connect_bd_intf_net -intf_net xfft_backward_M_AXIS_DATA [get_bd_intf_pins xfft_backward/M_AXIS_DATA] [get_bd_intf_pins findmax_0/stream_in]
  connect_bd_intf_net -intf_net xfft_backward_M_AXIS_STATUS [get_bd_intf_pins xfft_backward/M_AXIS_STATUS] [get_bd_intf_pins status_sink_0/s_axis_status]
  connect_bd_intf_net -intf_net xfft_forward_M_AXIS_DATA [get_bd_intf_pins xfft_forward/M_AXIS_DATA] [get_bd_intf_pins cross_correlate/stream_in]
  connect_bd_intf_net -intf_net xfft_forward_M_AXIS_STATUS [get_bd_intf_pins status_sink_1/s_axis_status] [get_bd_intf_pins xfft_forward/M_AXIS_STATUS]

  # Create port connections
  connect_bd_net -net clk_0  [get_bd_ports clk] \
  [get_bd_pins xfft_forward/aclk] \
  [get_bd_pins cross_correlate/ap_clk] \
  [get_bd_pins xfft_backward/aclk] \
  [get_bd_pins findmax_0/ap_clk] \
  [get_bd_pins fft_config_backward/aclk] \
  [get_bd_pins fft_config_forward/aclk] \
  [get_bd_pins samples_interleave_0/aclk] \
  [get_bd_pins status_sink_0/aclk] \
  [get_bd_pins status_sink_1/aclk]
  connect_bd_net -net ilconstant_0_dout  [get_bd_ports rst_n] \
  [get_bd_pins cross_correlate/ap_rst_n] \
  [get_bd_pins findmax_0/ap_rst_n]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


