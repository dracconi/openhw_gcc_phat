# AMD_Open_HW

Please see `doc/details.org` for details on the implementation and how to run the cores etc.

## How to run the demo

Instead of full synth+impl, you can just download the bitstream from the Releases section.
    
1. Clone the repo.   
2. Add a symlink `$repo/xilinx` that points to your Xilinx installation directory. It should contain `2025.1` folder etc.
3. If you do not have the IP core downloaded in the `ip_libs` directory, then go to `hls_gcc` and run `package.sh` script. This should result in `ip_libs/gcc_phat.xci.zip` file. Unzip this file to a directory `ip_libs/gcc_phat.xci`. Note that this is in the repo, so you should have those files already. If you do, then skip this step. Instead of synthesizing, the IP core is also available in Releases on Github.
4. Go to `top` and run `./run.sh`. This will open Vivado in Tcl mode. If you are on Windows, then just source `init.tcl` in Vivado.
5. You can open gui with `start_gui` tcl command. Vivado will _probably crash_ here. Just re-run `run.sh` or open the generated `top/prj.xpr` in Vivado. You are good to go.
6. Generate the OOC Block design `demo.bd` and normally synthesize the design, then implement, then generate the bitstream etc.
7. Program the FPGA.
8. Go to `py/`. You need `numpy` and `pyserial` packages.
9. Assert and deassert reset (on Urbana connected to SW0). Deasserted reset is when the switch is near the LED.
10. `python connect.py` for the demo.