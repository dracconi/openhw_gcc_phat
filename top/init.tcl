#create_project -force top prj -part xc7s50csga324-1
#add_files -fileset sim_1 sim
#add_files -fileset constrs_1 constr
#add_files src
#source bd.tcl
if {[file exist "prj"]} {
    open_project -part xc7s50csga324-1 "prj/top.xpr"
} else {
    create_project -force top prj -part xc7s50csga324-1
    add_files -fileset sim_1 sim
    add_files -fileset sim_1 sim/golden_fp.pcm
    add_files -fileset constrs_1 constr
    add_files src

    set repo "../ip_lib"

    set_property ip_repo_paths $repo [current_fileset]
    update_ip_catalog -rebuild

    create_ip -vlnv polsl:gcc_internal:gcc_phat:1.0 -module_name gcc_phat_0
    
    #source recreate.tcl
}
