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
    parameter DATA_WIDTH = 128,
    parameter CLK_PERIOD = 10
)
(

    );
    
    reg clk;
    reg rst_n;
    
    reg S_AXIS_DELAYS_tready = 1'b1;
    
    reg M_AXIS_DATA_tvalid = 1'b1;
    reg [DATA_WIDTH-1:0] M_AXIS_DATA_tdata = {128{1'b1}};
    
    wire [47:0] S_AXIS_DELAYS_tdata;
    wire S_AXIS_DELAYS_tvalid;
    wire M_AXIS_DATA_tready;
    
    
    gcc dut(
        .M_AXIS_DELAYS_tdata(S_AXIS_DELAYS_tdata),
        .M_AXIS_DELAYS_tready(S_AXIS_DELAYS_tready),
        .M_AXIS_DELAYS_tvalid(S_AXIS_DELAYS_tvalid),
        .S_AXIS_DATA_tdata(M_AXIS_DATA_tdata),
        .S_AXIS_DATA_tready(M_AXIS_DATA_tready),
        .S_AXIS_DATA_tvalid(M_AXIS_DATA_tvalid),
        .clk(clk),
        .rst_n(rst_n)
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
endmodule
