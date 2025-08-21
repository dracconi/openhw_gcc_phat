module uart_axis
#(
  parameter DIVIDER_WIDTH = 7,
  parameter DIVIDER = 100, // 1Mbaud @ 100MHz clock
  parameter DATA_WIDTH = 8,
  parameter BIT_CTR_WIDTH = 4
)
(
  input [DATA_WIDTH-1:0]      s_data_tdata,
  input                       s_data_tvalid,
  output reg                  s_data_tready,
  output reg [DATA_WIDTH-1:0] m_data_tdata,
  output reg                  m_data_tvalid,
  input                       m_data_tready,
  input                       rx,
  output reg                  tx,
  input                       aclk,
  input                       arstn
);
   // RX
   
   reg [BIT_CTR_WIDTH-1:0] current_rx_bit;
   reg [DIVIDER_WIDTH-1:0] counter_rx;
   reg [DATA_WIDTH-1:0]    current_rx;
   reg [1:0]               state_rx;

   always @(posedge aclk) begin
      if (!arstn) begin
         m_data_tdata <= {DATA_WIDTH{1'b0}};
         m_data_tvalid <= 1'b0;
         counter_rx <= {DATA_WIDTH{1'b0}};
         current_rx_bit <= {BIT_CTR_WIDTH{1'b0}};
         state_rx <= 2'b00;
      end else begin
         if (state_rx == 2'b00) begin
           if (rx == 1'b0)
             state_rx <= 2'b01;
         end else begin
            if (state_rx == 2'b10 && counter_rx > DIVIDER / 3 && counter_rx < DIVIDER * 2 / 3)
              current_rx[current_rx_bit] <= rx;                               
            if (counter_rx < DIVIDER - 1) begin
              counter_rx <= counter_rx + 1;
            end else begin
               counter_rx <= {DIVIDER_WIDTH{1'b0}}; 
               case (state_rx)
                 2'b01 : {state_rx} <= {2'b10};
                 2'b10 : begin
                    if (current_rx_bit == DATA_WIDTH - 1)
                      {state_rx, current_rx_bit} <= {2'b11, {BIT_CTR_WIDTH{1'b0}}};
                    else
                      {current_rx_bit} <= {current_rx_bit + 1};
                 end
                 2'b11 : {state_rx, m_data_tdata, m_data_tvalid} <= {2'b00, current_rx, 1'b1};
               endcase // case (state_rx)
            end
         end
         if (state_rx != 2'b11 && m_data_tvalid && m_data_tready) begin
            m_data_tvalid <= 1'b0;
         end
      end
   end


   // TX

   reg [DIVIDER_WIDTH-1:0] counter_tx;
   reg [DATA_WIDTH-1:0]    current_tx;
   reg [BIT_CTR_WIDTH-1:0]   current_tx_bit;
   reg [1:0]               state_tx;

   always @(posedge aclk) begin
      if (!arstn) begin
         counter_tx <= {DIVIDER_WIDTH{1'b0}};
         current_tx_bit <= {BIT_CTR_WIDTH{1'b0}};
         state_tx <= 2'b00;
         tx <= 1'b1;
         s_data_tready <= 1'b0;
      end else begin      
         if (state_tx == 2'b00)
           s_data_tready <= 1'b1;
         
         if (s_data_tready && s_data_tvalid) begin
            state_tx <= 2'b01;
            current_tx_bit <= {BIT_CTR_WIDTH{1'b0}};
            current_tx_bit[0] <= 1'b1;
            counter_tx <= {DIVIDER_WIDTH{1'b0}};
            s_data_tready <= 1'b0;
            current_tx <= s_data_tdata;
            tx <= 1'b0; // START cond
         end
         
         if (state_tx != 2'b00) begin
            if (counter_tx < DIVIDER - 1)
              counter_tx <= counter_tx + 1;
            else begin
               counter_tx <= {DIVIDER_WIDTH{1'b0}};
               case (state_tx)
                 2'b01 : {state_tx, tx} <= {2'b10, current_tx[0]};
                 2'b10 :
                   if (current_tx_bit == DATA_WIDTH)
                     {state_tx, tx} <= {2'b11, 1'b1}; // STOP
                   else
                     {current_tx_bit, tx} <= {current_tx_bit + 1, current_tx[current_tx_bit]};
                 default : {state_tx} <= {2'b00};
               endcase // case (state_tx)
            end
         end // if (state_tx != 2'b00)
      end
   end
  
endmodule // uart_axis

   
