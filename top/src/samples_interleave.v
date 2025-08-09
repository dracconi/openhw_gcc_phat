module samples_interleave
#(
    parameter CHANNEL_WIDTH = 16,
    parameter COMPLEX_WIDTH = CHANNEL_WIDTH * 2,
    parameter CHANNELS = 4,
    parameter INPUT_WIDTH = CHANNEL_WIDTH * CHANNELS,
    parameter OUTPUT_WIDTH = COMPLEX_WIDTH * CHANNELS
)
(
    input [INPUT_WIDTH-1:0] s_axis_simple_tdata,
    input s_axis_simple_tvalid,
    output s_axis_simple_tready,
    
    output [OUTPUT_WIDTH-1:0] m_axis_complex_tdata,
    output m_axis_complex_tvalid,
    input m_axis_complex_tready,
    
    input aclk
);
    genvar i;

    assign m_axis_complex_tvalid = s_axis_simple_tvalid;
    assign s_axis_simple_tready = m_axis_complex_tready;
    
    for (i = 0; i < CHANNELS; i = i + 1)
    begin
        assign m_axis_complex_tdata[i*COMPLEX_WIDTH +: COMPLEX_WIDTH] = {{CHANNEL_WIDTH{1'b0}}, s_axis_simple_tdata[i*CHANNEL_WIDTH +: CHANNEL_WIDTH]}; 
    end


endmodule; // samples_interleave
