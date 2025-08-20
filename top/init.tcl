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
    add_files -fileset constrs_1 constr
    add_files src
    
    #source recreate.tcl
}
