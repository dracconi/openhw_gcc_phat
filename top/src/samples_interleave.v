module samples_interleave
#(
    parameter CHANNEL_WIDTH = 16,
    parameter COMPLEX_WIDTH = CHANNEL_WIDTH * 2,
    parameter CHANNELS = 8,
    parameter INPUT_WIDTH = CHANNEL_WIDTH * CHANNELS,
    parameter OUTPUT_WIDTH = COMPLEX_WIDTH * CHANNELS
)
(
    input [INPUT_WIDTH-1:0] s_axis_simple_tdata,
    input s_axis_simple_tvalid,
    output s_axis_simple_tready,
    
    output [OUTPUT_WIDTH-1:0] m_axis_complex_tdata,
    output m_axis_complex_tvalid,
    input m_axis_complex_tready
);


endmodule; // samples_interleave
