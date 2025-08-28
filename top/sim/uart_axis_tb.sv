`timescale 1ns/100ps

parameter DATA_WIDTH = 8;

module uart_axis_tb
  ();
   reg [DATA_WIDTH-1:0]      s_data_tdata;
   reg                       s_data_tvalid;
   wire                      s_data_tready;
   wire [DATA_WIDTH-1:0]     m_data_tdata;
   wire                      m_data_tvalid;
   reg                       m_data_tready;
   reg                       rx;
   wire                      tx;
   reg                       aclk;
   reg                       arstn;
   

   uart_axis dut(s_data_tdata,
                 s_data_tvalid,
                 s_data_tready,
                 m_data_tdata,
                 m_data_tvalid,
                 m_data_tready,
                 rx,
                 tx,
                 aclk,
                 arstn);

   initial begin
      m_data_tready <= 1'b1;
      rx <= 1'b1;
      aclk <= 1'b0;
      arstn <= 1'b0;
      #50 arstn <= 1'b1;
   end

   always begin
      #5 aclk <= ~aclk;
   end

   initial begin
      #500 rx = 1'b0; // START
      #1000 rx = 1'b1; // 0
      #1000 rx = 1'b0; // 1
      #1000 rx = 1'b1; // 2
      #1000 rx = 1'b0; // 3
      #1000 rx = 1'b0; // 4
      #1000 rx = 1'b1; // 5
      #1000 rx = 1'b0; // 6
      #1000 rx = 1'b0; // 7
      #1000 rx = 1'b1; // STOP
      
      #1000 rx = 1'b0; // START
      #1000 rx = 1'b0; // 0
      #1000 rx = 1'b0; // 1
      #1000 rx = 1'b1; // 2
      #1000 rx = 1'b0; // 3
      #1000 rx = 1'b1; // 4
      #1000 rx = 1'b1; // 5
      #1000 rx = 1'b0; // 6
      #1000 rx = 1'b1; // 7
      #1000 rx = 1'b1; // STOP
   end // initial begin

   initial begin
      s_data_tvalid <= 1'b1;
      s_data_tdata <= 8'b1010110;
      #200 s_data_tvalid <= 1'b0;
   end
   

endmodule // uart_axis_tb
