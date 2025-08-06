##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2025.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ips.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project top prj -part xc7s50csga324-1
  set_property target_language Verilog [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:xfft:9.1 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP xfft_forward
##################################################################

set xfft_forward [create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name xfft_forward]

# User Parameters
set_property -dict [list \
  CONFIG.channels {4} \
  CONFIG.data_format {fixed_point} \
  CONFIG.implementation_options {automatically_select} \
  CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
  CONFIG.output_ordering {bit_reversed_order} \
  CONFIG.rounding_modes {convergent_rounding} \
  CONFIG.scaling_options {block_floating_point} \
  CONFIG.super_sample_rates {1} \
  CONFIG.target_clock_frequency {100} \
  CONFIG.target_data_throughput {1} \
  CONFIG.transform_length {16384} \
  CONFIG.xk_index {false} \
] [get_ips xfft_forward]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $xfft_forward

##################################################################

##################################################################
# CREATE IP xfft_reverse
##################################################################

set xfft_reverse [create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name xfft_reverse]

# User Parameters
set_property -dict [list \
  CONFIG.aresetn {false} \
  CONFIG.channels {3} \
  CONFIG.data_format {fixed_point} \
  CONFIG.implementation_options {automatically_select} \
  CONFIG.input_width {16} \
  CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
  CONFIG.phase_factor_width {16} \
  CONFIG.rounding_modes {convergent_rounding} \
  CONFIG.scaling_options {block_floating_point} \
  CONFIG.super_sample_rates {1} \
  CONFIG.target_clock_frequency {100} \
  CONFIG.target_data_throughput {1} \
  CONFIG.transform_length {16384} \
] [get_ips xfft_reverse]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $xfft_reverse

##################################################################

