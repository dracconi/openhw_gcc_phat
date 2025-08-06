create_project -force top prj -part xc7s50csga324-1
add_files -fileset sim_1 sim
add_files -fileset constrs_1 constr
add_files src
import_ip ips/xfft_forward/xfft_forward.xci ips/xfft_reverse/xfft_reverse.xci
