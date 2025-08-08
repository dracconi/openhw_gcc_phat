#set top_dir "/home/mjk/repos/AMD_Open_HW"
set top_dir [file dirname [file normalize [info script]]]

proc make_package { name } {
    upvar top_dir top
    open_component "$name"
    csynth_design
    cosim_design
    export_design -format ip_catalog -output "$top/ip_lib/$name.xci"
    close_component
}
    
