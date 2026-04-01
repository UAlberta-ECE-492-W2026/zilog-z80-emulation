`timescale 1 ns / 1 ps
// This slave wrapper encompasses all generated connections by Vivado while encompassing the AXI lite
// logic required to run the keyboard_interface module.
// it enables reading and writing of the fifo within said module
// also enables the handshake between AXI and the keyboard interface

module axi_wrapper_slave_lite_v1_0_S00_AXI #
(
// Users to add parameters here

// User parameters ends
// Do not modify the parameters beyond this line

// Width of S_AXI data bus
parameter integer C_S_AXI_DATA_WIDTH = 32,
// Width of S_AXI address bus
parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
// Users to add ports here

// User ports ends
// Do not modify the ports beyond this line

// Global Clock Signal
input wire  S_AXI_ACLK,
// Global Reset Signal. This Signal is Active LOW
input wire  S_AXI_ARESETN,
// Write address (issued by master, acceped by Slave)
input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
// Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
input wire [2 : 0] S_AXI_AWPROT,
// Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
input wire  S_AXI_AWVALID,
// Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
output wire  S_AXI_AWREADY,
// Write data (issued by master, acceped by Slave)
input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
// Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
// Write valid. This signal indicates that valid write
    // data and strobes are available.
input wire  S_AXI_WVALID,
// Write ready. This signal indicates that the slave
    // can accept the write data.
output wire  S_AXI_WREADY,
// Write response. This signal indicates the status
    // of the write transaction.
output wire [1 : 0] S_AXI_BRESP,
// Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
output wire  S_AXI_BVALID,
// Response ready. This signal indicates that the master
    // can accept a write response.
input wire  S_AXI_BREADY,
// Read address (issued by master, acceped by Slave)
input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
input wire [2 : 0] S_AXI_ARPROT,
// Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
input wire  S_AXI_ARVALID,
// Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
output wire  S_AXI_ARREADY,
// Read data (issued by slave)
output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
// Read response. This signal indicates the status of the
    // read transfer.
output wire [1 : 0] S_AXI_RRESP,
// Read valid. This signal indicates that the channel is
    // signaling the required read data.
output wire  S_AXI_RVALID,
// Read ready. This signal indicates that the master can
    // accept the read data and response information.
input wire  S_AXI_RREADY

);

// FIFO signals
logic [7:0] fifo_data_out;
logic fifo_empty;
logic fifo_full;
logic fifo_r_en;
logic fifo_w_en;
logic [7:0] fifo_data_in;

// AXI4LITE signals
reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
reg   axi_awready;
reg   axi_wready;
reg [1 : 0] axi_bresp;
reg   axi_bvalid;
reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
reg   axi_arready;
reg [1 : 0] axi_rresp;
reg   axi_rvalid;

// Example-specific design signals
// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)
localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
localparam integer OPT_MEM_ADDR_BITS = 1;
//----------------------------------------------
//-- Signals for user logic register space example
//------------------------------------------------
//-- Number of Slave Registers 4
reg [C_S_AXI_DATA_WIDTH-1:0] fifo_data_reg;
reg [C_S_AXI_DATA_WIDTH-1:0] fifo_status_reg;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2; // Not used
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg3; // Not used
integer byte_index;

// I/O Connections assignments
assign S_AXI_AWREADY = axi_awready;
assign S_AXI_WREADY = axi_wready;
assign S_AXI_BRESP = axi_bresp;
assign S_AXI_BVALID = axi_bvalid;
assign S_AXI_ARREADY = axi_arready;
assign S_AXI_RRESP = axi_rresp;
assign S_AXI_RVALID = axi_rvalid;
// state machine varibles
reg [2:0] state_write;
reg [2:0] state_read;
// State machine local parameters
localparam Idle  = 3'b000,
           Waddr = 3'b001,
           Wdata = 3'b010,
           Raddr = 3'b011,
           Rdata = 3'b100;
// Implement Write state machine
// Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
always @(posedge S_AXI_ACLK)                                
 begin                                
    if (S_AXI_ARESETN == 1'b0)                                
      begin                                
        axi_awready <= 0;                                
        axi_wready <= 0;                                
        axi_bvalid <= 0;                                
        axi_bresp <= 0;                                
        axi_awaddr <= 0;                                
        state_write <= Idle;                                
      end                                
    else                                  
      begin                                
        case(state_write)                                
          Idle:                                      
            begin                                
              if(S_AXI_ARESETN == 1'b1)                                  
                begin                                
                  axi_awready <= 1'b1;                                
                  axi_wready <= 1'b1;                                
                  state_write <= Waddr;                                
                end                                
              else state_write <= state_write;                                
            end                                
          Waddr:        //At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state                                
            begin                                
              if (S_AXI_AWVALID && S_AXI_AWREADY)                                
                 begin                                
                   axi_awaddr <= S_AXI_AWADDR;                                
                   if(S_AXI_WVALID)                                  
                     begin                                  
                       axi_awready <= 1'b1;                                
                       state_write <= Waddr;                                
                       axi_bvalid <= 1'b1;                                
                     end                                
                   else                                  
                     begin                                
                       axi_awready <= 1'b0;                                
                       state_write <= Wdata;                                
                       if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;                                
                     end                                
                 end                                
              else                                  
                 begin                                
                   state_write <= state_write;                                
                   if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;                                
                  end                                
            end                                
         Wdata:        //At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                
            begin                                
              if (S_AXI_WVALID)                                
                begin                                
                  state_write <= Waddr;                                
                  axi_bvalid <= 1'b1;                                
                  axi_awready <= 1'b1;                                
                end                                
               else                                  
                begin                                
                  state_write <= state_write;                                
                  if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;                                
                end                                              
            end                                
         endcase                                
       end                                
     end                                

// Implement memory mapped register select and write logic generation
// The write data is accepted and written to memory mapped registers when
// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
// select byte enables of slave registers while writing.
// These registers are cleared when reset (active low) is applied.
// Slave register write enable is asserted when valid address and data are available
// and the slave is ready to accept the write address and write data.


always @( posedge S_AXI_ACLK )
begin
 if ( S_AXI_ARESETN == 1'b0 )
   begin
     fifo_data_reg <= 0;
     slv_reg2 <= 0;
     slv_reg3 <= 0;
   end
 else begin
   if (S_AXI_WVALID)
     begin
       case ( (S_AXI_AWVALID) ? S_AXI_AWADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] : axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
         2'h0:
           for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
             if ( S_AXI_WSTRB[byte_index] == 1 ) begin
               // Respective byte enables are asserted as per write strobes
               // Slave register 0
               fifo_data_reg[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
             end  
         2'h2:
           for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
             if ( S_AXI_WSTRB[byte_index] == 1 ) begin
               // Respective byte enables are asserted as per write strobes
               // Slave register 2
               slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
             end  
         2'h3:
           for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
             if ( S_AXI_WSTRB[byte_index] == 1 ) begin
               // Respective byte enables are asserted as per write strobes
               // Slave register 3
               slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
             end  
         default : begin
                     fifo_data_reg <= fifo_data_reg;
                     slv_reg2 <= slv_reg2;
                     slv_reg3 <= slv_reg3;
                   end
       endcase
     end
 end
end    

// Implement read state machine
 always @(posedge S_AXI_ACLK)                                      
   begin                                      
     if (S_AXI_ARESETN == 1'b0)                                      
       begin                                      
        //asserting initial values to all 0's during reset                                      
        axi_arready <= 1'b0;                                      
        axi_rvalid <= 1'b0;                                      
        axi_rresp <= 2'b0;                                      
        state_read <= Idle;                                      
       end                                      
     else                                      
       begin                                      
         case(state_read)                                      
           Idle:     //Initial state inidicating reset is done and ready to receive read/write transactions                                      
             begin                                                
               if (S_AXI_ARESETN == 1'b1)                                        
                 begin                                      
                   state_read <= Raddr;                                      
                   axi_arready <= 1'b1;                                      
                 end                                      
               else state_read <= state_read;                                      
             end                                      
           Raddr:        //At this state, slave is ready to receive address along with corresponding control signals                                      
             begin                                      
               if (S_AXI_ARVALID && S_AXI_ARREADY)                                      
                 begin                                      
                   state_read <= Rdata;                                      
                   axi_araddr <= S_AXI_ARADDR;                                      
                   axi_rvalid <= 1'b1;                                      
                   axi_arready <= 1'b0;                                      
                 end                                      
               else state_read <= state_read;                                      
             end                                      
           Rdata:        //At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                      
             begin                                          
               if (S_AXI_RVALID && S_AXI_RREADY)                                      
                 begin                                      
                   axi_rvalid <= 1'b0;                                      
                   axi_arready <= 1'b1;                                      
                   state_read <= Raddr;                                      
                 end                                      
               else state_read <= state_read;                                      
             end                                      
          endcase                                      
         end                                      
       end                                        
// Implement memory mapped register select and read logic generation

// Add user logic here

// reference for the AXI system
// "https://zipcpu.com/blog/2020/03/08/easyaxil.html"
// "https://zipcpu.com/blog/2019/01/12/demoaxilite.html"
// "https://zipcpu.com/formal/2018/12/28/axilite.html"
// by The ZipCPU by Gisselquist Technology

keyboard_interface #(
    .FIFO_DEPTH(16)
) kb_fifo (
    .clk(S_AXI_ACLK),
    .reset(~S_AXI_ARESETN),

    .r_en(fifo_r_en),
    .w_en(fifo_w_en),

    .data_in(fifo_data_in),
    .data_out(fifo_data_out),

    .empty(fifo_empty),
    .full(fifo_full)
);

// AXI hand shake for writing
logic write_ready;
// checking the write address channel is valid, checking the data write channel is valid
// checking the write address channel is ready, checking the data write channel is ready
assign write_ready = S_AXI_AWVALID && S_AXI_WVALID && axi_awready && axi_wready;

// Checking if the address of AXI is equal to the base address of the fifo_data_reg
// if so then we are doing a data write instead of a status reg write.
// if set to 2'h00 then we are comparing it to the fifo_status_reg
// memory mapped register select
logic write_data_reg_select;
assign write_data_reg_select = ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h00 );
// pushing to fifo
always @( posedge S_AXI_ACLK ) begin
  // Active low reset driven by AXI master
    if ( !S_AXI_ARESETN ) begin
        fifo_w_en <= 0;
        fifo_data_in <= 0;
        fifo_status_reg <= 0;
    end else begin
      fifo_w_en <= 0;
      fifo_status_reg[0] <= fifo_empty; // first bit of fifo status represents empty fifo
      fifo_status_reg[1] <= fifo_full;  // second bit of fifo status represents full fifo
      // if the hand shake(write_ready) is active while there is left over space in the fifo you may write
      // to the fifo granted that the address corresponds to the fifo_data_reg address of h00
        if ( write_ready && write_data_reg_select && !fifo_full ) begin
            fifo_w_en <= 1;
            // each data burst carries one ASCII character from the keyboard
            // through usb and AXI onto the Z80 Chip
            // each ASCII character is one byte
            fifo_data_in <= S_AXI_WDATA[7:0];
        end
    end
end

// "A read transaction request takes place when both S_AXI_ARVALID and S_AXI_ARREADY are true on the same clock."
// from reference "https://zipcpu.com/formal/2018/12/28/axilite.html" by The ZipCPU by Gisselquist Technology

// AXI hand shake for reading
logic read_ready;
assign read_ready = S_AXI_ARVALID && axi_arready;

// read select of reading addres (similar to write previously)
// memory mapped register select
logic read_data_reg_select;
assign read_data_reg_select = ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h00);

// popping off fifo
always @( posedge S_AXI_ACLK ) begin
    if ( !S_AXI_ARESETN ) begin
        fifo_r_en <= 0;
    end else begin
          fifo_r_en <= 0;
      if ( read_ready && read_data_reg_select && !fifo_empty ) begin
          fifo_r_en <= 1;
      end
    end
end

// read data for the ascii slave
// either will reead the data on fifo data out or the status reg
assign S_AXI_RDATA = ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h00 ) ? {24'b0, fifo_data_out} : ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h01 ) ? fifo_status_reg : 32'b0;

endmodule
