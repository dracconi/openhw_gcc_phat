`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 02:30:23 AM
// Design Name: 
// Module Name: status_sink
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


module status_sink
#(
    parameter WIDTH = 24
)
(
    input [WIDTH-1:0] s_axis_status_tdata,
    input s_axis_status_tvalid,
    output s_axis_status_tready,
    input aclk
    );
    
    assign s_axis_status_tready = 1'b1;
endmodule
