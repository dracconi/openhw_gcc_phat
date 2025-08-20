`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 02:42:16 AM
// Design Name: 
// Module Name: gcc_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gcc_tb
#(
    parameter DATA_WIDTH = 64,
    parameter CLK_PERIOD = 10
)
(

    );
    integer golden;
    
    initial begin
    golden = $fopen("golden_fp.pcm", "r");
    end 
    
    reg clk;
    reg rst_n;
    
    reg S_AXIS_DELAYS_tready = 1'b1;
    
    reg M_AXIS_DATA_tvalid = 1'b1;
    reg [DATA_WIDTH-1:0] M_AXIS_DATA_tdata;
    
    wire [47:0] S_AXIS_DELAYS_tdata;
    wire S_AXIS_DELAYS_tvalid;
    wire M_AXIS_DATA_tready;
    
    
    gcc_phat_0 dut(
        .stream_out_TDATA(S_AXIS_DELAYS_tdata),
        .stream_out_TREADY(S_AXIS_DELAYS_tready),
        .stream_out_TVALID(S_AXIS_DELAYS_tvalid),
        .stream_in_TDATA(M_AXIS_DATA_tdata),
        .stream_in_TREADY(M_AXIS_DATA_tready),
        .stream_in_TVALID(M_AXIS_DATA_tvalid),
        .ap_clk(clk),
        .ap_rst_n(rst_n)
    );
    
    initial
    begin
    rst_n = 1'b0;
    #20 rst_n = 1'b1;
    end
    
    always
    begin
     clk = 1'b1;
     #(CLK_PERIOD/2) clk = 1'b0;
     #(CLK_PERIOD/2);
    end
    
    always @(posedge clk)
    begin
    if (M_AXIS_DATA_tready)
        $fread(M_AXIS_DATA_tdata, golden);
    end
endmodule
