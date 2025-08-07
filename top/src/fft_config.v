module fft_config
#(
  parameter FWDINV = 1'b1,
  parameter CHANNELS = 4
)
(
 output [CHANNELS-1:0] m_axis_config_tdata,
 output m_axis_config_tvalid,
 input m_axis_config_tready
);
   
   assign m_axis_config_tdata = {CHANNELS{FWDINV}};

endmodule; // fft_config


   
