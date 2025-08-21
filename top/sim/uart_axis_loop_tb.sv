`timescale 1ns/100ps

parameter DATA_WIDTH = 8;

module uart_axis_loop_tb
  ();
   reg [DATA_WIDTH-1:0]      s_data_tdata;
   reg                       s_data_tvalid;
   wire                      s_data_tready;
   wire [DATA_WIDTH-1:0]     m_data_tdata;
   wire                      m_data_tvalid;
   reg                       m_data_tready;
   wire                      tx;
   reg                       aclk;
   reg                       arstn;
   

   uart_axis dut(s_data_tdata,
                 s_data_tvalid,
                 s_data_tready,
                 m_data_tdata,
                 m_data_tvalid,
                 m_data_tready,
                 tx,
                 tx,
                 aclk,
                 arstn);

   initial begin
      s_data_tdata <= 8'h11;
      s_data_tvalid <= 1'b1;
      m_data_tready <= 1'b1;
      
      arstn <= 1'b0;
      aclk <= 1'b0;
      #50 arstn <= 1'b1;
   end

   always
     #5 aclk = ~aclk;

   always @(negedge s_data_tready)
     s_data_tdata <= s_data_tdata + 1;

endmodule // uart_axis_tb
