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

    read_bd bd/demo/demo.bd
    read_bd bd/test_uart/test_uart.bd

    make_wrapper -top -import [get_files bd/demo/demo.bd]
    make_wrapper -top -import [get_files bd/test_uart/test_uart.bd]

    set_property top demo_wrapper [current_fileset]
}
